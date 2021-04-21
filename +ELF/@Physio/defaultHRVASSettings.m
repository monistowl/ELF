function settings = defaultHRVASSettings()
%defaultHRVASSettings Return struct of default settings for HRVAS analysis
%See also: HRVAS
    settings = struct;
    settings.ArtLocatePer = 1;
    settings.ArtLocatePerVal = 20;
    settings.ArtLocateSD = 1;
    settings.ArtLocateSDVal = 3;
    settings.ArtLocateMed = 1;
    settings.ArtLocateMedVal = 4;
    settings.ArtReplace = 'Spline';
    settings.ArtReplaceMeanVal = 9;
    settings.ArtReplaceMedVal = 5;
    %settings.Detrend = 'Wavelet';
    settings.Detrend = 'Smothness Priors';
    settings.SmoothMethod = 'loess';
    settings.SmoothSpan = 5;
    settings.SmoothDegree = 0.1;
    settings.PolyOrder = 1;
    settings.WaveletType = 'db';
    settings.WaveletType2 = 3;
    settings.WaveletLevels = 6;
    settings.PriorsLambda = 10;
    settings.pNNx = 50;
    settings.SDNNi = 1;
    settings.VLF = [0 0.04];
    settings.LF = [0.04 0.15];
    settings.HF = [0.15 0.4];
    settings.Interp = 1; %sampling frequency for output (Hz)
    settings.Points = 1024;
    settings.WinWidth = 128;
    settings.WinOverlap = 64;
    settings.AROrder = 16;
    settings.m = 3;
    settings.r = 0.1;
    settings.n1 = 4;
    settings.n2 = 100;
    settings.breakpoint = 13;
    settings.tfWinSize = 30;
    settings.tfOverlap = 15;
    settings.headerSize = 0;
end

%% From Greg
% 
% function settings = defaultHRVASSettings()
% 
%     settings = struct;
%     settings.ArtLocatePer = 1;
%     settings.ArtLocatePerVal = 20;
%     settings.ArtLocateSD = 1;
%     settings.ArtLocateSDVal = 3;
%     settings.ArtLocateMed = 1;
%     settings.ArtLocateMedVal = 4;
%     settings.ArtReplace = 'Spline';
%     settings.ArtReplaceMeanVal = 9;
%     settings.ArtReplaceMedVal = 5;
%     %settings.Detrend = 'Wavelet';
%     settings.Detrend = 'Smothness Priors';
%     settings.SmoothMethod = 'loess';
%     settings.SmoothSpan = 5;
%     settings.SmoothDegree = 0.1;
%     settings.PolyOrder = 1;
%     settings.WaveletType = 'db';
%     settings.WaveletType2 = 3;
%     settings.WaveletLevels = 6;
%     settings.PriorsLambda = 10;
%     settings.pNNx = 50;
%     settings.SDNNi = 1;
%     settings.VLF = [0 0.04];
%     settings.LF = [0.04 0.15];
%     settings.HF = [0.15 0.4];
%     settings.Interp = 1; %sampling frequency for output (Hz)
%     settings.Points = 1024;
%     settings.WinWidth = 128;
%     settings.WinOverlap = 64;
%     settings.AROrder = 16;
%     settings.m = 3;
%     settings.r = 0.1;
%     settings.n1 = 4;
%     settings.n2 = 100;
%     settings.breakpoint = 13;
%     settings.tfWinSize = 30;
%     settings.tfOverlap = 15;
%     settings.headerSize = 0;
% end