%% run_tests.m - Run automated tests for Campus Energy Modeling library
%
% This script executes automated tests for the Campus Energy Modeling
% library and logs the results.
%
% COMMENTS:
% 1. To disable MATLAB test scripts, set
%       runMatlab = false
%    To disable Simulink test scripts, set
%       runSimulink = false
% 
% 2. For all tests to run successfully, all the software dependencies for
%    the Campus Energy Modeling library must be installed. Otherwise, some
%    tests will fail when they attempt to call external commands that are
%    not available. You can exclude tests for specific dependencies in the
%    configuration by specifying dependency names in the cell array
%    'excludeDeps'.
%
% 3. Set
%       clearOldLogs = true
%    to remove old test logs prior to executing the tests. Note that this
%    does not clear the main log file but only the logs for each individual
%    test.
%
% 4. Hardware-in-loop tests using RT-LAB cannot be run automatically and
%    are not included in this script.

clear all; close all; clc

%% Configuration
% Run MATLAB tests?
runMatlab = true;

% Run Simulink tests?
runSimulink = true;

% Exclude tests that require any of the following dependencies:
excludeDeps = {'databus'};

% Valid dependency names are:
%	databus
%   energyplus
%   mleplus
%   simpowersystems
%   ssc
%
% Names are not case sensitive; the script converts to lower case

% Log file name
logfile = 'run_tests.log';

% Clear old logs?
clearOldLogs = false;

%% Setup
% Open log file
flog = fopen(logfile, 'a+t');

% Log start of tests
fprintf_echo(flog, '[%s] %s\n', ...
    datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
    'Starting automated tests for Campus Energy Modeling library' );

% Report configuration
fprintf_echo(flog, '[%s] %s\n', ...
    datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
    'Configuration:' );
fprintf_echo(flog, '\tMATLAB tests: ');
if runMatlab
    fprintf_echo(flog, 'yes\n');
else
    fprintf_echo(flog, 'no\n');
end
fprintf_echo(flog, '\tSimulink tests: ');
if runSimulink
    fprintf_echo(flog, 'yes\n');
else
    fprintf_echo(flog, 'no\n');
end
fprintf_echo(flog, '\tSkipping tests with dependencies: %s\n', ...
    strjoin(excludeDeps,', ') );
fprintf_echo(flog, '\tClearing old log files: ');
if clearOldLogs
    fprintf_echo(flog, 'yes\n');
else
    fprintf_echo(flog, 'no\n');
end

% Set up counters
nPass = 0;
nFail = 0;
nSkip = 0;

% Root directory for test script
root = pwd;

% Suppress unreachable code warnings:
%#ok<*UNRCH>

