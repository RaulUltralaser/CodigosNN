clearvars
clc

n=80;

A=rand(n,n);
Q = A' * A;
Lambda1 = Q + 0.1 * eye(n); 

try chol(Lambda1);
    disp('Matrix Lambda1 is symmetric positive definite.')
catch ME
    disp('Matrix Lambda1 is not symmetric positive definite')
end

B=rand(n,n);
R = B' * B;
Lambda2 = R + 0.1 * eye(n); 

try chol(Lambda2);
    disp('Matrix Lambda2 is symmetric positive definite.')
catch ME
    disp('Matrix Lambda2 is not symmetric positive definite')
end