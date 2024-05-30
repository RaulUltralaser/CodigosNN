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
t=linspace(0,60,6083);
n=1;

figure
plot(t, errores);
title('Average error');
xlabel('Time (s)');
ylabel('Error');
grid on;

figure
subplot(2, 1, 1);
plot(t, Velocidades(n,:),'r');
title('Evolution of the node measured by the MoCap');
xlabel('Time (s)');
ylabel('Velocity (mm/s)');
grid on;
subplot(2, 1, 2);
plot(t, VelocidadesRed(n,:),'g');
title('Derivative from the positions aproximated by the network');
xlabel('Time (s)');
ylabel('Velocity (mm/s)');
grid on;