%% MATLAB Tests
% Run MATLAB tests
if runMatlab
    % Log message
    fprintf_echo(flog, '[%s] %s', ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
        'Running MATLAB tests:' );
    
    % Get contents of MATLAB test directory
    % (Rows = name, date, bytes, isdir, datenum)
    testSet = struct2cell( dir('./matlab') );
    
    % Filter to only diretories...
    testSet = testSet(:, cell2mat(testSet(4,:)) );
    
    % ...with names that aren't . or ..
    testSet = setdiff(testSet(1,:), {'.','..'});
    
    % If empty, record that information; otherwise record a newline
    if isempty(testSet)
        fprintf_echo(flog, ' %s\n', 'No tests found');
    else
        fprintf_echo(flog, '\n');
    end
    
    % Run each test
	for i = 1:length(testSet)
        % Change working directory
        cd( [root filesep 'matlab' filesep testSet{i}] );
        
        % Test script name
        n = testSet{i};
        
        % Clear old log file if requested
        if clearOldLogs && exist([n '.log'], 'file')
            delete( [n '.log'] );
        end
        
        % Verify presence of test script; skip otherwise
        if exist(n, 'file') ~= 2
            fprintf_echo(flog, ...
                '[%s] %s "%s" (%s)\n', ...
                datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Warning: Skipping test directory', n, ...
                'test script not found' );
            nSkip = nSkip + 1;
            continue    
        end
        
        % Check for known dependencies
        if exist('deps.cfg', 'file')
            fid = fopen('deps.cfg','r');
            deps = textscan(fid, '%s', 'Delimiter', ',');
            fclose(fid);
            deps = deps{:};
        else
            deps = {};
        end
        deps = intersect(lower(deps), lower(excludeDeps));
        
        % Run...
        if isempty(deps)
            % Run test w/ log message
            fprintf_echo(flog, '[%s] %s "%s.m"... ', ...
                datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Running test', n);
            ok = runTestScript(n);
            if ok
                status = 'success';
            else
                status = 'failure';
            end
            fprintf_echo(flog, '%s\n', status);
                
        % Skip...
        else
            fprintf_echo(flog, ...
                '[%s] %s "%s.m" (%s %s)\n', ...
                datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Skipping test', n, ...
                'due to dependency', deps{1} );
            ok = -1;
        end
        
        % Log what happened
        switch ok
            case 1
                nPass = nPass + 1;
            case 0
                nFail = nFail + 1;
            case -1
                nSkip = nSkip + 1;
        end
	end
    
    % Return to root folder
    cd(root)
    
% Skip MATLAB tests
else
    % Log message
    fprintf_echo(flog, '[%s] %s\n', ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
        'Skipping MATLAB tests' );
end

%% Simulink Tests
% Run Simulink tests
if runSimulink
    % Log message
    fprintf_echo(flog, '[%s] %s', ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
        'Running Simulink tests:' );
    
    % Get contents of MATLAB test directory
    % (Rows = name, date, bytes, isdir, datenum)
    testSet = struct2cell( dir('./simulink') );
    
    % Filter to only diretories...
    testSet = testSet(:, cell2mat(testSet(4,:)) );
    
    % ...with names that aren't . or ..
    testSet = setdiff(testSet(1,:), {'.','..'});
    
    % If empty, record that information; otherwise record a newline
    if isempty(testSet)
        fprintf_echo(flog, ' %s\n', 'No tests found');
    else
        fprintf_echo(flog, '\n');
    end
    
    % Run each test
	for i = 1:length(testSet)
        % Change working directory
        cd( [root filesep 'simulink' filesep testSet{i}] );
        
        % Test script name
        n = testSet{i};
        
        % Clear old log file if requested
        if clearOldLogs && exist([n '.log'], 'file')
            delete( [n '.log'] );
        end
        
        % Verify presence of test script; skip otherwise
        if exist(n, 'file') ~= 2
            fprintf_echo(flog, ...
                '[%s] %s "%s" (%s)\n', ...
                datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Warning: Skipping test directory', n, ...
                'test script not found' );
            nSkip = nSkip + 1;
            continue    
        end
        
        % Check for known dependencies
        if exist('deps.cfg', 'file')
            fid = fopen('deps.cfg','r');
            deps = textscan(fid, '%s', 'Delimiter', ',');
            fclose(fid);
            deps = deps{:};
        else
            deps = {};
        end
        deps = intersect(lower(deps), lower(excludeDeps));
        
        % Run...
        if isempty(deps)
            % Run test w/ log message
            fprintf_echo(flog, '[%s] %s "%s.m"... ', ...
                datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Running test', n);
            ok = runTestScript(n);
            if ok
                status = 'success';
            else
                status = 'failure';
            end
            fprintf_echo(flog, '%s\n', status);
                
        % Skip...
        else
            fprintf_echo(flog, ...
                '[%s] %s "%s.m" (%s %s)\n', ...
                datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Skipping test', n, ...
                'due to dependency', deps{1} );
            ok = -1;
        end
        
        % Log what happened
        switch ok
            case 1
                nPass = nPass + 1;
            case 0
                nFail = nFail + 1;
            case -1
                nSkip = nSkip + 1;
        end
	end
    
    % Return to root folder
    cd(root)
    
% Skip Simulink tests
else
    % Log message
    fprintf_echo(flog, '[%s] %s\n', ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
        'Skipping Simulink tests' );
end

%% Finish
% Summary report
fprintf_echo(flog, '[%s] %s\n', ...
    datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
    'Test Summary:' );
fprintf_echo(flog, '\t%d test(s) succeeded\n', nPass);
fprintf_echo(flog, '\t%d test(s) failed\n', nFail);
fprintf_echo(flog, '\t%d test(s) skipped\n', nSkip);
if nFail > 0
    fprintf_echo(flog, '\t%s\n', ...
        'For more information, see the log files in each test directory.')
end

% Close log file
fclose(flog);
