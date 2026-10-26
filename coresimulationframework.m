clc;
clear;
close all;

%% =========================
% PARAMETERS
%% =========================
N = 2000;                 % bits/frame
numFrames = 50;
EbNo_dB = 0:2:14;

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

% Progress display - Simulation start
fprintf('\n========================================\n');
fprintf('      SIMULATION STARTED\n');
fprintf('========================================\n');
fprintf('Total SNR points: %d\n', length(EbNo_dB));
fprintf('Frames per SNR: %d\n', numFrames);
fprintf('Bits per frame: %d\n', N);
fprintf('Total bits to process: %d\n', N * numFrames * length(EbNo_dB) * 4);
fprintf('========================================\n\n');

% Start timer
startTime = tic;

for k = 1:length(EbNo_dB)
    
    % Progress display - Current SNR
    fprintf('[%d/%d] Processing Eb/No = %d dB ... ', k, length(EbNo_dB), EbNo_dB(k));
    
    % Start timer for this SNR point
    snrStartTime = tic;

    bitErr_BPSK = 0;

    bitErr_Logistic = 0;
    bitErr_Tent = 0;
    bitErr_Proposed = 0;

    frameErr_Logistic = 0;
    frameErr_Tent = 0;
    frameErr_Proposed = 0;

    for f = 1:numFrames
        
        % Frame progress (shows every 10 frames)
        if f == 1
            fprintf('\n  ');
        end
        if mod(f, 10) == 0
            fprintf('▓');
        end

        %% RANDOM DATA
        data = randi([0 1],1,N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SYSTEM 1
%% CONVENTIONAL BPSK
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
%% SYSTEM 2
%% LOGISTIC MAP
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
%% SYSTEM 3
%% TENT MAP
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
%% SYSTEM 4
%% YOUR PROPOSED MAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        X = zeros(1,N);

        X(1)=0.3;

        for n=1:N-1

            if (X(n)>0) && (X(n)<0.5)

                X(n+1)=mod((X(n)^3+A),3)*X(n);

            else

                X(n+1)=mod(A*(3-X(n)),3);

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

        bitErr_Proposed = bitErr_Proposed + sum(dec~=data);

        if any(dec~=data)
            frameErr_Proposed = frameErr_Proposed + 1;
        end

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    BER_BPSK(k)=bitErr_BPSK/(N*numFrames);

    BER_Logistic(k)=bitErr_Logistic/(N*numFrames);

    BER_Tent(k)=bitErr_Tent/(N*numFrames);

    BER_Proposed(k)=bitErr_Proposed/(N*numFrames);

    FER_Logistic(k)=frameErr_Logistic/numFrames;

    FER_Tent(k)=frameErr_Tent/numFrames;

    FER_Proposed(k)=frameErr_Proposed/numFrames;

    % Progress display - Completion of current SNR
    snrElapsed = toc(snrStartTime);
    fprintf(' ✓ (%.1f sec)\n', snrElapsed);
    
    % Display current results summary
    fprintf('     BER: BPSK=%.2e, Logistic=%.2e, Tent=%.2e, Proposed=%.2e\n', ...
        BER_BPSK(k), BER_Logistic(k), BER_Tent(k), BER_Proposed(k));
    fprintf('     FER: Logistic=%.2e, Tent=%.2e, Proposed=%.2e\n', ...
        FER_Logistic(k), FER_Tent(k), FER_Proposed(k));
    fprintf('\n');

end

% Total time
totalTime = toc(startTime);
fprintf('========================================\n');
fprintf('      SIMULATION COMPLETED\n');
fprintf('========================================\n');
fprintf('Total time: %.2f seconds (%.2f minutes)\n', totalTime, totalTime/60);
fprintf('========================================\n\n');

%% =========================
% PLOTTING
%% =========================

fprintf('Generating plots...\n');

% BER Comparison
figure(1);
semilogy(EbNo_dB, BER_BPSK, 'b-o', 'LineWidth', 2, 'MarkerSize', 8); hold on;
semilogy(EbNo_dB, BER_Logistic, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);
semilogy(EbNo_dB, BER_Tent, 'g-d', 'LineWidth', 2, 'MarkerSize', 8);
semilogy(EbNo_dB, BER_Proposed, 'm-x', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
legend('BPSK', 'Logistic', 'Tent', 'Proposed', 'Location', 'southwest');
title('BER Comparison', 'FontSize', 14);
set(gca, 'FontSize', 11);

% FER Comparison
figure(2);
semilogy(EbNo_dB, FER_Logistic, 'r-s', 'LineWidth', 2, 'MarkerSize', 8); hold on;
semilogy(EbNo_dB, FER_Tent, 'g-d', 'LineWidth', 2, 'MarkerSize', 8);
semilogy(EbNo_dB, FER_Proposed, 'm-x', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('FER', 'FontSize', 12);
legend('Logistic', 'Tent', 'Proposed', 'Location', 'southwest');
title('FER Comparison', 'FontSize', 14);
set(gca, 'FontSize', 11);

% Waterfall Region
figure(3);
semilogy(EbNo_dB, BER_Proposed, 'b-o', 'LineWidth', 2, 'MarkerSize', 10);
xlim([2 10]);
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
title('Waterfall Region - Proposed Map', 'FontSize', 14);
set(gca, 'FontSize', 11);

fprintf('All plots generated successfully!\n');
fprintf('\n===== DONE =====\n');