rawData = load('Input.mat');

data = rawData.Input.signals.values;
time = rawData.Input.time;

%% BUILDING 
subplot(2,1,1);plot(time, data(:,1), 'r', time, data(:,1)+data(:,3), 'b');
legend('Single Building', 'Chiller');
grid on;
xlabel('Time');
ylabel('Mass Flow Rate [Kg/s]');
title('Mass Flow Rate');

subplot(2,1,2);plot(time, -data(:,2), 'r', time, -data(:,2)-data(:,4), 'b');
legend('Single Building', 'Chiller');
grid on;
xlabel('Time');
ylabel('Power Load [W]');
title('Power Load');