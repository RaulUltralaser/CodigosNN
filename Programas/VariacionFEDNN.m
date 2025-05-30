%%%%%%%%%%%%%%%Código de FEDNN alternativo%%%%%%%%%%%%%%%%%%%%%%%%%
% Necesito correr primero ControlInit.m para el valor de Am


clc
clearvars -except Am grad_Wv grad_Psiv Wv Psiv 
close all

%% Datos de la simulación
% ----------------------------------------------------
%Cargo los datos acomodados de los experimentos
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat');
Ts  = 0.01;							    %Tiempo de muestreo
N=20;                                   %Número de nodos
T  = size(Data,2);						%Número de iteraciones

V_data=Data;
U=zeros(N,T);
Tiempo_pertur=13.5;
Nodo_pertur=10;
indice_pertur = floor(Tiempo_pertur / Ts) + 1;
U(Nodo_pertur,indice_pertur)=1;
U_data=U;

%% Estimación de W_circ y \Phi_circ

% Parámetros de aprendizaje
alpha = 1e-5;       % Learning rate 
tol_error = 1e-3;   % Criterio de error mínimo (norma cuadrada total)

% Dimensiones de red
input_dim = 2 * N;
hidden_dim = N;     

% Inicialización aleatoria de vectores de pesos (vectorizados)
Wv = randn(hidden_dim * input_dim, 1);
Psiv = randn(input_dim * input_dim, 1);  % para Psi

% Bucle de entrenamiento
max_iters = 5000; % Seguridad de parada
for iter = 1:max_iters
    L_total = 0;
    grad_Wv = zeros(size(Wv));
    grad_Psiv = zeros(size(Psiv));
%     
    for k = 2:T
        Vk_prev = V_data(:, k-1);
        Vk_real = V_data(:, k);
        
        % Reconstruir matrices
        W = reshape(Wv, hidden_dim, input_dim);
        Psi = reshape(Psiv, input_dim, input_dim);

        % Evaluar activaciones
        Gamma = [sigmoid(Psi(:,1:N)', Vk_prev); phi_sigmoid(Psi(:,N+1:end)', Vk_prev)*U(:,k-1)];

        % Vectorización: (I ⊗ Gammaᵀ) * vec(W)
        kron_Gamma = kron(eye(N), Gamma');
        WGamma = kron_Gamma * Wv;

        % Estimar siguiente paso
        Pi = [zeros(N), eye(N); Am];
        B = [zeros(N); eye(N)];
        Vk_pred = Vk_prev + Ts * (Pi * Vk_prev + B * WGamma);

        % Error
        e = Vk_real - Vk_pred;
        L_total = L_total + norm(e)^2;

        % Gradientes (aproximados)
        % dL/dWv ≈ -2 * kron(eye(N), Gammaᵗ)ᵗ * Bᵗ * e
        grad_Wv = grad_Wv - 2 * (kron_Gamma') * (B' * e);

        % dL/dPsiv (aproximado con regla de la cadena)
        % Nota: Aquí puedes ajustar con Jacobianos reales si lo deseas
        % Simplemente hacemos un paso en la dirección negativa del gradiente estimado
        grad_Psiv = grad_Psiv - 2 * randn(size(Psiv)); % estimación cruda
    end
    
    % Actualización por gradiente descendiente
    Wv = Wv - alpha * grad_Wv;
    Psiv = Psiv - alpha * grad_Psiv;

    % Mostrar progreso
    if mod(iter, 100) == 0
        fprintf("Iteración %d, Error acumulado: %.6f\n", iter, L_total);
    end

    % Verificar criterio de paro
    if L_total < tol_error
        fprintf("Convergencia alcanzada en %d iteraciones, error: %.6f\n", iter, L_total);
        break;
    end
end


%% Iniciador hiperparametros
% Hiperparámetros
% input_dim = 2 * N;
% output_dim = N;
% hidden_dim = 2 * N;
% 
% % Inicialización de pesos
% W1_hat = randn(N, N);  % pesos capa oculta
% W2_hat = randn(N, N);  % pesos capa oculta * entrada
% Psi1_hat = randn(N, 2*N);  % pesos de entrada para sigma
% Psi2_hat = randn(N, 2*N);  % pesos de entrada para phi
% 
% % Funciones de activación
% sigma = @(x) tanh(x);        % activación sigma
% phi = @(x) 1 ./ (1 + exp(-x)); % activación phi sigmoidal


% %% Identificador
% 
% % Matrices Π y B
% Pi = [zeros(N), eye(N); Am]; 
% B = [zeros(N); eye(N)];
% 
% % Verifica si Pi es Hurwitz
% eig_Pi = eig(Pi);
% if all(real(eig_Pi) < 0)
%     disp('Pi es Hurwitz');
%     L=zeros(size(Pi));
% else
%     disp('Pi no es Hurwitz. Se requiere corrección mediante L');
% %     L=;
% end
% 
% 
% % Inicialización del estado estimado
% V_hat = zeros(2*N, T);
% 
% % Simulación del identificador
% for k = 2:T
%     Vk_hat = V_hat(:, k-1);
%     
%     % Evaluar activaciones
%     Gamma = [sigma(Psi1_hat * Vk_hat); phi(Psi2_hat * Vk_hat) .* U_data(:, k-1)];
%     
%     % Estimación del siguiente estado
%     V_dot = Pi * Vk_hat + [zeros(N); W1_hat * Gamma(1:N) + W2_hat * Gamma(N+1:end)];
%     V_hat(:, k) = Vk_hat + Ts * V_dot;
% end

function s = sigmoid(b,x)
   s = 1./(1+exp(-b*x)); 
end



function phi = phi_sigmoid(bp, xp)
    % Comprueba que b y x tengan las dimensiones adecuadas
    [rows_b, cols_b] = size(bp);
%     [rows_x, cols_x] = size(xp);

    % Inicializa la matriz de salida
    phi = zeros(rows_b, rows_b); % Matriz de 20x20

    % Calcula la sigmoide combinando cada fila de b con el vector x
    for i = 1:rows_b
        phi(i, :) = 1 ./ (1 + exp(-bp(i, :) * xp)); % Producto y sigmoide
    end
end
