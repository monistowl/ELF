function [ibis, Analysis] = ecg2ibi(ecg_clean,Fs)
%ECG2IBI Calculate inter-beat intervals from ECG signal
%   ibis: R to R intervals in seconds
%   Analysis: output from BioSigKit
%   
%   ecg_clean: de-noised ecg signal
%   Fs: samples per second (Hz)

    if(nargin<2)
        Fs = 1000; %assume 1 sample per ms
    end
    
    Analysis = RunBioSigKit(ecg_clean,Fs,false);
    Analysis.MTEO_qrstAlg;       % MTEO algorithm
    %Analysis.PanTompkins;        % Pan-Tompkins algorithm
    %Analysis.StateMachine;       % State Machine algorithm
    %Analysis.PhaseSpaceAlg;      % Non-linear Phase Space Reconstruction
    %Analysis.FilterBankQRS;      % Filter Bank method

    rpeaks = Analysis.Results.R;         % Peaks of R spikes detected
    %rpeaks = rpeaks(2:end); % trim first peak

    rr = [rpeaks rpeaks(end)]-[0 rpeaks]; %get inter-beat intervals
    rr = rr(1:end-1)'; %trim last value
            
    ibis = rr./Fs; %output in seconds
end

