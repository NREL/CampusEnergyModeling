%% OPENLOG - Open a log file using diary() function
%
% This utility function opens a log file using MATLAB's diary() function,
% returning the original diary settings as function outputs. It is designed
% for use with its counterpart closeLog() within automated test scripts to
% pipe output to a local log file without disrupting logged output from
% higher level scripts.
%
% SYNTAX:
%   [diaryStatus, diaryFile] = openLog(filename,ext)
%
% INPUTS:
%   filename =      Name of the log file to open (without extension)
%
% OPTIONAL INPUTS:
%   ext =           Extension for the log file (default = "log")
%
% OUTPUTS:
%   diaryStatus =   Original on/off status of the MATLAB diary
%   diaryFile =     Original output diary file
%
% EXAMPLE:
%   diary 'file1.txt';
%   disp('This message goes into file1.txt');
%   [oldStatus, oldFile] = openLog('file2');
%   disp('This message goes into file2.log');
%   closeLog(oldStatus, oldFile);
%   disp('Old settings restored; this message goes into file1.txt again');
%   diary off

function [diaryStatus, diaryFile] = openLog(filename,ext)
    % Default extension
    if nargin < 2
        ext = 'log';
    end
    
    % Store old diary status and filename
    diaryStatus =  get(0,'Diary');
    diaryFile =    get(0,'DiaryFile');

    % Initialize log file
    diary([filename '.' ext]);
    diary on
end