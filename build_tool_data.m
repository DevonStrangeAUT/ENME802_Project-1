function [ncon, X, Y, F, dzero, n_nodes, n_element, E, v, t, NDU] = build_tool_data(grid_density, varargin)
% BUILD_TOOL_DATA - Generate geometry, mesh, material properties, loads and BCs
%
% Output arguments:
% ncon      - element connectivity matrix (n_element x 3)
% X, Y      - nodal coordinates (column vectors)
% F         - global force vector (2*n_nodes x 1)
% dzero     - constrained DOF indices
% n_nodes   - number of nodes
% n_element - number of elements
% E         - Young's modulus (Pa)
% v         - Poisson's ratio
% t         - thickness
% NDU       - number of constrained DOFs
% Default geometry and loading
default_nodes = [
    0       0;
    0.0005  0;
    0.006   0;
    0.012   0;
    0.0112 -0.004;
    0.006  -0.004;
    0.00078 -0.004
    ];
default_cutting = [1 2];
default_Fc      = 2000;
default_Ft      = 1000;
default_fixed   = [];
% Accept overrides from custom_geometry if provided
if nargin >= 2 && ~isempty(varargin)
    base_nodes    = varargin{1};
    cutting_nodes = varargin{2};
    Fc            = varargin{3};
    Ft            = varargin{4};
    fixed_nodes   = varargin{5};
else
    base_nodes    = default_nodes;
    cutting_nodes = default_cutting;
    Fc            = default_Fc;
    Ft            = default_Ft;
    fixed_nodes   = default_fixed;
end
% Generate mesh
% Precompute mesh from polygon vertices using specified grid density
[ncon, X, Y] = generate_mesh(base_nodes, grid_density);
n_nodes   = length(X);
n_element = size(ncon, 1);
% Material properties
% Set linear elastic material properties and plate thickness
E = 210e9;
v = 0.3;
t = 1;
F = zeros(2*n_nodes, 1);
% Find cutting tip nodes by proximity to original vertex coordinates
% rather than relying on mesh node indices which change after generation
% Resolve cutting tip mesh node indices by nearest mesh node
tip_coords = base_nodes(cutting_nodes, :);
resolved_cutting_nodes = zeros(1, length(cutting_nodes));
for k = 1:length(cutting_nodes)
    dist = sqrt((X - tip_coords(k,1)).^2 + (Y - tip_coords(k,2)).^2);
    [~, resolved_cutting_nodes(k)] = min(dist);
end
% Distribute specified cutting and traction forces across tip nodes
for i = resolved_cutting_nodes
    F(2*i - 1) = Fc / length(resolved_cutting_nodes);
    F(2*i)     = -Ft / length(resolved_cutting_nodes);
end
% Boundary conditions
% If fixed_nodes not explicitly provided, find all nodes at minimum y
% When unspecified, fix nodes at lowest Y (support)
if isempty(fixed_nodes)
    tol         = 1e-6;
    fixed_nodes = find(abs(Y - min(Y)) < tol)';
else
    % Get the y-coordinates of the specified fixed vertices
    % then find ALL mesh nodes at those y levels
    % Map vertex fixed nodes to mesh nodes by Y coordinate
    fixed_y_coords = base_nodes(fixed_nodes, 2);
    tol = 1e-6;
    resolved = [];
    for k = 1:length(fixed_y_coords)
        matches = find(abs(Y - fixed_y_coords(k)) < tol)';
        resolved = [resolved, matches];
    end
    fixed_nodes = unique(resolved);
end
% Assemble constrained DOF indices (ux,uy) for each fixed node
dzero = [];
for i = fixed_nodes
    dzero = [dzero, 2*i-1, 2*i];
end
NDU = length(dzero);
end