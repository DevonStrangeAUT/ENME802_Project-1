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


% Step 2: Seed interior points using a regular grid
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

% Combine boundary and interior points ---
X = [bx; interior_x];
Y = [by; interior_y];

% Delaunay triangulation ---
tri = delaunay(X, Y);

% Filter triangles outside the tool domain ---
% Compute centroid of each triangle and remove those outside the polygon
n_tri = size(tri, 1);
keep  = false(n_tri, 1);
for i = 1:n_tri
    cx = mean(X(tri(i,:)));
    cy = mean(Y(tri(i,:)));
    keep(i) = inpolygon(cx, cy, bx, by);
end
ncon = tri(keep, :);
end