clc;
clear;
close all;

%% =========================
% PARAMETERS
%% =========================
N = 2000;                 % bits/frame
numFrames = 200;          % Increased for better accuracy
EbNo_dB = 0:1:14;         % More points for smoother curves

BER_BPSK = zeros(size(EbNo_dB));
BER_Logistic = zeros(size(EbNo_dB));
BER_Tent = zeros(size(EbNo_dB));
BER_Proposed = zeros(size(EbNo_dB));

FER_Logistic = zeros(size(EbNo_dB));
FER_Tent = zeros(size(EbNo_dB));
FER_Proposed = zeros(size(EbNo_dB));

A = 1.7;

%% =========================
% Eb/N0 LOOP
%% =========================

fprintf('Starting Simulation...\n');
fprintf('Total SNR points: %d\n', length(EbNo_dB));
fprintf('Frames per SNR: %d\n', numFrames);
fprintf('Total bits per SNR: %d\n\n', N*numFrames);

tic; % Start timer

for k = 1:length(EbNo_dB)
    
    bitErr_BPSK = 0;
    bitErr_Logistic = 0;
    bitErr_Tent = 0;
    bitErr_Proposed = 0;
    
    frameErr_Logistic = 0;
    frameErr_Tent = 0;
    frameErr_Proposed = 0;
    
    for f = 1:numFrames
        
        %% RANDOM DATA
        data = randi([0 1],1,N);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% SYSTEM 1 - CONVENTIONAL BPSK
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tx1 = 2*data - 1;
        Ps = mean(tx1.^2);
        SNR = 10^(EbNo_dB(k)/10);
        Pn = Ps/SNR;
        noise = sqrt(Pn)*randn(1,N);
        rx1 = tx1 + noise;
        dec1 = rx1 > 0;
        bitErr_BPSK = bitErr_BPSK + sum(dec1~=data);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% SYSTEM 2 - LOGISTIC MAP
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        X = zeros(1,N);
        X(1)=0.3;
        r = 4;
        for n=1:N-1
            X(n+1)=r*X(n)*(1-X(n));
        end
        key = X > mean(X);
        enc = xor(data,key);
        tx = 2*enc - 1;
        Ps = mean(tx.^2);
        Pn = Ps/SNR;
        noise = sqrt(Pn)*randn(1,N);
        rx = tx + noise;
        rx_bits = rx > 0;
        dec = xor(rx_bits,key);
        bitErr_Logistic = bitErr_Logistic + sum(dec~=data);
        if any(dec~=data)
            frameErr_Logistic = frameErr_Logistic + 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% SYSTEM 3 - TENT MAP
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        X = zeros(1,N);
        X(1)=0.3;
        mu = 2;
        for n=1:N-1
            if X(n)<0.5
                X(n+1)=mu*X(n);
            else
                X(n+1)=mu*(1-X(n));
            end
        end
        key = X > mean(X);
        enc = xor(data,key);
        tx = 2*enc - 1;
        Ps = mean(tx.^2);
        Pn = Ps/SNR;
        noise = sqrt(Pn)*randn(1,N);
        rx = tx + noise;
        rx_bits = rx > 0;
        dec = xor(rx_bits,key);
        bitErr_Tent = bitErr_Tent + sum(dec~=data);
        if any(dec~=data)
            frameErr_Tent = frameErr_Tent + 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% SYSTEM 4 - PROPOSED MAP
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        X = zeros(1,N);
        X(1)=0.3;
        
        for n=1:N-1
            epsilon = 1e-10;
            if (X(n) > epsilon) && (X(n) < 0.5 - epsilon)
                X(n+1) = mod((X(n)^3 + A), 3) * X(n);
            else
                X(n+1) = mod(A * (3 - X(n)), 3);
            end
            X(n+1) = max(0, min(3, X(n+1)));
        end
        
        key = X > mean(X);
        enc = xor(data,key);
        tx = 2*enc - 1;
        Ps = mean(tx.^2);
        Pn = Ps/SNR;
        noise = sqrt(Pn)*randn(1,N);
        rx = tx + noise;
        rx_bits = rx > 0;
        dec = xor(rx_bits,key);
        bitErr_Proposed = bitErr_Proposed + sum(dec~=data);
        if any(dec~=data)
            frameErr_Proposed = frameErr_Proposed + 1;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% SAVE RESULTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BER_BPSK(k) = bitErr_BPSK/(N*numFrames);
    BER_Logistic(k) = bitErr_Logistic/(N*numFrames);
    BER_Tent(k) = bitErr_Tent/(N*numFrames);
    BER_Proposed(k) = bitErr_Proposed/(N*numFrames);
    
    FER_Logistic(k) = frameErr_Logistic/numFrames;
    FER_Tent(k) = frameErr_Tent/numFrames;
    FER_Proposed(k) = frameErr_Proposed/numFrames;
    
    % Display progress
    fprintf('Completed Eb/No = %d dB (%.1f%%)\n', EbNo_dB(k), (k/length(EbNo_dB))*100);
end

elapsedTime = toc;
fprintf('\nSimulation completed in %.2f seconds\n', elapsedTime);

