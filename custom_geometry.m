function [base_nodes, cutting_nodes, Fc, Ft, fixed_nodes, E, v, t] = custom_geometry()
% CUSTOM_GEOMETRY - Interactive dialog for user-defined tool geometry
%
% Output arguments:
% base_nodes     - Nx2 array of user-defined boundary vertex coordinates
% cutting_nodes  - indices of nodes where cutting force is applied
% Fc             - cutting force magnitude (N)
% Ft             - thrust force magnitude (N)
% fixed_nodes    - indices of clamped (fixed) nodes
% Default geometry
% Default node coordinates used when user cancels or inputs invalid data
default_nodes = [
    0       0;
    0.0005  0;
    0.006   0;
    0.012   0;
    0.0112 -0.004;
    0.006  -0.004;
    0.00078 -0.004
    ];
% Prompt user for node count
answer = inputdlg('Number of boundary nodes:', 'Tool Geometry', 1, {'7'});
if isempty(answer)
    % User cancelled - return defaults
    base_nodes    = default_nodes;
    cutting_nodes = [1 2];
    Fc            = 2000;
    Ft            = 1000;
    fixed_nodes   = [5 6 7];
    E             = 210e9;
    v             = 0.3;
    t             = 1;
    return;
end
n_nodes = round(str2double(answer{1}));
if isnan(n_nodes) || n_nodes < 3
    warndlg('Invalid node count. Must be 3 or more. Using default geometry.', 'Warning');
    base_nodes    = default_nodes;
    cutting_nodes = [1 2];
    Fc            = 2000;
    Ft            = 1000;
    fixed_nodes   = [5 6 7];
    E             = 210e9;
    v             = 0.3;
    t             = 1;
    return;
end
% Initialize table data from defaults or zeros
if n_nodes == size(default_nodes, 1)
    init_data = num2cell(default_nodes);
else
    init_data = num2cell(zeros(n_nodes, 2));
end
% Add node index column for reference
node_labels = arrayfun(@(i) sprintf('Node %d', i), (1:n_nodes)', 'UniformOutput', false);
table_data  = [node_labels, init_data];
% Present editable table for node coordinates
fig = uifigure('Name', 'Define Tool Geometry', ...
    'Position', [200 200 480 60 + n_nodes*30], ...
    'Resize', 'off');
uilabel(fig, ...
    'Text', 'Edit node coordinates then close this window to continue.', ...
    'Position', [10 fig.Position(4)-30 460 22], ...
    'FontSize', 11);
tbl = uitable(fig, ...
    'Data', table_data, ...
    'ColumnName', {'Node', 'x (m)', 'y (m)'}, ...
    'ColumnEditable', [false true true], ...
    'ColumnWidth', {80 160 160}, ...
    'Position', [10 40 460 fig.Position(4)-70], ...
    'FontSize', 11);
% Confirm button
btn = uibutton(fig, ...
    'Text', 'Confirm Geometry', ...
    'Position', [160 8 160 28], ...
    'ButtonPushedFcn', @(~,~) uiresume(fig));
uiwait(fig);
% Extract data after user confirms
if ~isvalid(fig)
    % Window was closed without confirming - use defaults
    base_nodes    = default_nodes;
    cutting_nodes = [1 2];
    Fc            = 2000;
    Ft            = 1000;
    fixed_nodes   = [5 6 7];
    E             = 210e9;
    v             = 0.3;
    t             = 1;
    return;
end
raw_data   = tbl.Data;
base_nodes = zeros(n_nodes, 2);
% Parse table entries to numeric x,y per row
% Convert string entries to numeric values robustly
for i = 1:n_nodes
    x_val = raw_data{i, 2};
    y_val = raw_data{i, 3};
    if ischar(x_val) || isstring(x_val)
        x_val = str2double(x_val);
    end
    if ischar(y_val) || isstring(y_val)
        y_val = str2double(y_val);
    end
    base_nodes(i, 1) = x_val;
    base_nodes(i, 2) = y_val;
end
close(fig);
% Validate - check for any NaN entries
% If any invalid coordinates, revert to defaults
if any(isnan(base_nodes(:)))
    warndlg('Some coordinates are invalid. Using default geometry.', 'Warning');
    base_nodes    = default_nodes;
    cutting_nodes = [1 2];
    Fc            = 2000;
    Ft            = 1000;
    fixed_nodes   = [5 6 7];
    E             = 210e9;
    v             = 0.3;
    t             = 1;
    return;
end
% Ask user for cutting force indices and magnitudes
node_list = strjoin(arrayfun(@num2str, 1:n_nodes, 'UniformOutput', false), ', ');
prompt    = {sprintf('Cutting force node indices (e.g. 1, 2)\nAvailable nodes: %s', node_list), ...
    'Cutting force Fc (N):', ...
    'Thrust force Ft (N):'};
defaults  = {'1, 2', '2000', '1000'};
force_ans = inputdlg(prompt, 'Apply Cutting Forces', 1, defaults);
if isempty(force_ans)
    cutting_nodes = [1 2];
    Fc = 2000;
    Ft = 1000;
else
    cutting_nodes = str2num(force_ans{1});
    Fc            = str2double(force_ans{2});
    Ft            = str2double(force_ans{3});
    % Fall back to defaults if invalid
    if isempty(cutting_nodes) || isnan(Fc) || isnan(Ft)
        warndlg('Invalid force inputs. Using defaults.', 'Warning');
        cutting_nodes = [1 2];
        Fc = 2000;
        Ft = 1000;
    end
end
mat_ans = inputdlg( ...
    {'Young''s Modulus E (Pa):', ...
    'Poisson''s Ratio v:', ...
    'Thickness t (m):'}, ...
    'Material Properties', 1, ...
    {'210e9', '0.3', '1'});
if isempty(mat_ans)
    E = 210e9;
    v = 0.3;
    t = 1;
else
    E = str2double(mat_ans{1});
    v = str2double(mat_ans{2});
    t = str2double(mat_ans{3});
    if isnan(E) || isnan(v) || isnan(t)
        warndlg('Invalid material inputs. Using defaults.', 'Warning');
        E = 210e9;
        v = 0.3;
        t = 1;
    end
end
% Ask user for clamped node indices
fixed_ans = inputdlg( ...
    sprintf('Clamped node indices (e.g. 5, 6, 7)\nAvailable nodes: %s', node_list), ...
    'Boundary Conditions', 1, {'5, 6, 7'});
if isempty(fixed_ans)
    fixed_nodes = [5 6 7];
else
    fixed_nodes = str2num(fixed_ans{1});
    if isempty(fixed_nodes)
        warndlg('Invalid fixed node input. Using default nodes 5, 6, 7.', 'Warning');
        fixed_nodes = [5 6 7];
    end
end
end