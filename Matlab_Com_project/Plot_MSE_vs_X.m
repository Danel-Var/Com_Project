clear all; close all; clc;
% === Choose your folder ===
folderPath = fullfile(pwd,"MSE_Vs_X");
files = dir(fullfile(folderPath, "*.mat"));
outDir = fullfile(pwd, 'MSE_VS_X', 'results');

for k = 1:length(files)
    filepath = fullfile(folderPath, files(k).name);
    disp("Loading file: " + filepath);

    % Load the file content
    S = load(filepath);
    MSEdata= S.MSEdata;
    for d = 1:length(MSEdata)

    figure; hold on; grid on;

    % Extract useful data
    X         = MSEdata{d}.X;
    before    = MSEdata{d}.MSE_before;
    after     = MSEdata{d}.MSE_after;
    variances = MSEdata{d}.variance;
    x_axis_label= erase(files(k).name, '.mat');
    
    % Plot BEFORE Kalman
    plot(X, before, 'LineWidth', 2, 'DisplayName', 'Before Kalman');

    % Plot AFTER Kalman curves
    markers = {'o','s','d','^','v','>','<'};

    num_after = size(after, 1);  % number of variance curves
        for j = 1:num_after
            m = markers{mod(j-1, numel(markers)) + 1};  % cycle markers
            plot(X, after(j,:), '--', ...
                 'LineWidth', 1.5, ...
                 'Marker', m, ...
                 'MarkerSize', 8, ...
                 'DisplayName', sprintf("After Kalman (var = %.3f)", variances(j)));
        end

    % Titles and labels
    title(sprintf('MSE vs %s -- Dimension %d', x_axis_label, d));
    xlabel(x_axis_label);
    ylabel("MSE");

    legend('show');

    ax = gca;
    ax.FontWeight = 'bold';      % bold numbers on axes
    ax.LineWidth  = 1.2;         % thick axis lines
    xlabel(x_axis_label, "FontWeight","bold");
    ylabel("MSE", "FontWeight","bold");
    %save 
    % Get title text
    t = get(get(gca,'Title'),'String');
    
    % Make filename-safe version (remove spaces, illegal chars)
    fileName = regexprep(t,'[^a-zA-Z0-9_.-]','_');
    
    % Hide title so it won't appear in saved figure
    title('');

    %for article 
    % Set the figure properties
    FigW = 8.89;   % Target Width in cm (3.5 inches)
    FigH = 5.5;    % Target Height in cm (adjust this for aspect ratio)    
    % Get the current figure handle
    hFig = gcf;    
    % Set the units to centimeters (or inches)
    set(hFig, 'Units', 'centimeters');    
    % Set the position (the first two numbers are screen coordinates, usually 0)
    set(hFig, 'Position', [0 0 FigW FigH]);

    % Save PNG
    print(gcf, fullfile(outDir, fileName), '-dpng', '-r300');    % 300 dpi for print
    
    % Save EPS (journal ready)
    print(gcf, fullfile(outDir, fileName), '-depsc', '-r300');
    
    %after saving restor the title
    title(t);


    end

end