clearvars
clc
x=rand(80,20);
sigmoid(1,x)


function s = sigmoid(b,x)
   s = 1./(1+exp(-b*x)); 
end