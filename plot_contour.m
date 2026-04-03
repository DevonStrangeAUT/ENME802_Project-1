function plot_contour(ax, ncon, X, Y, values, titleStr)

cla(ax);
hold(ax,'on');
axis(ax,'equal');

n_nodes = length(X);
nodal_values = zeros(n_nodes,1);
counts = zeros(n_nodes,1);

% --- Average element values to nodes ---
for i = 1:size(ncon,1)
    nodes = ncon(i,:);
    for j = 1:3
        n = nodes(j);
        nodal_values(n) = nodal_values(n) + values(i);
        counts(n) = counts(n) + 1;
    end
end

nodal_values = nodal_values ./ counts;

% --- Plot ---
patch(ax, ...
    'Faces', ncon, ...
    'Vertices', [X Y], ...
    'FaceVertexCData', nodal_values, ...
    'FaceColor', 'interp', ...
    'EdgeColor', 'k');

colormap(ax, 'jet');
colorbar(ax);

title(ax, titleStr);

end