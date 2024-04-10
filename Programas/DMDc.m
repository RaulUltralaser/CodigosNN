clc
close all 
clearvars
% Cargar datos desde el archivo .mat
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat');  

X = Data;  %Valores medidos
Y = zeros(20,length(X)); %Iniciador de entradas
NodeU=10;
TimeU=13.5;
FrecuenciaMuestreo=100;
Y(NodeU,TimeU*FrecuenciaMuestreo)=111;  

% Definir la matriz de datos desplazada
X1 = X(:, 1:end-1);
X2 = X(:, 2:end);

% Definir la matriz G y Omega
Omega = [X1;Y];

% Aplicar la SVD (Singular Value Decomposition) a Omega
[U, S, V] = svd(Omega, 'econ');

% Elegir el rango de aproximación del rango S
rango_aproximacion =  rank(Omega);  

% Construir matrices truncadas y desplazadas
Ur = U(:, 1:rango_aproximacion);
Sr = S(1:rango_aproximacion, 1:rango_aproximacion);
Vr = V(:, 1:rango_aproximacion);

%%TODO: DEFINIR LO QUE ES N Y P

%Separar Ur1 y Ur2
Ur1=Ur(1:n,1:p);
Ur2=Ur(n+1:end,p+1:end);

%Encontrar A y B
A_tilde = X2*Vr*Ur1\Sr;
B_tilde = X2*Vr*Ur2\Sr;



