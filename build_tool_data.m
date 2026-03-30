function [data, F, dzero, n_nodes, n_element] = build_tool_data()

% ===== TOOL GEOMETRY =====

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

% ===== MATERIAL =====
E = 210e9;
v = 0.3;
t = 1; % thickness

% ===== LOAD VECTOR =====
F = zeros(2*n_nodes,1);

Fc = 1000;
Ft = 500;

cutting_nodes = [1 2];

for i = cutting_nodes
    F(2*i - 1) = Fc / length(cutting_nodes);
    F(2*i)     = -Ft / length(cutting_nodes);
end

% ===== BOUNDARY CONDITIONS =====
fixed_nodes = [5 6 7];

dzero = [];
for i = fixed_nodes
    dzero = [dzero, 2*i-1, 2*i];
end

NDU = length(dzero);

% ===== AREA (temporary, will fix later properly) =====
A = 1; % placeholder (we'll fix this next step)

% ===== BUILD DATA MATRIX =====
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


