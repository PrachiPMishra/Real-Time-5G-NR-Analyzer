function updateSpectrum(rfPlot, f_RF, PdB_smooth, rf_lo, rf_hi)

% ==========================================================
% UPDATE RF SPECTRUM DISPLAY
% ==========================================================

% Display only the requested RF range
mask = (f_RF >= rf_lo) & (f_RF <= rf_hi);

set(rfPlot, ...
    'XData', f_RF(mask), ...
    'YData', PdB_smooth(mask));

drawnow limitrate;

end