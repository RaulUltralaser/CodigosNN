clc
clearvars -except xt
x=xt;
b=ones(length(xt),length(xt));

for i=1:length(xt)
    for j=1:length(xt)
        sumbx=0
        for p=1:length(xt)
            sumbx=sumbx+(b(i,j)^p)*x(p)
        end
        phi(i,j)=1./(1+exp(-sumbx));
    end
end


