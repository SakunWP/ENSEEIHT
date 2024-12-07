%%%%% SET ENV %%%%%
close all

addpath('matlab_bgl');      %load graph libraries
addpath('matlab_tpgraphe'); %load tp ressources

load TPgraphe.mat;          %load data

%%%%%% DISPLAY INPUT DATA ON TERMINAL %%%%%

cities %names of cities
D      %distance matrix bw cities
pos    %x-y pos of the cities

%%%%%%EXO 1 (modeliser et afficher le graphe) %%%%%

A=((D<= 500) & (D>0)); %adj matrix
viz_adj(D,A,pos,cities);
A2=graphPower(A,2)
viz_adj(D,A2,pos,cities);

%%%%%% EXO 2 %%%%%

%Q1 - existence d'un chemin de longueur 3
B=graphPower(A,3);
B2=graphPower(A,2);
B3=B-B2
viz_adj(D,B3,pos,cities);



%Q2 - nb de chemins de 3 sauts
nbs3 = sum(sum(B3))

%Q3 - nb de chemins <=3
nbinf3 = sum(sum(B))

%%%%%%%% EXO 3 %%%%%
c=[18 13 9]; %la chaine 18 13 9 est t dans le graphe?
possedechaine(A,c)
c=[18 6 3]; %la chaine 18 6 3 est t dans le graphe?
possedechaine(A,c)
c=[26 5 17]; %la chaine 26 5 17 est t dans le graphe?
possedechaine(A,c)

%%%%%%%% EXO 4%%%%%
isEulerien(A)

%%%%%%%% EXO 5%%%%%
porteeEulerien(D)
