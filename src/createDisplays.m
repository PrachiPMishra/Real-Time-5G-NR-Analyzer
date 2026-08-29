function [wf, constDiag, rfPlot] = createDisplays(Fs, centerFreq, rf_lo, rf_hi)

% ==========================================================
% CREATE DISPLAY OBJECTS
%   - Waterfall (Spectrogram)
%   - Constellation Diagram
%   - RF Spectrum Figure
% ==========================================================

%% Waterfall Display

wf = dsp.SpectrumAnalyzer( ...
    SampleRate = Fs, ...
    SpectrumType = "Spectrogram", ...
    TimeSpan = 5, ...
    FrequencySpan = "Span and Center Frequency", ...
    Span = Fs/2, ...
    CenterFrequency = 0, ...
    ColorLimits = [-120 -20], ...
    Title = "5G Waterfall (Spectrogram)");

%% Constellation Diagram

constDiag = comm.ConstellationDiagram( ...
    "Title","Raw IQ Constellation", ...
    "ShowReferenceConstellation", false, ...
    "XLimits",[-1 1], ...
    "YLimits",[-1 1]);

%% RF Spectrum Figure

figure( ...
    'Name','Smooth RF Spectrum (2500-4500 MHz)', ...
    'NumberTitle','off');

rfPlot = plot(nan,nan,'y','LineWidth',1.5);

hold on;
grid on;

xlabel('Frequency (MHz)');
ylabel('Power (dB)');
title('Smooth RF Spectrum');

xline(centerFreq/1e6,'--r','Center','LineWidth',1.0);

xlim([rf_lo rf_hi]);
ylim([-100 0]);

drawnow;

end