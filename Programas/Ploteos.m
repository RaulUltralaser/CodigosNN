clc
close all
clearvars

% % Frecuencia de muestreo
% frecuencia_muestreo = 100; % Hz
% 
% % Número de muestras
% num_muestras = size(t, 1); % Suponiendo que x es una matriz donde las filas son muestras y las columnas son series de datos
% 
% % Calcular el tiempo total de la señal
% tiempo_total = num_muestras / frecuencia_muestreo;
% 
% % Crear vector de tiempo
% tiempo = linspace(0, tiempo_total, num_muestras);
% x = [x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20]; % Matriz de datos donde cada columna corresponde a una serie de datos x
% 
% % Colores para las líneas
% colores = hsv(20); % Genera una matriz de colores distintos
% 
% % Graficar
% figure;
% hold on;
% for i = 1:20
%     plot(tiempo, x(:, i), 'Color', colores(i, :));
% end
% hold off;
% 
% % Etiquetas y título
% xlabel('Tiempo');
% ylabel('Valor de x');
% title('Gráfica de x en función del tiempo');
% 
% % Crear gráficas individuales para cada serie de datos
% for i = 1:20
%     figure;
%     plot(tiempo, x(:, i), 'Color', colores(i, :));
%     xlabel('Tiempo');
%     ylabel(['Valor de x', num2str(i)]);
%     title(['Gráfica de x', num2str(i), ' en función del tiempo']);
% end

%% Esto es para plotear lo de simulink ES DECIR DNN
% 
% load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/ResultadosSimulinkDNN.mat')
% % 
% t=out.Comparison.time;
% x=out.Comparison.signals(1);
% x2=out.Comparison.signals(2);
% x=x.values;
% x2=x2.values;
% % Primero, eliminamos la dimensión innecesaria de x para facilitar el trabajo
% x = squeeze(x); % Ahora 'x' debería tener dimensiones 40x60001
% x2=squeeze(x2); %Estos son los reales se DNN ES x
% % Número de estados
% num_estados = size(x, 1);
% % 
% figure
% hold on; % Mantener la misma figura para múltiples plots
% for i = 1:19
%     plot(t, x(i, :));
% end
% hold off; % Liberar la figura
% xlabel('Time (s)');
% ylabel('Positions and velocities');
% title('System assumed by DNN');
% grid on
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Leyendas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% positionLabels = arrayfun(@(n) sprintf('Node %d', n), 1:20, 'UniformOutput', false);
% velocityLabels = arrayfun(@(n) sprintf('Node %d', n), 1:20, 'UniformOutput', false);
% 
% % Combine position and velocity labels for the legend
% legendLabels = [positionLabels, velocityLabels];
% 
% % Create the legend with 2 columns
% leg = legend(legendLabels, 'Location', 'eastoutside', 'NumColumns', 2);
% 
% % Get the position of the legend
% legendPosition = leg.Position;
% 
% % Adjust the Y offsets to place the text correctly above the legend
% % Increase or decrease the value for fine-tuning
% positionTextY = legendPosition(2) + 0.8054;  % Adjust this value for "Positions"
% velocityTextY = legendPosition(2) + 0.8054;  % Adjust this value for "Velocities"
% 
% % Add "Positions" and "Velocities" text above the legend using annotation
% annotation('textbox', [legendPosition(1),positionTextY, 0, 0], ...
%     'String', 'Positions', 'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontWeight', 'bold');
% 
% annotation('textbox', [legendPosition(1)+.2, velocityTextY, 0, 0], ...
%     'String', 'Velocities', 'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontWeight', 'bold');


%% Esto grafica errores del DNN 
% t=out.Errores.time;
% E=out.Errores.signals.values;
% 
% E=squeeze(E);
% E=mean(abs(E));
% 
% % Número de estados
% num_estados = size(x, 1);
% 
% %Plotear los errores
% figure; % Crear una nueva figura
% hold on; % Mantener la misma figura para múltiples plots
% 
% plot(t, E);
% 
% 
% hold off; % Liberar la figura
% xlabel('Time (s)');
% ylabel('Average error');
% title('Error');
% % legend show; % Mostrar la leyenda con los nombres de los estados
% grid on; % Mostrar una cuadrícula para facilitar la lectura



%% Esto es la imagen de todos juntos 

% clearvars
% %Estos datos son de todos los metodos
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DatosSeparadosPorMetodo.mat')

Tf=6001;             %El minimo valor de columnas de los metodos
f=19;                %Fila que quiero mostrar
t=linspace(0,60,Tf); %Genero un vector de tiempo

%Quito el offset de los datos
Reales=Reales(:,:)-Reales(:,1);
FEDNN=FEDNN(:,:)-FEDNN(:,1);

