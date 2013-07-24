data = load('FlowLoad.mat');

data = data.Input.signals.values;
time = data.Input.time;

%% BUILDING 
figure;plot(time, data(:,1), 'k', time, data(:,2), 'r', time, data(:,1)+data(:,2), 'b');
legend('Lights + Equipment', 'HVAC', 'TOTAL');
grid on;
xlabel('Time');
ylabel('Power Demand [W]');
title('Power Consumption (Single Building)');