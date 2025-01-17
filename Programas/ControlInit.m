clc 
clearvars
close all

load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/PesosFEDNN.mat');
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat');

n=20; %Nodos descontando el fijo


V0=Data(:,1);
V0(1:20)=Data(1:20,1)-35*ones(20,1);
Am=A(21:40,:);
Psi1=[V1 zeros(n,n)];
Psi2=[zeros(n,n) V2];
B=[zeros(n,n);eye(n,n)];


% eig_vals = eig(A); % Calcula los valores propios
% is_hurwitz = all(real(eig_vals) < 0); % Verifica si todos tienen parte real negativa
% 
% if is_hurwitz
%     disp('La matriz es Hurwitz.');
% else
%     disp('La matriz no es Hurwitz.');
% end

%% Control de Poznyack

k=-10*ones(n,1);


