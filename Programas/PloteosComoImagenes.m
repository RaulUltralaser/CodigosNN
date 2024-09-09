clc
clearvars
close all 

load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DatosSeparadosPorMetodo.mat');

% Suponiendo que 'posiciones' es una matriz de tamaño (20 x N), donde
% cada fila corresponde a un nodo y cada columna a un instante de tiempo
% y que 't' es el vector de tiempos.
Tf=6001;             %El minimo valor de columnas de los metodos
t=linspace(0,60,Tf);

%Quito el offset de los datos
Reales=Reales(:,:)-Reales(:,1);
FEDNN=FEDNN(:,:)-FEDNN(:,1);

% Generamos una matriz aleatoria como ejemplo (debes reemplazarla con tus datos reales):
% posiciones = Reales(1:20,1:Tf);
% posiciones = FEDNN(1:20,1:Tf);
% posiciones = DMD1(1:20,1:Tf);
% posiciones = DMD2(1:20,1:Tf);
posiciones = DNN(1:20,1:10:60001); %Este es especial porque use un tiempo de simulación diferente

% Crear la imagen
figure;
imagesc(t, 20:1, posiciones); % Usamos imagesc para crear la imagen
colorbar; % Muestra la barra de colores
xlabel('Time (s)');
ylabel('Node position (mm)');
% title('DNN');
colormap(parula); % Puede ser cambiado a: 'parula', 'hot',



