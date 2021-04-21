% Forked from:
% Ian Kleckner, Ph.D.
% Northeastern University
% ian.kleckner@gmail.com
%
% Load MindWare data from .Mw file as timetable
%
%----------------------------------------------------------------------
% INPUT DATA
% filename_Mw_data
%   Name of the input file
%
% duration_Mw_data_minutes_estimate
%   Make this slightly (e.g., 10%) larger than the duration of the dataset. This is
%   for preallocation and if it is not set properly then loading the data
%   will be very slow
%
%----------------------------------------------------------------------
% EXAMPLE
%   [raw_data_a, channel_name_string_array, Fs] = load_MindWare_data( 'PA_1.Mw', 10);
%   raw_data_tt
%
%----------------------------------------------------------------------
% FORMAT OF MINDWARE .Mw FILE
%   Header is numbers and strings of varying length
%   Data is a 2D array (each row is a timepoint and each column is a channel)
%
%--------------------------------------------
% Header elements are as follows:
%
% Channel list length (4 bytes)
% channel list string (eg 0,1,2)
% hardware config string length (4 bytes)
% hardware config string
% number of channels (4 bytes)
% 
% (For each channel...)
%     channel name string length (4bytes)
%     channel name string,
%     upper limit (4 bytes, SGL)
%     lower limit (4 bytes SGL)
%     range (4 bytes SGL)
%     polarity (enum type, 2 bytes, 0 = no change, 1 = bipolar, 2 = unipolar)
%     gain (4 bytes, SGL)
%     coupling (enum type, 2 bytes, 0 = no change, 1 = DC, 2 = AC, 3 = ground, 4 = internal refrence
%     hardware config (enum type, 2 bytes, 0 = no change, 1 = differential, 2 = referenced single ended, 3 = non ref single ended
%     scale multiplier (4 bytes SGL)
%     scale offset (4 bytes SGL)
% 
% scan rate (4 bytes SGL)
% channel clock (4 bytes SGL)
% user defined string
% ascii string
% _ delimited in the following format
% epoch name_subject number_epoch number
%----------------------------------------------------------------------

function [raw_data_tt, Fs] = ...
    readMw( sourcepath, duration_Mw_data_minutes_estimate )

    if nargin<=2
        duration_Mw_data_minutes_estimate = 120; % default value 2h
    end

    % warning('Did you set the HEADER_LENGTH_OFFSET? And the volts_to_units_array?');
    
    %OUTPUT_DEBUG = true;
    
    % ** The HEADER_LENGTH_OFFSET variable adjusts for how different computers
    %    read the MindWare data format. To determine which value to use,
    %    run the program with these values: 0, 2, 4, 8, 10, 12, 14, 16, etc.
    %    Run the program with each different value until you get your data 
    %    to line up with the labels in your output figure.
    %
    %  The value 4 worked for Ian Kleckner's data with 4 channels in Windows 7 OS with MATLAB 8.2.0.701 (R2013b)
    %  The value 4 worked for Eric Anderson's data with 8 channels on Mac OSX 10.7.5 and Matlab R2014b
    %  The value 0 worked for Ian Kleckner's data with 4 channels on Kubuntu 12.04 (Linux) and Matlab R2014a
    %  The value 6 worked for Nick's newschool data on Windows with R2017b via Horizon
    %  The value 9 (!) worked for Nick's newschool data on Arch with R2018a
    HEADER_LENGTH_OFFSET = 9;
    %----------------------------------------------------------------------
    
    % ** When first analyzing new data, you should check the scaling factor to
    % go from volts to native units (e.g., uS).
    %
    % E.g., for EDA data, you should
    % (1) Open your .Mw file in the EDA program
    % (2) Go to the settings tab (or something like that)
    % (3) Check the scaling factor (uS/Volt)
    % (4) Type that below
    
    % The following lists the scale factors for various channels
    % The volts_to_units_channel_name_array has to list the PART of the name of
    %  the channel that is in the .Mw file. So if the .Mw file has
    %  "GSC_Ch4" then you can list "GSC" so it will include slight
    %  variations such as "GSC_Ch3" or " GSC_Ch1"
    volts_to_units_channel_name_array = {'GSC', 'ECG'};    
    
    % The volts_to_units_array lists how much to multiple the reading in the .Mw
    % file by (in Volts) to achieve the desired units for the channel (e.g., uS)
    % For GSC this is often 10 (uS/Volt). For other channels this
    % may differ (e.g., Z0 may be 0.1 Volts/Ohm so you would have to type
    % 10 Ohms/Volt)
    volts_to_units_array = [10, 1];
    
    % For channels that are not listed here, the volts -> units converstion
    % assumes a scaling value of 1 (i.e., no conversion, or as if volts
    % WERE the units)    
    %----------------------------------------------------------------------

    % Open file with big-endian format
    FILE_Mw = fopen(sourcepath, 'r', 'b');

    % Read total header length (32 bits = 4 bytes) not including these 4 bytes and convert binary to decimal
    header_length   = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));
    NOT_USED        = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));

    % Channel list length (4 bytes) and its string (N bytes)
    channel_list_length = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));
    channel_list_string = fread(FILE_Mw, channel_list_length, 'char*1=>char')';

    % Hardware config string length (4 bytes) and its string (N bytes)
    hardware_config_length = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));

    % Hardware config string length (4 bytes)
    Nchannels = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));
    
    % Default scale factor for each channel
    scale_factor_array = ones(1,Nchannels);

    % For each channel...
    for c = 1:Nchannels        
        channel_name_length_array(c)     = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));
        channel_name_string_array{c}     = fread(FILE_Mw, channel_name_length_array(c), 'char*1=>char')';

        channel_upper_limit_array(c)     = fread(FILE_Mw, 1, 'single')';
        channel_lower_limit_array(c)     = fread(FILE_Mw, 1, 'single')';
        channel_range_array(c)           = fread(FILE_Mw, 1, 'single')';
        channel_polarity_array(c)        = bin2dec(sprintf('%d', fread(FILE_Mw, 16, 'ubit1'))); % 2 bytes
        channel_gain_array(c)            = fread(FILE_Mw, 1, 'single')';
        channel_coupling_array(c)        = bin2dec(sprintf('%d', fread(FILE_Mw, 16, 'ubit1'))); % 2 bytes
        channel_hardware_config_array(c) = bin2dec(sprintf('%d', fread(FILE_Mw, 16, 'ubit1'))); % 2 bytes
        channel_scale_multipliers_array(c)= fread(FILE_Mw, 1, 'single')';
        channel_scale_offset_array(c)    = fread(FILE_Mw, 1, 'single')';
        
        % Over-ride the value in the header because all Mw data is 10
        % volts range over 16 bits
        channel_scale_multipliers_array(c) = 10 / (2^16);
        
        % Get the scale factor for the channel, given its name
        channel_name = channel_name_string_array{c};
        
        for ch = 1:length(volts_to_units_channel_name_array)
            channel_name_to_find = volts_to_units_channel_name_array{ch};
            
            k_start = strfind(channel_name, channel_name_to_find);
                       
            if( ~isempty(k_start) )
                % Found the channel, so set the appropriate scaling factor
                scale_factor_array(c) = volts_to_units_array(ch);
            end
        end
    end

    Fs = fread(FILE_Mw, 1, 'single')';
    channel_clock = fread(FILE_Mw, 1, 'single')';

    % FYI I am not sure how to read the rest of the file so I just stopped
    % - this is not critical anyway for loading the data.
    %
    %user_defined_string = fread(FILE_Mw, 7156, 'char*1=>char')'
    %ascii_string = 0;

    % Now skip the rest of the header by re-opening the file and going
    % past all the other characters straight to the data
    frewind(FILE_Mw);
    header_length       = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));
    NOT_USED            = bin2dec(sprintf('%d', fread(FILE_Mw, 32, 'ubit1')));
    
    header_length = header_length + HEADER_LENGTH_OFFSET;
    entire_header_string= fread(FILE_Mw, header_length, 'char*1=>char')';


    %------------------------------------------------------------------
    % Read data as a 2D array of int16

    % Initialize
    raw_data_a = NaN*zeros(Fs*60*duration_Mw_data_minutes_estimate, Nchannels);
    r = 1;
    
    while( 1 )
        try
            raw_data_a(r,:) = fread(FILE_Mw, Nchannels, 'int16') ...
                .* channel_scale_multipliers_array' .* scale_factor_array';
        catch
            break;
        end

        % Move to the next row
        r = r+1;
    end

    % Close the file
    fclose(FILE_Mw);

    % Trim remaining data
    k_first_nan = find( isnan(raw_data_a(:,1)), 1, 'first' );
    raw_data_a(k_first_nan:end,:) = [];
    
    % Construct timetable
    raw_data_tt = array2timetable(raw_data_a, ...
        'TimeStep', seconds(1/Fs), ...
        'VariableNames', regexprep(regexprep(regexprep(channel_name_string_array,' ','_'),'/','_'),'-','_'));
end
