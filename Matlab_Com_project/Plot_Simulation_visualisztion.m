clear all; close all; clc;

% MATLAB script to plot simulation data from .mat file
% This script handles missing data (None values) and creates individual plots
% for each dimension and measurement type (Position, Velocity, Omega)

% === Choose your folder ===
folderPath = "C:\Users\drorm\main dir\programming\university\Com_project\Simulation_visualization";

% === Get list of .mat files ===
files = dir(fullfile(folderPath, "*.mat"));
outDir = fullfile(pwd, 'Simulation_visualization', 'results');

% Create output directory if it doesn't exist
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

filename = fullfile(folderPath, files(1).name);
data = load(filename);

% Get field names (dim_0, dim_1, etc.)
fields = fieldnames(data);
num_dimensions = length(fields);

% Define dimension labels
dim_labels = {'L_d', 'L_c'};

% Helper function to check if field exists and is not empty
function result = hasData(struct, fieldname)
    result = isfield(struct, fieldname) && ...
             ~isempty(struct.(fieldname)) && ...
             ~all(isnan(struct.(fieldname)(:)));
end

% Figure properties for article
FigW = 8.89;   % Target Width in cm (3.5 inches)
FigH = 5.5;    % Target Height in cm

% Define line styles with markers and colors
style_true   = {'b', '-', 'o'};
style_doa    = {'r', '-', 's'};
style_kalman = {[1 0.6 0], '-', 'd'};

