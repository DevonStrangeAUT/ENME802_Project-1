classdef GUIforFEA_merged < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        % Save/Restore (from Ryan's)
        RestoreSaveButton               matlab.ui.control.Button
        % Status + Reset (from yours)
        StatusLabel                     matlab.ui.control.Label
        ResetButton                     matlab.ui.control.Button
        % Export
        ExportResultsButton             matlab.ui.control.Button
        % Material input fields
        tEditField                      matlab.ui.control.NumericEditField
        tEditFieldLabel                 matlab.ui.control.Label
        vEditField                      matlab.ui.control.NumericEditField
        vEditFieldLabel                 matlab.ui.control.Label
        EEditField                      matlab.ui.control.NumericEditField
        EEditFieldLabel                 matlab.ui.control.Label
        FtEditField                     matlab.ui.control.NumericEditField
        FtEditFieldLabel                matlab.ui.control.Label
        FcEditField                     matlab.ui.control.NumericEditField
        FcEditFieldLabel                matlab.ui.control.Label
        % Result selection
        ResultDropDown                  matlab.ui.control.DropDown
        ResultTypeDropDownLabel         matlab.ui.control.Label
        % Geometry / mesh controls
        SelectBoundaryConditionsButton  matlab.ui.control.Button
        MeshSlider                      matlab.ui.control.Slider
        MeshSliderLabel                 matlab.ui.control.Label
        GeometryDropDown                matlab.ui.control.DropDown
        GeometryDropDownLabel           matlab.ui.control.Label
        DrawGeometryButton              matlab.ui.control.Button
        ShowResultsButton               matlab.ui.control.Button
        DisplayDeformedStructureButton  matlab.ui.control.Button
        RunAnalysisButton               matlab.ui.control.Button
        ShowMeshInfoButton              matlab.ui.control.Button
        GenerateMeshButton              matlab.ui.control.Button
        LoadModelButton                 matlab.ui.control.Button
        % Axes
        UIAxes_2                        matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    properties (Access = public)

        n_element
        n_nodes
        E
        ncon
        X
        Y
        NDU
        dzero
        F
        v
        t
        K
        U
        Sx
        Sy
        Sxy
        Ex
        Ey
        Gxy
        Fc
        Ft
        manualX         % declared properly (from your version)
        manualY
        inputs          % for save/restore (from Ryan's)

        geometryMode    % 'excel' or 'manual'
        selectedNodes   % for BC selection
        meshDensity     % scalar

    end

    methods (Access = private)

        function ResultDropDownValueChanged(app)

            switch app.ResultDropDown.Value

                case 'Deformation'
                    plot_deformed(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, ...
                        app.U, app.F, app.dzero);

                case 'Sx Stress'
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, ...
                        app.Sx, 'Sx Stress');

                case 'Sy Stress'
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, ...
                        app.Sy, 'Sy Stress');

                case 'Sxy Stress'
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, ...
                        app.Sxy, 'Sxy Stress');

                % --- Extended result types from your version ---
                case 'Ex Strain'
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, app.Ex, 'Ex Strain');

                case 'Ey Strain'
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, app.Ey, 'Ey Strain');

                case 'Gxy Strain'
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, app.Gxy, 'Gxy Strain');

                case 'Total Displacement'
                    Ux = app.U(1:2:end);
                    Uy = app.U(2:2:end);
                    Umag = sqrt(Ux.^2 + Uy.^2);
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, Umag, '|U|');

                case 'Von Mises'
                    vm = sqrt(app.Sx.^2 + app.Sy.^2 - app.Sx.*app.Sy + 3*app.Sxy.^2);
                    plot_contour(app.UIAxes_2, ...
                        app.ncon, app.X, app.Y, vm, 'Von Mises Stress');
            end

        end

        function GenerateMesh(app)

            if strcmp(app.GeometryDropDown.Value,'Manual')

                if isempty(app.manualX)
                    error('No manual geometry defined');
                end

                tri = delaunay(app.manualX, app.manualY);

                app.ncon = tri;
                app.X    = app.manualX;
                app.Y    = app.manualY;

                app.n_nodes   = length(app.X);
                app.n_element = size(tri,1);

            end
        end

    end

    % Callbacks
    methods (Access = private)

        % Startup
        function startupFcn2(app)

            app.geometryMode  = 'excel';
            app.meshDensity   = app.MeshSlider.Value;
            app.selectedNodes = [];

            app.GeometryDropDown.Items = {'Excel','Manual'};
            app.GeometryDropDown.Value = 'Excel';

            % Extended result list (from your version)
            app.ResultDropDown.Items = { ...
                'Deformation', 'Sx Stress', 'Sy Stress', 'Sxy Stress', ...
                'Ex Strain', 'Ey Strain', 'Gxy Strain', ...
                'Total Displacement', 'Von Mises'};
            app.ResultDropDown.Value = 'Deformation';

            % Auto-load saved inputs on startup (from Ryan's)
            app.loadSavedInputs();

        end

        % Shared helper: load app_inputs.mat into fields (from Ryan's)
        function loadSavedInputs(app)
            filename = 'app_inputs.mat';
            if isfile(filename)
                loadedStruct = load(filename);
                app.inputs = loadedStruct;
                app.Fc = app.inputs.Fc;
                app.Ft = app.inputs.Ft;
                app.E  = app.inputs.E;
                app.v  = app.inputs.v;
                app.t  = app.inputs.t;
                app.FcEditField.Value = app.Fc;
                app.FtEditField.Value = app.Ft;
                app.EEditField.Value  = app.E;
                app.vEditField.Value  = app.v;
                app.tEditField.Value  = app.t;
            end
        end

        % Load Model button — passes material params like Ryan's build_tool_data call,
        % but also retrieves E/v/t from the function return like your version.
        % If build_tool_data accepts material params use Ryan's signature;
        % if it returns them use yours. Adjust the line below to match your function.
        function LoadModelButtonPushed(app, event)

            % Read current field values before loading
            app.Fc = app.FcEditField.Value;
            app.Ft = app.FtEditField.Value;
            app.E  = app.EEditField.Value;
            app.v  = app.vEditField.Value;
            app.t  = app.tEditField.Value;

            % Call build_tool_data — choose ONE of the two signatures below
            % depending on how your function is written:
            %
            % Option A (Ryan's style — pass material params in, get geometry out):
            %   [app.ncon, app.X, app.Y, app.F, app.dzero, ...
            %       app.n_nodes, app.n_element, app.NDU] = ...
            %       build_tool_data(app.Fc, app.Ft, app.E, app.v, app.t);
            %
            % Option B (your style — function returns material params too):
            %   [app.ncon, app.X, app.Y, app.F, app.dzero, ...
            %       app.n_nodes, app.n_element, ...
            %       app.E, app.v, app.t, app.NDU] = build_tool_data();

            % --- DEFAULT: Option A (edit if needed) ---
            [app.ncon, app.X, app.Y, app.F, app.dzero, ...
                app.n_nodes, app.n_element, app.NDU] = ...
                build_tool_data(app.Fc, app.Ft, app.E, app.v, app.t);

            % Sync fields back in case build_tool_data modified them
            app.FcEditField.Value = app.Fc;
            app.FtEditField.Value = app.Ft;
            app.EEditField.Value  = app.E;
            app.vEditField.Value  = app.v;
            app.tEditField.Value  = app.t;

            uialert(app.UIFigure, 'Data loaded successfully', 'Success');
            app.StatusLabel.Text = 'Model Loaded';
        end

        % Generate Mesh
        function GenerateMeshButtonPushed(app, event)

            cla(app.UIAxes)

            patch(app.UIAxes, 'Faces', app.ncon, 'Vertices', [app.X app.Y], ...
                'FaceColor', 'none', 'EdgeColor', 'k');

            axis(app.UIAxes, 'equal')
            grid(app.UIAxes, 'on')
            title(app.UIAxes, 'Generated Mesh')
            app.StatusLabel.Text = 'Mesh displayed';
            drawnow;

        end

        % Show Mesh Info
        function ShowMeshInfoButtonPushed(app, event)

            if isempty(app.ncon)
                uialert(app.UIFigure, 'Load or create a model first.', 'No Model');
                return;
            end

            msg = sprintf([ ...
                'Nodes: %d\n' ...
                'Elements: %d\n' ...
                'DOFs: %d\n' ...
                'Young''s Modulus: %.3e Pa\n' ...
                'Poisson Ratio: %.2f'], ...
                app.n_nodes, ...
                app.n_element, ...
                2 * app.n_nodes, ...
                app.E, ...
                app.v);

            uialert(app.UIFigure, msg, 'Mesh Information');

        end

        % Run Analysis
        function RunAnalysisButtonPushed(app, event)

            if isempty(app.ncon)
                uialert(app.UIFigure, 'Load or create a model first.', 'No Model');
                return;
            end

            app.StatusLabel.Text = 'Solving...';
            drawnow;

            [app.U, app.Sx, app.Sy, app.Sxy, app.Ex, app.Ey, app.Gxy] = run_FEA( ...
                app.ncon, app.X, app.Y, ...
                app.E, app.v, app.t, ...
                app.F, app.dzero, app.NDU);

            msg = sprintf('Max U = %.3e m\nMax Sx = %.3e Pa', ...
                max(abs(app.U)), max(abs(app.Sx)));
            uialert(app.UIFigure, msg, 'Analysis Complete');

            ResultDropDownValueChanged(app)

            app.StatusLabel.Text = 'Complete';

        end

        % Display Deformed Structure
        function DisplayDeformedStructureButtonPushed(app, event)

            plot_deformed(app.UIAxes_2, ...
                app.ncon, app.X, app.Y, ...
                app.U, app.F, app.dzero);

        end

        % Show Results
        function ShowResultsButtonPushed(app, event)
            ResultDropDownValueChanged(app);
        end

        % Draw Geometry
        function DrawGeometryButtonPushed(app, event)
            cla(app.UIAxes);
            hold(app.UIAxes, 'on');
            title(app.UIAxes, 'Click nodes. Press Enter when done');

            [x, y] = ginput;

            app.manualX = x;
            app.manualY = y;

            tri = delaunay(x, y);

            app.ncon      = tri;
            app.X         = x;
            app.Y         = y;
            app.n_nodes   = length(x);
            app.n_element = size(tri, 1);

            triplot(tri, x, y, 'k', 'Parent', app.UIAxes);
            plot(app.UIAxes, x, y, 'ro');
        end

        % Select Boundary Conditions
        function SelectBoundaryConditionsButtonPushed(app, event)
            title(app.UIAxes, 'Click nodes to fix');

            [x_click, y_click] = ginput;

            selected = [];
            for k = 1:length(x_click)
                dist = sqrt((app.X - x_click(k)).^2 + (app.Y - y_click(k)).^2);
                [~, idx] = min(dist);
                selected(end+1) = idx;
            end

            app.selectedNodes = unique(selected);

            scatter(app.UIAxes, app.X(app.selectedNodes), ...
                app.Y(app.selectedNodes), 80, 'filled', 'r');
        end

        % Result dropdown changed
        function ResultDropDownValueChanged2(app, event)
            if ~isempty(app.U)
                ResultDropDownValueChanged(app);
            end
        end

        % Material field callbacks — all properly capture values (your version)
        function EEditFieldValueChanged(app, event)
            app.E = app.EEditField.Value;
        end

        function vEditFieldValueChanged(app, event)
            app.v = app.vEditField.Value;
        end

        function tEditFieldValueChanged(app, event)
            app.t = app.tEditField.Value;
        end

        function FcEditFieldValueChanged(app, event)
            app.Fc = app.FcEditField.Value;
        end

        function FtEditFieldValueChanged(app, event)
            app.Ft = app.FtEditField.Value;
        end

        % Export / Save inputs (Ryan's save logic, your export_data call)
        function ExportResultsButtonPushed(app, event)

            % Save material inputs to .mat (Ryan's)
            app.inputs.Fc = app.FcEditField.Value;
            app.inputs.Ft = app.FtEditField.Value;
            app.inputs.E  = app.EEditField.Value;
            app.inputs.v  = app.vEditField.Value;
            app.inputs.t  = app.tEditField.Value;

            dataToSave = app.inputs;
            save('app_inputs.mat', '-struct', 'dataToSave', '-mat');

            % Export results to Excel (your version)
            export_data('FEA_Results.xlsx', app);

            uialert(app.UIFigure, 'Inputs saved and results exported.', 'Success');
            app.StatusLabel.Text = 'Exported';
        end

        % Restore Save (Ryan's)
        function RestoreSaveButtonPushed(app, event)
            app.loadSavedInputs();
            app.StatusLabel.Text = 'Inputs restored';
        end

        % Reset (your version)
        function ResetButtonPushed(app, event)
            cla(app.UIAxes);
            cla(app.UIAxes_2);

            app.ncon      = [];
            app.X         = [];
            app.Y         = [];
            app.n_nodes   = [];
            app.n_element = [];

            app.U   = [];
            app.Sx  = [];
            app.Sy  = [];
            app.Sxy = [];
            app.Ex  = [];
            app.Ey  = [];
            app.Gxy = [];

            app.selectedNodes = [];
            app.ResultDropDown.Value = 'Deformation';
            app.StatusLabel.Text = 'Reset Complete';
        end

    end

    % Component initialization
    methods (Access = private)

        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.902 0.902 0.902];
            app.UIFigure.Position = [100 100 998 635];
            app.UIFigure.Name = 'FEA Tool';

            % --- Axes ---
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Tool Geometry & Mesh Generation')
            app.UIAxes.FontWeight = 'bold';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [13 1 483 322];

            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Contour Plot')
            app.UIAxes_2.FontWeight = 'bold';
            app.UIAxes_2.XTick = [];
            app.UIAxes_2.YTick = [];
            app.UIAxes_2.Position = [497 1 484 314];

            % --- Left column buttons (workflow order) ---
            app.LoadModelButton = uibutton(app.UIFigure, 'push');
            app.LoadModelButton.ButtonPushedFcn = createCallbackFcn(app, @LoadModelButtonPushed, true);
            app.LoadModelButton.BackgroundColor = [0 0 0];
            app.LoadModelButton.FontColor = [1 1 1];
            app.LoadModelButton.Position = [21 586 100 25];
            app.LoadModelButton.Text = 'Load Model';

            app.GenerateMeshButton = uibutton(app.UIFigure, 'push');
            app.GenerateMeshButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateMeshButtonPushed, true);
            app.GenerateMeshButton.BackgroundColor = [0 0 0];
            app.GenerateMeshButton.FontColor = [1 1 1];
            app.GenerateMeshButton.Position = [21 549 115 25];
            app.GenerateMeshButton.Text = 'Generate Mesh';

            app.ShowMeshInfoButton = uibutton(app.UIFigure, 'push');
            app.ShowMeshInfoButton.ButtonPushedFcn = createCallbackFcn(app, @ShowMeshInfoButtonPushed, true);
            app.ShowMeshInfoButton.BackgroundColor = [0 0 0];
            app.ShowMeshInfoButton.FontColor = [1 1 1];
            app.ShowMeshInfoButton.Position = [21 514 121 25];
            app.ShowMeshInfoButton.Text = 'Show Mesh Info';

            app.RunAnalysisButton = uibutton(app.UIFigure, 'push');
            app.RunAnalysisButton.ButtonPushedFcn = createCallbackFcn(app, @RunAnalysisButtonPushed, true);
            app.RunAnalysisButton.BackgroundColor = [0 0 0];
            app.RunAnalysisButton.FontColor = [1 1 1];
            app.RunAnalysisButton.Position = [21 481 103 25];
            app.RunAnalysisButton.Text = 'Run Analysis';

            app.ShowResultsButton = uibutton(app.UIFigure, 'push');
            app.ShowResultsButton.ButtonPushedFcn = createCallbackFcn(app, @ShowResultsButtonPushed, true);
            app.ShowResultsButton.BackgroundColor = [0 0 0];
            app.ShowResultsButton.FontColor = [1 1 1];
            app.ShowResultsButton.Position = [21 449 106 25];
            app.ShowResultsButton.Text = 'Show Results';

            app.ExportResultsButton = uibutton(app.UIFigure, 'push');
            app.ExportResultsButton.ButtonPushedFcn = createCallbackFcn(app, @ExportResultsButtonPushed, true);
            app.ExportResultsButton.BackgroundColor = [0 0 0];
            app.ExportResultsButton.FontColor = [1 1 1];
            app.ExportResultsButton.Position = [21 414 106 25];
            app.ExportResultsButton.Text = 'Export / Save';

            app.RestoreSaveButton = uibutton(app.UIFigure, 'push');
            app.RestoreSaveButton.ButtonPushedFcn = createCallbackFcn(app, @RestoreSaveButtonPushed, true);
            app.RestoreSaveButton.BackgroundColor = [0 0 0];
            app.RestoreSaveButton.FontColor = [1 1 1];
            app.RestoreSaveButton.Position = [21 381 106 25];
            app.RestoreSaveButton.Text = 'Restore Save';

            % --- Result type dropdown ---
            app.ResultTypeDropDownLabel = uilabel(app.UIFigure);
            app.ResultTypeDropDownLabel.BackgroundColor = [0 0 0];
            app.ResultTypeDropDownLabel.HorizontalAlignment = 'right';
            app.ResultTypeDropDownLabel.FontColor = [1 1 1];
            app.ResultTypeDropDownLabel.Position = [223 449 65 33];
            app.ResultTypeDropDownLabel.Text = 'Result Type';

            app.ResultDropDown = uidropdown(app.UIFigure);
            app.ResultDropDown.Items = {'Deformation', 'Sx Stress', 'Sy Stress', 'Sxy Stress', ...
                'Ex Strain', 'Ey Strain', 'Gxy Strain', 'Total Displacement', 'Von Mises'};
            app.ResultDropDown.ValueChangedFcn = createCallbackFcn(app, @ResultDropDownValueChanged2, true);
            app.ResultDropDown.FontColor = [1 1 1];
            app.ResultDropDown.BackgroundColor = [0 0 0];
            app.ResultDropDown.Position = [303 454 150 22];
            app.ResultDropDown.Value = 'Deformation';

            % --- Material input fields (Fc, Ft, E, v, t) ---
            app.FcEditFieldLabel = uilabel(app.UIFigure);
            app.FcEditFieldLabel.HorizontalAlignment = 'right';
            app.FcEditFieldLabel.Position = [471 525 25 22];
            app.FcEditFieldLabel.Text = 'Fc';

            app.FcEditField = uieditfield(app.UIFigure, 'numeric');
            app.FcEditField.ValueChangedFcn = createCallbackFcn(app, @FcEditFieldValueChanged, true);
            app.FcEditField.Position = [511 525 60 22];

            app.FtEditFieldLabel = uilabel(app.UIFigure);
            app.FtEditFieldLabel.HorizontalAlignment = 'right';
            app.FtEditFieldLabel.Position = [585 525 25 22];
            app.FtEditFieldLabel.Text = 'Ft';

            app.FtEditField = uieditfield(app.UIFigure, 'numeric');
            app.FtEditField.ValueChangedFcn = createCallbackFcn(app, @FtEditFieldValueChanged, true);
            app.FtEditField.Position = [625 525 60 22];

            app.EEditFieldLabel = uilabel(app.UIFigure);
            app.EEditFieldLabel.HorizontalAlignment = 'right';
            app.EEditFieldLabel.Position = [406 490 25 22];
            app.EEditFieldLabel.Text = 'E';

            app.EEditField = uieditfield(app.UIFigure, 'numeric');
            app.EEditField.ValueChangedFcn = createCallbackFcn(app, @EEditFieldValueChanged, true);
            app.EEditField.Position = [446 490 60 22];

            app.vEditFieldLabel = uilabel(app.UIFigure);
            app.vEditFieldLabel.HorizontalAlignment = 'right';
            app.vEditFieldLabel.Position = [519 490 25 22];
            app.vEditFieldLabel.Text = 'v';

            app.vEditField = uieditfield(app.UIFigure, 'numeric');
            app.vEditField.ValueChangedFcn = createCallbackFcn(app, @vEditFieldValueChanged, true);
            app.vEditField.Position = [559 490 60 22];

            app.tEditFieldLabel = uilabel(app.UIFigure);
            app.tEditFieldLabel.HorizontalAlignment = 'right';
            app.tEditFieldLabel.Position = [632 490 25 22];
            app.tEditFieldLabel.Text = 't';

            app.tEditField = uieditfield(app.UIFigure, 'numeric');
            app.tEditField.ValueChangedFcn = createCallbackFcn(app, @tEditFieldValueChanged, true);
            app.tEditField.Position = [662 490 60 22];

            % --- Right panel: geometry / mesh controls ---
            app.SelectBoundaryConditionsButton = uibutton(app.UIFigure, 'push');
            app.SelectBoundaryConditionsButton.ButtonPushedFcn = createCallbackFcn(app, @SelectBoundaryConditionsButtonPushed, true);
            app.SelectBoundaryConditionsButton.BackgroundColor = [0 0 0];
            app.SelectBoundaryConditionsButton.FontColor = [1 1 1];
            app.SelectBoundaryConditionsButton.Position = [749 573 203 25];
            app.SelectBoundaryConditionsButton.Text = 'Select Boundary Conditions';

            app.GeometryDropDownLabel = uilabel(app.UIFigure);
            app.GeometryDropDownLabel.BackgroundColor = [0 0 0];
            app.GeometryDropDownLabel.HorizontalAlignment = 'right';
            app.GeometryDropDownLabel.FontColor = [1 1 1];
            app.GeometryDropDownLabel.Position = [716 466 140 22];
            app.GeometryDropDownLabel.Text = 'Geometry Drop Down';

            app.GeometryDropDown = uidropdown(app.UIFigure);
            app.GeometryDropDown.FontColor = [1 1 1];
            app.GeometryDropDown.BackgroundColor = [0 0 0];
            app.GeometryDropDown.Position = [871 466 100 22];

            app.MeshSliderLabel = uilabel(app.UIFigure);
            app.MeshSliderLabel.HorizontalAlignment = 'right';
            app.MeshSliderLabel.Position = [719 525 68 22];
            app.MeshSliderLabel.Text = 'Mesh Slider';

            app.MeshSlider = uislider(app.UIFigure);
            app.MeshSlider.Position = [821 535 150 3];

            app.DrawGeometryButton = uibutton(app.UIFigure, 'push');
            app.DrawGeometryButton.ButtonPushedFcn = createCallbackFcn(app, @DrawGeometryButtonPushed, true);
            app.DrawGeometryButton.BackgroundColor = [0 0 0];
            app.DrawGeometryButton.FontColor = [1 1 1];
            app.DrawGeometryButton.Position = [821 414 118 25];
            app.DrawGeometryButton.Text = 'Draw Geometry';

            app.DisplayDeformedStructureButton = uibutton(app.UIFigure, 'push');
            app.DisplayDeformedStructureButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayDeformedStructureButtonPushed, true);
            app.DisplayDeformedStructureButton.BackgroundColor = [0 0 0];
            app.DisplayDeformedStructureButton.FontColor = [1 1 1];
            app.DisplayDeformedStructureButton.Position = [750 336 201 25];
            app.DisplayDeformedStructureButton.Text = 'Display Deformed Structure';

            % --- Status label + Reset (your version) ---
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.BackgroundColor = [0.8 0.8 0.8];
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontSize = 14;
            app.StatusLabel.Position = [378 586 166 50];
            app.StatusLabel.Text = 'Ready';

            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.Position = [552 599 100 23];
            app.ResetButton.Text = 'Reset';

            % Show figure
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        function app = GUIforFEA_merged

            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @startupFcn2)

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
