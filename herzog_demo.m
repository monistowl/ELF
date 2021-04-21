%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quick demo of ELF features for S. Herzog Dissertation Data
%   Last modified July 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Overture

%setupELF; %Install Extensible Lab Framework
clear all;

%Range of participants to look for
fromid=101; toid=185;

%Places to look for them
%RDT_physio_searchpath = '/Volumes/Seagate\ Backup\ Plus\ Drive/Participant\ Data/%d/output data/**/*HRV*.txt';
RDT_physio_searchpath = '/home/tom/Documents/Participant Data/%d/output data/**/*HRV*.txt';
%RDT_physio_searchpath = 'Y:\Individual lab members folders\Sarah H\Herzog_Dissertation\Participant Data\%d\output data\**\*HRV*.txt';
%RDT_events_searchpath = '/Volumes/Seagate\ Backup\ Plus\ Drive/Participant\ Data/%d/*rdt_1_event.txt';
RDT_events_searchpath = '/home/tom/Documents/Participant Data/%d/*rdt_1_event.txt';
%RDT_events_searchpath = 'Y:\Individual lab members folders\Sarah H\Herzog_Dissertation\Participant Data\%d\*rdt_1_event.txt';


%Table to store results
results_t=table;
%File to save results
%results_savepath= '/Users/sarahherzog/Desktop/Dissertation\ Data/MatlabOutput'
results_savepath= '/home/tom/results.xlsx';

%% Per-participant calculations

for id=fromid:toid

% Find and import files for this ID (TODO: Make this automatic/hidden)
listing = dir(sprintf(RDT_physio_searchpath,id));
if isempty(listing); continue; else; listing=listing(end,:); end
RDT_physiopath = fullfile(listing.folder,listing.name);
listing = dir(sprintf(RDT_events_searchpath,id));
if isempty(listing); continue; else; listing=listing(end,:); end
RDT_eventspath = fullfile(listing.folder,listing.name);

RDT_Physio = ELF.Physio(RDT_physiopath); %Import realtime write
RDT_AllEvents = ELF.Events(RDT_eventspath); %Import event file
%% Get RDT HRV stats 10s before and 30s after first Uncomf, GoneTooFar, and Leave events

%Grab only the first of each event
RDT_Response_Events = ...
    RDT_AllEvents.firstMatches('Uncomf','GoneTooFar','Leave');

%Define a set of windows from ten seconds before to thirty seconds after each
RDT_Response_Windows = ...
    RDT_Response_Events.winsAround({'Uncomf','GoneTooFar','Leave'},-10,30);

%Define a set of windows from ten seconds before each response
RDT_Response_Before = ...
    RDT_Response_Events.winsAround({'Uncomf','GoneTooFar','Leave'},-10,0);

%Define a set of windows from thirty seconds after each response
RDT_Response_After = ...
    RDT_Response_Events.winsAround({'Uncomf','GoneTooFar','Leave'},0,30);

%Get means for all HRV stats within those three windows
RDT_Response_HRV = ...
    {RDT_Physio.hrvWinStats(RDT_Response_Windows,@mean)};
%% Get max/min HF/LF ratios during RDT Task

%Define a window between the start and end task events
RDT_Trial_Window = ...
    RDT_AllEvents.winsBetween('RDTStartTask','RDTEndTask');
%Rename to 'RDT_Trial' (default name was onset event 'RDTStartTask')
RDT_Trial_Window.renameWins('RDT_Trial');

%Get maximum LF/HF HRV ratio within window, and time at which it occurred
RDT_Trial_HRVMax = ...
    {RDT_Physio.hrvWinMax(RDT_Trial_Window,'LFHFRatio')};

%Get minimum value/time for same
RDT_Trial_HRVMin = ...
    {RDT_Physio.hrvWinMin(RDT_Trial_Window,'LFHFRatio')};
%% Get max/min HF/LF ratios during RDT Recovery

%Define window between RecoveryOnset and RecoveryOffset events
RDT_Recovery_Window = ...
    RDT_AllEvents.winsBetween('RecoveryOnset','RecoveryOffset');

%(Windows are named after their onset events by default)
RDT_Recovery_Window.renameWins('RDT_Recovery');

%Get means of all HRV stats within window
RDT_Recovery_HRV = ...
    {RDT_Physio.hrvWinStats(RDT_Recovery_Window,@mean)};

%Find time and value of max LF/HF HRV ratio within window
RDT_Recovery_HRVMax = ...
    {RDT_Physio.hrvWinMax(RDT_Recovery_Window,'LFHFRatio')};

%Find minimum of same
RDT_Recovery_HRVMin = ...
    {RDT_Physio.hrvWinMin(RDT_Recovery_Window,'LFHFRatio')};
%% Get HRV stats for threat segments

%Events are inconsistently named 'Seg[...]' or 'Set[...]' -- luckily,
% we can search with regular expressions that account for either:
RDT_Segment_Windows = ...
    RDT_AllEvents.winsBetween('Se[gt]\dOnset','Se[gt]\dOffset');
    %(The [gt] matches either 'g' or 't' and the '\d' matches any digit)

%Change all window names to RDT_ThreatSegment1, RDT_ThreatSegment2, &c.
RDT_Segment_Windows.renameWins('RDT_ThreatSegment');

%Get means of all available HRV stats within each threat segment window
RDT_Segment_HRV = ...
    {RDT_Physio.hrvWinStats(RDT_Segment_Windows,@mean)};
%% Combine all calculated data from this ID into one row of the results table

row_t=table(id,RDT_Response_HRV,RDT_Trial_HRVMax,RDT_Trial_HRVMin,...
    RDT_Recovery_HRV,RDT_Recovery_HRVMax,RDT_Recovery_HRVMin,RDT_Segment_HRV);
results_t=[results_t;row_t]; % (TODO: make this unnecessary)

end %Cycle through all participants, then:
%Fix table (TODO: make this unnecessary)
id=results_t.id; results_t.id=[]; allresults_t = table; allresults_t.id=id; allresults_t=[allresults_t,tblstackall(results_t)];
%% Write results to spreadsheet

writetable(allresults_t,results_savepath);





