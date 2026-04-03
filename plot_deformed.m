function plot_deformed(ax, ncon, X, Y, U, F, dzero)

cla(ax);
hold(ax,'on');
axis(ax,'equal');

scale = 1e5;

Xd = X + scale * U(1:2:end);
Yd = Y + scale * U(2:2:end);

% Original mesh
patch(ax,'Faces',ncon,'Vertices',[X Y], ...
    'FaceColor','none','EdgeColor','k','LineStyle','--');

% Deformed mesh
patch(ax,'Faces',ncon,'Vertices',[Xd Yd], ...
    'FaceColor','red','FaceAlpha',0.3,'EdgeColor','r');

% Forces
scale_force = 1e-6;
for i = 1:length(X)
    Fx = F(2*i - 1);
    Fy = F(2*i);
    if Fx ~= 0 || Fy ~= 0
        quiver(ax, X(i), Y(i), Fx, Fy, scale_force, 'b');
    end
end

% Fixed nodes
fixed_nodes = unique(ceil(dzero/2));
plot(ax, X(fixed_nodes), Y(fixed_nodes), 'ks', ...
    'MarkerFaceColor','y');

title(ax,'Deformed Structure');

end