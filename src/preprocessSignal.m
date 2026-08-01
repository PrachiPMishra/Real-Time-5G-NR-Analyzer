function [concatX, cfoEst, dcbin, notchWidth] = preprocessSignal(concatX, Fs)

% ==========================================================
% PREPROCESS RECEIVED SIGNAL
%   - DC Notch Filtering
%   - Coarse CFO Estimation
%   - CFO Correction
% ==========================================================

%% ---------------- DC notch to reduce Pluto center spike

Xtmp = fftshift(fft(concatX));

dcbin = round(length(Xtmp)/2);

% Zero a small block around DC
notchWidth = 60;

Xtmp(dcbin-notchWidth : dcbin+notchWidth) = 0;

concatX = ifft(ifftshift(Xtmp));

%% ---------------- Coarse CFO estimation & correction

cfoEst = angle(sum(concatX(1:end-1) .* conj(concatX(2:end)))) ...
            * Fs / (2*pi);

n = (0:length(concatX)-1).';

concatX = concatX .* exp(-1j*2*pi*cfoEst*n/Fs);

fprintf("CFO corrected: %.1f Hz | ", cfoEst);

end