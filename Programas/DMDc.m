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


