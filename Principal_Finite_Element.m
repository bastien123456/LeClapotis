fileName = 'VC_F50';         %File name for Matlab to read correctly
Path = 'Studies\VerticalCylinder\'; %Path of the file
gmshVersion = '2.2';        %Version of gmsh used to mesh the geometry
PointingDirFS = 'z';                    %Pointing direction of the normal vector to the free surface (exemple : 'z' : normal vector pointing in the z direction in gmsh)
ShowTank = 'no';                       %If we want to plot the tank surfaces 'yes' and if we don't want 'no'
n = 10;                                 %Number of eigen vectors to plot (except the first because it's null)
Kvp = 30;                               %Number of eigenvalues to compute
Freesurf_idx = 123; %Tag of the free surface points and triangles : as default = 123



g = 9.81; %Earth gravitationnal constant
Lateral_idx = 50; %Tag of the free surface points and triangles : as default = 50
ScaleFactor = 1;

if (strcmp(gmshVersion,'2.2') == 1)
    [Nbpt,Nbtri,Coorneu,Refneu,Numtri,Reftri,Numtre,Nbtre]=lecture_mesh([Path,fileName,'.msh'],Freesurf_idx,Lateral_idx);
elseif (strcmp(gmshVersion,'4.15') == 1)
    [Nbpt,Nbtri,Coorneu,Refneu,Numtri,Reftri,Numtre,Nbtre]=LC_read_mesh([Path,fileName,'.msh'],Freesurf_idx,Lateral_idx);
end

Coorneu = 1/ScaleFactor*Coorneu;
idx_l = find(Refneu == Lateral_idx);
idx_s = find(Refneu == Freesurf_idx);          % Indices of free surface nodes
idx_i = setdiff(1:Nbpt, idx_s);       % Indices of interior nodes
idx_tri_surf = find(Reftri == Freesurf_idx);   % Indices of free surface triangles
idx_tri_lat = find(Reftri == Lateral_idx); % Indices of lateral surfaces triangles

%%%%%%%%%%%%%%%ASSEMBLY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[K,M] = Assembly(Coorneu,Numtre,Numtri,Reftri,Nbtre,Nbtri,Nbpt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%PROBLEME SOLVING%%%%%%%%%%%%%%%%%%%%%%%
[Vs,Vi,D] = Resolving(idx_s,idx_i,K,M,Kvp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%OUTPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Phi = Vs;
Freq = sqrt(diag(real(abs(D)))*g) / (2 * pi);
Amp = abs(max(Vs))';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%PLOT SPECTRUM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotSpectrum(Freq,Amp,fileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%PLOT MODES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2:n+1
    PlotFreeSurface(i, Vs,D, Coorneu,Numtri, idx_tri_surf,idx_tri_lat,idx_s, Nbpt,g,Path,PointingDirFS,ShowTank);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%MATRIX WRITING%%%%%%%%%%%%%%%%%%%%%%%%%%%
WriteVP(D,fileName,Path);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%