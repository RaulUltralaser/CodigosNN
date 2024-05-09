clc
clearvars
close all

load('~/Documentos/Doctorado/Tesis/NeuralNetwork/CodigosNN/Datos/EstadosCalculadosPorFEDNN.mat');
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/CodigosNN/Datos/DataAcomodada24.mat');

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

subplot(3, 1, 1);
plot(t, errores);
title('Error');
xlabel('Time (s)');
ylabel('Average errors');
grid on;
subplot(3, 1, 2);
plot(t, Velocidades(n,:),'r');
title('Evolution of the node measured by the MoCap');
xlabel('Time (s)');
ylabel('Velocity (mm/s)');
grid on;
subplot(3, 1, 3);
plot(t, VelocidadesRed(n,:),'g');
title('Derivative from the positions aproximated by the network');
xlabel('Time (s)');
ylabel('Velocity (mm/s)');
grid on;