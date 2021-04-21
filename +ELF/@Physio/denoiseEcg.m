function ecg_clean = denoiseEcg(ecg_raw)
%CLEAN_ECG De-noises a raw ECG signal
%   Smooths out electrical interference &c.
    ecg_clean = wdenoise(fillmissing(ecg_raw,'previous'),14, ...
        'Wavelet', 'sym4', ...
        'DenoisingMethod', 'Bayes', ...
        'ThresholdRule', 'Median', ...
        'NoiseEstimate', 'LevelDependent');
    
    
    
    
%     % check if signal is upside-down
% if mean(ECGm(tqrs))<mean(ECGm)
%     ECGm=-ECGm;
% end
end
