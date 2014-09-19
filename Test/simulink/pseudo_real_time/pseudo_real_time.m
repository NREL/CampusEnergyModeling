%% pseudo_real_time.m - Test Pseudo Real-Time Clock block
%
% This script tests the 'Pseudo Real-Time Clock' block in the Campus Energy
% Modeling Simulink library. The tests verify that the block enforces
% pseudo real-time simulation and that the various block features operate
% properly.
%
% FUNCTIONS:
%
% SIMULINK BLOCKS:
%   Pseudo Real-Time Clock

%% Setup
% Relative tolernace for completion time
tol = 0.05;

% Name of Simulink model
mdl = 'pseudo_rt';

% Run time
totTime = 10;

%% Test Timing of Real-Time Simulation
% Open model
open_system(mdl);

% Adjust simulation parameters
set_param( mdl, ...
    'FixedStep',    '1'                 , ...   % 1 second
    'StartTime',    '0'                 , ...
    'StopTime',     num2str(totTime)    );

% Setup pseudo real-time clock
set_param( strjoin({mdl, 'Pseudo Real-Time Clock'}, '/'), ...
    'enab',        1            , ...
    'speedup',     num2str(1)   , ...
    'rtv_action',  'Silent'     );

% Run and time simulation
tic;
sim(mdl);
dt = toc;

% Check time
assert( dt >= (1-tol)*totTime && dt <= (1+tol)*totTime, ...
    'pseudo_real_time:realTimeError', ...
    ['Simulation run time is not accurate within specified tolerance ' ...
    'of ±%f%%.'], tol*100 );

%% Test Alignment with Start Time
% Adjust start time
adj = totTime/2;

% Shift start time forward
set_param( mdl, ...
    'StartTime',    num2str(adj)            , ...
    'StopTime',     num2str(totTime+adj)    );

% Run and time simulation
tic;
sim(mdl);
dt = toc;

% Check time
assert( dt >= (1-tol)*totTime && dt <= (1+tol)*totTime, ...
    'pseudo_real_time:timeAlignmentError', ...
    ['Simulation run time is not accurate within specified tolerance ' ...
    'of ±%f%% when start time is not t = 0.'], tol*100 );

% Shift start time backward
set_param( mdl, ...
    'StartTime',    num2str(-adj)           , ...
    'StopTime',     num2str(totTime-adj)    );

% Run and time simulation
tic;
sim(mdl);
dt = toc;

% Check time
assert( dt >= (1-tol)*totTime && dt <= (1+tol)*totTime, ...
    'pseudo_real_time:timeAlignmentError', ...
    ['Simulation run time is not accurate within specified tolerance ' ...
    'of ±%f%% when start time is not t = 0.'], tol*100 );

%% Test Enable/Disable
% Disable pseudo real-time clock
set_param( strjoin({mdl, 'Pseudo Real-Time Clock'}, '/'), ...
    'enab', 0 );

% Run and time simulation
tic;
sim(mdl);
dt = toc;

% Check time: should be under 1 sec for this model
assert( dt <= 1.0, ...
    'pseudo_real_time:blockDisableError', ...
    'Pseudo real-time clock did not properly disable.' );

%% Test Silent/Warning/Error Options for Real Time Violations
% Decrease timestep to a value too small for the simulation to keep up
set_param( mdl, ...
    'FixedStep',    '0.0001'    , ...
    'StartTime',    '0'         , ...
    'StopTime',     '1'         );

% Real Time Violation: Silent
set_param( strjoin({mdl, 'Pseudo Real-Time Clock'}, '/'), ...
    'enab',        1            , ...
    'speedup',     num2str(1)   , ...
    'rtv_action',  'Silent'     );

% Force the warning message for this block to generate an error instead
% (Note: This is an undocumented MATLAB feature; see
% http://undocumentedmatlab.com/blog/trapping-warnings-efficiently/)
s = warning('error', ...
    'CampusEnergyModeling:PseudoRealTimeClock:RealTimeViolation');

% Simulate (Should not generate any errors or warnings)
try
    sim(mdl);
catch err
    error( 'pseudo_real_time:realTimeViolationAction', ...
    ['Real time violation action is set to ''Silent'', but the block ' ...
     'is still generating warnings or errors.'] );
end

% Real Time Violation: Warning
set_param( strjoin({mdl, 'Pseudo Real-Time Clock'}, '/'), ...
    'enab',        1            , ...
    'speedup',     num2str(1)   , ...
    'rtv_action',  'Warning'    );

% Simulate (Should generate a warning)
try
    sim(mdl);
    wrn_occurred = false;  % We don't want to get here 
catch err
    wrn_occurred = true;   % Instead, we want to get here
end
assert( wrn_occurred, ...
    'pseudo_real_time:realTimeViolationAction', ...
    ['Real time violation action is set to ''Warning'' but the block ' ...
     'appears to not be generating warnings on real time violations.']);

% Restore the warnings back to their previous (non-error) state
warning(s);

% Real Time Violation: Error
set_param( strjoin({mdl, 'Pseudo Real-Time Clock'}, '/'), ...
    'enab',        1            , ...
    'speedup',     num2str(1)   , ...
    'rtv_action',  'Error'    );

% Simulate (Should generate an error)
try
    sim(mdl);
    err_occurred = false;  % We don't want to get here 
catch err
    err_occurred = true;   % Instead, we want to get here
end
assert( err_occurred, ...
    'pseudo_real_time:realTimeViolationAction', ...
    ['Real time violation action is set to ''Error'' but the block ' ...
     'appears to not be generating errors on real time violations.']);

%% Test Speedup Factor
% Speedup to test
speedup = 100;

% Adjust simulation parameters
set_param( mdl, ...
    'FixedStep',    num2str(speedup)            , ...
    'StartTime',    '0'                         , ...
    'StopTime',     num2str(totTime*speedup)    );

% Setup pseudo real-time clock
set_param( strjoin({mdl, 'Pseudo Real-Time Clock'}, '/'), ...
    'enab',        1                , ...
    'speedup',     num2str(speedup) );

% Run and time simulation
tic;
sim(mdl);
dt = toc;

% Check time (note: speedup factor cancels on both sides of inequalities)
assert( dt >= (1-tol)*totTime && dt <= (1+tol)*totTime, ...
    'pseudo_real_time:realTimeError', ...
    ['Simulation run time is not accurate within specified tolerance ' ...
    'of ±%f%%.'], tol*100 );

%% Cleanup
% Close model
close_system(mdl, 0);