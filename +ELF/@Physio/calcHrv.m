function [hrv_tt,HRVAS_Analysis,dibi] = calcHrv(ibis,settings)
%calcHrv Calculate heart rate variability data
% IMPORTANT: Not all stats makes sense in short windows.
%  Consult <a href="matlab:
%  web('https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5624990/')
%  ">the norms</a>, and <a href="matlab:
%  web('https://www.lesswrong.com/posts/X2AD2LgtKgkRNPj2a/
%   privileging-the-hypothesis')">beware apophenia</a>.
%
% Inputs:
%  ibis: a vector of inter-beat intervals in seconds
%  settings: arg to use custom settings saved from HRVAS GUI
% Outputs:
%  hrv_tt: timetable of second-by-second estimates of HRV measures
%  HRVAS_Analysis: raw output of dependent framework
%
% Syntax:
%  calcHrv(ibis) % Analyze HRV using IBI series, ECG-derived respiration (EDR),
%                % and default analysis settings.
%  calcHrv(ibis,settings) % Pass in custom settings (e.g. saved from hrvGui)
% 
% TODO: Full parser, options for passing in resp, switching between HRVAS
%  and other frameworks.
% 
% Output units for tf include:
%   peakHF,peakLF,peakVLF (Hz)
%   aHF,aLF,aVLF (ms^2)
%   pHF,pLF,pVLF (%)
%   nHF,nLF,nVLF (%)
%   lfhf,rlfhf
%   PSD          (ms^2/Hz)
%   F            (Hz)
%
%See also: hrvGui, hrvFromIbis, defaultHRVASSettings

    warning('off');
    if(nargin<2)
        HRVAS_Analysis.settings = ELF.PhysioData.defaultHRVASSettings();
    else
        HRVAS_Analysis.settings = settings;
    end
    
    ibi_preproc_args = ibiSettings(HRVAS_Analysis.settings);
    
    %convert to vertical 2-col array of numbers if necessary
    if(length(ibis(1,:)) > 2)
        ibis = ibis';
    end
    if(length(ibis(1,:)) == 1)
        t = cumsum(ibis);
        ibis = [t,ibis];
    end
    if(isduration(ibis))
        ibis = seconds(ibis);
    end
    
    [dibi,nibi,~,~]=preProcessIBI(ibis, ibi_preproc_args);
    
    %get time-frequency data from hrvas
    HRVAS_Analysis.tf=timeFreqHRV(dibi,nibi, ...
        HRVAS_Analysis.settings.VLF,HRVAS_Analysis.settings.LF, ...
        HRVAS_Analysis.settings.HF,HRVAS_Analysis.settings.AROrder, ...
        HRVAS_Analysis.settings.tfWinSize,HRVAS_Analysis.settings.tfOverlap, ...
        HRVAS_Analysis.settings.Points,HRVAS_Analysis.settings.Interp, ...
        {'wavelet'});
    

    
    Time = seconds(1:length(HRVAS_Analysis.tf.wav.t))';
    n = length(Time);

    %Get time domain data from HRVAS
    td_winsize = 120; %Window size for moving estimate
    pnnx_ms = 50; %Deviation threshold in ms (e.g. 50 for pNN50)
    HRVAS_Analysis.td = [];
    td_ibis = ibis(ibis(:,1)<td_winsize+2,2); %overshoot ignored
    td_ibis = [ibis(:,2);td_ibis]; %skip first beat
    td_ibis = [cumsum(td_ibis),td_ibis];
    for i=1:n
        td_ibis_win = td_ibis(td_ibis(:,1)>i & td_ibis(:,1)<td_winsize+i+2,2);
        td_ibis_win = [cumsum(td_ibis_win),td_ibis_win];
        td = timeDomainHRV(td_ibis_win,td_winsize/4,pnnx_ms);
        HRVAS_Analysis.td = [HRVAS_Analysis.td,td];
    end
    HRVAS_Analysis.td = struct2table(HRVAS_Analysis.td);
    
    RSA = log(HRVAS_Analysis.tf.wav.hrv.aHF)';
    %HeartRate = 
    %RespirationRate = 
    HFPower = HRVAS_Analysis.tf.wav.hrv.aHF';
    LFPower = HRVAS_Analysis.tf.wav.hrv.aLF';
    LFHFRatio = HRVAS_Analysis.tf.wav.hrv.LFHF';
    
    SDNN = HRVAS_Analysis.td.SDNN;
    %AVNN = 
    RMSSD = HRVAS_Analysis.td.RMSSD;
    NN50 = HRVAS_Analysis.td.NNx;
    pNN50 = HRVAS_Analysis.td.pNNx;
    
    hrv_tt = timetable(Time, RSA, HFPower, LFPower, LFHFRatio, SDNN, RMSSD, ...
        NN50, pNN50);  
%     
%                                       %aVLF    aLF    aHF    aTotal
%     hrv_tt.Properties.VariableUnits = {'ms^2','ms^2','ms^2','ms^2', ...
%     ... %pVLF  pLF  pHF  nLF  nHF  LFHF peakVLF peakLF peakHF ...
%          '%',  '%', '%', '%', '%', '',  'Hz',   'Hz',  'Hz'   };
%
end

function ibi_preproc_args = ibiSettings(settings)
    %ibiSettings Build cell array of locate artifacts methods from settings
    %See also: defaultHRVASSettings
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
    %Determine which window/span to use
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


