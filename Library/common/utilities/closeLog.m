%% CLOSELOG - Close a log file previously opened from openLog()
%
% This utility function closes a log file previously opened by openLog(),
% restoring the original diary settings if they are given. It is designed
% for use with its counterpart openLog() within automated test scripts to
% pipe output to a local log file without disrupting logged output from
% higher level scripts.
%
% SYNTAX:
%   closeLog(diaryStatus, diaryFile)
%
% INPUTS:
%   diaryStatus =   Status of the MATLAB diary to restore ('on' or 'off')
%   diaryFile =     Output diary file to restore
%
% EXAMPLE:
%   diary 'file1.txt';
%   disp('This message goes into file1.txt');
%   [oldStatus, oldFile] = openLog('file2');
%   disp('This message goes into file2.log');
%   closeLog(oldStatus, oldFile);
%   disp('Old settings restored; this message goes into file1.txt again');
%   diary off

function closeLog(diaryStatus, diaryFile)
    % First, turn the diary off
    diary off
    
    % Restore old diary filename
    diary(diaryFile)
    
    % Restore old diary status
    switch diaryStatus
        case 'on'
            diary on
        otherwise
            diary off
    end
end