%% Set up toolkits for Extensible Lab Framework
function ELF_dir = setupELF()
ELF_dir = fileparts(mfilename('fullpath'));
addpath(ELF_dir);

%Helpers -- miscellaneous utility functions
addpath(fullfile(ELF_dir,'Dependencies','Helpers'));

%BioSigKit -- for analyzing ECG (and EMG, EEG...)
%https://github.com/hooman650/BioSigKit
%Sedghamiz, (2018). BioSigKit: A Matlab Toolbox and Interface for Analysis of
% BioSignals. Journal of Open Source Software, 3(30), 671,
% https://doi.org/10.21105/joss.00671
addpath(fullfile(ELF_dir,'Dependencies','BioSigKit'));


%HRVAS -- for calculating HRV from IBIs
%https://github.com/jramshur/HRVAS
%Ramshur, J. (2010). Design, Evaluation, and Application of Heart Rate
% Variability Analysis Software (HRVAS). Masters Thesis. University of Memphis,
% Memphis, TN.
addpath(fullfile(ELF_dir,'Dependencies','HRVAS-master'));


%WFDB toolbox -- for PhysioBank WFDB functions
%Silva, I, Moody, G. "An Open-source Toolbox for Analysing and Processing
% PhysioNet Databases in MATLAB and Octave." Journal of Open Research Software
% 2(1):e27 [http://dx.doi.org/10.5334/jors.bi] ; 2014 (September 24).
% addpath(fullfile(dependencies_dir,'mcode'));

savepath;



end