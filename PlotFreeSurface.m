function PlotFreeSurface(n,Vs,D,Coorneu,Numtri,idx_tri_surf,idx_tri_lat,idx_s,Nbpt,g,Path,PointingDirFS,ShowTank)

%Change the plot direction and axis depending the free surface point direction
if(strcmp(PointingDirFS, 'x'))
    plt_x_idx = 2;
    plt_y_idx = 3;
    plt_z_idx = 1;
    xl = 'Y';
    yl = 'Z';
elseif(strcmp(PointingDirFS, 'y'))
    plt_x_idx = 1;
    plt_y_idx = 3;
    plt_z_idx = 2;
    xl = 'X';
    yl = 'Z';
elseif(strcmp(PointingDirFS, 'z'))
    plt_x_idx = 1;
    plt_y_idx = 2;
    plt_z_idx = 3;
    xl = 'X';
    yl = 'Y';
end

%Change axis and plot direction depending on Path
if strcmp(Path ,'Studies\ReelTank\')%  Scale factor 
    plt_x_idx = 1;
    plt_y_idx = 3;
    xl = 'X';
    yl = 'Z';
elseif(strcmp(Path ,'Studies\VerticalCylinder\'))
    plt_x_idx = 1;
    plt_y_idx = 2;
    xl = 'X';
    yl = 'Y';
elseif(strcmp(Path ,'Studies\StrangeShape\'))
    plt_x_idx = 1;
    plt_y_idx = 2;
    xl = 'X';
    yl = 'Y';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%PLOT THE FREE SURFACE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
amp = abs(max(Vs))';
omega = sqrt(diag(D)*g) / (2 * pi);
V_full = zeros(Nbpt, 1);
%On affiche un mode propre de la surface libre la surface libre
%On configure le mode propre
figure(n+1)
V_full(idx_s) = Vs(:, n);
V_full = V_full/max(abs(V_full)); %On normalise l'amplitude
V_full = V_full * max(abs(Coorneu(idx_s)))/4;

if strcmp(ShowTank,'yes')
    V_full(idx_s) = V_full(idx_s) + Coorneu(idx_s,plt_z_idx);
end

%On affiche le mode propre
trimesh(Numtri(idx_tri_surf, :), Coorneu(:, plt_x_idx), Coorneu(:, plt_y_idx), V_full);
xlabel(xl); ylabel(yl); zlabel('Velocity Potential Normalized');
axis on;
axis equal;
ax = gca; ax.XAxisLocation = 'origin';
title(['Mode n°', num2str(n-1), ' ||| Frequency : ',num2str(omega(n)),'Hz']);
colorbar;
view(-45, 30);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(ShowTank,'yes')
    Coor = zeros(Nbpt,3);
    Coor(:,plt_x_idx) = Coorneu(:,plt_x_idx);
    Coor(:,plt_y_idx) = Coorneu(:,plt_y_idx);
    Coor(:,plt_z_idx) = Coorneu(:,plt_z_idx);
    s = trisurf(Numtri(idx_tri_lat,:), Coor(:,plt_x_idx), Coor(:,plt_y_idx), Coor(:,plt_z_idx));
    s.FaceAlpha = 0.2;
    s.FaceColor = 'black';
    s.EdgeAlpha = 0.3;
    s.EdgeColor = 'black'; 
end