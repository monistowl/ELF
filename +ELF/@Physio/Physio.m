classdef Physio < ELF.ELF_HandleObj
%Physio: Physiological data and processing routines
% Channel data from mindware files and associated cleaning code
%  (e.g. de-noising ECG, calculating HRV)
% Can be used standalone or as part of a parent Task (to combine/batch)
%See also: Task, Event, Behav
    
    %% MAIN PROPERTIES    
    properties
    %These are SAVED whenever the object is saved
    %Inherited from ELF_HandleObj:
    % path = '' %Source file
    % savepath = '' %Where to save object
    % problems = []; %List of issues to troubleshoot

        Fs = 1000; %Samples per second of raw physio (Hz)
        
        ecg = []; %De-noised electrocardiogram signal
        resp = []; %De-noised respiration signal
        gsc = []; %De-noised galvanic skin conductance signal
        emg = []; %De-noised electromyogram signal
        
        %Channel names to search for in raw .mw
        % Will find FIRST match -- use pickChannels to customize.
        channel_names = struct( ...
            'ecg','ECG','resp','RESP','gsc','GSC','emg','EMG');
        
        ibis = []; %Inter-beat intervals (s)
        
        cleaner = ''; %Name of person who cleaned heartbeats
                      % (If not set, will pause before caclHRV by default)
        
        hrv_tt = table; %Timetable of calculated HRV stats
        
        BioSigKit_Analysis %Output from BioSigKit
        HRVAS_Analysis %Output from HRVAS
    end
    
    %% TRANSIENT PROPERTIES
    properties (Transient)
        % These are NOT SAVED -- data is left in original file
        
        raw_data_tt = timetable(); %Timetable of raw physio readings from file
    end
    
    %% DEPENDENT PROPERTIES
    properties (Dependent)
        % These are calculated on the fly from the main properties above,
        % using get.propertyname methods below
        
        ecg_tt %Timetable of de-noised ecg signal
        resp_tt %Timetable of de-noised respiration signal
        gsc_tt %Timetable of de-noised galvanic skin current signal
        emg_tt %Timetable of de-noised electromyography signal
        
        
        channel_names_t %Channel name assignments as table
        ecg_channel %Search string for ECG channel
        resp_channel %Search string for respiration channel
        gsc_channel %Search string for GSC channel
        emg_channel %Search string for EMG channel
        
        
        ibis_a %2-col array of [beattime,ibi] in seconds
        beat_idx %ECG-length vector of 0s, 1 if beat, calculated from IBIs
        ibis_tt %Timetable of inter-beat intervals
        ecg_with_beats_tt %ECG with column of beat indices, for plotting
        hand_cleaned %True if someone has certified clean beats
        
        hrv_t %HRV data as table (not timetable)
        hrv_vars %Available vars (for window functions)
        psd %Power spectrum density
        
        %Quick booleans testing whether fields have been set yet
        
        has_raw %True if raw physio channels have been read
        has_ecg %True if ECG has been imported and de-noised
        has_gsc %True if GSC has been imported and de-noised
        has_resp %True if respiration has been imported and de-noised
        has_emg %True if EMG has been imported and de-noised
        has_ibis %True if IBI series is present
        has_hrv %True if HRV timetable has been calculated
        
        Time %Column vector of shared physio timestamps as durations
        
        %TODO
        %resp_clean_tt
        %emg_clean_tt
        %gsc_clean_tt
    end
    
    %% PUBLIC METHODS
    methods
        %% CONSTRUCTOR
        function Physio = Physio(sourcepath,varargin)
        %Physio Initialize Physio object
        % ELF.Physio() % Create a totally empty object
        % ELF.Physio(sourcepath) % Reads file and runs preproc
        % ELF.Physio(sourcepath,'PreprocNow',false) % Just set sourcepath
        % ELF.Physio(sourcepath,'ChannelNames',channel_names) %Specify channels
        %  e.g. struct('ecg','ECG','resp','RESP','gsc','GSC','emg','EMG')
        % ELF.Physio(Physio) %Open existing Physio object
        % ELF.Physio(file.mat) %Load from file 
        %See also: preproc, importFromPath, save, open
            
            %Parse sourcepath and PreprocNow
            if nargin==0; sourcepath=''; end
            Physio=Physio@ELF.ELF_HandleObj(sourcepath,varargin{:});
            
            %Parses additional options (for validation see setters)
            p = inputParser;
            p.KeepUnmatched=true;
            p.addParameter('ChannelNames', struct( ...
                'ecg','ECG','resp','RESP','gsc','GSC','emg','EMG'));
            p.parse(varargin{:});
            Physio.channel_names = p.Results.ChannelNames;
        end
        
        %% PREPROC
        function preproc(Physio,handclean)
        %preproc Read source file and (re)analyze data
        % If no sourcepath, abort and return object as-is
        % Read input file, choosing appropriate type by file extension
        % Physio.preproc %stop before HRV, wait for IBI beat correction
        % Physio.preproc(skip_handclean) %calc HRV without manual fixBeats
        %See also: ELF.Physio.fixBeats, ELF.Physio.importFromPath
        
            if ~Physio.has_sourcepath; return; end %if no source, leave empty
        
            if nargin<2; handclean = false; end
            Physio.importFromPath;
            
            if ~Physio.has_ecg && Physio.has_raw        
                try
                    Physio.ecgFromMw;
                    %P.respFromMw;
                catch ME
                    Physio.addProblem(ME);
                end
            end
            
            if Physio.has_ecg && ~Physio.has_ibis; Physio.ibisFromEcg; end
            %if P.has_resp; P.respFromMw; end
            
            if Physio.has_ibis && (~handclean || Physio.hand_cleaned); ...
                Physio.hrvFromIbis; end
        end
        
        %Launch GUI
        function gui(Physio); PhysioGui(Physio); end
        
        function importFromPath(Physio,sourcepath)
        %Physio.importFromPath Grab data from file, guessing type by extension
        % Physio.importFromPath %Use stored sourcepath, abort if not set
        % Physio.importFromPath(sourcepath) %Use specified sourcepath
        %See also: rawFromMwFile, hrvFromMwRealtimeTxt, ibisFromFile
        
            if nargin<2; sourcepath = Physio.sourcepath; end
            if strcmp(sourcepath,'')
                Physio.addProblem(MException('Physio:SourceNotSet', ...
                    'Tried to import file, but no sourcepath specified!'));
                return;
            end
            
            Physio.clearProblems; %new data, old problems obsolete
            [folder, filename, extension] = fileparts(sourcepath);
            try %attempt to read appropriate data based on file extension
                if exist(fullfile(folder,strcat(filename,extension)),'file')
                    switch extension
                        case '.mw'
                            Physio.rawFromMwFile();
                        case '.txt'
                            Physio.hrvFromMwRealtimeTxt();
                        case '.ibi'
                            Physio.ibisFromFile();
                        otherwise
                            error('Unknown file type: %s',extension);
                    end
                else
                    error('Physio:SourceNotFound', ...
                        'Could not find file: %s',sourcepath);
                end
            catch ME
                Physio.addProblem(ME);
            end
        end

        %pickChannels.m: select which mindware channels to use for what
        pickChannels(Physio)
        

        function plotAll(Physio)
        %plotAll Spit out graphs for ECG, IBI, HRV, and wavelet PSD
        %See also: plotEcg, plotIbis, plotHrv, plotPsd

            Physio.plotEcg;
            Physio.plotIbis;
            Physio.plotHrv;
            Physio.plotPsd;
        end
        
        function plotEcg(Physio,withbeats)
        %plotEcg Plot denoised ECG signal
        % plotEcg %Just the signal
        % plotEcg(withbeats) %If true and IBIs available, plot beats 
        
            if nargin<2 || ~withbeats || ~Physio.has_ibis; withbeats=false; end

            figure;
            plot(Physio.ecg_tt.Time,Physio.ecg)
            
            if withbeats
                hold on;
                plot(Physio.ecg_with_beats_tt.Time, ...
                    Physio.ecg_with_beats_tt.Beats)  
            end
            
            xlabel('Time (s)');
            ylabel('Amplitude (v)');
            if withbeats
                legend({'ECG Signal','R-Spikes'});
                title('ECG with R Peaks');
            else
                legend({'ECG Signal'});
                title('ECG (denoised)');
            end
        end
        
        function plotHrv(Physio)
            figure;
            plot(Physio.hrv_tt.Time,Physio.hrv_tt.LFPower);
            hold on;
            plot(Physio.hrv_tt.Time,Physio.hrv_tt.HFPower);
            xlabel('s');
            ylabel('ms^2');
            legend({'LFPower','HFPower'});
            title('HRV (absolute units)');
        end 
        
        function plotIbis(Physio)
            figure;
            plot(Physio.ibis_tt.Time,Physio.ibis_tt.IBI);
            xlabel('Time (s)');
            ylabel('R-R IBI (s)');
            title('Inter-Beat Intervals');
        end
        
        function plotPsd(Physio)
            mesh(Physio.HRVAS_Analysis.tf.wav.psd);
        end
        
        %calculate HRV stats as Windows (IMPROVED)
        [Window,unstacked_wins] = hrvWinStats(Physio,varargin)
        
        %calculate HRV stats within a window (DEPRECATED)
        stats = hrvWinStatsStruct(Physio,window_start,window_end,vars,func) 
        
        %backwards-calculate max value / time of max value of vars in wins
        win_max_t = hrvWinMax(Physio,Windows,WinVars)
        
        %as above but min instead of max
        win_min_t = hrvWinMin(Physio,Windows,WinVars)
        
        function rawFromMwFile (P,sourcepath)
        %rawFromMwFile: Set raw_data_tt from sourcepath to .Mw file
        % rawFromMwFile %Read from saved P.sourcepath
        % rawFromMwFile(sourcepath) %Read from specified sourcepath
        %See also: readMw, ecgFromMw
        
            if nargin<2; sourcepath=P.sourcepath; end
            [P.raw_data_tt,P.Fs] = ... %read raw data from file
                ELF.Physio.readMw(sourcepath);
        end
        
        function ecgFromMw(P,channel_name)
        %ecgFromMw Set ecg from raw_data_tt and denoise
        % ecgFromMw %Finds first channel name containing 'ECG'
        % ecgFromMw(channel_name) %Finds specified channel name
        %See also: rawFromMwFile, ecg2ibi

            if nargin<2; channel_name=P.channel_names.ecg; end
            try 
                raw_ecg = P.findChannel(channel_name);
            catch ME
                P.addProblem(ME);
            end
            P.ecg = ELF.Physio.denoiseEcg(raw_ecg);
        end
        
        function respFromMw(P,channel_name)
        %respFromMw Set resp from raw_data_tt and denoise
        % respFromMw %Finds first channel name containing 'RESP'
        % respFromMw(channel_name) %Finds specified channel name
        %See also: rawFromMwFile

            if nargin<2; channel_name=P.channel_names.resp; end
            try 
                raw_resp = P.findChannel(channel_name);
            catch
                P.addProblem(ME);
            end
            P.resp = ELF.Physio.denoiseResp(raw_resp);
        end
        
        function gscFromMw(Physio,channel_name)
        %gscFromMw Set GSC from raw_data_tt and denoise
        % gscFromMw %Finds first channel name containing 'GSC'
        % gscFromMw(channel_name) %Finds specified channel name
        %See also: rawFromMwFile
        
            if nargin<2; channel_name=Physio.channel_names.gsc; end
            try 
                raw_gsc = Physio.findChannel(channel_name);
            catch ME
                Physio.addProblem(ME);
            end
            Physio.gsc = ELF.Physio.denoiseGsc(raw_gsc);
        end
        
        function emgFromMw(Physio,channel_name)
        %emgFromMw Set EMG from raw_data_tt and denoise
        % emgFromMw %Finds first channel name containing 'EMG'
        % emgFromMw(channel_name) %Finds specified channel name
        %See also: rawFromMwFile
        
        if nargin<2; channel_name=Physio.channel_names.emg; end
            try 
                raw_emg = Physio.findChannel(channel_name);
            catch ME
                Physio.addProblem(ME);
            end
            Physio.emg = ELF.Physio.denoiseGsc(raw_emg);
        end
        
        function ibisFromEcg(Physio)
        %ibisFromEcg Use ECG to find R peaks and calculate IBI series
        %See also: fixBeats, ibisFromFile
            
            if ~Physio.has_ecg
                Physio.addProblem(MException('Physio:EcgNotFound', ...
                    'Tried to calc IBIs from ECG, but had no ECG signal!'));
                return;
            end
                
            try
                [Physio.ibis,Physio.BioSigKit_Analysis] = ... %get beats
                    ELF.Physio.ecg2ibi(Physio.ecg,Physio.Fs);
            catch ME
                Physio.addProblem(ME);
            end
        end
        
        function ibis = ibisFromFile(Physio,ibi_path)
        %ibisFromFile Read IBI series from file
        % TODO
        %See also: ibisFromEcg, ibisFromMwEdit, fixBeats
        
        end
        
        function ibis = ibisFromMwEdit(Physio,edh_path)
        %ibisFromEdh Read hand-cleaned ibis from .edh (Mw edit file)
        % TODO
        %See also: ibisFromEcg, ibisFromFile, fixBeats
        end
        
        function hrvFromMwRealtimeTxt(Physio,mwrt_path)
        %hrvFromMwRealtimeTxt: populate HRV table from pre-analyzed RT write
        %
        %See also: readMwRealtime
            if nargin<2; mwrt_path = Physio.sourcepath; end
            Physio.hrv_tt = ELF.Physio.readMwRealtime(mwrt_path);
        end
        
        function hrvFromIbis(Physio,settings)
        %hrvFromIbis Use IBI series to calculate HRV
        % hrvFromIbis %Use default HRV settings
        % hrvFromIbis %Use custom settings
        %See also: calcHrv, hrvGui, defaultHRVASSettings
            if nargin<2; settings=ELF.Physio.defaultHRVASSettings; end 
            try
                [Physio.hrv_tt,Physio.HRVAS_Analysis] = ...
                    ELF.Physio.calcHrv(Physio.ibis,settings);
            catch ME
                Physio.addProblem(ME);
            end
        end
        
        function respFromIbis(Physio,ibis)
        %respFromIbis Calculate ECG-derived respiration
        % TODO
        %See also: ibi2resp
            if nargin<2; ibis=Physio.ibis; end
            try
                Physio.resp = ELF.Physio.ibi2resp(ibis);
            catch ME
                Physio.addProblem(ME);
            end
        end
        
        function exportIbis(Physio,ibi_savepath)
        %exportIbis Export IBI series to file
        % exportIbis % Prompts for savepath
        % exportIbis(savepath) % Writes to specified file
        %  (File extension determines save type: .csv, .xlsx, &c.
        % TODO: format options (ms or s, w or w/o beats, horizontal, &c.)
        %See also: ELF.Physio.writeIbis, writetable
        
            if nargin<2; [~,ibi_savepath] = uiputfile(); end
            ELF.Physio.writeIbis(Physio.ibis,ibi_savepath);
        end
        
        function exportHrv(Physio,hrv_savepath)
        %exportHrv Export HRV table to file
        % exportHrv % Prompts for savepath
        % exportHrv(savepath) % Writes to specified file
        %  (File extension determines save type: .csv, .xlsx, &c.)
        
            if nargin<2; [~,hrv_savepath] = uiputfile(); end
            ELF.Physio.writeHrv(Physio.hrv_t,hrv_savepath);
        end
        
        %fixBeats Clean up IBI by hand-correcting
        fixBeats(Physio)
        
        %hrvGui HRVAS wrapper
        hrvGui(Physio)
        
    end
    
    methods
    %% GETTERS AND SETTERS

        % SETTERS: Do bounds-checking when values are assigned
        
        function Physio = set.channel_names(Physio,new_channel_names)
        %channel_names Validate and set struct of channel names for .mw
            if ~isstruct(new_channel_names) || ...
                    length(intersect({'ecg'},fieldnames(new_channel_names)))<1
                Physio.addProblem(MException('Physio:BadChannelNames', ...
                    strcat('Invalid channel names!\n', ...
                    'Must be a struct with .ecg, .resp, .gsc, .emg')));
                new_channel_names = struct( ... %Use defaults
                    'ecg','ECG','resp','RESP','gsc','GSC','emg','EMG');
            end
                    
            Physio.channel_names=new_channel_names;
        end
            
        % GETTERS: Calculate dependent properties on the fly
        
        function ecg_tt = get.ecg_tt(Physio)
            ecg_tt = timetable(Physio.ecg,'SamplingRate',Physio.Fs, ...
                'VariableNames',{'ECG'});
        end
        
        function ibis_a = get.ibis_a(Physio)
        %ibis_a Get IBIs as array of doubles (in seconds)
            ibis_a = [cumsum(Physio.ibis),Physio.ibis];
        end
        
        function ibis_tt = get.ibis_tt(P)
        %ibis_tt Get IBIs as timetable
            ibis_tt = timetable(seconds(cumsum(P.ibis)),seconds(P.ibis), ...
                'VariableNames',{'IBI'});
        end
        
        function beat_idx = get.beat_idx(P)
        %beat_idx Get beat indices
            beat_idx = zeros(length(P.ecg),1);
            
            beats = round((cumsum(P.ibis)*P.Fs));
            beat_idx(beats,:) = 1;
            beat_idx(length(P.ecg)+1:end) = [];
        end
        
        %Get power spectrum density (wavelet)
        function psd = get.psd(P); psd = P.HRVAS_Analysis.tf.wav.psd; end
        
        function ecg_with_beats_tt = get.ecg_with_beats_tt(P)
        %ecg_with_beats_tt Clean ecg timetable with IBI beats as bools
            ECG = P.ecg;
            Beats = P.beat_idx;
            ecg_with_beats_tt = timetable(P.Time,ECG,Beats);
        end
        
        function hrv_t = get.hrv_t(Physio)
        %hrv_t Get HRV as simple table (not timetable)
            hrv_t = timetable2table(Physio.hrv_tt);
        end
        
        function hrv_vars = get.hrv_vars(Physio)
        %hrv_vars List vars available for HRV window functions
            hrv_vars = Physio.hrv_tt.Properties.VariableNames;
        end
        
        %channel name struct interfaces
        function ecg_channel = get.ecg_channel(Physio); ...
            ecg_channel = Physio.channel_names.ecg; end
        function set.ecg_channel(Physio,name); ...
            Physio.channel_names.ecg = name; end
        function resp_channel = get.resp_channel(Physio); ...
            resp_channel = Physio.channel_names.resp; end
        function set.resp_channel(Physio,name); ...
            Physio.channel_names.resp = name; end
        function gsc_channel = get.gsc_channel(Physio); ...
        	gsc_channel = Physio.channel_names.gsc; end
        function set.gsc_channel(Physio,name); ...
            Physio.channel_names.gsc = name; end
        function emg_channel = get.emg_channel(Physio); ...
            emg_channel = Physio.channel_names.emg; end
        function set.emg_channel(Physio,name); ...
            Physio.channel_names.emg = name; end
        
        function channel_names_t = get.channel_names_t(Physio); ...
            channel_names_t = struct2table(Physio.channel_names); end
        
        
        
        function has_raw = get.has_raw(Physio); ...
                has_raw = ~isempty(Physio.raw_data_tt); end
        
        function has_ecg = get.has_ecg(Physio); ...
                has_ecg = ~isempty(Physio.ecg); end
        function has_gsc = get.has_gsc(Physio); ...
                has_gsc = ~isempty(Physio.gsc); end
        function has_resp = get.has_resp(Physio); ...
                has_resp = ~isempty(Physio.resp); end
        function has_emg = get.has_emg(Physio); ...
                has_emg = ~isempty(Physio.resp); end
        
        function hand_cleaned = get.hand_cleaned(Physio); ...
            hand_cleaned = ~isempty(Physio.cleaner); end
        function has_ibis = get.has_ibis(Physio); ...
            has_ibis = ~isempty(Physio.ibis); end 
        
        function has_hrv = get.has_hrv(Physio); ...
            has_hrv = ~isempty(Physio.hrv_tt); end
        
        function Time = get.Time(Physio)
        %Time Calculate appropriate duration vector for timetables
            if Physio.has_raw; Time=Physio.raw_data_tt.Time; return; end
            if Physio.has_ecg
                Time=seconds(1:length(Physio.ecg))./Physio.Fs; return;
            end
            Time = seconds(1:cumsum(Physio.ibis)*Physio.Fs)./Physio.Fs;
        end
        
%         function ibis = asdf(P)
%             rpeaks = find(P.ecg_with_beats_tt.Beats)';
%             rr = [rpeaks rpeaks(end)]-[0 rpeaks]; %get inter-beat intervals
%             rr = rr(1:end-1)'; %trim missing vals from beginning/end
% 
%             ibis = rr./P.Fs; %output in seconds
%         end
    end
    
    %% STATIC METHODS
    methods (Static)
        % These methods can be called from outside:
        % ELF.Physio.function(args) does not require a new object be made
        % This is so you can use them for debugging or as general-purpose
        
        % readMw.m: read a .Mw file containing physio recordings
        [raw_data_tt, Fs] = readMw(sourcepath,mins)
        
        % denoiseEcg.m: get de-noised ECG
        ecg_clean = denoiseEcg(ecg_raw, Fs)
        
        % denoiseResp.m: get de-noised respiration
        resp_clean = denoiseResp(resp_raw, Fs)
        
        % denoisegsc.m: get de-noised gsc
        gsc_clean = denoisegsc(resp_raw, Fs)
        
        % denoiseEmg.m: get de-noised EMG
        emg_clean = denoiseEmg(resp_raw, Fs)
        
        % ecg2ibis.m: find beats, get ibi series in standard format
        [ibis,BioSigKit_Analysis] = ecg2ibi(ecg_clean, Fs)
        
        % calcHrv.m: get heartrate variability data from ibi series
        [hrv_tt,HRVAS_Analysis,dibis] = calcHrv(ibis,settings)
        
        % read realtime physio stats generated by mindware
        hrv_tt = readMwRealtime(path)
        
        % ibiTTtoArray: get ibi timetable to standard .ibi format
        function ibi_array = ibiTTtoArray(ibi_tt)
                ibi_tt.Time.Format = 's';
                ibi_tt.IBI.Format = 's';
                ibi_array = [seconds(ibi_tt.Time), ...
                seconds(ibi_tt.IBI)];
        end
        
        %ibis2resp.m: get ecg-derived respiration from ibi series
        resp = ibis2resp(ibis);
        
        %writeIBI.m: write .ibi file in standard text format
        writeIbis(ibis,savepath)
        
        function writeHrv(hrv_t,hrv_savepath)
            writetable(hrv_t,hrv_savepath);
        end
        
        %defaultHRVASSettings.m: return Greg's HRVAS settings
        hrvas_settings = defaultHRVASSettings() %From Greg
        
    end
    
end



%% GLOSSARY
% SDNN	ms	Standard deviation of NN intervals
% SDRR	ms	Standard deviation of RR intervals
% SDANN	ms	Standard deviation of the average NN intervals for each 5?min segment of a 24?h HRV recording
% SDNN index (SDNNI)	ms	Mean of the standard deviations of all the NN intervals for each 5?min segment of a 24?h HRV recording
% pNN50	%	Percentage of successive RR intervals that differ by more than 50?ms
% HR Max???HR Min	bpm	Average difference between the highest and lowest heart rates during each respiratory cycle
% RMSSD	ms	Root mean square of successive RR interval differences
% HRV triangular index		Integral of the density of the RR interval histogram divided by its height
% TINN	ms	Baseline width of the RR interval histogram
% 
% ULF power	ms2	Absolute power of the ultra-low-frequency band (?0.003?Hz)
% VLF power	ms2	Absolute power of the very-low-frequency band (0.0033?0.04?Hz)
% LF peak	Hz	Peak frequency of the low-frequency band (0.04?0.15?Hz)
% LF power	ms2	Absolute power of the low-frequency band (0.04?0.15?Hz)
% LF power	nu	Relative power of the low-frequency band (0.04?0.15?Hz) in normal units
% LF power	%	Relative power of the low-frequency band (0.04?0.15?Hz)
% HF peak	Hz	Peak frequency of the high-frequency band (0.15?0.4?Hz)
% HF power	ms2	Absolute power of the high-frequency band (0.15?0.4?Hz)
% HF power	nu	Relative power of the high-frequency band (0.15?0.4?Hz) in normal units
% HF power	%	Relative power of the high-frequency band (0.15?0.4?Hz)
% LF/HF	%	Ratio of LF-to-HF power

% RSA = ln(HFPower)
% S	ms	Area of the ellipse which represents total HRV
% SD1	ms	Poincar? plot standard deviation perpendicular the line of identity
% SD2	ms	Poincar? plot standard deviation along the line of identity
% SD1/SD2	%	Ratio of SD1-to-SD2
% ApEn		Approximate entropy, which measures the regularity and complexity of a time series
% SampEn		Sample entropy, which measures the regularity and complexity of a time series
% DFA ?1		Detrended fluctuation analysis, which describes short-term fluctuations
% DFA ?2		Detrended fluctuation analysis, which describes long-term fluctuations
% D2		Correlation dimension, which estimates the minimum number of variables required to construct a model of system dynamics

