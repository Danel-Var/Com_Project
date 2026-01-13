clear all; close all; clc;

% === Input / Output folders ===
folderPath = fullfile(pwd, "Complexity");
files = dir(fullfile(folderPath, "*.mat"));
outDir = fullfile(pwd, 'Complexity', 'results');

if ~exist(outDir, "dir")
    mkdir(outDir);
end

for k = 1:length(files)

    filepath = fullfile(folderPath, files(k).name);
    disp("Loading file: " + filepath);

    % Load data
    if strcmp(files(k).name, "MultiplacationTimePerSample.mat")
        S_time_analsys = load(filepath);
        % Extract naming base (remove .mat)
        [~, baseName_time_analsys, ~] = fileparts(files(k).name);
        % Extract data
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
    else
        S_multiplication_anlasys = load(filepath);
        % Extract naming base (remove .mat)
        [~, baseName_multiplication_anlasys, ~] = fileparts(files(k).name); 
        % Extract data
        scan_d1_multiplication_anlasys = S_multiplication_anlasys.dim_1_x1;
        No_kalman_d1_multiplication_anlasys = S_multiplication_anlasys.dim_1_y1;
        With_kalman_d1_multiplication_anlasys = S_multiplication_anlasys.dim_1_y2;
        
        scan_d2_multiplication_anlasys = S_multiplication_anlasys.dim_2_x1;
        No_kalman_d2_multiplication_anlasys = S_multiplication_anlasys.dim_2_y1;
        With_kalman_d2_multiplication_anlasys = S_multiplication_anlasys.dim_2_y2;
    end

end
    

% ========= Time visualization ===========

%% ===== Plot Dim 1 =====
figure(1); clf; hold on; grid on;
plot(dim_1_coherence_time_step, dim_1_coherence_time_value.*1000, 'o','LineWidth', 1.6, 'DisplayName','cohernce time');
plot(dim_1_calc_time_no_kalman_step, dim_1_calc_time_no_kalman_value.*1000,'-' , 'LineWidth', 1.6, 'DisplayName','With on Kalman');
plot(dim_1_calc_time_with_kalman_step, dim_1_calc_time_with_kalman_value.*1000,'--' ,  'LineWidth', 1.6, 'DisplayName','With Kalman');

xlabel('Scan'); ylabel('Time[ms]'); set(gca, 'XScale', 'log', 'YScale', 'log');
legend('show');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

FigW = 8.89;  FigH = 5.5;
hFig = gcf;
set(hFig, 'Units', 'centimeters');    
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_time_analsys + "_d1.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_time_analsys + "_d1.eps"), '-depsc','-r300');

title('Multiplication Time Per Sample (Dim 1)');

%% ===== Plot Dim 1 Delta =====
figure(2); clf; hold on; grid on;
delta_d1 = (dim_1_calc_time_no_kalman_value - dim_1_calc_time_with_kalman_value);
plot(dim_1_calc_time_no_kalman_step, delta_d1.*1000, 'LineWidth', 1.6);

xlabel('Scan'); ylabel('Improvement (ΔTime[ms])');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_time_analsys + "_d1_Delta.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_time_analsys + "_d1_Delta.eps"), '-depsc','-r300');

title('Improvement (ΔTime) for (Dim 1)');

%% ===== Plot Dim 2 =====
figure(3); clf; hold on; grid on;

plot(dim_2_coherence_time_step, ...
     dim_2_coherence_time_value .* 1000, 'o', ...
     'LineWidth', 1.6, 'DisplayName','coherence time');

plot(dim_2_calc_time_no_kalman_step, ...
     dim_2_calc_time_no_kalman_value .* 1000, '-', ...
     'LineWidth', 1.6, 'DisplayName','Without Kalman');

plot(dim_2_calc_time_with_kalman_step, ...
     dim_2_calc_time_with_kalman_value .* 1000, '--', ...
     'LineWidth', 1.6, 'DisplayName','With Kalman');

