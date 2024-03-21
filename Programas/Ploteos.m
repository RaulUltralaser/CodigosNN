clc
close all

% Frecuencia de muestreo
frecuencia_muestreo = 100; % Hz

% Número de muestras
num_muestras = size(t, 1); % Suponiendo que x es una matriz donde las filas son muestras y las columnas son series de datos

% Calcular el tiempo total de la señal
tiempo_total = num_muestras / frecuencia_muestreo;

% Crear vector de tiempo
tiempo = linspace(0, tiempo_total, num_muestras);
x = [x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20]; % Matriz de datos donde cada columna corresponde a una serie de datos x

% Colores para las líneas
colores = hsv(20); % Genera una matriz de colores distintos

% Graficar
figure;
hold on;
for i = 1:20
    plot(tiempo, x(:, i), 'Color', colores(i, :));
end
hold off;

% Etiquetas y título
xlabel('Tiempo');
ylabel('Valor de x');
title('Gráfica de x en función del tiempo');

% Crear gráficas individuales para cada serie de datos
for i = 1:20
    figure;
    plot(tiempo, x(:, i), 'Color', colores(i, :));
    xlabel('Tiempo');
    ylabel(['Valor de x', num2str(i)]);
    title(['Gráfica de x', num2str(i), ' en función del tiempo']);
end