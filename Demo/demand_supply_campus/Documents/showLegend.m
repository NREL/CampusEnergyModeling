hScopes = findall(0,'Tag','SIMULINK_SIMSCOPE_FIGURE','Name', 'Mass & Flow Partition')
hAxes = findall(hScopes(1),'Type','axes');
legend(hAxes(1),{'Building 2','Building 1','Total'},'Color',[1 1 1]);
