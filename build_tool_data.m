function [ncon, X, Y, F, dzero, n_nodes, n_element, E, v, t, NDU] = build_tool_data()
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

% Tool boundary vertices (ordered)
base_nodes = [
    0       0;
    0.0005  0;
    0.006   0;
    0.012   0;
    0.0112 -0.004;
    0.006  -0.004;
    0.00078 -0.004
];

% Generate mesh
grid_density = 0.0005;
[ncon, X, Y] = generate_mesh(base_nodes, grid_density);
n_nodes   = length(X);
n_element = size(ncon, 1);

% Material properties
E = 210e9;
v = 0.3;
t = 1;

% Force vector
F  = zeros(2*n_nodes, 1);
Fc = 2000;
Ft = 1000;
cutting_nodes = [1 2];
for i = cutting_nodes
    F(2*i - 1) = Fc / length(cutting_nodes);
    F(2*i)     = -Ft / length(cutting_nodes);
end

% Boundary conditions - find all nodes on the clamped base by coordinate
tol         = 1e-6;
fixed_nodes = find(abs(Y - (-0.004)) < tol)';
dzero       = [];
for i = fixed_nodes
    dzero = [dzero, 2*i-1, 2*i];
end
NDU = length(dzero);
end