clear all; close all; clc;

% === Configuration ===
folderName = 'PoleSway';
outDirName = 'results';
xLabelStr = 'Time[s]'; % Assuming x-axis is sample index (time)
yLabelStr = 'Amplitude[cm]';

% --- Setup Paths and Directories ---
folderPath = fullfile(pwd, folderName);
outDir = fullfile(folderPath, outDirName);

% --- Find and Load the Single .mat File ---
files = dir(fullfile(folderPath, "*.mat"));

% Since there is only one file, we take the first element (files(1))
filepath = fullfile(folderPath, files(1).name);
S = load(filepath);

% --- Data Extraction and Alignment ---
theta_d = S.theta_d; 
theta_c = S.theta_c; 
time = S.time;

fileNameRoot = erase(files(1).name, '.mat');

% =========================================================================
% === PLOT 1: theta_d over time ===
% =========================================================================
figure('Name', [fileNameRoot, ' - Theta D']);
plot(time,theta_d);
t1='\theta_d (along wind)';
title('');
xlabel(xLabelStr, "FontWeight", "bold");
ylabel('', "FontWeight", "bold");
ylim([-1.5 1.5]);

ax = gca;
ax.FontWeight = 'bold';      % bold numbers on axes
ax.LineWidth  = 1.2;         % thick axis lines

grid on;
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

% Save Plot 1
% Save PNG
print(gcf, fullfile(outDir, [fileNameRoot, '_L_d.png']), '-dpng', '-r300');
% Save EPS (journal ready)
print(gcf, fullfile(outDir, [fileNameRoot, '_L_d.eps']), '-depsc', '-r300');

%saveas(gcf, fullfile(outDir, [fileNameRoot, '_theta_d.png']));
title(t1)
ylabel(yLabelStr, "FontWeight", "bold");

% =========================================================================
% === PLOT 2: theta_c over time (New Plot) ===
% =========================================================================
figure('Name', [fileNameRoot, ' - Theta C']);
plot(time,theta_c);

t2='\theta_c (cross wind)';
title('');
xlabel(xLabelStr, "FontWeight", "bold");
ylabel(yLabelStr, "FontWeight", "bold");
ylim([-1.5 1.5]);

ax = gca;
ax.FontWeight = 'bold';      % bold numbers on axes
ax.LineWidth  = 1.2;         % thick axis lines

grid on;

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

% Save Plot 2
% Save PNG
print(gcf, fullfile(outDir, [fileNameRoot, '_L_c.png']), '-dpng', '-r300');
% Save EPS (journal ready)
print(gcf, fullfile(outDir, [fileNameRoot, '_L_c.eps']), '-depsc', '-r300');
title(t2);
% =========================================================================
% === PLOT 3: Phase Plot (theta_c vs theta_d) ===
% (theta_d is X-axis, theta_c is Y-axis)
% =========================================================================
figure('Name', [fileNameRoot, ' - Phase Plot']);
% 'b-' plots a blue line connecting the points; consider 'b.' for scatter plot
plot(theta_d, theta_c, 'b-');

t3='Point of view from above';
title('');
xlabel('L_d [cm]', "FontWeight", "bold", 'Interpreter', 'tex');
ylabel('L_c [cm]', "FontWeight", "bold", 'Interpreter', 'tex');
ax = gca;
ax.FontWeight = 'bold';      % bold numbers on axes
ax.LineWidth  = 1.2;         % thick axis lines

grid on;
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

axis equal; % Ensures the X and Y axes have the same scaling, often crucial for phase plots

% Save Plot 3
print(gcf, fullfile(outDir, [fileNameRoot, '_Phase_Plot.png']), '-dpng', '-r300');
% Save EPS (journal ready)
print(gcf, fullfile(outDir, [fileNameRoot, '_Phase_Plot.eps']), '-depsc', '-r300');
title(t3);

% =========================================================================
% === PLOT 4: Phase Plot (theta_c vs theta_d over time) ===
% (theta_d is X-axis, theta_c is Y-axis, time is Z-axis)
% =========================================================================
figure('Name', [fileNameRoot, ' - 3D Trajectory']);

% Create 3D line plot
plot3(theta_d, theta_c, time, 'b-', 'LineWidth', 1.5);

t4 = '3D Trajectory Over Time';
title('');
xlabel('L_d [cm]', "FontWeight", "bold", 'Interpreter', 'tex');
ylabel('L_c [cm]', "FontWeight", "bold", 'Interpreter', 'tex');
zlabel('Time [s]', "FontWeight", "bold");

ax = gca;
ax.FontWeight = 'bold';
ax.LineWidth = 1.2;

grid on;
view(3); % Set to default 3D view
axis tight;

% For article formatting
FigW = 8.89;
FigH = 7.5;  % Slightly taller for 3D plot
hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

% Save Plot 4
print(gcf, fullfile(outDir, [fileNameRoot, '_3D_Trajectory.png']), '-dpng', '-r300');
print(gcf, fullfile(outDir, [fileNameRoot, '_3D_Trajectory.eps']), '-depsc', '-r300');
title(t4);