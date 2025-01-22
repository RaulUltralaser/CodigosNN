%open modal_SAP_control.slx
clearvars
close all
clc

%%%%%%%%%%%%%%%%%%Valores mecánicos%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L=1;              %Longitud de la viga                    m
d=2e-3;           %Espesor                                m
b=25e-3;          %Anchura                                m
area=b*d;         %Area sección transversal               m^2
E=69e7;           %Modulo de Young                        N/m2 
a=0.0015;
I=a^4/12;         %Momento de inercia                     m^4
rho=2710;         %Densidad del metal                     kg/m^3

%%%%%%%%%%%%%%%%%%Valores para el analisis de elemento finito%%%%%%%%%%%%%
ne=21;            %Número de elementos
nne=2;            %Número de modos por elemento
dof=2;            %Grado de liberad -> Número de variables por nodo
Le=L/ne;          %Distancia entre elementos
nn=ne+1;          %Número de nodos
N=nn*dof;         %Númeor de variables totales

%% Esto ya es el calculo de lo requerido
imass=1;   %este valor lo requiere la función febeam1, debe ser 1 para 
           %masas continuas o dos para masa con grumos (la barra es 1)


Rm=1e-3;
Rk=1e-4;

x=0:Le:L;                                  %se define x
x=x';                                      %x nunca se vuelve a usar
yo=zeros(nn,1);                            %yo nunca se usa 

nodes=zeros(ne,nne);                       %inicializa la matriz de nodos
%nodes es una matriz de cuyos renglones son números consecutivos esto es
%solo para ordenar los nodos que estan juntos
for i=1:ne
    nodes(i,:)=[i,i+1];
end

%Inicializa las matrices de rigidez y masas
KK=zeros(N,N);
MM=zeros(N,N);

%Utiliznado febeam1 se crea l amatriz de rigidez y masas de un elemento y
%estas son ensambladas usando feasmbl1 para cerar las respectivas matrices
%de todo el sistema. El programa feeldof computa los grados de libertad
%asociados a cada elemento.
for e=1:ne
    [K,M]=febeam1(E,I,Le,area,rho,imass);
    index=feeldof(nodes(e,:),nne,dof);
    KK=feasmbl1(KK,K,index);
    MM=feasmbl1(MM,M,index);
end



%simply supported beam
bc=[1,nn]; 
nbc=length(bc);
bcval=zeros(1,dof*nbc);
ibc=feeldof(bc,nbc,dof);
%traction vector

qi=2:nn-1; %controled nodes 
qo=2:nn-1;  %measurable nodes  

m=length(qi);
p=length(qo);

%fd=1;  %displacement force 
%fa=0;  %angle force


iqi=feeldof(qi,m,dof);
iqo=feeldof(qo,p,dof);

FF=zeros(N,m);

fi=[1,0]';  %displacement force
%fi=[0,1]'; %angular force
i=1;
for j=1:m
    FF(iqi(i:i+1),j)=fi;
    i=i+dof;
end

H=zeros(p,N);
hi=[1,0];
i=1;
for j=1:p
    H(j,iqo(i:i+1))=hi;
    i=i+dof;
end

%%dyanmic analysis
[KK,MM]=feaplycs(KK,MM,ibc);

%%%%%%%%%%%%%%
%%Remove fixed nodes (Dirichlet boundary conditions)
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

Dbc=Rm*Mbc+Rk*Kbc;


%system with bc 
A=[zeros(nq,nq),eye(nq);
   -Mbc\Kbc  ,-Mbc\Dbc];   
B=[zeros(nq,m);
    Mbc\Fbc];


%Fbcw2=[1,0,1,0,1,0,1,0,1,0,1,0,1,0]';
%Bw2=[zeros(nq,1);Mbc\Fbcw2];  %Usar este vector para H_infty

C=[Hbc,zeros(p,nq)];
C2=[zeros(p,nq),Hbc];


