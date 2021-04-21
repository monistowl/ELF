function hrv_tt = readMwRealtime(filename)
%readMwRealtime: Import mindware-generated HRV as timetable.
%   hrv_tt = Physio.readMwRealtime(filename)
%
% Example:
%   hrv_tt = Physio.readMwRealtime('AAI_2570_1_HRV RT_1_03 PM.txt');
%

%% Find var name row
delimiter = '\t'; fileID = fopen(filename,'r'); namerow=0; startRow=1; while ~namerow; line=fgets(fileID); if contains(line,'Time (s)'); namerow=startRow; end; startRow=startRow+1; end

%% Get clean var names
varnames=strsplit(line,delimiter); varnames=cellfun(@(x) strrep(x,'(',' '), varnames, 'UniformOutput', false); varnames=cellfun(@(x) strrep(x,')',' '), varnames, 'UniformOutput', false); varnames=cellfun(@(x) strrep(x,'/',' '), varnames, 'UniformOutput', false); varnames=cellfun(@genvarname, varnames, 'UniformOutput', false); varnames{1}='Time'; nvars=length(varnames); formatSpec = strcat(repmat('%f',1,nvars),'%[^\n\r]'); endRow = Inf; frewind(fileID);

%% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n'); for block=2:length(startRow); frewind(fileID); dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n'); for col=1:length(dataArray); dataArray{col} = [dataArray{col};dataArrayBlock{col}]; end; end

%% Close the text file.
fclose(fileID);

%% Create output variable
hrv_tt = table(dataArray{1:end-1}, 'VariableNames', varnames); hrv_tt=[hrv_tt;hrv_tt(end-60:end,:)]; hrv_tt.Time(end-60:end)=hrv_tt.Time(end-61)+1:hrv_tt.Time(end-61)+61; hrv_tt.Time = seconds(hrv_tt.Time); hrv_tt = table2timetable(hrv_tt);


