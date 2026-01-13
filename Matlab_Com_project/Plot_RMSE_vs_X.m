clear all; close all; clc;

% === Choose your folder ===
folderPath = fullfile(pwd,"rmse_Vs_X");
files = dir(fullfile(folderPath, "*.mat"));
outDir = fullfile(pwd, 'rmse_VS_X', 'results');

% === PARAMETERS ===
useYLim      = false;          % set true to enforce y-limits
yLimVals     = [0 2];     % [ymin ymax]
semilog_y_en = false;           % semilog Y axis

for k = 1:length(files)
    filepath = fullfile(folderPath, files(k).name);
    disp("Loading file: " + filepath);

    S = load(filepath);
    rmsedata = S.rmsedata;

    for d = 1:length(rmsedata)

        figure; hold on; grid on;

        % Extract useful data
        X         = rmsedata{d}.X;
        before    = rmsedata{d}.rmse_before;
        after     = rmsedata{d}.rmse_after;
        variances = rmsedata{d}.variance;
        x_axis_label = erase(files(k).name, '.mat');

        % === BEFORE Kalman ===
        if semilog_y_en
            semilogy(X, before, 'LineWidth', 2, ...
                     'DisplayName', 'Before Kalman');
        else
            plot(X, before, 'LineWidth', 2, ...
                 'DisplayName', 'Before Kalman');
        end

        % === AFTER Kalman ===
        markers = {'o','s','d','^','v','>','<'};
        num_after = size(after, 1);

        for j = 1:num_after
            m = markers{mod(j-1, numel(markers)) + 1};

            if semilog_y_en
                semilogy(X, after(j,:), '--', ...
                         'LineWidth', 1.5, ...
                         'Marker', m, ...
                         'MarkerSize', 8, ...
                         'DisplayName', ...
                         sprintf("After Kalman (var = %.3f)", variances(j)));
            else
                plot(X, after(j,:), '--', ...
                     'LineWidth', 1.5, ...
                     'Marker', m, ...
                     'MarkerSize', 8, ...
                     'DisplayName', ...
                     sprintf("After Kalman (var = %.3f)", variances(j)));
            end
        end

        % === Labels & styling ===
        title(sprintf('rmse vs %s -- Dimension %d', x_axis_label, d));
        xlabel(x_axis_label, "FontWeight","bold");
        ylabel("rmse", "FontWeight","bold");
        legend('show');

        ax = gca;
        ax.FontWeight = 'bold';
        ax.LineWidth  = 1.2;

        % === Y-limits option ===
        if useYLim
            ylim(yLimVals);
        end
        
        % === Save (NO TITLE in saved figures) ===
        
        fileNameBase = sprintf('%s_dim_%d', x_axis_label, d);
        fileNameBase = regexprep(fileNameBase,'[^a-zA-Z0-9_.-]','_');
        
        % Remove title (keep axis labels)
        title('');
        
        % Figure size for article
        FigW = 8.89;   % cm
        FigH = 5.5;    % cm
        set(gcf, 'Units','centimeters', 'Position',[0 0 FigW FigH]);
        set(gca, 'YScale', 'log');
        
        % Save PNG
        print(gcf, fullfile(outDir, [fileNameBase '.png']), '-dpng', '-r300');
        
        % Save EPS
        print(gcf, fullfile(outDir, [fileNameBase '.eps']), '-depsc', '-r300');

    end
end