[Phi,W2]=eig(Kbc,Mbc);
Z=Rm*eye(nq)+Rk*W2;
z=diag(Z);
w2=diag(W2);
w=real(sqrt(w2));
zeta=z./(2*w);
Psi2=[Phi'*Mbc,zeros(nq);zeros(nq),Phi'*Mbc];
Phi2=[Phi,zeros(nq);zeros(nq),Phi];
iPhi=inv(Phi);

%modal red
r=5;
k=2*r;
W2r=W2(1:r,1:r);
Zr=Z(1:r,1:r);
Phir=Phi(:,1:r);
iPhir=iPhi(1:r,:);
Phir2=[Phir,zeros(nq,r);zeros(nq,r),Phir];
iPhir2=[iPhir,zeros(r,nq);zeros(r,nq),iPhir];

Am2=[zeros(r,r),eye(r);
    -W2r, -Zr];
Bm2=[zeros(r,m);                    %%%This will be useful for optimal SAP
    Phir'*Fbc];

Cm2=[Hbc*Phir,zeros(p,r)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[zeta_min,i]=min(zeta);
cr=zeros(1,r);
i=1;  %mode
cr(i)=1;
Cv=[zeros(1,r),cr];
Cp=[cr,zeros(1,r)];

Cm=[ones(1,r),zeros(1,r)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Sensor Actuator Performance Measure (SAP)

%zetad=1/sqrt(2);
zetad=0.7;
%zetad=1;
zetag=zetad-zeta(i);



PhiB=Phir'*Fbc;
PhiC=Hbc*Phir;
%PB=Phi'*Fbc;
%PC=Hbc*Phi;

L1=max(abs(PhiB(i,:)));
L2=min(abs(PhiB(i,:)));

rmodes=1:r;
rmodes(i)=[]; %residual modes


mu0=zeros(p,m);
mu1=zeros(p,m);
beta=zeros(p,m);
betav=zeros(p,m);
au=zeros(1,r-1);


for h=1:p
    ci=abs(PhiC(h,i));
    
    for f=1:m
        bi=abs(PhiB(i,f));
        if (ci*bi)<1e-9 
            mu0(h,f)=inf;     
        else
            for j=1:r-1
                rm=rmodes(j);
                au(j)=abs(PhiC(h,rm))*abs(PhiB(rm,f))/abs(w2(rm)-w2(i));
                %c2(j) =abs(PhiC(h,rm))*abs(PhiB(rm,f))/sqrt((w2(rm)-w2(i))^2+(2*zeta(rm)*w(rm)*w(i))^2);
                %c8(j)=abs(PhiC(h,rm))*abs(PhiB(rm,f))/(2*zeta(rm)*w(rm));           
            end      
        end
        mu0(h,f)=L1*ci/(2*zeta(i)*w2(i));
        mu1(h,f)=L1*sum(au)/bi;   
        beta(h,f)=L1*ci/(2*zetad*w2(i))+mu1(h,f);
        betav(h,f)=L1*ci/(2*zetad*w(i))+mu1(h,f);
    end
end

%mu  %Utilizamos |G^j|, que es menor que la norma infinita de G
%mu2 %Utlizamos norma infinita


%%%%%%Controller parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%H_\infty control
n=length(A);
gam=0.5;
% Mgam=[A -B*B'+Bw2*Bw2'/gam^2;
%     -eye(24) -A'];
% [v,d]=eig(Mgam);
% Vs1=Vs(1:n,:);
% Vs2=Vs()

%P=ss(Ag,Bg,Cg,0);
%[K,~,gamma] = hinfsyn(P,1,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Open-loop analysis
%figure()


%%Closed-loop analysis
%[~,f]=min(mu);
i=1;

h=1;
f=9;

h2=1;
f2=2;

fd=8;
%fd=8;


Bw=B(:,fd);
Bmw=Bm2(:,fd);


bi=PhiB(i,f);
ci=PhiC(h,i);

b2=PhiB(i,f2);
c2=PhiC(h2,i);

Cp1=ci*Cp;
Cv1=ci*Cv;

Cp2=c2*Cp;
Cv2=c2*Cv;

d0=1;
bd=abs(PhiB(i,fd));
dmax=abs(ci)*bd*d0/(2*zeta(i)*w(i));
dmax2=abs(ci)*bd*d0/(2*zeta(i)*w2(i));
dmax_dB=20*log10(dmax);

du=ci*L1*d0/(2*zeta(i)*w(i)^2);
dl=ci*L2*d0/(2*zeta(i)*w(i)^2);

gp= -2*w2(i)*zetad/(bi*ci);
gv= -2*w(i)*zetag/(bi*ci);

gp2= -2*w2(i)*zetad/(b2*c2);
gv2= -2*w(i)*zetag/(b2*c2);

beta_dB=20*log10(beta(h,f));

disp(['fd=', num2str(fd),' h=',num2str(h),' f=',num2str(f),' h2=',num2str(h2),' f2=',num2str(f2)])
disp(['zetad=', num2str(zetad)])
disp(['dmax=', num2str(dmax),' dmax2=', num2str(dmax2)])
disp(['beta=', num2str(beta(h,f))])
disp(['beta2=', num2str(beta(h2,f2))])
disp(['betav=', num2str(betav(h,f))])


%closed loop dynamics
Ap1=A+B(:,f)*gp*Cp1*iPhir2;
Ap2=A+B(:,f2)*gp2*Cp2*iPhir2;

Av1=A+B(:,f)*gv*Cv1*iPhir2;
Av2=A+B(:,f2)*gv2*Cv2*iPhir2;

%Apof=Am2+Bm2(:,f)*gpof*Cp1;
%Avof=Am2+Bm2(:,f)*gvof*Cv1;

Ch=C(h,:);
Ch2=C2(h,:);

[b,a]=ss2tf(A,Bw,Ch,0);
G=tf(b,a);

[bp1,ap1]=ss2tf(Ap1,Bw,Ch,0);
[bp2,ap2]=ss2tf(Ap2,Bw,Ch,0);

Gp= tf(bp1,ap1);
Gp2=tf(bp2,ap2);


[bv1,av1]=ss2tf(Av1,Bw,Ch,0);
[bv2,av2]=ss2tf(Av2,Bw,Ch,0);

Gv= tf(bv1,av1);
Gv2=tf(bv2,av2);

% figure()
% %hp = bodeplot(G,'k',Gp2,'r--',Gp,'b',{0.1,10000});
% hp = bodeplot(G,'k',{0.1,10000});
% setoptions(hp,'PhaseVisible','off');
% legend('Open-loop','Generic location','Optimal location')
% grid on
% hold on 
% 
% figure()
% hv = bodeplot(G,'k',Gv2,'r--',Gv,'b',{0.1,10000});
% setoptions(hv,'PhaseVisible','off');
% legend('Open-loop','Generic location','Optimal location')
% grid on


% figure(2)
% [br,ar]=ss2tf(Am2,Bw2,Cpm,0);
% Gm=tf(br,ar);
% hm = bodeplot(Gm);
% setoptions(hm,'FreqUnits','Hz','PhaseVisible','off');
% grid on
% hold on
% 
% [bp,ap]=ss2tf(Apof,Bw2,Cpm,0);
% Gpof=tf(bp,ap);
% hp=bodeplot(Gpof);
% 
% [bv,av]=ss2tf(Avof,Bw2,Cpm,0);
% Gvof=tf(bv,av);
% hv=bodeplot(Gvof);


%figure()
% X=Phi';
% hold on
% x1=X(1,1:2:end);
% x2=X(1,2:2:end);
% x3=X(2,1:2:end);
% x4=X(2,2:2:end);
% x5=X(3,1:2:end);
% x6=X(3,2:2:end);
% plot(x1)
% %plot(x2)
% plot(x3)
% %plot(x4)
% plot(x5)
% %plot(x6)

