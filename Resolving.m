function [Vs,Vi,D] = Resolving(idx_s,idx_i,K,M,Kvp)

% Vs = Matrice contenant les vecteurs propres du prbolème aux vp généralisé
% D = Matrice diagonale avec les valeurs propres sur la diagonale rangées
% en ordre croissant
% idx_i = indice des noeuds intérieurs
% idx_s = indice des noeuds de la surface libre


%On extrait les blocs de la matrice K
Kss = K(idx_s, idx_s);
Ksi = K(idx_s, idx_i);
Kis = K(idx_i, idx_s);
Kii = K(idx_i, idx_i);
%On extrait le bloc de masse de surface
Mss = M(idx_s, idx_s);
%On calcul la raideur condensée (Influence du volume sur la surface)
K_condensee = Kss - Ksi * (Kii \ Kis);

%On résout le problème aux valeurs propres généralisé
[Vs, D] = eigs(K_condensee, Mss, Kvp, 'sm');

Vi = -(Kii \ Kis) * Vs;

