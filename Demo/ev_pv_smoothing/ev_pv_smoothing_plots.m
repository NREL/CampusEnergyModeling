%% PV Smoothing using Electric Vehicles - Plotting Script
%
% This script generates a nice comparison plot of grid load with and
% without PV smoothing. Outputs plots to the current MATLAB working
% directory in PNG format.
%
% To run this script successfully:
% 1. Run 'ev_pv_smoothing_init.m' with your desired settings.
% 2. Manually modify the model as follows:
%    a. Select the [PVPower] signal as the control source for smoothing
%    b. Modify the PI controller as noted for the PV control source...
%       P = 1.0, I = 0.0, Kt = 0.0, Anti-windup = clamping
% 3. With the 'ev_pv_smoothing.mdl' Simulink model still open, run this
%    script.
%
% Note that at the end of this process, the model will be tailored to the
% needs of this script. If you don't want logging enabled or a PV control
% source, don't save the model after the script concludes.
%
% COMMENTS:
% 1. If using this script with the DataBus data set, you may want to also
%    manually set the model timestep to 15 seconds rather than 1 second in
%    order to speed up the run time.

%% Setup
% System name
sys = 'ev_pv_smoothing';

% Enable logging to workspace
set_param([sys '/Enable Logging'],'Value','1');


%% Run Model and Log Data
% Set EV control off; run model:
% Puts outputs in vars 'ev_load', 'pv_gen', 'grid_net', and 't'
set_param([sys '/Enable Regulation'],'CurrentSetting','0');
sim(sys);

% Copy results for temporary storage
ev_load_noctl = ev_load(:,1);
grid_net_noctl = grid_net(:,1);
pv_gen_noctl = pv_gen(:,1);

% Set EV control on; run model:
% Puts outputs in vars 'ev_load', 'pv_gen', and 'grid_net'
set_param([sys '/Enable Regulation'],'CurrentSetting','1');
sim(sys);

% Extract power data only
ev_load = ev_load(:,1);
grid_net = grid_net(:,1);
pv_gen = pv_gen(:,1);

%% Data Setup
% Convert all data to kW
ev_load        = ev_load / 1000;
ev_load_noctl  = ev_load_noctl / 1000;
grid_net       = grid_net / 1000;
grid_net_noctl = grid_net_noctl / 1000;
pv_gen         = pv_gen / 1000;
pv_gen_noctl   = pv_gen_noctl / 1000;

% Logic for trimming data and time to 6 AM - 8 PM
tStart = 5;                             % hour
tEnd   = 19;                            % hour
idx    = (t >= tStart) & (t <= tEnd);   % Logical index

%% Plot: Total Power With and Without Control
% Create figure
figure('Units', 'in', ...
    'Position', [1 1 7 5]);
hold on;

% Power w/out control
pWithout = line(t(idx), grid_net_noctl(idx), ...
    'Color', 'red'      , ...
    'LineWidth', 1.2    );

% Power w/ control
pWith = line(t(idx), grid_net(idx), ...
    'Color', 'blue'     , ...
    'LineWidth', 1.2    );

% Title
title('Campus Power Consumption', ...
    'FontSize'   , 12    	, ...
    'FontWeight' , 'bold'	);

% Axis labels
xlabel('Hour of Day'                 );
ylabel('Electricity Consumption (kW)');

% Legend
legend( [pWithout, pWith], ...
    'Without EV control'    , ...
    'With EV control'       , ...
    'location', 'NorthEast' );

% Plot region setup
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'in'      , ...
    'TickLength'  , [.01 .01] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       , 6:2:20    , ...     % Hour
    'YTick'       , -10:10:50 , ...     % kW
    'LineWidth'   , 1         );

% Finish
hold off;

% Print to file
set(gcf, ...
    'PaperUnits',       'inches'    , ...
    'PaperPosition',    [0 0 7 5]   );
print(gcf, '-dpng', '-r200', ...
    [sys '_demo_total_power_comparison.png'])
    
%% Plot: PV and EV w/out control
% Create figure
figure('Units', 'in', ...
    'Position', [1 1 5 5]);
hold on;

% PV w/out control
pv = line(t(idx), pv_gen_noctl(idx), ...
    'Color', [1,0.64,0]     , ...
    'LineWidth', 1.2        );

% EV w/out control
ev = line(t(idx), ev_load_noctl(idx), ...
    'Color', [0,0.4,0]      , ...
    'LineWidth', 1.2        );

% Title
title('Without EV Control', ...
    'FontSize'   , 12    	, ...
    'FontWeight' , 'bold'	);

% Axis labels
xlabel('Hour of Day'                 );
ylabel('Electricity Generation/Consumption (kW)');

% Legend
legend( [pv, ev], ...
    'PV Generation'    , ...
    'EV Consumption'       , ...
    'location', 'NorthEast' );

% Plot region setup
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'in'      , ...
    'TickLength'  , [.01 .01] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       , 6:2:20    , ...     % Hour
    'YTick'       , -10:10:50 , ...     % kW
    'LineWidth'   , 1         );

% Finish
hold off;

% Print to file
set(gcf, ...
    'PaperUnits',       'inches'    , ...
    'PaperPosition',    [0 0 5 5]   );
print(gcf, '-dpng', '-r200', ...
    [sys '_demo_without_ev_control.png'])
    
%% Plot: PV and EV w/ control
% Create figure
figure('Units', 'in', ...
    'Position', [1 1 5 5]);
hold on;

% PV w/ control
pv = line(t(idx), pv_gen(idx), ...
    'Color', [1,0.64,0]     , ...
    'LineWidth', 1.2        );

% EV w/ control
ev = line(t(idx), ev_load(idx), ...
    'Color', [0,0.4,0]      , ...
    'LineWidth', 1.2        );

% Title
title('With EV Control', ...
    'FontSize'   , 12    	, ...
    'FontWeight' , 'bold'	);

% Axis labels
xlabel('Hour of Day'                 );
ylabel('Electricity Generation/Consumption (kW)');

% Legend
legend( [pv, ev], ...
    'PV Generation'    , ...
    'EV Consumption'       , ...
    'location', 'NorthEast' );

% Plot region setup
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'in'      , ...
    'TickLength'  , [.01 .01] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       , 6:2:20    , ...     % Hour
    'YTick'       , -10:10:50 , ...     % kW
    'LineWidth'   , 1         );

% Finish
hold off;

% Print to file
set(gcf, ...
    'PaperUnits',       'inches'    , ...
    'PaperPosition',    [0 0 5 5]   );
print(gcf, '-dpng', '-r200', ...
    [sys '_demo_with_ev_control.png'])