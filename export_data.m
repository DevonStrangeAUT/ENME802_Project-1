function export_data(filename, app)
    %EXPORT_DATA - Export model inputs and results to a single Excel sheet
    %
    % Input arguments:
    % filename - output Excel filename
    % app      - data from UI
    % Export all model inputs and solved results in Excel sheet
    if nargin < 1 || isempty(filename)
        % Set default filename if not provided
        filename = 'FEA_results.xlsx';
    end
    % Check analysis exists
    if isempty(app.U)
        uialert(app.UIFigure,'Run analysis before exporting results.','No Results');
        return;
    end
    % Copy app data into local arrays (so that if anything is changed it dosent change it for the ui file values)
    X     = app.X(:);
    Y     = app.Y(:);
    ncon  = app.ncon;
    F     = app.F(:);
    dzero = app.dzero(:);
    U   = app.U(:);
    Sx  = app.Sx(:);
    Sy  = app.Sy(:);
    Sxy = app.Sxy(:);
    Ex  = app.Ex(:);
    Ey  = app.Ey(:);
    Gxy = app.Gxy(:);
    E = app.E;
    v = app.v;
    t = app.t;
    n_nodes   = length(X);
    n_element = size(ncon,1);

    if isfile(filename)
        % Remove existing file to avoid write conflicts
        delete(filename);
    end
    % Output summary block to top of xlsx
    summary = {
        'FEA Data',''
        'Export Date', datetime('now')
        'Nodes', n_nodes
        'Elements', n_element
        'Youngs Modulus (Pa)', E
        'Poissons Ratio', v
        'Thickness (m)', t
        'Constrained DOFs', length(dzero)
        };
    writecell(summary,filename,'Sheet','Results','Range','A1');
    % Write nodal data to xlsx
    % Assemble and write node table
    Node = (1:n_nodes).';
    Ux = U(1:2:end);
    Uy = U(2:2:end);
    Fx = F(1:2:end);
    Fy = F(2:2:end);
    Fixed = false(n_nodes,1);
    % Map constrained DOF indices to node indices and mark as fixed
    Fixed(unique(ceil(dzero/2))) = true;
    NodeTable = table(Node,X,Y,Fx,Fy,Ux,Uy,Fixed,...
        'VariableNames',{'Node','X','Y','Fx','Fy','Ux','Uy','Fixed'});
    writetable(NodeTable,filename,'Sheet','Results','Range','A12');
    % Write elements to xlsx
    % Assemble and write element table
    Elem = (1:n_element).';
    n1 = ncon(:,1);
    n2 = ncon(:,2);
    n3 = ncon(:,3);
    ElemTable = table(Elem,n1,n2,n3,Sx,Sy,Sxy,Ex,Ey,Gxy,...
        'VariableNames',{'Element','Node1','Node2','Node3',...
        'StressX','StressY','StressXY','StrainX','StrainY','StrainXY'});
    startRow = n_nodes + 16;
    % Compute starting Excel row for element table after node table
    rangeStr = sprintf('A%d',startRow);
    writetable(ElemTable,filename,'Sheet','Results','Range',rangeStr);
    % Write statistics to xlsx
    % Write basic statistics for key fields
    statsRow = startRow + n_element + 4;
    statsRange = sprintf('A%d',statsRow);
    stats = {
        'Statistics','','',''
        'Quantity','Min','Max','Mean'
        'Ux',min(Ux),max(Ux),mean(Ux)
        'Uy',min(Uy),max(Uy),mean(Uy)
        'Sx',min(Sx),max(Sx),mean(Sx)
        'Sy',min(Sy),max(Sy),mean(Sy)
        'Sxy',min(Sxy),max(Sxy),mean(Sxy)
        'Ex',min(Ex),max(Ex),mean(Ex)
        'Ey',min(Ey),max(Ey),mean(Ey)
        'Gxy',min(Gxy),max(Gxy),mean(Gxy)
        };
    writecell(stats,filename,'Sheet','Results','Range',statsRange);
    % Notify user of successful export
    uialert(app.UIFigure,...
        ['Data exported to ',filename],...
        'Export Complete');
end