function [PdB_smooth, f_RF] = computeSpectrum( ...
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
    centerFreq)

% ==========================================================
% COMPUTE SMOOTH RF SPECTRUM
%   - FFT Averaging
%   - Windowing
%   - Power Spectrum
%   - Frequency Smoothing
% ==========================================================

%% Build high-resolution smooth spectrum

acc = zeros(Nfft,1);

% Use the already processed block as the first average
for aset = 1:avgSets

    if aset == 1

        block = concatX;

    else

        % Capture frames for averaging
        tmpBlock = zeros(Nfft,1);

        for fidx = 1:framesPerSpectrum

            tmpBlock( ...
                (fidx-1)*samplesPerFrame + (1:samplesPerFrame) ...
                ) = rx();

        end

        %% Apply DC notch

        Xtmp2 = fftshift(fft(tmpBlock));

        Xtmp2(dcbin-notchWidth : dcbin+notchWidth) = 0;

        tmpBlock = ifft(ifftshift(Xtmp2));

        %% Apply CFO correction

        tmpBlock = tmpBlock .* ...
            exp(-1j*2*pi*cfoEst*(0:length(tmpBlock)-1)'/Fs);

        block = tmpBlock;

    end

    %% Windowing

    w = hann(Nfft);

    %% FFT

    Xb = fftshift(fft(block .* w, Nfft));

    %% Power accumulation

    acc = acc + abs(Xb).^2;

end

%% Average power

Pavg = acc / avgSets;

PdB = 10*log10(Pavg + eps);

%% Normalize to peak

PdB = PdB - max(PdB);

%% Smooth spectrum

PdB_smooth = movmean(PdB,200);

%% Frequency axis

f_base = linspace(-Fs/2, Fs/2, Nfft);

f_RF = (centerFreq + f_base)/1e6;

end