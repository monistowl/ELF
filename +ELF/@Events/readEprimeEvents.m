function events_tt = readEprimeEvents(path)
%ReadEprimeEvents Import eprime event log as a timetable.
%
% Event types will be stored as numbers, names as cellstrings {'name'}
% 
% Event times will be converted to seconds since acquisition start, to line up
% with other data.
%
%Example:
% event_table = read_eprime_events('mindware_events.txt');
%See also: Events

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%*s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(path,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

% Converts text in the input cell array to numbers. Replace non-numeric
% text with NaN.
rawData = dataArray{1};
for row=1:size(rawData, 1)
    % Create a regular expression to detect and remove non-numeric prefixes and
    % suffixes.
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
        result = regexp(rawData(row), regexstr, 'names');
        numbers = result.numbers;
        
        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if numbers.contains(',')
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(numbers, thousandsRegExp, 'once'))
                numbers = NaN;
                invalidThousandsSeparator = true;
            end
        end
        % Convert numeric text to numbers.
        if ~invalidThousandsSeparator
            numbers = textscan(char(strrep(numbers, ',', '')), '%f');
            numericData(row, 1) = numbers{1};
            raw{row, 1} = numbers{1};
        end
    catch
        raw{row, 1} = rawData{row};
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using the
% specified date format.
try
    dates{3} = datetime(dataArray{3}, 'InputFormat','hh:mm:ss.SSS a','Format','hh:mm:ss.SSS a');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{3} = cellfun(@(x) x(2:end-1), dataArray{3}, 'UniformOutput', false);
        dates{3} = datetime(dataArray{3}, 'InputFormat','hh:mm:ss.SSS a','Format','hh:mm:ss.SSS a');
    catch
        dates{3} = repmat(datetime([NaN NaN NaN]), size(dataArray{3}));
    end
end

dates = dates(:,3);

%% Convert all timestamps to seconds since acquisition started
acq_start = dates{1}(1);
dates = cellfun(@(x) seconds(x-acq_start),dates, 'UniformOutput', false);


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, 1);
rawStringColumns = string(raw(:, 2));


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
idx = (rawStringColumns(:, 1) == "<undefined>");
rawStringColumns(idx, 1) = "";

%% Create output variable
EventType = cell2mat(rawNumericColumns(:, 1));
EventName = cellstr(rawStringColumns(:, 1));
Time = seconds(dates{:, 1});
events_tt = timetable(Time,EventType,EventName);
%set acquisition start event number to 0 (first row)
events_tt.EventType(1) = 0;
%set acquisition start time to 1ms, to avoid lengthening 1-indexed signals
events_tt.Time(1) = seconds(0.001);
