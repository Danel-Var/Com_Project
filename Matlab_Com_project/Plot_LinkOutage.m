clear all; close all; clc;

% =========================
% User Options
% =========================
useSemiLogY = true;      % true = semilog-y, false = linear y

% =========================
% Input / Output folders
% =========================
folderPath = fullfile(pwd, "LinkOutage");
files = dir(fullfile(folderPath, "*.mat"));
outDir = fullfile(folderPath, 'results');

if ~exist(outDir, "dir")
    mkdir(outDir);
end

% =========================
% Plot styling
% =========================
markers = {'o','s','^','d','v','>','<','p','h'};
dim = 1;

axisFontSize  = 12;   % tick labels
labelFontSize = 14;   % axis titles
legendFontSize = 10;

% =========================
% Main Loop
% =========================
for k = 1:length(files)

    filepath = fullfile(folderPath, files(k).name);
    disp("Loading file: " + filepath);

    % === X-axis parameter name ===
    tokens = split(files(k).name, '_');
    paramValue = tokens{1};

    % === Load data ===
    S = load(filepath);
    [~, baseName, ~] = fileparts(files(k).name);
    baseName = strrep(baseName, ' ', '_');

    X_vec = S.X_vec;
    meas_var_vec = S.measurments_var_vec;
    params_length = S.params_length;
    num_measurements = S.num_measurements;

    ratio_before = reshape(S.ratios_before_kalman, ...
                           params_length, num_measurements)';
    ratio_after  = reshape(S.ratios_after_kalman, ...
                           params_length, num_measurements)';

    % === Create figure ===
    figure(dim); clf;
    hold on;

    colors = lines(length(meas_var_vec));
    legend_entries = {};

    % Select plotting function
    if useSemiLogY
        plotFcn = @semilogy;
    else
        plotFcn = @plot;
    end

    % === Plot data ===
    for m_idx = 1:length(meas_var_vec)

        markerType = markers{mod(m_idx-1, length(markers)) + 1};

        % --- Before Kalman ---
        y_before = ratio_before(m_idx,:);
        y_before(y_before < 1e-3) = 1e-3;

        plotFcn(X_vec, y_before, '--', ...
            'LineWidth', 1.6, ...
            'Color', colors(m_idx,:), ...
            'Marker', markerType, ...
            'MarkerSize', 6, ...
            'MarkerFaceColor', 'none');

        legend_entries{end+1} = ...
            sprintf('Before Kalman');

        % --- After Kalman ---
        y_after = ratio_after(m_idx,:);
        y_after(y_after < 1e-3) = 1e-3;

        plotFcn(X_vec, y_after, '-', ...
            'LineWidth', 1.8, ...
            'Color', colors(m_idx,:), ...
            'Marker', markerType, ...
            'MarkerSize', 6, ...
            'MarkerFaceColor', colors(m_idx,:));

        legend_entries{end+1} = ...
            sprintf('After Kalman');
    end

    % === Axes formatting ===
    FigW = 10;  FigH = 8;   % cm
    hFig = gcf;
    set(hFig, 'Units', 'centimeters', 'Position', [0 0 FigW FigH]);

    grid on;
    set(gca, ...
        'GridLineStyle', ':', ...
        'GridAlpha', 0.4, ...
        'FontSize', axisFontSize, ...
        'LineWidth', 1.1);

    xlabel(paramValue, ...
        'Interpreter','none', ...
        'FontWeight','bold', ...
        'FontSize', labelFontSize);

    ylabel('Outage Ratio', ...
        'FontWeight','bold', ...
        'FontSize', labelFontSize);

    if useSemiLogY
        set(gca, 'YScale', 'log');
    end

    legend(legend_entries, ...
        'Location', 'southeast', ...
        'FontSize', legendFontSize);

    % === Save ===
    set(hFig,'Renderer','painters');

    print(fullfile(outDir, sprintf('%s_d%d.png', baseName, dim)), ...
        '-dpng', '-r300');

    print(fullfile(outDir, sprintf('%s_d%d.eps', baseName, dim)), ...
        '-depsc', '-r300');

    dim = dim + 1;

end
