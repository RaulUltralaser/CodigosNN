%%%Iniciador de parametros para el sistema de solo ocho estados

clc
clearvars
f=4;  %Nodo a leer del 1 al 4

%Matrices llenadas bajo la tecnica de peak picking
%frecuencias naturales
w1=18.21855;
w2=127.71475;
w3=244.45897;
w4=375.4227;
wn=[w1 w2 w3 w4];

%factores de amortiguamiento
xi1=0.0116;
xi2=0.0137;
xi3=0.0056;
xi4=0.0036;
xin=[xi1 xi2 xi3 xi4];

%mode shapes
phi1=[8.2044; -0.8491; -4.3655; 2.6594  ];
phi2=[-7.0012; 6.1720; 3.0441; 0.5753];
phi3=[-139.09; -9.2087; 0.9947; 0.3556];
phi4=[-5.7143; -136.83; 2.8840; 0.6618];
Phi=[phi1 phi2 phi3 phi4];

Fbc=[1 0 0 0;
     0 1 0 0;
     0 0 1 0;
     0 0 0 1];
Hbc=[1 0 0 0;
     0 1 0 0;
     0 0 1 0;
     0 0 0 1];

W2=diag(wn.^2);

r=length(wn);
m=length(wn);

Z=diag(2*xin.*wn);


A=[zeros(r,r),eye(r);
    -W2, -Z];
B=[zeros(r,m);                    
    Phi'*Fbc];

%% DNN
load('QuintoPesos.mat')


AH=[1, -1, -1, -1, -1, -1, -1, -1;
    1, 1, -1, -1, -1, -1, -1, -1;
    1, 1, 1, -1, -1, -1, -1, -1;
    1, 1, 1, 1, -1, -1, -1, -1;
    1, 1, 1, 1, 1, -1, -1, -1;
    1, 1, 1, 1, 1, 1, -1, -1;
    1, 1, 1, 1, 1, 1, 1, -1;
    1, 1, 1, 1, 1, 1, 1, 1 ];

nodos=4; %nodos
E=nodos*2; %estados


k1  = 1;
k2	= 1/2;

%Inicializador de pesos
W1_0=rand(E,E); 
W2_0=rand(E,E);

%Valores para R
wstar1=Pesos1;
lambda1=eye(E);

wstar2=Pesos2;
lambda2=eye(E);

alpha=3; %Factor escalar de wbar

Wbar1=alpha*(wstar1*inv(lambda1)*wstar1');
Wbar2=alpha*(wstar2*inv(lambda2)*wstar2');

%Calcular el valor de R
R=Wbar1+Wbar2;

%Valores para Q
ubar=4; %tiene que ser mayor a la norma cuadrada de la entrada 
Dsigma=2;
Dphi=2;
beta=1/6; %Factor escalar de Q0

Q0=beta*eye(E);

%Calcular el valor de Q
Q=Q0+Dsigma+Dphi*ubar;


[P,~,~] = icare(A,[],Q,[],[],[],-R);