%% ===========================
%% POSITION PLOTS
%% ===========================
for i = 1:num_dimensions
    dim_name = fields{i};
    dim_data = data.(dim_name);

    % === ADDED: Extract time vector ===
    if hasData(dim_data, 'time')
        t = dim_data.time(:);
    else
        t = (1:length(dim_data.true_position))';
    end

    % Check if any position data exists for this dimension
    has_position = hasData(dim_data, 'true_position') || ...
                   hasData(dim_data, 'DOA_position') || ...
                   hasData(dim_data, 'Kalman_position');

    if has_position
        figure('Name', sprintf('Position - %s', dim_labels{i}), ...
               'NumberTitle', 'off', 'Visible', 'on');
        hold on;

        % --- DOA position ---
        if hasData(dim_data, 'DOA_position')
            plot(t, dim_data.DOA_position, ...             % === CHANGED ===
                'Color', style_doa{1}, ...
                'LineStyle', style_doa{2}, ...
                'Marker', style_doa{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'Before Kalman (H-MUSIC)');
        end

        % --- Kalman position ---
        if hasData(dim_data, 'Kalman_position')
            kalman_pos = dim_data.Kalman_position;
            plot(t, kalman_pos, ...                         % === CHANGED ===
                'Color', style_kalman{1}, ...
                'LineStyle', style_kalman{2}, ...
                'Marker', style_kalman{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'After Kalman');

        % --- True position ---
        if hasData(dim_data, 'true_position')
            plot(t, dim_data.true_position, ...            % === CHANGED ===
                'Color', style_true{1}, ...
                'LineStyle', style_true{2}, ...
                'Marker', style_true{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'True Angle');
        end
            
            % Confidence interval
            if hasData(dim_data, 'Kalman_position_ci')
                ci = dim_data.Kalman_position_ci;
                x = t(:)';                                   % === CHANGED ===
                fill([x fliplr(x)], ...
                     [kalman_pos(:)'-ci, fliplr(kalman_pos(:)'+ci)], ...
                     [1 0.6 0], 'FaceAlpha', 0.25, ...
                     'EdgeColor', 'none', ...
                     'DisplayName', '95% CI');
            end
        end

        xlabel('Time (sec)');                                 % === CHANGED ===
        ylabel('Angle (degrees)');
        title(sprintf('Position - %s', dim_labels{i}));
        legend('Location', 'best');
        grid on;
        hold off;

        % Figure size for article
        hFig = gcf;
        set(hFig, 'Units', 'centimeters');
        set(hFig, 'Position', [0 0 FigW FigH]);

        title_text = get(get(gca, 'Title'), 'String');
        title('');

        print(hFig, fullfile(outDir, sprintf('Position_%s.eps', dim_labels{i})), '-depsc');
        print(hFig, fullfile(outDir, sprintf('Position_%s.png', dim_labels{i})), '-dpng', '-r300');

        title(title_text);
    end
end

%% ===========================
%% VELOCITY PLOTS
%% ===========================
for i = 1:num_dimensions
    dim_name = fields{i};
    dim_data = data.(dim_name);

    % === ADDED: Extract time vector ===
    if hasData(dim_data, 'time')
        t = dim_data.time(:);
    else
        t = (1:length(dim_data.true_velocity))';
    end

    has_velocity = hasData(dim_data, 'true_velocity') || ...
                   hasData(dim_data, 'kalman_velocity');

    if has_velocity
        figure('Name', sprintf('Velocity - %s', dim_labels{i}), ...
               'NumberTitle', 'off', 'Visible', 'on');
        hold on;

        % True velocity
        if hasData(dim_data, 'true_velocity')
            plot(t, dim_data.true_velocity, ...             % === CHANGED ===
                'Color', style_true{1}, ...
                'LineStyle', style_true{2}, ...
                'Marker', style_true{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'True Velocity');
        end

        % Kalman velocity
        if hasData(dim_data, 'kalman_velocity')
            kalman_vel = dim_data.kalman_velocity;
            plot(t, kalman_vel, ...                         % === CHANGED ===
                'Color', style_kalman{1}, ...
                'LineStyle', style_kalman{2}, ...
                'Marker', style_kalman{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'Velocity after Kalman');

            % CI
            if hasData(dim_data, 'kalman_velocity_ci')
                ci = dim_data.kalman_velocity_ci;
                x = t(:)';                                   % === CHANGED ===
                fill([x fliplr(x)], ...
                     [kalman_vel(:)'-ci, fliplr(kalman_vel(:)'+ci)], ...
                     [1 0.6 0], 'FaceAlpha', 0.25, ...
                     'EdgeColor', 'none', ...
                     'DisplayName', '95% CI');
            end
        end

        xlabel('Time (sec)');                                % === CHANGED ===
        ylabel('Velocity (deg/sec)');
        title(sprintf('Velocity - %s', dim_labels{i}));
        legend('Location', 'best');
        grid on;
        hold off;

        hFig = gcf;
        set(hFig, 'Units', 'centimeters');
        set(hFig, 'Position', [0 0 FigW FigH]);

        title_text = get(get(gca, 'Title'), 'String');
        title('');

        print(hFig, fullfile(outDir, sprintf('Velocity_%s.eps', dim_labels{i})), '-depsc');
        print(hFig, fullfile(outDir, sprintf('Velocity_%s.png', dim_labels{i})), '-dpng', '-r300');

        title(title_text);
    end
end

%% ===========================
%% OMEGA PLOTS
%% ===========================
for i = 1:num_dimensions
    dim_name = fields{i};
    dim_data = data.(dim_name);

    % === ADDED: Extract time vector ===
    if hasData(dim_data, 'time')
        t = dim_data.time(:);
    else
        t = (1:length(dim_data.true_omega))';
    end

    has_omega = hasData(dim_data, 'true_omega') || ...
                hasData(dim_data, 'kalman_omega');

    if has_omega
        figure('Name', sprintf('Omega - %s', dim_labels{i}), ...
               'NumberTitle', 'off', 'Visible', 'on');
        hold on;

        % True Omega
        if hasData(dim_data, 'true_omega')
            plot(t, dim_data.true_omega, ...                % === CHANGED ===
                'Color', style_true{1}, ...
                'LineStyle', style_true{2}, ...
                'Marker', style_true{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'True Omega');
        end

        % Kalman Omega
        if hasData(dim_data, 'kalman_omega')
            kalman_omega = dim_data.kalman_omega;
            plot(t, kalman_omega, ...                       % === CHANGED ===
                'Color', style_kalman{1}, ...
                'LineStyle', style_kalman{2}, ...
                'Marker', style_kalman{3}, ...
                'MarkerSize', 4, ...
                'MarkerIndices', 1:10:length(t), ...
                'LineWidth', 1.5, ...
                'DisplayName', 'Omega after Kalman');

            if hasData(dim_data, 'kalman_omega_ci')
                ci = dim_data.kalman_omega_ci;
                x = t(:)';                                   % === CHANGED ===
                fill([x fliplr(x)], ...
                     [kalman_omega(:)'-ci, fliplr(kalman_omega(:)'+ci)], ...
                     [1 0.6 0], 'FaceAlpha', 0.25, ...
                     'EdgeColor', 'none', ...
                     'DisplayName', '95% CI');
            end
        end

        xlabel('Time (sec)');                                % === CHANGED ===
        ylabel('Omega (rad/sec)');
        title(sprintf('Omega - %s', dim_labels{i}));
        legend('Location', 'best');
        grid on;
        hold off;

        hFig = gcf;
        set(hFig, 'Units', 'centimeters');
        set(hFig, 'Position', [0 0 FigW FigH]);

        title_text = get(get(gca, 'Title'), 'String');
        title('');

        print(hFig, fullfile(outDir, sprintf('Omega_%s.eps', dim_labels{i})), '-depsc');
        print(hFig, fullfile(outDir, sprintf('Omega_%s.png', dim_labels{i})), '-dpng', '-r300');

        title(title_text);
    end
end

disp('Plotting complete! Files saved to:');
disp(outDir);
