function [] = display_structure(~,ncon,X,Y,U,F,dzero)

figure;
hold on;
axis equal;

scale = 10000;

Xd = X + scale * U(1:2:end);
Yd = Y + scale * U(2:2:end);

patch('Faces', ncon, 'Vertices', [X Y], ...
      'FaceColor', 'none', 'EdgeColor', 'k', 'LineStyle', '--');

patch('Faces', ncon, 'Vertices', [Xd Yd], ...
      'FaceColor', 'red', 'FaceAlpha', 0.3, ...
      'EdgeColor', 'r', 'LineWidth', 1.5);

for i = 1:length(X)
    text(X(i), Y(i), sprintf(' %d', i), 'FontSize', 20);
end

scale_force = 1e-6;
for i = 1:length(X)
    Fx = F(2*i - 1);
    Fy = F(2*i);

    if Fx ~= 0 || Fy ~= 0
        quiver(X(i), Y(i), Fx, Fy, scale_force, ...
            'b', 'LineWidth', 1.5, 'MaxHeadSize', 2);
    end
end

fixed_nodes = unique(ceil(dzero/2));
plot(X(fixed_nodes), Y(fixed_nodes), ...
    'ks', 'MarkerSize', 8, 'MarkerFaceColor','y');

end