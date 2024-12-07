% fonction estim_param_MC (pour exercice_1.m)

function parametres = estim_param_MC(d,x,y)

    p=length(x);
    A=zeros(p,d);
    for i=1:d
        A(:,i)=vecteur_bernstein(x,d,i);
    end
    B=y-y(1)*(vecteur_bernstein(x,d,0));
    parametres=A\B;

    
end
