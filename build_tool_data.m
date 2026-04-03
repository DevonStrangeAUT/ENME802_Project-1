function [data, F, dzero, n_nodes, n_element] = build_tool_data()
% BUILDTOOLDATA - Create geometry, material, loads, and BCs for a 2D tool mesh
%
% Output arguments:
% data      - element/node data matrix used by downstream solver
% F         - global force vector (2*n_nodes)
% dzero     - fixed DOF indices
% n_nodes   - number of nodes
% n_element - number of elements
% tool geometry, nodal positioning and triangulation
nodes = [
    0       0;
    0.0005  0;
    0.006   0;
    0.012   0;
    0.0112 -0.004;
    0.006  -0.004;
    0.00078 -0.004
    ];
elements = [
    1 7 2
    2 6 3
    2 7 6
    3 5 4
    3 6 5
    ];
n_nodes = size(nodes,1);
n_element = size(elements,1);
X = nodes(:,1);
Y = nodes(:,2);
% material properties
E = 210e9;
v = 0.3;
t = 1; % thickness - use 1 as we assume unit thickness (this is irrelevant for 2d cases)
% test loads
F = zeros(2*n_nodes,1);
Fc = 2000;
Ft = 3000;
cutting_nodes = [1 2];
% Distribute concentrated cutting forces to specified nodes
for i = cutting_nodes
    F(2*i - 1) = Fc / length(cutting_nodes);
    F(2*i)     = -Ft / length(cutting_nodes);
end
% boundary condition setup - assume that the tool is held fixed along the bottom
fixed_nodes = [5 6 7];
dzero = [];
% Assemble fixed DOF list (both x and y for each fixed node)
for i = fixed_nodes
    dzero = [dzero, 2*i-1, 2*i];
end
NDU = length(dzero);
% area
A = 1; % placeholder
% data matrix
data = zeros(n_element,14);
data(1,1) = n_element;
data(1,2) = n_nodes;
data(1,8) = E;
data(1,9) = A;
data(1,11) = NDU;
data(1,13) = v;
data(1,14) = t;
for i = 1:n_element
    data(i,3:5) = elements(i,:);
end
for i = 1:n_nodes
    data(i,6) = X(i);
    data(i,7) = Y(i);
end

