function nodes = refine_boundary(base_nodes)
% REFINE_BOUNDARY - Subdivide polygon edges into specified segment counts
%
% Input arguments:
% base_nodes - Nx2 array of polygon vertex coordinates (ordered)
%
% Output arguments:
% nodes      - Mx2 array of refined boundary points (closed polygon)
divisions = [10, 20, 20, 25, 20, 20, 25];
nodes = [];
for i = 1:length(divisions)
    p1 = base_nodes(i,:);

    if i < length(base_nodes)
        p2 = base_nodes(i+1,:);
    else
        p2 = base_nodes(1,:); % wrap around
    end
    ndiv = divisions(i);
    if i == length(divisions)
        % LAST EDGE → include endpoint
        j_range = 0:ndiv;
    else
        % ALL OTHER EDGES → exclude endpoint
        j_range = 0:ndiv-1;
    end
    % Linear-interpolate along the edge according to t
    for j = j_range
        t = j / ndiv;
        pt = (1-t)*p1 + t*p2;
        nodes = [nodes; pt];
    end
end
end