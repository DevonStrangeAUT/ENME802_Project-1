function [U,Sx,Sy,Sxy] = run_FEA(ncon,X,Y,E,v,t,F,dzero,NDU)
% RUN_FEA - Assemble global stiffness and run post-processing
%
% Input arguments:
% ncon   - element connectivity (n_element x nodes_per_element)
% X,Y    - nodal coordinates
% E,v,t  - material and thickness parameters
% F      - global force vector
% dzero  - prescribed displacements/conditions
% NDU    - number of degrees of freedom
%
% Output arguments:
% U      - displacement solution
% Sx,Sy  - stress components
% Sxy    - shear stress component

n_nodes = length(X);
n_element = size(ncon,1);
K = zeros(2*n_nodes);
% === Assemble stiffness ===
% Loop over elements, compute element stiffness and scatter into K
for i = 1:n_element
    KE = pre_processing(i,ncon,X,Y,E,[],t,v);
    n1 = ncon(i,1);
    n2 = ncon(i,2);
    n3 = ncon(i,3);
    ROC = [2*n1-1 2*n1 2*n2-1 2*n2 2*n3-1 2*n3];
    for IX = 1:6
        for JX = 1:6
            K(ROC(IX),ROC(JX)) = K(ROC(IX),ROC(JX)) + KE(IX,JX);
        end
    end
end
% === Solve ===
% Apply boundary conditions and compute displacements and stresses
[U,Sx,Sy,Sxy] = post_processing(...
    n_element,K,NDU,dzero,F,ncon,X,Y,E,[],v);
end