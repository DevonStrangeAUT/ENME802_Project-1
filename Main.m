[data, F, dzero, n_nodes, n_element] = build_tool_data();

% extract variables from data
E = data(1,8);
A = data(1,9);
ncon = data(1:n_element,3:5);
X = data(1:n_nodes,6);
Y = data(1:n_nodes,7);
NDU = data(1,11);
v = data(1,13);
t = data(1,14);

% initiate Matrices
KE = zeros(6);
K = zeros(2*n_nodes);

% main Routine
% loop over elements: form element stiffness and assemble global stiffness
for i=1:n_element
    % evaluates Elemental Stiffness Matrices
    [KE] = pre_processing(i,ncon,X,Y,E,A,t,v);

    % assembles Overall Stiffness Matrix
    n1 = ncon(i,1);
    n2 = ncon(i,2);
    n3 = ncon(i,3);

    ROC(1) = (2*n1)-1;
    ROC(2) = (2*n1);
    ROC(3) = (2*n2)-1;
    ROC(4) = (2*n2);
    ROC(5) = (2*n3)-1;
    ROC(6) = (2*n3);

    % map element DOFs to global DOFs and add element KE
    for IX = 1:6
        MI = ROC(IX);
        for JX = 1:6
            MJ = ROC(JX);
            K(MI,MJ) = K(MI,MJ) + KE(IX,JX);
        end
    end
end

KM = K;

% calculates Unknown Displacements and Stresses
[U, Sx, Sy, Sxy] = post_processing(n_element,KM,NDU,dzero,F,ncon,X,Y,E,A,v);

% Outputs Exported To Excel Files
dlmwrite('Displacement.xls', U,   '')
dlmwrite('StressX.xls',      Sx,  '')
dlmwrite('StressY.xls',      Sy,  '')
dlmwrite('StressXY.xls',     Sxy, '')
dlmwrite('StrainX.xls',      Ex,  '')
dlmwrite('StrainY.xls',      Ey,  '')
dlmwrite('StrainXY.xls',     Gxy, '')

% Plots the Initial and Final Structure
display_structure(n_element, ncon, X, Y, U, F, dzero);

