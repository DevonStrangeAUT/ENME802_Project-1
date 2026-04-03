function [] = display_structure(~,ncon,X,Y,U,F,dzero)
% DISPLAY_STRUCTURE - Visualize structure geometry, displacements, and loads
%
% Input arguments:
% ~     - unused first argument (placeholder)
% ncon  - face connectivity for patch plotting
% X,Y   - nodal coordinates (Nx1)
% U     - displacement vector [Ux1; Uy1; ...]
% F     - force vector [Fx1; Fy1; ...]
% dzero - DOF indices that are fixed (1-based DOF numbering)
figure;
hold on;
axis equal;
scale = 10000;
Xd = X + scale * U(1:2:end);
Yd = Y + scale * U(2:2:end);
patch('Faces', ncon, 'Vertices', [X Y], ...
    'FaceColor', 'none', 'EdgeColor', 'k', 'LineStyle', '--');
% Draw deformed shape semi-transparent and scaled for visibility
patch('Faces', ncon, 'Vertices', [Xd Yd], ...
    'FaceColor', 'red', 'FaceAlpha', 0.3, ...
    'EdgeColor', 'r', 'LineWidth', 1.5);
% Label nodes with their indices for reference
% for i = 1:length(X)
%    text(X(i), Y(i), sprintf(' %d', i), 'FontSize', 20);
% end
scale_force = 1e-6;
% Plot applied nodal forces as blue quivers, skip zero forces
for i = 1:length(X)
    Fx = F(2*i - 1);
    Fy = F(2*i);
    if Fx ~= 0 || Fy ~= 0
        quiver(X(i), Y(i), Fx, Fy, scale_force, ...
            'b', 'LineWidth', 1.5, 'MaxHeadSize', 2);
    end
end
% Mark fixed nodes (convert DOF indices to node indices)
fixed_nodes = unique(ceil(dzero/2));
plot(X(fixed_nodes), Y(fixed_nodes), ...
    'ks', 'MarkerSize', 8, 'MarkerFaceColor','y');
end