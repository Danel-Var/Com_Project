clear all; close all; clc;

% === Input / Output folders ===
folderPath = fullfile(pwd, "multiple_timming_complexity");
files = dir(fullfile(folderPath, "*.mat"));
outDir = fullfile(pwd, 'multiple_timming_complexity', 'results');

if ~exist(outDir, "dir")
    mkdir(outDir);
end

% Create figures ONCE before the loop
figure(1); clf; hold on; grid on;
figure(2); clf; hold on; grid on;
figure(3); clf; hold on; grid on;
figure(4); clf; hold on; grid on;

coherence_time_plotted_dim1 = false;
coherence_time_plotted_dim2 = false;

for k = 1:length(files)

    filepath = fullfile(folderPath, files(k).name);
    disp("Loading file: " + filepath);

    % Load data
    S_time_analsys = load(filepath);
    
    % Extract resolution from filename
    [~, fileName, ~] = fileparts(files(k).name);
    stream = split(fileName, '_');
    res = stream{end};

    % Manually assign line styles based on resolution
    if strcmp(res, '0.1')
        withKalmanStyle = '--';
        withoutKalmanStyle = '-.';
        deltaStyle = '-';
    elseif strcmp(res, '0.8')
        withKalmanStyle = ':';
        withoutKalmanStyle = '-o';
        deltaStyle = '--';
    else
        % Default styles for other resolutions if any
        withKalmanStyle = '--';
        withoutKalmanStyle = '-.';
        deltaStyle = '-';
    end

    % -------- Dimension 1 --------
    dim_1_coherence_time_step = S_time_analsys.dim_1_coherence_time_step;
    dim_1_coherence_time_value = S_time_analsys.dim_1_coherence_time_value;

    dim_1_calc_time_no_kalman_step = ...
        S_time_analsys.dim_1_calculation_time_without_kalman_step;
    dim_1_calc_time_no_kalman_value = ...
        S_time_analsys.dim_1_calculation_time_without_kalman_value;

    dim_1_calc_time_with_kalman_step = ...
        S_time_analsys.dim_1_calculation_time_with_kalman_step;
    dim_1_calc_time_with_kalman_value = ...
        S_time_analsys.dim_1_calculation_time_with_kalman_value;

    % -------- Dimension 2 --------
    dim_2_coherence_time_step = S_time_analsys.dim_2_coherence_time_step;
    dim_2_coherence_time_value = S_time_analsys.dim_2_coherence_time_value;

    dim_2_calc_time_no_kalman_step = ...
        S_time_analsys.dim_2_calculation_time_without_kalman_step;
    dim_2_calc_time_no_kalman_value = ...
        S_time_analsys.dim_2_calculation_time_without_kalman_value;

    dim_2_calc_time_with_kalman_step = ...
        S_time_analsys.dim_2_calculation_time_with_kalman_step;
    dim_2_calc_time_with_kalman_value = ...
        S_time_analsys.dim_2_calculation_time_with_kalman_value;
    
    % Plot dim 1
    figure(1);
    if ~coherence_time_plotted_dim1
        coherence_time_plotted_dim1 = true;
        plot(dim_1_coherence_time_step, dim_1_coherence_time_value.*1000, '-', 'LineWidth', 2.5, 'DisplayName', 'Coherence time', 'Color', 'b');
    end
    
    % With Kalman
    if strcmp(withKalmanStyle, ':')
        plot(dim_1_calc_time_with_kalman_step, dim_1_calc_time_with_kalman_value.*1000, withKalmanStyle, 'LineWidth', 3, 'DisplayName', ['With Kalman res=' res]);
    else
        plot(dim_1_calc_time_with_kalman_step, dim_1_calc_time_with_kalman_value.*1000, withKalmanStyle, 'LineWidth', 2.5, 'DisplayName', ['With Kalman res=' res]);
    end
    
    % Without Kalman
    if strcmp(withoutKalmanStyle, '-o')
        %plot(dim_1_calc_time_no_kalman_step, dim_1_calc_time_no_kalman_value.*1000, withoutKalmanStyle, 'LineWidth', 2, 'MarkerSize', 5, 'MarkerIndices', 1:10:length(dim_1_calc_time_no_kalman_step), 'DisplayName', ['Without Kalman res=' res]);
        x = double(dim_1_calc_time_no_kalman_step(:));
        y = double(dim_1_calc_time_no_kalman_value(:)) * 1000;
    
        % Remove non-positive x (required for log scale)
        valid = x > 0 & ~isnan(x) & ~isinf(x);
        x = x(valid);
        y = y(valid);
    
        % ---- marker control ----
        Nmarkers = 8;
        % ------------------------
    
        if numel(x) >= Nmarkers
    
            xmin = min(x);
            xmax = max(x);
    
            log_targets = logspace(log10(xmin), log10(xmax), Nmarkers);
    
            marker_idx = zeros(1, Nmarkers);
            for i = 1:Nmarkers
                [~, marker_idx(i)] = min(abs(x - log_targets(i)));
            end
    
            marker_idx = unique(marker_idx);
    
            plot(x, y, '-o', ...
                'LineWidth', 2, ...
                'MarkerSize', 6, ...
                'MarkerIndices', marker_idx, ...
                'DisplayName', ['Without Kalman res=' res]);
        else
        % Fallback: too few points
        plot(x, y, '-o', ...
            'LineWidth', 2, ...
            'MarkerSize', 6, ...
            'DisplayName', ['Without Kalman res=' res]);
        end
    else
            plot(dim_1_calc_time_no_kalman_step, dim_1_calc_time_no_kalman_value.*1000, withoutKalmanStyle, 'LineWidth', 2.5, 'DisplayName', ['Without Kalman res=' res]);
    end
    
    % Plot dim 2
    figure(2);
    if ~coherence_time_plotted_dim2
        coherence_time_plotted_dim2 = true;
        plot(dim_2_coherence_time_step, dim_2_coherence_time_value.*1000, '-', 'LineWidth', 2.5, 'DisplayName', 'Coherence time', 'Color', 'b');
    end
    
    % With Kalman
    if strcmp(withKalmanStyle, ':')
        plot(dim_2_calc_time_with_kalman_step, dim_2_calc_time_with_kalman_value.*1000, withKalmanStyle, 'LineWidth', 3, 'DisplayName', ['With Kalman res=' res]);
    else
        plot(dim_2_calc_time_with_kalman_step, dim_2_calc_time_with_kalman_value.*1000, withKalmanStyle, 'LineWidth', 2.5, 'DisplayName', ['With Kalman res=' res]);
    end
    
    % Without Kalman
    if strcmp(withoutKalmanStyle, '-o')
        %plot(dim_2_calc_time_no_kalman_step, dim_2_calc_time_no_kalman_value.*1000, withoutKalmanStyle, 'LineWidth', 2, 'MarkerSize', 5, 'MarkerIndices', 1:10:length(dim_2_calc_time_no_kalman_step), 'DisplayName', ['Without Kalman res=' res]);
        x = double(dim_2_calc_time_no_kalman_step(:));
        y = double(dim_2_calc_time_no_kalman_value(:)) * 1000;
    
        % Remove non-positive x (required for log scale)
        valid = x > 0 & ~isnan(x) & ~isinf(x);
        x = x(valid);
        y = y(valid);
    
        % ---- marker control ----
        Nmarkers = 8;
        % ------------------------
    
        if numel(x) >= Nmarkers
    
            xmin = min(x);
            xmax = max(x);
    
            log_targets = logspace(log10(xmin), log10(xmax), Nmarkers);
    
            marker_idx = zeros(1, Nmarkers);
            for i = 1:Nmarkers
                [~, marker_idx(i)] = min(abs(x - log_targets(i)));
            end
    
            marker_idx = unique(marker_idx);
    
            plot(x, y, '-o', ...
                'LineWidth', 2, ...
                'MarkerSize', 6, ...
                'MarkerIndices', marker_idx, ...
                'DisplayName', ['Without Kalman res=' res]);
        else
            % Fallback: too few points
            plot(x, y, '-o', ...
                'LineWidth', 2, ...
                'MarkerSize', 6, ...
                'DisplayName', ['Without Kalman res=' res]);
        end
    else
        plot(dim_2_calc_time_no_kalman_step, dim_2_calc_time_no_kalman_value.*1000, withoutKalmanStyle, 'LineWidth', 2.5, 'DisplayName', ['Without Kalman res=' res]);
    end
    
    % Plot delta dim 1
    figure(3);
    delta_d1 = (dim_1_calc_time_no_kalman_value - dim_1_calc_time_with_kalman_value);
    plot(dim_1_calc_time_no_kalman_step, delta_d1.*1000, deltaStyle, 'LineWidth', 2.5, 'DisplayName', ['res=' res]);
    
    % Plot delta dim 2
    figure(4);
    delta_d2 = dim_2_calc_time_no_kalman_value - dim_2_calc_time_with_kalman_value;
    plot(dim_2_calc_time_no_kalman_step, delta_d2.*1000, deltaStyle, 'LineWidth', 2.5, 'DisplayName', ['res=' res]);
