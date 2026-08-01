function [rx, centerFreq] = initPluto(ARFCN, Fs, samplesPerFrame, gain)

% ==========================================================
% FIND PLUTO DEVICE AND CREATE RECEIVER OBJECT
% ==========================================================

% Convert ARFCN to center frequency
centerFreq = ((ARFCN - 600000) * 15 + 3000000) * 1e3;

% Shift off DC to avoid Pluto center spike
centerFreq = centerFreq + 1e6;

%% Find Pluto
dev = findPlutoRadio;

if isempty(dev)
    error("Pluto SDR not found. Connect the board and run Support Package setup.");
end

radioID = dev.RadioID;

fprintf("Using Pluto: %s\n", radioID);

%% Create Receiver

rx = sdrrx('Pluto', ...
    'RadioID', radioID, ...
    'CenterFrequency', centerFreq, ...
    'BasebandSampleRate', Fs, ...
    'SamplesPerFrame', samplesPerFrame, ...
    'OutputDataType', 'double', ...
    'GainSource', 'Manual', ...
    'Gain', gain);

end