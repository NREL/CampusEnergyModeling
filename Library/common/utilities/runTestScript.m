%% RUNTESTSCRIPT - Run a MATLAB script, capture errors, and log the result
%
% This utility function provides logging and error handling for test
% scripts. When used as a wrapper for a test script, this function:
%   1. Writes the test script output to the specified log file
%   2. Catches errors and writes them to the specified log file without
%      terminating program execution
%   3. Returns a flag indicating completion status of the test script
%
% SYNTAX:
%   ok = runTestScript(scriptfile)
%   ok = runTestScript(scriptfile, logfile)
%   ok = runTestScript(scriptfile, logfile, ext)
%
% INPUTS:
%   scriptfile =    Test script to run (without extension)
%
% OPTIONAL INPUTS:
%   logfile =       Name of the log file (default = same as script name)
%   ext =           Extension for the log file (default = "log")
%
% OUTPUTS:
%   ok =            'true' if test script completed without errors;
%                   'false' otherwise
%
% COMMENTS:
% 1. Prior to running this function, set the working directory to the
%    location where the logged output should be written. (This is also the
%    working directory in which the test script will run.)
%
% 2. Optional inputs, if provided, must be provided in the order listed.
%    For example, one can provide 'logfile' without 'ext' but not 'ext'
%    without 'logfile'.

function ok = runTestScript(scriptfile, logfile, ext)
    %% Setup
    % Default log file and extension
    if nargin < 3, ext = 'log'; end
    if nargin < 2, logfile = scriptfile; end
    
    % Check for existence of script to run
    assert( exist(scriptfile, 'file') == 2, ...
        'runTestScript:cannotOpenScript', ...
        ['Cannot locate a script named "%s.m" in the MATLAB path or ' ...
         'the current working directory. Test aborted.'], ...
        scriptfile );
    
    %% Open Log
    % Log file full name
    logfilename = [logfile '.' ext];
    
    % Open log file
    fid = fopen(logfilename, 'a');
    assert( fid >= 0, ...
        'runTestScript:cannotOpenLogFile', ...
        ['Cannot open log file "%s.%s" for test script "%s" under ' ...
         'the current working directory. Test aborted.'], ...
        logfile, ext, scriptfile );
    
    % Log start of test
    dateAndTime = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    fprintf(fid, '[%s] Begin test of script ''%s.m''\n', ...
        dateAndTime, scriptfile );
    
    % Close log file (so we can use diary instead)
    fclose(fid);
    
    %% Run Script
    % Termination flag - default true
    ok = true;
    
    % Run script with error handling
    try
        % Open diary to log file
        diary(logfilename)
        
        % Run script; pipe output to log file
        eval(scriptfile)
        
        % Turn diary off
        diary off
    catch exception
        % Turn diary off
        diary off
        
        % Write error message to log
        fid = fopen(logfilename, 'a');
        dateAndTime = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        fprintf(fid, '[%s] Exception in ''%s.m'' at line %d:\n', ...
            dateAndTime, ...
            exception.stack(length(exception.stack)-1).name, ...
            exception.stack(length(exception.stack)-1).line);
        fprintf(fid, '%s', getReport(exception, 'basic'));
        fclose(fid);
        
        % Something is quite wrong!
        ok = false;
    end
    
    %% Close Log
    % Reopen log file
    fid = fopen(logfilename, 'a');
    
    % Log end of test
    dateAndTime = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    if ok
        fprintf(fid, '[%s] Test completed successfully\n', dateAndTime );
    else
        fprintf(fid, '[%s] Test terminated with errors\n', dateAndTime );
    end
    
    % Close log file
    fclose(fid);
end