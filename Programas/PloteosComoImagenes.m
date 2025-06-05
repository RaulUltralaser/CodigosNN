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

% Guardo los valores de la REALES para comparación
posicionesREALES=Reales(1:20,1:Tf);

% Solo descomentar la que se quiera graficar
posiciones = Reales(1:20,1:Tf);
% posiciones = FEDNN(1:20,1:Tf);
% posiciones = DMD1(1:20,1:Tf);
% posiciones = DMD2(1:20,1:Tf);
% posiciones = DNN(1:20,1:10:60001); %Este es especial porque use un tiempo de simulación diferente

% Resta valores reales menos valores a comparar
graficar=posicionesREALES-posiciones;

% Crear una paleta de colores personalizada (no me gustó)
% custom_colormap = [0, 0, 0;  % Negro
%                    0.5, 0.5, 0.5;  % Gris medio
%                    1, 1, 1]; % Blanco

% Crear la imagen
figure;
imagesc(t, 20:1, posiciones); % Usamos imagesc para crear la imagen
colorbar; % Muestra la barra de colores
xlabel('Time (s)');
ylabel('Node Number');
% title('DNN');
% colormap(custom_colormap); % Aplicar la paleta de colores
% colormap(cmocean('gray'));
% colormap(parula); % Puede ser cambiado a: 'parula', 'hot',
% clim([-80 80]);
colormap("parula");
clim([-30 30]);
xline(13.5, '--w', 'Impulse', 'LabelVerticalAlignment','bottom', 'LabelHorizontalAlignment','center');
% annotation('textbox',[.8 .1 .1 .1],'String','Values beyond ±30 saturated','FitBoxToText','on');



% Crear graficas de comparación en x,t
% figure;
% imagesc(t, 20:1, graficar); % Usamos imagesc para crear la imagen
% colorbar; % Muestra la barra de colores
% xlabel('Error over time');
% ylabel('Node number');
% % colormap(custom_colormap); % Aplicar la paleta de colores
% colormap(cmocean('gray'));
% % colormap(parula); % Puede ser cambiado a: 'parula', 'hot',


% Graficas del error con respecto al tiempo
% normas=vecnorm(graficar);
% figure;
% plot(t, normas, 'g:', 'LineWidth', 1.5); % Graficamos las normas de cada columna con respecto al tiempo
% xlabel('Time (s)');
% ylabel('Error');
% grid on; % Añade una rejilla para facilitar la lectura


% Todos los errores en una misma imagen
% norma1=vecnorm(posicionesREALES-FEDNN(1:20,1:Tf));
% norma2=vecnorm(posicionesREALES-DMD2(1:20,1:Tf));
% norma3=vecnorm(posicionesREALES-DNN(1:20,1:10:60001));
% figure;
% hold on
% plot(t,norma1,'LineWidth', .5);
% plot(t,norma2,'--','LineWidth', .5);
% plot(t,norma3,'g:','LineWidth', .5);
% xlabel('Time (s)');
% ylabel('Error');
% grid on
% hold off