end

% Format and save figure 1 (Dim 1) - NO TITLE
figure(1);
xlabel('Scan'); ylabel('Time [ms]'); 
set(gca, 'XScale', 'log', 'YScale', 'log');
legend('show');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

FigW = 8.89;  FigH = 5.5;
set(gcf, 'Units', 'centimeters');    
set(gcf, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, "MultiplicationTimePerSample_d1.png"), '-dpng','-r300');
print(fullfile(outDir, "MultiplicationTimePerSample_d1.eps"), '-depsc','-r300');

title('Multiplication Time Per Sample (Dim 1)');

% Format and save figure 2 (Dim 2) - NO TITLE
figure(2);
xlabel('Scan');  
set(gca, 'XScale', 'log', 'YScale', 'log');
legend('show');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

set(gcf, 'Units', 'centimeters');
set(gcf, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, "MultiplicationTimePerSample_d2.png"), '-dpng','-r300');
print(fullfile(outDir, "MultiplicationTimePerSample_d2.eps"), '-depsc','-r300');

ylabel('Time [ms]');
title('Multiplication Time Per Sample (Dim 2)');

% Format and save figure 3 (delta dim 1) - NO TITLE
figure(3);
xlabel('Scan'); ylabel('Improvement (ΔTime[ms])');
set(gca, 'XScale', 'log');
legend('show', 'Location', 'northwest');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

set(gcf, 'Units', 'centimeters');    
set(gcf, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, "MultiplicationTimePerSample_d1_delta.png"), '-dpng','-r300');
print(fullfile(outDir, "MultiplicationTimePerSample_d1_delta.eps"), '-depsc','-r300');

title('Improvement (ΔTime) for (Dim 1)');

% Format and save figure 4 (delta dim 2) - NO TITLE
figure(4);
xlabel('Scan'); 
set(gca, 'XScale', 'log');
legend('show', 'Location', 'northwest');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

set(gcf, 'Units', 'centimeters');    
set(gcf, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, "MultiplicationTimePerSample_d2_delta.png"), '-dpng','-r300');
print(fullfile(outDir, "MultiplicationTimePerSample_d2_delta.eps"), '-depsc','-r300');

ylabel('Improvement (ΔTime[ms])');
title('Improvement (ΔTime) for (Dim 2)');