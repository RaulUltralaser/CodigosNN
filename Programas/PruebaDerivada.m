clc
clearvars
close all

load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/EstadosCalculadosPorFEDNN.mat');
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat');

%Guardo los datos reales
Velocidades = Data(21:40,1:end-1); 

%Derivo y acomodo los datos de la red para obtener la temporada
Derivada = diff(utotal')/0.01;
vectorCero = zeros(20,1);
VelocidadesRed= [vectorCero,Derivada'];

%Calculo el error
error = Velocidades-VelocidadesRed;
errores = mean(abs(error));

%Genero esta matriz para poder graficar
t=linspace(0,6083,6083);
n=1;

subplot(3, 1, 1);
plot(t, errores);
title('Error en cada iteración');
xlabel('Número de iteración');
ylabel('Error promedio');
grid on;
subplot(3, 1, 2);
plot(t, Velocidades(n,:),'r');
title('Velocidades reales');
xlabel('Número de iteración');
ylabel('Velocidad');
grid on;
subplot(3, 1, 3);
plot(t, VelocidadesRed(n,:));
title('Velocidades de la Red (derivada)');
xlabel('Número de iteración');
ylabel('Velocidad');
grid on;