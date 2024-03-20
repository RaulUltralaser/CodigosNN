clc
close all

%%%%%%%%%%%%%%%%%%%%PROGRAMA DE ACOMODO PARA LOS DATOS%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cargar los datos
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/PosicionesyVelocidades24.mat');

% Definir el número de nodos y el número de instantes de tiempo
num_nodos = 20;
num_instantes = 6084; %length de cualquier x o v en el primer valor

% Inicializar la matriz Data
Data = zeros(num_nodos * 2, num_instantes);

% Llenar la matriz Data con las posiciones y velocidades
for t = 1:num_instantes
    % Para cada instante de tiempo, organizar las posiciones y velocidades en la matriz Data
    for i = 1:num_nodos
        % Asignar las posiciones en la fila correspondiente
        Data(i, t) = eval(['x', num2str(i), '(t)']);
        % Asignar las velocidades en la fila correspondiente
        Data(i + num_nodos, t) = eval(['v', num2str(i), '(t)']);
    end
end

