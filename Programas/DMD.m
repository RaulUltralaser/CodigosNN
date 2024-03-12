clc
close all 
clearvars
% Cargar datos desde el archivo .mat
%load('tus_datos.mat');  

X = datos;

% Definir matrices X1 y X2 para la construcción de matrices de datos consecutivas
X1 = X(:, 1:end-1);
X2 = X(:, 2:end);

% Aplicar la SVD (Singular Value Decomposition) a X1
[U, S, V] = svd(X1, 'econ');

% Elegir el rango de aproximación del rango S
rango_aproximacion =  rank(X1);  

% Construir matrices truncadas y desplazadas
Ur = U(:, 1:rango_aproximacion);
Sr = S(1:rango_aproximacion, 1:rango_aproximacion);
Vr = V(:, 1:rango_aproximacion);

% Reconstruir matrices de datos desplazadas y truncadas
A_tilde = Ur' * X2 * Vr / Sr;

% Calcular los valores y vectores propios de A_tilde
[eigenvects, eigvals] = eig(A_tilde);

% Calcular modos DMD y frecuencias asociadas
modos_DMD = X2 * Vr / Sr * eigenvects;
frecuencias_DMD = imag(log(diag(eigvals)));

% Visualizar los resultados
figure;
scatter(real(frecuencias_DMD), imag(frecuencias_DMD), 'o');
title('Frecuencias DMD');
xlabel('Parte Real');
ylabel('Parte Imaginaria');




