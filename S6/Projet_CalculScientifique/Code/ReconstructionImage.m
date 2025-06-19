%%  Application de la SVD : compression d'images

clear all
close all

% Lecture de l'image
I = imread('BD_Spirou_2.jpg');
I = rgb2gray(I);
I = double(I);


[q, p] = size(I)

% Décomposition par SVD
fprintf('Décomposition en valeurs singulières\n')
tic
[U, S, V] = svd(I);
toc

l = min(p,q);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% On choisit de ne considérer que 200 vecteurs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 200 vecteurs utilisés pour la reconstruction et on affiche l'image tous les 40 vecteurs (pas)
inter = 1:40:(200+40);
inter(end) = 200;

% vecteur pour stocker la différence entre l'image et l'image reconstruite

differenceSVD = zeros(size(inter,2), 1);

% images reconstruites en utilisant de 1 à 200 vecteurs
ti = 0;
td = 0;
for k = inter

    % Calcul de l'image de rang k
    Im_k = U(:, 1:k)*S(1:k, 1:k)*V(:, 1:k)';

    % Affichage de l'image reconstruite
    ti = ti+1;
    figure(ti)
    colormap('gray')
    imagesc(Im_k), axis equal
    
    % Calcul de la différence entre les 2 images (RMSE : Root Mean Square Error)
    td = td + 1;
    differenceSVD(td) = sqrt(sum(sum((I-Im_k).^2)));
    pause
end

% Figure des différences entre l'image réelle et les images reconstruites
ti = ti+1;
figure(ti)
hold on 
plot(inter, differenceSVD, 'rx')
ylabel('RMSE')
xlabel('rank k')
pause


% Plugger les différentes méthodes : eig, puissance itérée et les 4 versions de la "subspace iteration method" 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUELQUES VALEURS PAR DÉFAUT DE PARAMÈTRES, 
% VALEURS QUE VOUS DEVEZ FAIRE ÉVOLUER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tolérance
eps = 1e-8;
% nombre d'itérations max pour atteindre la convergence
maxit = 10000;

% taille de l'espace de recherche (m)
search_space = 400;

% pourcentage que l'on se fixe
percentage = 0.99;

% p pour les versions 2 et 3 (attention p déjà utilisé comme taille)
puiss = 1;


%%%%%%%%%%%%%%%%%%% Methodes %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods = {'eig', 'subspace_iter_v0', 'subspace_iter_v1', 'subspace_iter_v2', 'subspace_iter_v3', 'power_v11', 'power_v12'};
nb_methods = length(methods);


% Décomposition par SVD
for id_method = 1:nb_methods
    method = methods{id_method};
    fprintf('\nDécomposition en valeurs singulières avec %s\n', method)
    tic
    %%

    %%
    % calcul des couples propres
    %%
    if q<p 
      M = I'*I;
      U = zeros(q);
      
    else
      M = I*I';
      V = zeros(p);
      
    end
    
    switch method
        case 'eig'
            [W, D] = eig(M);
            
        case 'subspace_iter_v0'
            [W, D, ~, ~] = subspace_iter_v0(M, search_space, eps, maxit);

        case 'subspace_iter_v1'
            [W, D, ~, ~, ~, ~] = subspace_iter_v1(M, search_space, percentage, eps, maxit);

        case 'subspace_iter_v2'
            [W, D, ~, ~, ~, ~] = subspace_iter_v2(M, search_space, percentage, puiss, eps, maxit);

        case 'subspace_iter_v3'
            [W, D, ~, ~, ~, ~] = subspace_iter_v3(M, search_space, percentage, puiss, eps, maxit);
        case 'power_v11'
            [W, D, ~, ~, ~] = power_v11(M, search_space, percentage, eps, maxit);

        case 'power_v12'
            [W, D, ~, ~, ~] = power_v12(M, search_space, percentage, eps, maxit);
  
    end
 
    [D, indices] = sort(diag(D), 'descend');
    W = W(:,indices);
 
    if q<p
        V = W;
    else
        U = W;
    end
    %%
    % calcul des valeurs singulières
    %%
    Sigma = zeros(q,p);
    for i = 1:min(q,p)
        Sigma(i,i) = sqrt(D(i));
    end
    S= Sigma;
    %%

    % calcul de l'autre ensemble de vecteurs
    %%
    if q<p
        U = (I*V(:,1:q))*diag(1./diag(S));
    else
        V = (I'*U(:,1:p))*diag(1./diag(S));
    end
    
    toc
    %%
    % calcul des meilleures approximations de rang faible
    %%
    for k = 1 %...
        % Calcul de l'image de rang k
        Im_k = U(:, 1:k)*S(1:k, 1:k)*V(:, 1:k)';
 
        % Affichage de l'image reconstruite
        ti = ti+1;
        figure(ti)
        colormap('gray')
        imagesc(Im_k)
        title("Méthode utilisée : ", method)
        % Calcul de la différence entre les 2 images
        td = td + 1;
        differenceSVD_2(td) = sqrt(sum(sum((I-Im_k).^2)));
        pause
    end
 
    % Figure des différences entre image réelle et image reconstruite
    ti = ti+1;
    figure(ti)
    hold on 
    plot(inter, differenceSVD_2, 'rx')
    title("difference between I and Ik (Méthode : ", method, " )")
    ylabel('RMSE')
    xlabel('rank k')
    pause
end


