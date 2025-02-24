clc 
clearvars 
close all

load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/PesosFEDNN.mat');
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat');

n=20; %Nodos descontando el fijo


V0=Data(:,1);
V0(1:20)=Data(1:20,1)-mean(Data(1:20,1));
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

%% Propuesta de control con H infinito

% A_h=W1;
% B_h=W2;
% sys=ss(A_h,B_h,eye(20),0);
% % Definir pesos de desempeño (ej: penalizar error y esfuerzo de control)
% W1_h = tf(1, [0.1 1]);   % Peso sobre el error
% W2_h = tf(0.1, [1 0]);    % Peso sobre el control
% [K, ~, ~] = hinfsyn(sys, W1_h, W2_h);


%% Para los controles tendría que elegir sobre que nodo quiero que se aplique
%%tanto la perturbación como el control
nodeControl=3;
nodeDisturbe=5;

NC=zeros(1,40);
NC(1,nodeControl)=1;

NCP=zeros(1,20);
NCP(1,nodeControl)=1;

%% Control de Poznyack

gains=ones(1,20);
gains(1,nodeControl)=2.55;
k=diag(gains);


%% Control modal

% %%%%%%%%%%%%%%%%%%Valores mecánicos%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L=1;              %Longitud de la viga                    m
d=2e-3;           %Espesor                                m
b=25e-3;          %Anchura                                m
area=b*d;         %Area sección transversal               m^2
E=69e7;           %Modulo de Young                        N/m2 
a=0.0015;
I=a^4/12;         %Momento de inercia                     m^4
rho=2710;         %Densidad del metal                     kg/m^3
% 
% %%%%%%%%%%%%%%%%%%Valores para el analisis de elemento finito%%%%%%%%%%%%%
ne=21;            %Número de elementos
nne=2;            %Número de modos por elemento
dof=2;            %Grado de liberad -> Número de variables por nodo
Le=L/ne;          %Distancia entre elementos
nn=ne+1;          %Número de nodos
N=nn*dof;         %Númeor de variables totales
% 
% %% Esto ya es el calculo de lo requerido
imass=1;   %este valor lo requiere la función febeam1, debe ser 1 para 
%            %masas continuas o dos para masa con grumos (la barra es 1)
% 
Rm=1e-3;
Rk=1e-4;
% 
nodes=zeros(ne,nne);                       %inicializa la matriz de nodos
% %nodes es una matriz de cuyos renglones son números consecutivos esto es
% %solo para ordenar los nodos que estan juntos
for i=1:ne
    nodes(i,:)=[i,i+1];
end
% 
% %Inicializa las matrices de rigidez y masas
KK=zeros(N,N);
MM=zeros(N,N);
% 
% %Utiliznado febeam1 se crea l amatriz de rigidez y masas de un elemento y
% %estas son ensambladas usando feasmbl1 para cerar las respectivas matrices
% %de todo el sistema. El programa feeldof computa los grados de libertad
% %asociados a cada elemento.
for e=1:ne
    [K,M]=febeam1(E,I,Le,area,rho,imass);
    index=feeldof(nodes(e,:),nne,dof);
    KK=feasmbl1(KK,K,index);
    MM=feasmbl1(MM,M,index);
end
% 
% %simply supported beam
bc=[1,nn]; 
nbc=length(bc);
% bcval=zeros(1,dof*nbc);
ibc=feeldof(bc,nbc,dof);
% %traction vector
% 
qi=2:nn-1; %controled nodes 
qo=2:nn-1;  %measurable nodes  
% 
m=length(qi);
p=length(qo);
% 
iqi=feeldof(qi,m,dof);
iqo=feeldof(qo,p,dof);
% 
FF=zeros(N,m);
% 
fi=[1,0]';  %displacement force
%fi=[0,1]'; %angular force
i=1;
for j=1:m
    FF(iqi(i:i+1),j)=fi;
    i=i+dof;
end
% 
H=zeros(p,N);
hi=[1,0];
i=1;
for j=1:p
    H(j,iqo(i:i+1))=hi;
    i=i+dof;
end
% 
% %%dyanmic analysis
[KK,MM]=feaplycs(KK,MM,ibc);
% 
% %%%%%%%%%%%%%%
% %%Remove fixed nodes (Dirichlet boundary conditions)
nq=dof*(nn-nbc);
Hbc=zeros(p,nq);
Fbc=zeros(nq,m);

Kbc=zeros(nq,nq);
Mbc=zeros(nq,nq);
qq=1:2*nn;
qq(ibc)=[];

for i=1:nq
    for j=1:nq
        Kbc(i,j)=KK(qq(i),qq(j));
        Mbc(i,j)=MM(qq(i),qq(j));
    end
    Fbc(i,:)=FF(qq(i),:);
    Hbc(:,i)=H(:,qq(i));
end

[Phi,W2_j]=eig(Kbc,Mbc);
Z=Rm*eye(nq)+Rk*W2_j;
z=diag(Z);
w2=diag(W2_j);
w=real(sqrt(w2));
zeta=z./(2*w);

iPhi=inv(Phi);

r=5;

Phir=Phi(:,1:r);

%zetad=1/sqrt(2);
zetad=0.7;
%zetad=1;
zetag=zetad-zeta(i);

PhiB=Phir'*Fbc;
PhiC=Hbc*Phir;

i=1;
h=1;
f=9;

bi=PhiB(i,f);
ci=PhiC(h,i);

gp= -2*w2(i)*zetad/(bi*ci);
gv= -2*w(i)*zetag/(bi*ci);