%% Crear la figura principal
figure
hold on
plot(t, DMD1(f,1:Tf), '-b') % Azul
plot(t, DMD2(f,1:Tf), '-m') % Rojo
plot(t, FEDNN(f,1:Tf), '-r') % Verde
plot(t, DNN(f,1:Tf), '-g') % Magenta
plot(t, Reales(f,1:Tf), '--k') % Línea discontinua negra
title({'Comparison between the different nodes', 'and the real data'})
xlabel('Time (s)');
ylabel('Position of the last node (mm)');
grid on;

% Create the legend (It's easier to change the name manually)
legend('Location', 'eastoutside');
% Definir la región para el zoom 
x_zoom = [50, 55]; %Tiempo
y_zoom = [2,6];    %Valor

% Crear un nuevo eje para el zoom
axes('Position', [0.45 0.6 0.26 0.26]) % [x, y, width, height] ajustar según sea necesario
box on
hold on

% Graficar los mismos datos en la nueva región de zoom
plot(t, DMD1(f,1:Tf), '-b') 
plot(t, DMD2(f,1:Tf), '-m') 
plot(t, FEDNN(f,1:Tf), '-r', 'LineWidth', 1.2) 
plot(t, DNN(f,1:Tf), '-g') 
plot(t, Reales(f,1:Tf), '--k', 'LineWidth', 2) % Línea discontinua negra
xlim(x_zoom)
ylim(y_zoom)
grid on

% Volver al eje principal (opcional)
axes(gca)


%% DMDCaso1
% figure
% plot(t,DMD1(:,1:Tf))
% title('System assumed by DMD')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on

%% DMDCaso2
% figure
% plot(t,DMD2(:,1:Tf))
% title('System assumed by DMD')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on

%% RealData
figure
plot(t, Reales(:, 1:Tf))
title('Real Measurements')
ylabel('Positions and Velocities (mm-mm/s)')
xlabel('Time (s)')
grid on

%%%%%%%%%%%%%%%%%%%%%%Las leyendas funcionan igual con las figuras DMD CASO
%%%%%%%%%%%%%%%%%%%%%%1 Y CASO 2 Y REAL DATA, DNN Y FEDNN SON CASO
%%%%%%%%%%%%%%%%%%%%%%DISTINTOS
% % Create cell arrays for node labels
% positionLabels = arrayfun(@(n) sprintf('Node %d', n), 1:20, 'UniformOutput', false);
% velocityLabels = arrayfun(@(n) sprintf('Node %d', n), 1:20, 'UniformOutput', false);
% 
% % Combine position and velocity labels for the legend
% legendLabels = [positionLabels, velocityLabels];
% 
% % Create the legend with 2 columns
% leg = legend(legendLabels, 'Location', 'eastoutside', 'NumColumns', 2);
% 
% % Get the position of the legend
% legendPosition = leg.Position;
% 
% % Adjust the Y offsets to place the text correctly above the legend
% % Increase or decrease the value for fine-tuning
% positionTextY = legendPosition(2) + 0.8054;  % Adjust this value for "Positions"
% velocityTextY = legendPosition(2) + 0.8054;  % Adjust this value for "Velocities"
% 
% % Add "Positions" and "Velocities" text above the legend using annotation
% annotation('textbox', [legendPosition(1),positionTextY, 0, 0], ...
%     'String', 'Positions', 'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontWeight', 'bold');
% 
% annotation('textbox', [legendPosition(1)+.2, velocityTextY, 0, 0], ...
%     'String', 'Velocities', 'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontWeight', 'bold');


%% FEDNN
% figure
% plot(t,FEDNN(:,1:Tf))
% title('System assumed by FEDNN')
% ylabel('Positions (mm)')
% xlabel('Time(s)')
% grid on
% 
% % Create cell arrays for node labels
% positionLabels = arrayfun(@(n) sprintf('Node %d', n), 1:20, 'UniformOutput', false);
% 
% % Combine position and velocity labels for the legend
% legendLabels = positionLabels;
% 
% % Create the legend with 2 columns
% leg = legend(legendLabels, 'Location', 'eastoutside');
% 
% % Get the position of the legend
% legendPosition = leg.Position;
% 
% % Adjust the Y offsets to place the text correctly above the legend
% % Increase or decrease the value for fine-tuning
% positionTextY = legendPosition(2)+.80 ;  % Adjust this value for "Positions"
% 
% % Add "Positions" and "Velocities" text above the legend using annotation
% annotation('textbox', [legendPosition(1),positionTextY, 0, 0], ...
%     'String', 'Positions', 'FitBoxToText', 'on', 'EdgeColor', 'none', 'FontWeight', 'bold');

