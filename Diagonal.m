clearvars
clc

% Tamaño de la matriz diagonal
n = 5; % Puedes cambiar este valor según tus necesidades

% Generar valores aleatorios positivos para la diagonal
diagonal_values = rand(1, n) + 1; % Sumar 1 para asegurar que sean positivos

% Crear la matriz diagonal definida positiva
matriz_diagonal = diag(diagonal_values);

% Mostrar la matriz resultante
disp('Matriz diagonal definida positiva:');
disp(matriz_diagonal);
