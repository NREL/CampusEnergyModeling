power = load('Power.mat');

data = power.Power.signals.values;
time = power.Power.time;

%% BUILDING 
subplot(3,1,1);plot(time, data(:,1), 'k', time, data(:,2), 'r', time, data(:,1)+data(:,2), 'b');
legend('Lights + Equipment', 'HVAC', 'TOTAL');
grid on;
xlabel('Time');
ylabel('Power Demand [W]');
title('Power Consumption (Single Building)');

%% CHILLER PLANT
subplot(3,1,2);plot(time, data(:,5), 'k', time, data(:,6), 'r', time, data(:,5)+data(:,6), 'b');
legend('Chiller', 'Pump', 'TOTAL');
grid on;
xlabel('Time');
ylabel('Power Demand [W]');
title('Power Consumption (Chiller Plant)');

%% TOTAL CAMPUS
build_tot = data(:,1)+data(:,2)+data(:,3)+data(:,4);
chiller_tot = data(:,5)+data(:,6);
campus_tot = chiller_tot + build_tot;
subplot(3,1,3);;plot(time, build_tot, 'k', time, chiller_tot, 'r', time, campus_tot, 'b');
legend('Buildings', 'Chiller Plant', 'Campus');
grid on;
xlabel('Time');
ylabel('Power Demand [W]');
title('Power Consumption (Campus)');




