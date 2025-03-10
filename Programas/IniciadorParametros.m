clc
clearvars -except out
close all 

 f=19;        %que nodo quiero leer en la simulación

% Valores de la viga
ne=20;              %Numero elementos
nne=2;              %Nodos por elemento
dof=1;              %Grados de libertad
L=1;                %Largo %m
Le=L/ne;            %Distancia entre elementos
E=69e3;             %Modulo de Young N/m2 
d=2e-3;             %Espesor m
b=25e-3;            %Ancho m
rho=2710;           %Densidad Kg/m3
nodosFix=1;         %Especificación de la cantidad de los nodos fijos
imass=1;            %1 Si la masa es consistente, 2 si es grumosa
Rm=1e-3;            %Constantes de Rayleigh para la matriz de amortiguamiento
Rk=1e-4;            %Constantes de Rayleigh para la matriz de amortiguamiento

area=b*d;           %Área transversal
nn=ne+nodosFix;     %Número de nodos totales (incluido el fijo)
a=b^3*d;            %Medida para encontrar el momento de inercia
I=a/12;             %m4 moment of inertia (Ancho³Espesor/12
N=nn*dof;           %Grados de libertad totales


nodes=zeros(ne,nne);%Inicializa una matriz de nodos

for i=1:ne          %Rellena la matriz de nodos con números consecutivos
    nodes(i,:)=[i,i+1]; %tal que nodes(i,j)=nodes(i+1,j-1) ([1,2;2,3...]
end

%Inicializa la matriz stiffness y mass
KK=zeros(N,N);
MM=zeros(N,N);

%Arrange the matrices
for e=1:ne
    [K,M]=febeam1(E,I,Le,area,rho,imass); %Matrices de rigidez y masa para elemento de viga hermitiana.
    index=feeldof(nodes(e,:),nne,dof);    %Cálcula el dof del sistema asociado con cada elemento
    KK=feasmbl1(KK,K,index);              %Ensambla la matriz de rigidez
    MM=feasmbl1(MM,M,index);              %Ensambla la matriz de masas
end



%simply supported beam
bc=1;                      %Boundary condition (En este caso solo el primer nodo)
nbc=length(bc);            %Cancidad de nodos restringidos
bcval=zeros(1,dof*nbc);    %Valores de los nodos restringidos 
ibc=feeldof(bc,nbc,dof);   %Calcula los dofs asociados a cada elemento


qi=2:nn;    %Nodos controlados 
qo=2:nn;    %Nodos medibles  

m=length(qi); %Se usa para la matriz B
p=length(qo); %Se usa para la matriz H

iqi=feeldof(qi,m,dof);  %Cálcula el dof del sistema asociado con cada elemento
iqo=feeldof(qo,p,dof);  %Cálcula el dof del sistema asociado con cada elemento

FF=zeros(N,m);%Inicializa la matriz de fuerzas

%principal
fi=[1,0]';  %FUerza de desplazamiento

%Rellena la matriz de fuerzas con una diagonal de 1 bajo la diagonal
i=1;
for j=1:m-1
    FF(iqi(i:i+1),j)=fi;
    i=i+dof;
end

H=zeros(p,N);%Inicializo la matriz de salidas
zetad=0.7;
%REllena la matriz de salida igual que la de fuerzas
hi=[1,0];
i=1;
for j=1:p-1
    H(j,iqo(i:i+1))=hi;
    i=i+dof;
end

%%dyanmic analysis
[KK,MM]=feaplycs(KK,MM,ibc);%Aplica restricciones a la ecuación matricial de valores propios

%%%%%%%%%%%%%%
%%Remueve nodos fijos(Dirichlet boundary conditions)
nq=dof*(nn-nbc);
Hbc=zeros(p,nq);
Fbc=zeros(nq,m);

Kbc=zeros(nq,nq); %Stiffness sin nodos fijos
Mbc=zeros(nq,nq); %Masas sin nodos fijos
qq=1:2*nn;
qq(ibc)=[];


%Rellena las matrices sin nodos fijos
for i=1:nq
    for j=1:nq
        Kbc(i,j)=KK(qq(i),qq(j));
        Mbc(i,j)=MM(qq(i),qq(j));
    end
    Fbc(i,:)=FF(qq(i),:);
    Hbc(:,i)=H(:,qq(i));
end

Dbc=Rm*Mbc+Rk*Kbc; %La matriz de amortiguamiento calculada como Rayleigh


%Systema con bondary conditions   
A=[zeros(nq,nq),eye(nq);
   -Mbc\Kbc  ,-Mbc\Dbc];   
B=[zeros(nq,m);
    Mbc\Fbc];

%Esto es para calcular los modeshapes
[Phi,W2]=eig(Kbc,Mbc);
iPhi=inv(Phi);

%%  DNN
%-----------------------------------------------
% Parameters initilization for DNN
% ---------------------------------------------


k1  = 0.7;
k2	= 0.15;

n = ne*2;    %estos van a  ser los estados de mi sistema (vector modal, posiciones y velocidades)

%Inicializador de Pesos
W1_0=rand(n,n);
W2_0=rand(n,n/2);
% W1_0=out.Pesos1(:,:,6001);
% W2_0=out.Pesos2(:,:,6001);

%Valores para R
wstar1=diag(1:n);
lambda1=eye(n);

wstar2=diag(1:n);
lambda2=eye(n);

alpha=50; %Factor escalar de wbar

Wbar1=alpha*(wstar1*inv(lambda1)*wstar1');
Wbar2=alpha*(wstar2*inv(lambda2)*wstar2');


%Calcular el valor de R
R=Wbar1+Wbar2;

%Valores para Q
ubar=30; %tiene que ser mayor a la norma cuadrada de la entrada 
Dsigma=2;
Dphi=2;
beta=1/4; %factor escalar Q0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          

Q0=beta*eye(n);

%Calcular el valor de Q
Q=Q0+Dsigma+Dphi*ubar;


% [P,~,~] = icare(A,[],Q,[],[],[],-R);
P=0.01*eye(n,n);

impulse=10; %El valor de el impulso
%% DNN SIMULACION REALES

% load('~/Documentos/CodigosNN/Datos/DataAcomodada24.mat'); 
load('~/Documentos/Doctorado/Tesis/NeuralNetwork/Datos/DataAcomodada24.mat')
X = Data;                   %Valores medidos
Xmov=X(1:20,:)-X(1:20,1);   %Llevo los valores iniciales a cero
X = [Xmov;X(20+1:end,:)];   %Formo X con la correción del offset
ValorInicial=X(:,1);


% 
% function A = SPDmatrix(size)
%     % Generate a random symmetric matrix
%     A = randn(size, size);
% 
%     % Make the matrix symmetric
%     A = 0.5 * (A + A');
% 
%     % Make the matrix positive definite
%     A = A + size * eye(size);
% end


