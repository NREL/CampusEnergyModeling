rawData1 = load('InOutTemp1.mat');
rawData2 = load('InOutTemp2.mat');

data1 = rawData1.InOutTemp1.signals.values;
data2 = rawData2.InOutTemp2.signals.values;
time = rawData1.InOutTemp1.time;

%% BUILDING 
figure;plot(time, data1(:,2), 'r', time, data1(:,1), 'b');
legend('Inlet Water Temperature', 'Outlet Water Temperature');
grid on;
xlabel('Time');
ylabel('Water Temperature [C]');
title('Water Temperature (Building)');
axis ([ 0 4.5e5 7 15])
% subplot(2,1,2);plot(time, -data(:,2), 'r', time, -data(:,2)-data(:,4), 'b');
% legend('Single Building', 'Chiller');
% grid on;
% xlabel('Time');
% ylabel('Power Load [W]');
% title('Power Load');
