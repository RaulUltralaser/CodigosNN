clc
close all

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

%% Esto es para plotear lo de simulink
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/ResultadosSimulinkDNN.mat')

t=out.Comparison.time;
x=out.Comparison.signals(1);
x2=out.Comparison.signals(2);

x=x.values;
x2=x2.values;
% Primero, eliminamos la dimensión innecesaria de x para facilitar el trabajo
x = squeeze(x); % Ahora 'x' debería tener dimensiones 40x60001
x2=squeeze(x2);
% Número de estados
num_estados = size(x, 1);

% Plotear los estados
figure; % Crear una nueva figura
% Primer subplot para los valores de x
subplot(2, 1, 1); % 2 filas, 1 columna, primer subplot
hold on; % Mantener la misma figura para múltiples plots
for i = 1:num_estados
    plot(t, x(i, :));
end
hold off; % Liberar la figura
xlabel('Time (s)');
ylabel('Positions and velocities');
title('System assumed by DNN');
% legend show; % Mostrar la leyenda con los nombres de los estados
grid on; % Mostrar una cuadrícula para facilitar la lectura

% Segundo subplot para los valores de x2
subplot(2, 1, 2); % 2 filas, 1 columna, segundo subplot
hold on; % Mantener la misma figura para múltiples plots
for i = 1:num_estados
    plot(t, x2(i, :));
end
hold off; % Liberar la figura
xlabel('Time (s)');
ylabel('Positions and velocities');
title('Real measurements');
% legend show; % Mostrar la leyenda con los nombres de los estados
grid on; % Mostrar una cuadrícula para facilitar la lectura


figure
hold on; % Mantener la misma figura para múltiples plots
for i = 1:num_estados
    plot(t, x(i, :));
end
hold off; % Liberar la figura
xlabel('Time (s)');
ylabel('Positions and velocities');
title('System assumed by DNN');
grid on
% 
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
% 
% load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DatosSeparadosPorMetodo.mat')
% 
% %Quito el offset de los datos
% Reales=Reales(:,:)-Reales(:,1);
% FEDNN=FEDNN(:,:)-FEDNN(:,1);
% 
% Tf=6001; %El minimo valor de columnas de los metodos
% f=19;  %Fila que quiero mostrar
% t=linspace(0,60,Tf);

% Crear la figura principal
% figure
% hold on
% plot(t, DMD1(f,1:Tf), '-b') % Azul
% plot(t, DMD2(f,1:Tf), '-m') % Rojo
% plot(t, FEDNN(f,1:Tf), '-r') % Verde
% plot(t, DNN(f,1:Tf), '-g') % Magenta
% plot(t, Reales(f,1:Tf), '--k') % Línea discontinua negra
% title('Comparison between the different nodes and the real data');
% xlabel('Time (s)');
% ylabel('Values of one node');
% grid on;
% 
% % Definir la región para el zoom (ajusta los valores de acuerdo a tus necesidades)
% x_zoom = [50, 55]; % Ejemplo de rango de tiempo
% y_zoom = [2,6]; 
% 
% % Crear un nuevo eje para el zoom
% axes('Position', [0.6 0.6 0.26 0.26]) % [x, y, width, height] ajustar según sea necesario
% box on
% hold on
% 
% % Graficar los mismos datos en la nueva región de zoom
% plot(t, DMD1(f,1:Tf), '-b') 
% plot(t, DMD2(f,1:Tf), '-m') 
% plot(t, FEDNN(f,1:Tf), '-r', 'LineWidth', 1.2) 
% plot(t, DNN(f,1:Tf), '-g') 
% plot(t, Reales(f,1:Tf), '--k', 'LineWidth', 2) % Línea discontinua negra
% xlim(x_zoom)
% ylim(y_zoom)
% grid on
% 
% % Volver al eje principal (opcional)
% axes(gca)

%DMD CASO 1
% figure
% plot(t,DMD1(:,1:Tf))
% title('System assumed by DMD')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on

%DMD CASO 2
% figure
% plot(t,DMD2(:,1:Tf))
% title('System assumed by DMD')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on
% 
% %DNN
% figure
% plot(t,DNN(f,1:Tf))
% title('System assumed by DNN')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on

% %FEDNN
% figure
% plot(t,FEDNN(:,1:Tf))
% title('System assumed by FEDNN')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on
% 
% figure
% plot(t,Reales(:,1:Tf))
% title('Real Mesurements')
% ylabel('Positions and velocities')
% xlabel('Time(s)')
% grid on
