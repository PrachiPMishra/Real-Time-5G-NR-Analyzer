function [haveNRToolbox, pssFFT] = createPSSTemplates(pssFFTsize)

% ==========================================================
% PRECOMPUTE PSS TEMPLATES
% Requires 5G Toolbox (nrPSS)
% ==========================================================

%% Check for 5G Toolbox

haveNRToolbox = exist('nrPSS','file') == 2;

if haveNRToolbox

    pssFD = cell(1,3);

    % Generate frequency-domain PSS sequences
    for nid2 = 0:2
        pssFD{nid2+1} = nrPSS(nid2);      % 127 subcarriers
    end

    % Map to FFT bins
    pssFFT = zeros(pssFFTsize,3);

    midP = pssFFTsize/2;
    leftP = midP - 63;

    for nid2 = 0:2

        tmp = zeros(pssFFTsize,1);

        tmp(leftP:leftP+126) = pssFD{nid2+1};

        pssFFT(:,nid2+1) = tmp;

    end

else

    warning("nrPSS() not found. PSS detection will be disabled.");

    % Return an empty matrix so downstream code still works
    pssFFT = [];

end

end