% Reads External Data
array = readmatrix('data_structure.xlsx');
data = array;

n_element = data(1,1);
n_nodes = data(1,2);
E = data(1,8);
A = data(1,9);
ncon = [data(:,3),data(:,4),data(:,5)];
X = data(:,6);
Y = data(:,7);
NDU = data(1,11);
dzero = data(:,12);
F = data(:,10);
v = data(1,13);
t = data(1,14);

% Initiate Matricies
KE = zeros(6);
K = zeros(2*n_nodes);

% Main Routine
for i=1:n_element
    % Evaluates Elemental Stiffness Matricies
    [KE] = pre_processing(i,ncon,X,Y,E,A,t,v);

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

    for IX = 1:6
        MI = ROC(IX);
        for JX = 1:6
            MJ = ROC(JX);

            K(MI,MJ) = K(MI,MJ) + KE(IX,JX);
        end
    end
end

KM = K;
% Calculates Unknown Displacements and Stresses

[U, Sx, Sy, Sxy] = post_processing(n_element,KM,NDU,dzero,F,ncon,X,Y,E,A,v);

% Outputs Exported To Excel FIles

dlmwrite('Displacement.xls',U,'')
dlmwrite('StressX.xls',Sx,'')
dlmwrite('StressY.xls',Sy,'')
dlmwrite('StressXY.xls',Sxy,'')

% Plots the Initial and Final Structure

display_structure(n_element,ncon,X,Y,U);


