% Figure 20: Processing Time Comparison - Proposed vs Mursi et al. [3]

clear; close all; clc;

% Data
System = {'Mursi et al. [3]', 'Proposed System'};
ProcessingTime = [14.55, 0.005]; % Seconds

% Plot
figure('Position', [100, 100, 600, 500]);
bar(ProcessingTime, 'FaceColor', [0.2, 0.4, 0.8], 'EdgeColor', 'k', 'LineWidth', 1.5);
set(gca, 'XTickLabel', System, 'FontSize', 12);
ylabel('Processing Time (seconds)', 'FontSize', 14, 'FontWeight', 'bold');
title('Processing Time Comparison', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% Add values on bars
for i = 1:length(ProcessingTime)
    text(i, ProcessingTime(i) + 0.5, sprintf('%.2f s', ProcessingTime(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end

% Save
saveas(gcf, 'Figure20_Processing_Time_Comparison.png');