%   Nbpt : number of summits
%   Nbtri : number of triangles
%   Nbtre : number of tetrahedrons
%   Coorneu : Coordinate of each points of the mesh : matrix (x1, y1, z1;
%                                                             x2, y2, z2; ...
%   Refneu : reference/tag of each point || To see if points are on the
%   freesurface
%   Numtri : triangles list, index the 3 summits of the triangle : 
%   Numtri(i,:) = (idx_i1,idx_i2,idx_i3)
%   Numtre : tetrahedrons list, index the 4 summits of the tetrahedis : 
%   Numtre(i,:) = (idx_i1,idx_i2,idx_i3,idx_i4)
%   Reftri : reference/tag of each triangle || To see if triangles are on the
%   freesurface for the computation of the M matrix

function [Nbpt,Nbtri,Coorneu,Refneu,Numtri,Reftri,Numtre,Nbtre]=lecture_mesh(nomfile,idx_Free,idx_lat)
  fid=fopen(nomfile,'r');
  if fid <=0
    msg=['Le fichier de maillage : ' nomfile ' n''a pas ?t? trouv?'];
    error(msg);
  end

  %Searching for '$Nodes' to start reading nodes
  ligne = fgetl(fid);
  while ~strcmp(ligne,'$Nodes')
    ligne = fgetl(fid);
  end

  %Variable intializing
  Nbpt = str2num(fgetl(fid));
  Coorneu = zeros(Nbpt,3);
  Refneu = zeros(Nbpt,1);

  %We get summits coordinates
  ligne = fgetl(fid);
  while ~strcmp(ligne,'$EndNodes')
    data = str2num(ligne);
    Coorneu(data(1),:) = data(2:end);
    ligne = fgetl(fid);
  end

  %Searching for '$Elements' to start reading elements
  ligne = fgetl(fid);
  while ~strcmp(ligne,'$Elements')
    ligne = fgetl(fid);
  end

  %Number of elements
  Nbelem = str2num(fgetl(fid));

  %Variable initializing
  Numtri = zeros(Nbelem,3);
  Reftri = zeros(Nbelem,1);
  Nbtri = 0;

  Numtre = zeros(Nbelem,4);
  Reftre = zeros(Nbelem,1);
  Nbtre = 0;

  %We get triangles informations 
  ligne = fgetl(fid);
  for k = 1:Nbelem
    data = str2num(ligne);
    type_elem = data(2);
    ref_elem  = data(4);

    if type_elem == 2 % Triangle
      Nbtri = Nbtri + 1;
      nodes = data(6:end);
      Numtri(Nbtri,:) = nodes;
      Reftri(Nbtri) = ref_elem;

      % If it's the free surface we mark the tag to nodes
      if ref_elem == idx_Free
        Refneu(nodes) = idx_Free;
      end

      if ref_elem == idx_lat
          for i_n = 1:length(nodes)
            if Refneu(nodes(i_n)) ~= idx_Free
                Refneu(nodes(i_n)) = idx_lat;
            end
          end
      end

    elseif type_elem == 4 % tetrahedrons
      Nbtre = Nbtre + 1;
      Numtre(Nbtre,:) = data(6:end);
      Reftre(Nbtre) = ref_elem;
    end

    ligne = fgetl(fid); % On lit la ligne suivante pour le prochain tour
  end

  %We only keep the good numbers of elements in each category
  Numtri = Numtri(1:Nbtri, :);
  Reftri = Reftri(1:Nbtri, :);
  Numtre = Numtre(1:Nbtre, :);