xlabel('Scan'); ylabel('Time [ms]'); set(gca, 'XScale', 'log', 'YScale', 'log');
legend('show');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_time_analsys + "_d2.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_time_analsys + "_d2.eps"), '-depsc','-r300');

title('Multiplication Time Per Sample (Dim 2)');

%% ===== Plot Dim 2 Delta =====
figure(4); clf; hold on; grid on;

delta_d2 = dim_2_calc_time_no_kalman_value - ...
           dim_2_calc_time_with_kalman_value;

plot(dim_2_calc_time_no_kalman_step, ...
     delta_d2 .* 1000, 'LineWidth', 1.6);

xlabel('Scan'); ylabel('Improvement (ΔTime [ms])');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_time_analsys + "_d2_Delta.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_time_analsys + "_d2_Delta.eps"), '-depsc','-r300');

title('Improvement (ΔTime) for (Dim 2)');

% ========= CASE 2 — Multiplications count ===========

%% ===== Plot Dim 1 =====
figure(5); clf; hold on; grid on;
plot(scan_d1_multiplication_anlasys, No_kalman_d1_multiplication_anlasys, '--','LineWidth', 1.6, 'DisplayName','No Kalman');
plot(scan_d1_multiplication_anlasys, With_kalman_d1_multiplication_anlasys,  'LineWidth', 1.6, 'DisplayName','With Kalman');

xlabel('Scan'); ylabel('Multiplications');
legend('show');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

FigW = 8.89;  FigH = 5.5;
hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_multiplication_anlasys + "_d1.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_multiplication_anlasys + "_d1.eps"), '-depsc','-r300');

title('Number of Multiplications (Dim 1)');

%% ===== Plot Dim 1 Delta =====
figure(6); clf; hold on; grid on;
delta2_d1 = No_kalman_d1_multiplication_anlasys - With_kalman_d1_multiplication_anlasys;
plot(scan_d1_multiplication_anlasys, delta2_d1, 'LineWidth', 1.6);

xlabel('Scan'); ylabel('Improvement (ΔMultiplications)');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_multiplication_anlasys + "_d1_Delta.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_multiplication_anlasys + "_d1_Delta.eps"), '-depsc','-r300');

title('Improvement (ΔMultiplications) for (Dim 1)');


%% ===== Plot Dim 2 =====
figure(7); clf; hold on; grid on;
plot(scan_d2_multiplication_anlasys, No_kalman_d2_multiplication_anlasys, '--','LineWidth', 1.6, 'DisplayName','Without Kalman');
plot(scan_d2_multiplication_anlasys, With_kalman_d2_multiplication_anlasys,  'LineWidth', 1.6, 'DisplayName','With Kalman');

xlabel('Scan'); ylabel('Multiplications');
legend('show');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_multiplication_anlasys + "_d2.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_multiplication_anlasys + "_d2.eps"), '-depsc','-r300');

title('Number of Multiplications (Dim 2)');

%% ===== Plot Dim 2 Delta =====
figure(8); clf; hold on; grid on;
delta2_d2 = No_kalman_d2_multiplication_anlasys - With_kalman_d2_multiplication_anlasys;
plot(scan_d2_multiplication_anlasys, delta2_d2, 'LineWidth', 1.6);

xlabel('Scan'); ylabel('Improvement (ΔMultiplications)');
set(gca, 'LineWidth', 1.2, 'FontWeight', 'bold');

hFig = gcf;
set(hFig, 'Units', 'centimeters');
set(hFig, 'Position', [0 0 FigW FigH]);

print(fullfile(outDir, baseName_multiplication_anlasys + "_d2_Delta.png"), '-dpng','-r300');
print(fullfile(outDir, baseName_multiplication_anlasys + "_d2_Delta.eps"), '-depsc','-r300');

title('Improvement (ΔMultiplications) for (Dim 2)');



