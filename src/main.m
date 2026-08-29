%% ==========================================================
% REAL-TIME 5G NR LIVE VISUALIZER + PSS DETECTOR (PLUTO SDR)
%
% Main Script
% ==========================================================

clear;
clc;
close all;

%% -------------------- USER PARAMETERS --------------------

Fs = 20e6;                      % Pluto baseband sample rate
samplesPerFrame = 32768;        % Samples returned per rx() call
framesPerSpectrum = 4;          % Frames concatenated per FFT
avgSets = 6;                    % FFT averages
Nfft = 131072;                  % FFT size

% ARFCN center selection (example: Jio n78)
ARFCN = 634080;

gain = 45;                      % Pluto RX gain

pssFFTsize = 2048;              % FFT size for PSS templates
pssThreshold = 0.15;            % Detection threshold

% RF display limits (MHz)
rf_lo = 3502;
rf_hi = 3522;

%% -------------------- Sanity Check ------------------------

if framesPerSpectrum * samplesPerFrame ~= Nfft
    warning("framesPerSpectrum * samplesPerFrame != Nfft. Using Nfft = framesPerSpectrum*samplesPerFrame");
    Nfft = framesPerSpectrum * samplesPerFrame;
end

%% -------------------- Initialize Pluto --------------------

[rx, centerFreq] = initPluto( ...
    ARFCN, ...
    Fs, ...
    samplesPerFrame, ...
    gain);

%% -------------------- Create Displays ---------------------

[wf, constDiag, rfPlot] = createDisplays( ...
    Fs, ...
    centerFreq, ...
    rf_lo, ...
    rf_hi);

%% -------------------- Create PSS Templates ----------------

[haveNRToolbox, pssFFT] = createPSSTemplates(pssFFTsize);

%% -------------------- Main Realtime Loop ------------------

fprintf("Starting real-time capture. Press Ctrl+C to stop.\n\n");

try

    while true

        %% Capture Samples

        concatX = captureFrame( ...
            rx, ...
            wf, ...
            samplesPerFrame, ...
            framesPerSpectrum, ...
            Nfft);

        %% Update Constellation

        constDiag( ...
            concatX(1:round(length(concatX)/50):end) ...
            / max(abs(concatX)));

        %% Signal Preprocessing

        [concatX, cfoEst, dcbin, notchWidth] = ...
            preprocessSignal(concatX, Fs);

        %% Compute Spectrum

        [PdB_smooth, f_RF] = computeSpectrum( ...
            rx, ...
            concatX, ...
            avgSets, ...
            Nfft, ...
            framesPerSpectrum, ...
            samplesPerFrame, ...
            dcbin, ...
            notchWidth, ...
            cfoEst, ...
            Fs, ...
            centerFreq);

        %% Update RF Spectrum

        updateSpectrum( ...
            rfPlot, ...
            f_RF, ...
            PdB_smooth, ...
            rf_lo, ...
            rf_hi);

        %% Detect PSS

        detectPSS( ...
            concatX, ...
            pssFFTsize, ...
            pssFFT, ...
            haveNRToolbox, ...
            pssThreshold);

    end

catch ME

    disp('Stopping capture.');

    cleanupRadio(rx);

    rethrow(ME);

end