%% =========================
% THEORETICAL BER FOR BPSK
%% =========================
EbNo_lin = 10.^(EbNo_dB/10);
BER_theory = 0.5*erfc(sqrt(EbNo_lin));

%% =========================
% PLOTTING RESULTS
%% =========================

% Figure 1: BER Comparison with Theory
figure(1);
semilogy(EbNo_dB, BER_theory, 'k-', 'LineWidth', 2, 'DisplayName', 'BPSK Theory'); hold on;
semilogy(EbNo_dB, BER_BPSK, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'BPSK Simulation');
semilogy(EbNo_dB, BER_Logistic, 'r-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Logistic Map');
semilogy(EbNo_dB, BER_Tent, 'g-^', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Tent Map');
semilogy(EbNo_dB, BER_Proposed, 'm-d', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Proposed Map');
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 10);
title('BER Performance Comparison', 'FontSize', 14);
set(gca, 'FontSize', 11);
axis([0 14 1e-6 1]);

% Figure 2: FER Comparison
figure(2);
semilogy(EbNo_dB, FER_Logistic, 'r-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Logistic Map'); hold on;
semilogy(EbNo_dB, FER_Tent, 'g-^', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Tent Map');
semilogy(EbNo_dB, FER_Proposed, 'm-d', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Proposed Map');
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('Frame Error Rate (FER)', 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 10);
title('FER Performance Comparison', 'FontSize', 14);
set(gca, 'FontSize', 11);
axis([0 14 1e-3 1]);

% Figure 3: Combined BER and FER for Proposed System
figure(3);
semilogy(EbNo_dB, BER_Proposed, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'BER - Proposed'); hold on;
semilogy(EbNo_dB, FER_Proposed, 'r-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'FER - Proposed');
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('Error Rate', 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 10);
title('BER vs FER for Proposed System', 'FontSize', 14);
set(gca, 'FontSize', 11);
axis([0 14 1e-4 1]);

% Figure 4: All Chaotic Systems BER (Zoomed)
figure(4);
semilogy(EbNo_dB, BER_Logistic, 'r-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Logistic Map'); hold on;
semilogy(EbNo_dB, BER_Tent, 'g-^', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Tent Map');
semilogy(EbNo_dB, BER_Proposed, 'm-d', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Proposed Map');
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 10);
title('Chaotic Systems BER Comparison (Zoomed)', 'FontSize', 14);
set(gca, 'FontSize', 11);
axis([0 14 1e-5 1e-1]);

%% =========================
% DISPLAY NUMERIC RESULTS
%% =========================
fprintf('\n========== RESULTS SUMMARY ==========\n');
fprintf('\nBER Results:\n');
fprintf('Eb/No(dB)\tBPSK Theory\tBPSK Sim\tLogistic\tTent\t\tProposed\n');
fprintf('--------------------------------------------------------------------\n');
for k = 1:length(EbNo_dB)
    fprintf('%d\t\t%.2e\t%.2e\t%.2e\t%.2e\t%.2e\n', ...
        EbNo_dB(k), BER_theory(k), BER_BPSK(k), BER_Logistic(k), BER_Tent(k), BER_Proposed(k));
end

fprintf('\nFER Results:\n');
fprintf('Eb/No(dB)\tLogistic\tTent\t\tProposed\n');
fprintf('----------------------------------------------\n');
for k = 1:length(EbNo_dB)
    fprintf('%d\t\t%.2e\t%.2e\t%.2e\n', ...
        EbNo_dB(k), FER_Logistic(k), FER_Tent(k), FER_Proposed(k));
end

%% =========================
% PERFORMANCE ANALYSIS
%% =========================
fprintf('\n========== PERFORMANCE ANALYSIS ==========\n');

% Find SNR for BER = 10^-3
targetBER = 1e-3;
for k = 1:length(EbNo_dB)
    if BER_Proposed(k) <= targetBER
        fprintf('Proposed Map achieves BER < 10^{-3} at %d dB\n', EbNo_dB(k));
        break;
    end
end

% Find SNR for FER = 10^-1
targetFER = 1e-1;
for k = 1:length(EbNo_dB)
    if FER_Proposed(k) <= targetFER
        fprintf('Proposed Map achieves FER < 10^{-1} at %d dB\n', EbNo_dB(k));
        break;
    end
end

% Compare at 10 dB
idx10 = find(EbNo_dB == 10);
fprintf('\nAt 10 dB SNR:\n');
fprintf('  Logistic BER: %.2e, FER: %.2e\n', BER_Logistic(idx10), FER_Logistic(idx10));
fprintf('  Tent BER: %.2e, FER: %.2e\n', BER_Tent(idx10), FER_Tent(idx10));
fprintf('  Proposed BER: %.2e, FER: %.2e\n', BER_Proposed(idx10), FER_Proposed(idx10));

%% =========================
% SAVE RESULTS TO FILE
%% =========================
save('chaos_simulation_results.mat', 'EbNo_dB', 'BER_BPSK', 'BER_Logistic', ...
     'BER_Tent', 'BER_Proposed', 'FER_Logistic', 'FER_Tent', 'FER_Proposed', ...
     'BER_theory', 'N', 'numFrames');

fprintf('\nResults saved to "chaos_simulation_results.mat"\n');
fprintf('\n===== SIMULATION COMPLETE =====\n');