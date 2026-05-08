function [K,M] = Assembly(Coorneu,Numtre,Numtri,Reftri,Nbtre,Nbtri,Nbpt)
%Assemblage des matrices de raideur et de masse surfacique grâce aux calculs
%des matrices élémentaires

K = sparse(Nbpt,Nbpt); % stifness matrix
M = sparse(Nbpt,Nbpt); % wieght matrix


for l = 1:Nbtre %loop on tetraedris, we add contributions from each elementary tetraedre to each point.
  S1 = Coorneu(Numtre(l,1),:);
  S2 = Coorneu(Numtre(l,2),:);
  S3 = Coorneu(Numtre(l,3),:);
  S4 = Coorneu(Numtre(l,4),:);

  Kel = calcul_K_elementary(S1,S2,S3,S4);

  for i = 1:4
    for j = 1:4
      K(Numtre(l,i),Numtre(l,j)) = K(Numtre(l,i),Numtre(l,j)) + Kel(i,j);
    end
  end
end

for t = 1:Nbtri %Calcul de la matrice de masse surfacique
  if Reftri(t) == 123
    S1 = Coorneu(Numtri(t,1),:);
    S2 = Coorneu(Numtri(t,2),:);
    S3 = Coorneu(Numtri(t,3),:);

    Mel = calcul_M_elementary(S1,S2,S3);

    for i = 1:3
      for j = 1:3
        M(Numtri(t,i),Numtri(t,j)) = M(Numtri(t,i),Numtri(t,j)) + Mel(i,j);
      end
    end
  end
end