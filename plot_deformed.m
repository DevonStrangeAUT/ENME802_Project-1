function plot_deformed(ax, ncon, X, Y, U, F, dzero)
  % PLOT_DEFORMED - Visualize original and deformed mesh with forces and supports
  %
  % Input arguments:
  % ax     - axes handle to draw on
  % ncon   - connectivity (faces) for patch
  % X,Y    - nodal coordinates
  % U      - displacement vector [ux1;uy1;ux2;uy2;...]
  % F      - force vector [fx1;fy1;fx2;fy2;...]
  % dzero  - indices of fixed DOFs (1-based)
cla(ax);
hold(ax,'on');
axis(ax,'equal');
scale = 10000;
Xd = X + scale * U(1:2:end);
Yd = Y + scale * U(2:2:end);
% Original mesh
patch(ax,'Faces',ncon,'Vertices',[X Y], ...
    'FaceColor','none','EdgeColor','k','LineStyle','--');
% Deformed mesh (scaled for visibility)
patch(ax,'Faces',ncon,'Vertices',[Xd Yd], ...
    'FaceColor','red','FaceAlpha',0.3,'EdgeColor','r');
% Forces (draw non-zero nodal forces as blue arrows)
scale_force = 1e-6;
for i = 1:length(X)
    Fx = F(2*i - 1);
    Fy = F(2*i);
    if Fx ~= 0 || Fy ~= 0
        quiver(ax, X(i), Y(i), Fx, Fy, scale_force, 'b');
    end
end
% Fixed nodes (dzero lists fixed DOFs; convert to unique node indices)
fixed_nodes = unique(ceil(dzero/2));
plot(ax, X(fixed_nodes), Y(fixed_nodes), 'ks', ...
    'MarkerFaceColor','y');
title(ax,'Deformed Structure');
end