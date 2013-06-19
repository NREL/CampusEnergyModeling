% perfData = SysInfoData;
% t = timer;
% t.Period = 0.5;
% t.ExecutionMode = 'fixedRate';
% t.TimerFcn = @(obj, evnt)perfData.measure;
% t.TasksToExecute = Inf;
% start(t);


perfData = SysInfoDataNew;
t = timer;
t.Period = 0.5;
t.ExecutionMode = 'fixedRate';
t.TimerFcn = @(obj, evnt)perfData.measure;
t.TasksToExecute = Inf;
start(t);