function detectPSS(concatX, pssFFTsize, pssFFT, haveNRToolbox, pssThreshold)

% ==========================================================
% PSS DETECTION
% ==========================================================

if haveNRToolbox

    % Compute FFT of received signal
    Xpss = fftshift(fft(concatX, pssFFTsize));

    corrVals = zeros(3,1);

    % Correlate with each PSS sequence
    for nid2 = 0:2

        corrVals(nid2+1) = abs(sum( ...
            Xpss .* conj(pssFFT(:,nid2+1))));

    end

    % Find strongest correlation
    [peakCorr, idx] = max(corrVals);

    detectedNID2 = idx - 1;

    % Detection decision
    if peakCorr > pssThreshold

        fprintf("PSS Detected! NID2 = %d   Corr = %.3f\n", ...
            detectedNID2, peakCorr);

    else

        fprintf("No PSS detected (Corr = %.3f)\n", ...
            peakCorr);

    end

end

end