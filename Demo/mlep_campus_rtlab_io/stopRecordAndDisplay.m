stop(t);

x1 = perfData.TimeArray;
x2 = x1;
y1 = perfData.UsedMemoryArrayMatlab;
y2 = perfData.UsedCPUArrayMatlab;
z1 = perfData.UsedMemoryArrayEplus;
z2 = perfData.UsedCPUArrayEplus;

fig = figure;
% Plot first plot
ax(1) = gca;
set(fig,'NextPlot','add');

lineWidth = 2;
color1 = 'b';

h1 = plot(ax(1),x1,y1, color1, x1,z1, 'g*-');
set(ax(1),'Box','on', 'YColor', color1);
set(h1, 'LineWidth', lineWidth);
datetick(ax(1),'x', 'HH:MM:SS');
ylabel(ax(1), sprintf('Memory Used (%s)', perfData.UsedMemoryUnits));
legend('Matlab', 'EnergyPlus');


% Create second axes

ax(2) = axes('HandleVisibility',  get(ax(1),'HandleVisibility'), ...
             'Units',             get(ax(1),'Units'), ...
             'Position',          get(ax(1),'Position'), ...
             'Parent',            get(ax(1),'Parent'));

color2 = 'r';
h2 = plot(ax(2),x2,y2, color2, x2,z2, 'm*-');
set(h2, 'LineWidth', lineWidth);
set(ax(2), ...
    'YColor', color2, ...
    'YAxisLocation', 'right',...
    'Color',         'none', ...
    'XGrid','off','YGrid','off','Box','off');

datetick(ax(2),'x', 'HH:MM:SS');
grid(ax(2), 'on');
ylabel(ax(2), sprintf('CPU Used (%s)', perfData.UsedCPUUnits));
legend('Matlab', 'EnergyPlus');
