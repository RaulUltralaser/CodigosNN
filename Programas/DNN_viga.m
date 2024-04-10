%%%%%%%%%%%% Codigo para la FEDNN con datos reales%%%%%%%%%%%%%%%%%%
%%% NOTA: Correr primero iniciador parametros
clc
clearvars -except P k1 k2 A
close all

% load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat'); 


x = Data;    %valores reales (medidos con el MoCap)
xt = x(:,1); %valor inicial de valores aproximados
N  = size(Data,2);

u = zeros(40,1);
b1=ones(length(xt));
% ---------------------------------------------------------------
%% Algoritmo 
% ---------------------------------------------------------------
% for i= 1:N
% 
%     if i == 1350
%         u(10)=100;
%     end
%     Delta = xt-x(:,i);
% 
%     dW1=-k1*P*Delta*sigmoid(1,xt)';
%     dW2=-k2*P*Delta*u'*phi_function(b1,xt)';
% 
%     W1= cumtrapz(dW1);
%     W2= cumtrapz(dW2);
% 
%     dxt = A*xt+W1*sigmoid(1,xt)+W2*phi_function(b1,xt)*u;
% 
%     xt = trapz(dxt);
% 
% 
%     errores(i) = mean(abs(Delta(:)));
% 
% end
% 
% iteraciones = size(errores,2);
% % Graficar errores en el primer cuadrante
% subplot(3, 1, 1);
% plot(1:iteraciones, errores, '-o');
% title('Error en cada iteración');
% xlabel('Número de iteración');
% ylabel('Error promedio');
% grid on;

% b1=ones(length(xt));
% 
% phi_function(b1,xt);

function s = sigmoid(b,x)
   s = 1./(1+exp(-b*x)); 
end

function phi = phi_function(b, x)
    for i=1:length(x)
        for j=1:length(x)
            sumbx=0;
            for p=1:length(x)
                sumbx=sumbx+(b(i,j)^p)*x(p);
            end
            phi(i,j)=1./(1+exp(-sumbx));
        end
    end
end

