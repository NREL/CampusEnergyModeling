% Loads Day-Ahead Pricing from June, 2013 from PJM.

% Load Array from CSV File
day = 1;
M = zeros(1,30*24);
D = zeros(1,24);
for day = 1:30
    D = csvread('201306-da.csv',5+day,1,[5+day 1 5+day 24])/1000';
    M((day-1)*24+1:(day-1)*24+24) = D;
end

% Price is for $/KWh 
x = M;
t = [0:60*60:24*60*60*30-1];
priceDA = timeseries(x, t);

% Assign time series time properties
priceDA.TimeInfo.Units = 'seconds';
% priceDA.TimeInfo.StartDate = start;
% priceDA.TimeInfo.Format = tFormat;

% Assign time series data properties
priceDA.Name = 'priceDA';
priceDA.DataInfo.Units = '$/KWh';
priceDA.DataInfo.UserData = 'Total LMP ($/KWh)';

% % Create Bus
% 
% % Create the bus
% BusDef_Price = Simulink.Bus;
% BusDef_Price.Description = 'LMP DAY-AHEAD';
% 
% % Populate the bus
% % Create bus element w/ proper names, etc
% x = Simulink.BusElement;
% x.Name = 'priceDA';
% x.DocUnits = out.priceDA.DataInfo.Units;
% x.Description = out.priceDA.DataInfo.UserData;
% 
% % Store in bus
% BusDef_Price.Elements = x;
% 
% % Place in base workspace
% assignin('base', 'BusDef_Price', BusDef_Price);

% % Clear local copy
% clear('BusDef_Price');

save('PriceDA.mat', 'priceDA', '-v7.3');