function plot_contour(ax, ncon, X, Y, values, titleStr)
  % PLOT_CONTOUR - Render interpolated contour on triangular mesh
  %
  % Input arguments:
  % ax       - axes handle to plot into
  % ncon     - connectivity (Nx3) triangle node indices
  % X, Y     - node coordinates (column vectors)
  % values   - per-element scalar values (length N)
  % titleStr - plot title string
cla(ax);
hold(ax,'on');
axis(ax,'equal');
n_nodes = length(X);
nodal_values = zeros(n_nodes,1);
counts = zeros(n_nodes,1);
% --- Average element values to nodes ---
% Accumulate element value contributions for each vertex then average
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
% Use interpolated face-vertex coloring for smooth contour display
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