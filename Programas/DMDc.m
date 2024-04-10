clc
close all 
clearvars -except B
% Cargar datos desde el archivo .mat
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat');  

X = Data;                   %Valores medidos
Xmov=X(1:20,:)-X(1:20,1);   %Llevo los valores iniciales a cero
X = [Xmov;X(20+1:end,:)];   %Formo X con la correción del offset
Y = zeros(20,length(X)-1);  %Iniciador de entradas
NodeU=10;
TimeU=13.5;
FrecuenciaMuestreo=100;
Y(NodeU,TimeU*FrecuenciaMuestreo)=10;  

% Definir la matriz de datos desplazada
X1 = X(:, 1:end-1);    %X_k
X2 = X(:, 2:end);      %X_k+1

% Definir la matriz G y Omega
Omega = [X1;Y];

%% Caso 1 B es conocida (la tomo de FEM)
[U, S, V] = svd(X1, 'econ');

% Elegir el rango de aproximación del rango S
p =  rank(X1);  %rango de aproximación


% Construir matrices truncadas y desplazadas
Ur = U(:, 1:p);
Sr = S(1:p, 1:p);
Vr = V(:, 1:p);

A_tilde=(X2-B*Y)*Vr*(Sr\Ur');
%% Caso 2 B es desconocida

% % Aplicar la SVD (Singular Value Decomposition) a Omega
% [U, S, V] = svd(Omega, 'econ');
% 
% % Elegir el rango de aproximación del rango S
% p =  rank(Omega);  %rango de aproximación
% 
% 
% % Construir matrices truncadas y desplazadas
% Ur = U(:, 1:p);
% Sr = S(1:p, 1:p);
% Vr = V(:, 1:p);
% 
% %%TODO: DEFINIR LO QUE ES N Y P
% G= X2*Vr*(Sr\Ur');
% 
% %Separar Ur1 y Ur2
% Ur1=Ur(1:p-1,:);
% Ur2=Ur(p:end,:);
% 
% %Encontrar A y B
% A_tilde = X2*Vr*(Sr\Ur1');
% B_tilde = X2*Vr*(Sr\Ur2');



