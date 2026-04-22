function [KE] = pre_processing(i,ncon,X,Y,E,~,t,v)
% PRE_PROCESSING - Compute element stiffness matrix for a triangular element
%
% Input arguments:
% i    - element index into connectivity ncon
% ncon - connectivity matrix (elements x 3 node indices)
% X,Y  - nodal coordinate vectors
% E    - Young's modulus
% ~    - unused input (placeholder)
% t    - element thickness
% v    - Poisson's ratio
%
% Output arguments:
% KE   - 6x6 element stiffness matrix
global KE;
% Extract node indices and coordinates for element i
n1 = ncon(i,1);
n2 = ncon(i,2);
n3 = ncon(i,3);
x1 = X(n1);
x2 = X(n2);
x3 = X(n3);
y1 = Y(n1);
y2 = Y(n2);
y3 = Y(n3);
% Edge coefficients for B matrix (from nodal coordinates)
b1 = (y2 - y3);
b2 = (y3 - y1);
b3 = (y1 - y2);
c1 = (x3 - x2);
c2 = (x1 - x3);
c3 = (x2 - x1);
% Compute triangle area (signed)
A = 0.5 * det([1 x1 y1;
    1 x2 y2;
    1 x3 y3]);
% Construct strain-displacement matrix B (constant for linear triangle)
B = (1/(2*A))*[b1 0 b2 0 b3 0
    0 c1 0 c2 0 c3
    c1 b1 c2 b2 c3 b3];
% Plane strain constitutive matrix D
D = (E/((1+v)*(1-2*v))) * [
    1-v   v     0
    v   1-v     0
    0     0  (1-2*v)/2
    ];
% Assemble element stiffness matrix
KE = t*A*(B.')*D*B;