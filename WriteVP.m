function WriteVP(D,fileName,Path)

%On s'occupe de récupérer les valeurs que l'on souhaite
D = real(D);
g = 9.81;
Omega = sqrt(diag(D)*g) / (2 * pi);

%On écrit les valeurs propres dans un fichier csv
writematrix(real(Omega),[Path,'frequencies_',fileName,'.csv'], WriteMode='overwrite');