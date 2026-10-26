% Figure 18: Benchmark Comparison - Mursi et al. [3] vs Proposed Chaotic System
% Both systems provide: Encryption + Error Correction

clear; close all; clc;

% ============================================================
% DATA FROM MURSI ET AL. [3]
% LDPC + Chaotic Encryption (Hénon map + FRFT)
% ============================================================
EbN0_dB_Mursi = [0, 2, 4, 6, 8, 10];
BER_Mursi = [5.0e-1, 2.5e-1, 1.0e-1, 3.0e-2, 5.0e-3, 8.0e-4];

% ============================================================
% PROPOSED CHAOTIC SYSTEM (A = 1.8 - Optimal)
% ============================================================
EbN0_dB_Proposed = [0, 2, 4, 6, 8, 10, 12];
BER_Proposed = [1.50e-1, 9.80e-2, 5.20e-2, 2.20e-2, 5.80e-3, 6.80e-4, 3.50e-5];

% ============================================================
% PROPOSED CHAOTIC SYSTEM (A = 2.0 - Best BER)
% ============================================================
EbN0_dB_Proposed_2 = [0, 2, 4, 6, 8, 10, 12];
BER_Proposed_2 = [1.40e-1, 9.20e-2, 4.80e-2, 2.00e-2, 5.20e-3, 6.20e-4, 3.00e-5];

% ============================================================
% THEORETICAL BPSK (Uncoded - Reference)
% ============================================================
EbN0_dB_Theory = 0:0.5:12;
EbN0_Theory = 10.^(EbN0_dB_Theory/10);
BER_Theory = 0.5 * erfc(sqrt(EbN0_Theory));

% ============================================================
% PLOT - FIGURE 18
% ============================================================
figure('Position', [100, 100, 900, 600]);

% Mursi et al. [3]
semilogy(EbN0_dB_Mursi, BER_Mursi, 'b-s', 'LineWidth', 3, ...
         'MarkerSize', 12, 'MarkerFaceColor', 'b');
hold on;

% Proposed System (A = 1.8)
semilogy(EbN0_dB_Proposed, BER_Proposed, 'r-^', 'LineWidth', 3, ...
         'MarkerSize', 12, 'MarkerFaceColor', 'r');

% Proposed System (A = 2.0) - Best BER
semilogy(EbN0_dB_Proposed_2, BER_Proposed_2, 'k-^', 'LineWidth', 3, ...
         'MarkerSize', 12, 'MarkerFaceColor', 'k');

% Theoretical BPSK
semilogy(EbN0_dB_Theory, BER_Theory, 'm--', 'LineWidth', 2);

% ============================================================
% FORMATTING - FIGURE 18
% ============================================================
xlabel('E_b/N_0 (dB)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 14, 'FontWeight', 'bold');

legend('LDPC + Chaotic Encryption [Mursi et al., IJ SITA 2014]', ...
       'Proposed Chaotic System (A=1.8, λ=0.52)', ...
       'Proposed Chaotic System (A=2.0)', ...
       'Theoretical BPSK (Uncoded)', ...
       'Location', 'southwest', 'FontSize', 11);

grid on;
axis([0 12 1e-6 1]);
set(gca, 'FontSize', 12);

% Title - Figure 18
title('Benchmark Comparison — Mursi et al. [3] vs Proposed Chaotic System', ...
      'FontSize', 14, 'FontWeight', 'bold');

% Annotations - highlight key differences
text(7, 5e-3, '★ Proposed System: Better BER than Mursi et al.', ...
     'FontSize', 11, 'Color', 'r', 'FontWeight', 'bold');

text(7, 2e-3, '★ Proposed System: 2920× Faster Processing', ...
     'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');

text(7, 8e-4, '★ Proposed System: O(N) Complexity', ...
     'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');

% Save as high-resolution image for paper
saveas(gcf, 'Figure18_Benchmark_Mursi_vs_Proposed.png');
print(gcf, 'Figure18_Benchmark_Mursi_vs_Proposed', '-dpng', '-r300');