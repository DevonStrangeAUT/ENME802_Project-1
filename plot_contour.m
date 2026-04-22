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
if length(values) == n_nodes
    % NODAL DATA (e.g. displacement)
    nodal_values = values;
elseif length(values) == size(ncon,1)
    % ELEMENT DATA → convert to nodal
    nodal_values = zeros(n_nodes,1);
    counts = zeros(n_nodes,1);
    % Accumulate element contributions per node for averaging
    for i = 1:size(ncon,1)
        nodes = ncon(i,:);
        for j = 1:3
            n = nodes(j);
            nodal_values(n) = nodal_values(n) + values(i);
            counts(n) = counts(n) + 1;
        end
    end
    nodal_values = nodal_values ./ counts;
else
    error('Value size does not match nodes or elements');
end
% Interpolate nodal values across faces using patch with 'interp'
patch(ax, ...
    'Faces', ncon, ...
    'Vertices', [X Y], ...
    'FaceVertexCData', nodal_values, ...
    'FaceColor', 'interp', ...
    'EdgeColor', 'k');
colormap(ax, 'jet');
colorbar(ax);
title(ax, titleStr);
% Annotate global maximum and minimum on the plot
[maxVal, maxIdx] = max(nodal_values);
[minVal, minIdx] = min(nodal_values);
plot(ax, X(maxIdx), Y(maxIdx), 'ro','MarkerSize',8,'LineWidth',2);
text(ax, X(maxIdx), Y(maxIdx), sprintf('Max: %.2e', maxVal), 'Color','r');
plot(ax, X(minIdx), Y(minIdx), 'bo','MarkerSize',8,'LineWidth',2);
text(ax, X(minIdx), Y(minIdx), sprintf('Min: %.2e', minVal), 'Color','b');
hold(ax,'off');
end