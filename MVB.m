clear; clc;
nodes = [
    0       0; % cutting point 1
    0.0005  0; % cutting point 2
    0.006   0; % point 3
    0.012   0; % point 4
    0.0112 -0.004; % point 5
    0.006  -0.004; % point 6
    0.00078 -0.004 % point 7
    ];
elements = [
    1 7 2
    2 6 3
    2 7 6
    3 5 4
    3 6 5
    ];
E = 210e9;
nu = 0.3;
model = 'plane_strain';
F = zeros(2*length(nodes),1);
Fc = 1000;
Ft = 500;
cutting_nodes = [1 2];
for i = cutting_nodes
    F(2*i - 1) = Fc / length(cutting_nodes);
    F(2*i)     = -Ft / length(cutting_nodes);
end
fixed_nodes = [5 6 7];
% apply constraints later in solver

% Check element orientation by computing signed area (positive = CCW)
for i = 1:size(elements,1)
    n = elements(i,:);
    x = nodes(n,1);
    y = nodes(n,2);
    A = det([1 x(1) y(1);
        1 x(2) y(2);
        1 x(3) y(3)]);
    if A < 0
        fprintf('Element %d is clockwise (BAD)\n', i);
    else
        fprintf('Element %d is counter-clockwise (GOOD)\n', i);
    end
end