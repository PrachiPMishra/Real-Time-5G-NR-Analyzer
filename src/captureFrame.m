function concatX = captureFrame(rx, wf, samplesPerFrame, framesPerSpectrum, Nfft)

% ==========================================================
% CAPTURE FRAMES FROM PLUTO SDR
%   - Updates waterfall display
%   - Concatenates frames into one block
% ==========================================================

concatX = zeros(Nfft,1);

for fidx = 1:framesPerSpectrum

    % Capture one frame
    x_frame = rx();

    % Update waterfall
    wf(x_frame);

    % Store into concatenated buffer
    concatX( ...
        (fidx-1)*samplesPerFrame + (1:samplesPerFrame) ...
        ) = x_frame;

end

end