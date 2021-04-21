function [dibis,nibis,trend,art] = detrendIbis(ibis,settings)
%DETREND_IBI Clean up inter-beat intervals
%   Uses wavelet methods to find aberrant beats
%   inputs:
%       ibis: inter-beat interval series
%   outputs:
%       dibis: de-trended IBI series as vertical vector of duration seconds
%       nibis: non-detrended IBI series
%       trend:
%       art:

    if nargin<2
        settings = defaultHRVASSettings;
    end
    
    %convert to 2-col array of [beats,ibis] (HRVAS format) if necessary
    if length(ibis(1,:))>2; ibis = ibis'; end
    if length(ibis(1,:))==2; ibis = ibis(:,2); end
    if all(isduration(ibis)); ibis = seconds(ibis); end
    ibis_a = [cumsum(ibis),ibis];

    [dibis_a,nibis_a,trend,art]=preProcessIBI(ibis_a, ibiSettings(settings));
    
    %convert back to 1d
    dibis = dibis_a(:,2);
    nibis = nibis_a(:,2);
end

function ibi_preproc_args = ibiSettings(settings)
    %build cell array of locate artifacts methods
    methods={}; methInput=[];
    if settings.ArtLocatePer
        methods=[methods,'percent'];
        methInput=[methInput,settings.ArtLocatePerVal];
    end
    if settings.ArtLocateSD
        methods=[methods,'sd'];
        methInput=[methInput,settings.ArtLocateSDVal];
    end
    if settings.ArtLocateMed
        methods=[methods,'median'];
        methInput=[methInput,settings.ArtLocateMedVal];
    end
    %determine which window/span to use
    if strcmpi(settings.ArtReplace,'mean')
        replaceWin=settings.ArtReplaceMeanVal;
    elseif strcmpi(settings.ArtReplace,'median')
        replaceWin=settings.ArtReplaceMedVal;
    elseif strcmpi(settings.ArtReplace,'spline')
        replaceWin=0;
    else
        replaceWin=0;
    end
    
    ibi_preproc_args.locateMethod = methods;
    ibi_preproc_args.locateInput = methInput;
    ibi_preproc_args.replaceMethod = settings.ArtReplace;
    ibi_preproc_args.replaceInput = replaceWin;
    ibi_preproc_args.detrendMethod = settings.Detrend;
    ibi_preproc_args.smoothMethod = settings.SmoothMethod;
    ibi_preproc_args.smoothSpan = settings.SmoothSpan;
    ibi_preproc_args.smoothDegree = settings.SmoothDegree;
    ibi_preproc_args.polyOrder = settings.PolyOrder;
    ibi_preproc_args.waveletType = ...
        [settings.WaveletType num2str(settings.WaveletType2)];
    ibi_preproc_args.waveletLevels = settings.WaveletLevels;
    ibi_preproc_args.lambda = settings.PriorsLambda;
    ibi_preproc_args.resampleRate = settings.Interp;
    ibi_preproc_args.meanCorrection = true;
end
