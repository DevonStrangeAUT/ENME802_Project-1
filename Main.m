[ncon, X, Y, F, dzero, n_nodes, n_element, E, v, t, NDU] = build_tool_data();

% Initiate matrices
KE = zeros(6);
K  = zeros(2*n_nodes);

% Main Routine
% Loop over elements: form element stiffness and assemble global stiffness
for i = 1:n_element
    % Evaluates Elemental Stiffness Matrices
    [KE] = pre_processing(i, ncon, X, Y, E, [], t, v);
    % Assembles Overall Stiffness Matrix
    n1 = ncon(i,1);
    n2 = ncon(i,2);
    n3 = ncon(i,3);
    ROC(1) = (2*n1)-1;
    ROC(2) = (2*n1);
    ROC(3) = (2*n2)-1;
    ROC(4) = (2*n2);
    ROC(5) = (2*n3)-1;
    ROC(6) = (2*n3);
    % Map element DOFs to global DOFs and add element KE
    for IX = 1:6
        MI = ROC(IX);
        for JX = 1:6
            MJ = ROC(JX);
            K(MI,MJ) = K(MI,MJ) + KE(IX,JX);
        end
    end
end

KM = K;

% Calculates Unknown Displacements, Stresses and Strains
[U, Sx, Sy, Sxy, Ex, Ey, Gxy] = post_processing(n_element, KM, NDU, dzero, F, ncon, X, Y, E, [], v);

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