%%%%%%%%%%%% Codigo para la FEDNN%%%%%%%%%%%%%%%%%%
%NECESITA CORRER ANTES Iniciador de parametros
%NECESITA TENER DATOS MEDIDOS Y CARGARLOS
clc
clearvars -except Kbc ne
close all
global V1 W1 K1 K2 P V0 l Lambda A 

% -----------------------------------------------------
%% Datos de la simulación
% ----------------------------------------------------
%Cargo los datos acomodados de los experimentos
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat'); 
h  = 0.01;							    % sample time
N  = size(Data,2);						% number of iterations

% -------------------------------------------------------
%% Iniciador de parametros para la FEDNN
% ------------------------------------------------------


MesuredData=Data;
V1 = 2*rand(ne,ne)-1;			% Matriz de pesos
W1 = 2*rand(ne,ne)-1;			% Matriz de pesos
us = MesuredData(1:20,1);       %Primer estado del sistema real
u  = us;                        %Primer estado del sistema approx

load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/Lambda.mat'); %Aquí cargo solo lambda
Kmask 	= Kbc;
V1		= V1.*Kmask;
W1      = W1.*Kmask;
V0      = V1;
%
I       = eye(ne);
K1		= 1.5;
K2		= 1;
l 		= 1.1620;
P       = I;
% Lambda	= SPDmatrix(ne);
aa      = -25;%-51.1440;
A       = aa*eye(ne);
%
Q0  = I;%SPDmatrix(nnode);
Q   = Q0 +Lambda;
bW1 = W1*inv(Lambda)*W1';
R   = 2*bW1 +inv(Lambda);

a = [-P*A-A'*P-Q P; P inv(R)];
try chol(a);
    disp("All parameters P, A, Q and R satisfy the conditions ...")
catch ME
    disp('Matrix is not symmetric positive definite')
end

% ---------------------------------------------------------------
%% Algoritmo 1
% ---------------------------------------------------------------


for i = 1:N-1
	W1 = W1.*Kmask;
	V1 = V1.*Kmask;
    
    [k1u, k1W, k1V] = DNN(u,us,W1,V1,h);
    
    % Las mediciones son una a cada Ts, por lo que no puedo tomar a 0.5Ts,
    % como en el ejemplo, así que interpolo valores linealmente
    for row = 1:20
        interpolated_values(row) = interp1([i, i+1], [MesuredData(row, i), MesuredData(row, i+1)], i+0.5);
    end
    
    %uso los valores interpolados, considerandolos como
    %MesuredData(1:20,i+0.5)
    us = interpolated_values';

    [k2u, k2W, k2V] = DNN(u+.5*k1u,us,W1+.5*k1W,V1+.5*k1V,h);
	[k3u, k3W, k3V] = DNN(u+.5*k2u,us,W1+.5*k2W,V1+.5*k2V,h);

    us = MesuredData(1:20,i+1);
	%
	[k4u, k4W, k4V] = DNN(u+k3u,us,W1+k3W,V1+k3V,h);
	%
	u  =  u + 1/6*k1u + 1/3*k2u + 1/3*k3u + 1/6*k4u;
	V1 = V1 + 1/6*k1V + 1/3*k2V + 1/3*k3V + 1/6*k4V;
	W1 = W1 + 1/6*k1W + 1/3*k2W + 1/3*k3W + 1/6*k4W;

    error = u - MesuredData(1:20,i);
   
    errores(i) = mean(abs(error(:)));

    utotal(:,i) = u;
    
end


%% PLOTEOS

fila_a_comparar = 1; %Es muy dificil ver todo al mismo tiempo así que aquí 
                     %puedo decidir cual nodo se va a comparar


iteraciones = size(errores,2);
% Graficar errores en el primer cuadrante
subplot(3, 1, 1);
plot(1:iteraciones, errores, '-o');
title('Error en cada iteración');
xlabel('Número de iteración');
ylabel('Error promedio');
grid on;

% Graficar evolución de la primera fila de MeasuredData y u en el segundo cuadrante
subplot(3, 1, 2);
plot(1:iteraciones+1, MesuredData(fila_a_comparar, :),'r');
title('Evolución del nodo medido por el MoCap');
xlabel('Número de iteración');
ylabel('Valor');
grid on;
subplot(3,1,3)
plot(1:iteraciones, utotal(fila_a_comparar, :),'g');
title('Evolución del nodo aproximado por la red');
xlabel('Número de iteración');
ylabel('Valor');
grid on;

% Ajusta el espacio entre subgráficos
sgtitle('Comparación de errores y evolución de la primera fila');

% ---------------------------------------------------------------
%% Definición de las funciones que se usan en este programa 
% --------------------------------------------------------------



%Definición de la función DNN
function [du, dW, dV] = DNN(u, us, W1, V1, h)
	global  K1 K2 P V0 l Lambda A
	Delta   = u - us;
	sigma   = sigmoid(1,V1*u);
	D_sigma = diag(sigma.*(1-sigma));
	%
	dW      = h*(-K1*P*Delta*sigma' + K1*P*Delta*u'*(V1-V0)'*D_sigma);
	dV		= h*(-K2*D_sigma'*W1'*P*Delta*u' - l/2*K2*Lambda*(V1-V0)*(u*u'));
	du		= h*(A*u + W1*sigma);
end

%Definición de la función sigmoide
function s = sigmoid(b,x)
   s = 1./(1+exp(-b*x)); 
end

%Definición de la función SPDmatrix 
function A = SPDmatrix(size)
    % Generate a random symmetric matrix
    A = randn(size, size);

    % Make the matrix symmetric
    A = 0.5 * (A + A');

    % Make the matrix positive definite
    A = A + size * eye(size);
end