%% Demand Response Demo - Plotting Script
%
% This script generates some nice comparison plots of grid load with and
% without the manual and automated demand response algorithms enabled.
%
% To run this script successfully:
% 1. Run 'demand_response_init.m'.
% 2. With the 'demand_response.mdl' Simulink model still open, run this
%    script.
%
% Note that at the end of this process, the model will be tailored to the
% needs of this script. If you don't want logging enabled or the DR
% settings modified, don't save the model after the script concludes.

%% Setup
% System name
sys = 'demand_response';

% Enable logging to workspace
set_param([sys '/Enable Logging'],'Value','1');

%% Run Model and Log Data
% Outputs are in vars 'power', 'zone_sp', 'zone_temp', and 't'

% Controls...
%   DR Enable: 1 = OFF, 0 = ON
%   DR Type: 1 = MANUAL, 0 = AUTO
%   
% (This is done for optimal visual routing. Sadly, I cannot seem to flip
% the sides of the switch which are 1 and 0.)

% Set DR off; run model
set_param([sys '/DR Enable'],'CurrentSetting','1');
sim(sys);

% Copy results for temporary storage
power_no_ctl     = power;
zone_sp_no_ctl   = zone_sp;
zone_temp_no_ctl = zone_temp;

% Set DR manual; run model
pause(1);
set_param([sys '/DR Enable'],'CurrentSetting','0');
set_param([sys '/DR Type'],'CurrentSetting','1');
sim(sys);

% Copy results for temporary storage
power_man_ctl     = power;
zone_sp_man_ctl   = zone_sp;
zone_temp_man_ctl = zone_temp;

% Set DR auto; run model
pause(1);
set_param([sys '/DR Enable'],'CurrentSetting','0');
set_param([sys '/DR Type'],'CurrentSetting','0');
sim(sys);

% Copy results for temporary storage
power_auto_ctl     = power;
zone_sp_auto_ctl   = zone_sp;
zone_temp_auto_ctl = zone_temp;

%% Data Setup
% Transform time such that t = 0 is simulation start
t = t - t(1);

% Convert power data to kW
power_no_ctl   = power_no_ctl / 1000;
power_man_ctl  = power_man_ctl / 1000;
power_auto_ctl = power_auto_ctl / 1000;

% Logic for trimming data and time to 6 AM - 8 PM
tStart = 5;                             % hour
tEnd   = 19;                            % hour
idx    = (t >= tStart) & (t <= tEnd);   % Logical index

%% Plot: Total Power Under Each Scenario
% Create figure
figure('Units', 'in', ...
    'Position', [1 1 7 5]);
hold on;

% No DR
pNo = line(t(idx), power_no_ctl(idx), ...
    'Color', 'black'    , ...
    'LineWidth', 1.2    );

% Manual DR
pMan = line(t(idx), power_man_ctl(idx), ...
    'Color', 'red'      , ...
    'LineStyle', '-.'   , ...
    'LineWidth', 1.2    );

% Automated DR
pAuto = line(t(idx), power_auto_ctl(idx), ...
    'Color', 'blue'     , ...
    'LineStyle', '--'   , ...
    'LineWidth', 1.2    );

% Title
title('Demand Response Scenarios: Building Load', ...
    'FontSize'   , 12    	, ...
    'FontWeight' , 'bold'	);

% Axis labels
xlabel('Hour of Day'                 );
ylabel('Electricity Consumption (kW)');

% Legend
legend( [pNo, pMan, pAuto] , ...
    'No DR'                , ...
    'Manual DR'            , ...
    'Automated DR'         , ...
    'location', 'South'    );

% Plot region setup
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'in'      , ...
    'TickLength'  , [.01 .01] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       , 6:2:18    , ...     % Hour
    'YTick'       , 0:5:25   , ...     % kW
    'LineWidth'   , 1         );
xlim([5, 19]);
ylim([-1, 29]);

% Finish
hold off;

% Print to file
set(gcf, ...
    'PaperUnits',       'inches'    , ...
    'PaperPosition',    [0 0 7 5]   );
print(gcf, '-dpng', '-r200', ...
    [sys '_demo_total_power_comparison.png'])

%% Plot: Zone Temp Under Each Scenario
% Create figure
figure('Units', 'in', ...
    'Position', [1 1 7 5]);
hold on;

% No DR
zTempNo = line(t(idx), zone_temp_no_ctl(idx), ...
    'Color', 'black'    , ...
    'LineWidth', 1.2    );

% Manual DR
zTempMan = line(t(idx), zone_temp_man_ctl(idx), ...
    'Color', 'red'      , ...
    'LineStyle', '-.'   , ...
    'LineWidth', 1.2    );

% Automated DR
zTempAuto = line(t(idx), zone_temp_auto_ctl(idx), ...
    'Color', 'blue'     , ...
    'LineStyle', '--'   , ...
    'LineWidth', 1.2    );

% Title
title('Demand Response Scenarios: Zone Temperatures', ...
    'FontSize'   , 12    	, ...
    'FontWeight' , 'bold'	);

% Axis labels
xlabel('Hour of Day'          );
ylabel('Temperature (°C)');

% Legend
legend( [zTempNo, zTempMan, zTempAuto] , ...
    'No DR'                 , ...
    'Manual DR'             , ...
    'Automated DR'          , ...
    'location', 'NorthWest' );

% Plot region setup
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'in'      , ...
    'TickLength'  , [.01 .01] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'XTick'       , 6:2:18    , ...     % Hour
    'YTick'       , 21:28     , ...     % °C
    'LineWidth'   , 1         );
xlim([5, 19]);
ylim([20.5, 28.5]);

% Finish
hold off;

% Print to file
set(gcf, ...
    'PaperUnits',       'inches'    , ...
    'PaperPosition',    [0 0 7 5]   );
print(gcf, '-dpng', '-r200', ...
    [sys '_demo_temp_comparison.png'])