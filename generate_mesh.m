function [ncon, X, Y] = generate_mesh(base_nodes, grid_density)
% GENERATE_MESH - Generate a triangular mesh for the tool cross-section
% Input arguments:
% base_nodes    - Nx2 array of tool boundary vertex coordinates (ordered)
% grid_density  - scalar controlling interior point spacing (suggested: 0.0005)
% Output arguments:
% ncon - element connectivity matrix (n_elements x 3)
% X    - nodal x-coordinates (column vector)
% Y    - nodal y-coordinates (column vector)
% Generate refined boundary points
boundary_pts = refine_boundary(base_nodes);
bx = boundary_pts(:,1);
by = boundary_pts(:,2);
% Seed interior points using a regular grid
% Generate a grid over the bounding box then keep only points inside polygon
x_min = min(bx);  x_max = max(bx);
y_min = min(by);  y_max = max(by);
[gx, gy] = meshgrid(x_min:grid_density:x_max, y_min:grid_density:y_max);
gx = gx(:);
gy = gy(:);
% Keep only points strictly inside the tool polygon
in = inpolygon(gx, gy, bx, by);
interior_x = gx(in);
interior_y = gy(in);
% Additional interior seeding near the cutting tip for higher density
tip_x_max = 0.003;
tip_y_min = -0.004;
[gx_tip, gy_tip] = meshgrid(x_min:grid_density/2:tip_x_max, tip_y_min:grid_density/2:0);
gx_tip = gx_tip(:);
gy_tip = gy_tip(:);
in_tip = inpolygon(gx_tip, gy_tip, bx, by);
interior_x = [interior_x; gx_tip(in_tip)];
interior_y = [interior_y; gy_tip(in_tip)];
% Combine boundary and interior points
pts = [bx by; interior_x interior_y];
% Merge near-duplicate nodes by rounding
pts = unique(round(pts,12), 'rows');
X = pts(:,1);
Y = pts(:,2);
% Delaunay triangulation
tri = delaunay(X, Y);
% Filter triangles outside the tool domain
% Compute centroid of each triangle and remove those outside the polygon
n_tri = size(tri, 1);
keep  = false(n_tri, 1);
for i = 1:n_tri
    cx = mean(X(tri(i,:)));
    cy = mean(Y(tri(i,:)));
    keep(i) = inpolygon(cx, cy, bx, by);
end
ncon = tri(keep, :);
% Ensure all elements have counter-clockwise orientation
clean = [];
for i = 1:size(ncon,1)
    n = ncon(i,:);
    A = det([1 X(n(1)) Y(n(1));
        1 X(n(2)) Y(n(2));
        1 X(n(3)) Y(n(3))]) / 2;
    % remove small area elements
    if abs(A) < 1e-12
        continue
    end
    % Fix clockwise orientation
    if A < 0
        n = n([1 3 2]);
    end
    clean = [clean; n];
end
ncon = clean;