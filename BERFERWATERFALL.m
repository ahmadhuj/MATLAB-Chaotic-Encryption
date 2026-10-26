%% ===================================
% BER COMPARISON (IMPROVED)
%% ===================================
figure;
semilogy(EbNo_dB,BER_BPSK,'b-o','LineWidth',2,'MarkerSize',6); hold on;
semilogy(EbNo_dB,BER_Logistic,'r-s','LineWidth',2,'MarkerSize',6);
semilogy(EbNo_dB,BER_Tent,'g-d','LineWidth',2,'MarkerSize',6);
semilogy(EbNo_dB,BER_Proposed,'m-x','LineWidth',3,'MarkerSize',8);
grid on;
xlabel('Eb/N0 (dB)','FontSize',12);
ylabel('BER','FontSize',12);
legend('BPSK','Logistic','Tent','Proposed','Location','southwest');
title('BER Comparison','FontSize',14);
set(gca,'FontSize',11);
xlim([0 14]);
ylim([1e-6 1]);

%% ===================================
% FER COMPARISON (IMPROVED)
%% ===================================
figure;
semilogy(EbNo_dB,FER_Logistic,'r-s','LineWidth',2,'MarkerSize',6); hold on;
semilogy(EbNo_dB,FER_Tent,'g-d','LineWidth',2,'MarkerSize',6);
semilogy(EbNo_dB,FER_Proposed,'m-x','LineWidth',3,'MarkerSize',8);
grid on;
xlabel('Eb/N0 (dB)','FontSize',12);
ylabel('FER','FontSize',12);
legend('Logistic','Tent','Proposed','Location','southwest');
title('FER Comparison','FontSize',14);
set(gca,'FontSize',11);
xlim([0 14]);
ylim([1e-3 1]);

%% ===================================
% WATERFALL (IMPROVED)
%% ===================================
figure;
semilogy(EbNo_dB,BER_Proposed,'b-o','LineWidth',2,'MarkerSize',8);
xlim([2 10]);
ylim([1e-5 1e-1]);  % Add this for better zoom
grid on;
xlabel('Eb/N0 (dB)','FontSize',12);
ylabel('BER','FontSize',12);
title('Waterfall Region - Proposed Map','FontSize',14);
set(gca,'FontSize',11);