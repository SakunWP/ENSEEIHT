% Auteur : J. Gergaud
% décembre 2017
% -----------------------------
% 



function Jac = diff_finies_avant(fun,x,option)
%
% Cette fonction calcule les différences finies avant sur un schéma
% Paramètres en entrées
% fun : fonction dont on cherche à calculer la matrice jacobienne
%       fonction de IR^n à valeurs dans IR^m
% x   : point où l'on veut calculer la matrice jacobienne
% option : précision du calcul de fun (ndigits)
%
% Paramètre en sortie
% Jac : Matrice jacobienne approximé par les différences finies
%        real(m,n)
% ------------------------------------
w=max(eps,10^(-option));
n=size(x,1);
m=size(fun(x),1);
Jac=zeros(m,n);
v=zeros(n,1);
for k=1:m
    for j=1:n
        h=sqrt(w)*max(abs(x(k)),1)*sgn(x(k));
        v(j)=1;
        Jac(k,j)=(fun(x+h*v)-fun(x))/h;
    end
end
end

function s = sgn(x)
% fonction signe qui renvoie 1 si x = 0
if x==0
  s = 1;
else 
  s = sign(x);
end
end







