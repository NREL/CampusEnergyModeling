classdef SysInfoDataNew < handle
    % properties will be displayed
    properties (SetAccess = 'private')
        % Stored Data
        TimeArray = [];
        UsedCPUArrayMatlab = [];
        UsedMemoryArrayMatlab = [];
        UsedCPUArrayEplus = [];
        UsedMemoryArrayEplus = [];
        
        % General Informations
        UsedCPUUnits = '%';
        UsedMemoryUnits = 'MB';
        NumOfCPU = 0;
        MachineName = '';
        TotalMemory = 0;
        CpuSpeed = '';
    end
    
    % properties will not be displayed
    properties (SetAccess = 'private', GetAccess = 'private')        
        % performance counters
        ProcPerfCounterHandleMatlab = [];
        MemPerfCounterHandleMatlab = [];
        ProcPerfCounterHandleEplus = [];
        MemPerfCounterHandleEplus = [];
        
        % data management
        BufferSize = 100;
        NextDataIndex = 1;
    end    
    
    methods
        function obj = SysInfoDataNew() % constructor
            if ~ispc
               errorObj = MException('SysInfoDataNew:NotSupported', 'SysInfoDataNew class is only supported on Windows');
               errorObj.throw();            
            end
            reset(obj);
            [notused,  systemview] = memory;
            obj.TotalMemory = round(systemview.SystemMemory.Available/1024^2);
            
            % Note: this function makes the whole class slow to initialize, 
            %       If not needed this feature feel free to delete it
            %obj.CpuSpeed = getCpuSpeed();
            % end of Note
            
            obj.MachineName = char(System.Environment.MachineName);
            obj.NumOfCPU = double(System.Environment.ProcessorCount);
            curProcess = System.Diagnostics.Process.GetCurrentProcess();
            
            % Create performancecounter
            obj.ProcPerfCounterHandleMatlab = System.Diagnostics.PerformanceCounter('Process', '% Processor Time', curProcess.ProcessName);            
            obj.MemPerfCounterHandleMatlab = System.Diagnostics.PerformanceCounter('Process', 'Working Set', curProcess.ProcessName);            
            obj.ProcPerfCounterHandleEplus = System.Diagnostics.PerformanceCounter('Process', '% Processor Time', 'EnergyPlus');            
            obj.MemPerfCounterHandleEplus = System.Diagnostics.PerformanceCounter('Process', 'Working Set', 'EnergyPlus');            
            
        end % constructor
        
        function reset(obj)
            % reset the data values
            obj.TimeArray = zeros(obj.BufferSize, 1);
            obj.UsedCPUArrayMatlab = zeros(obj.BufferSize, 1); 
            obj.UsedMemoryArrayMatlab = zeros(obj.BufferSize, 1);
            obj.UsedCPUArrayEplus = zeros(obj.BufferSize, 1);
            obj.UsedMemoryArrayEplus = zeros(obj.BufferSize, 1);
            
            obj.NextDataIndex = 1;
        end % reset
        
        function measure(obj) 
            % Measure the Time, CPU, Memory
            
            % expand buffer if needed
            if numel(obj.TimeArray) >= obj.NextDataIndex
                % need to expand the buffer
                obj.TimeArray = vertcat(obj.TimeArray, zeros(obj.BufferSize, 1));
                obj.UsedCPUArrayMatlab = vertcat(obj.UsedCPUArrayMatlab, zeros(obj.BufferSize, 1));
                obj.UsedMemoryArrayEplus = vertcat(obj.UsedMemoryArrayEplus, zeros(obj.BufferSize, 1));
                
            end
            
            % Measure new Data
            obj.TimeArray(obj.NextDataIndex) = now;
            obj.UsedCPUArrayMatlab(obj.NextDataIndex) = obj.ProcPerfCounterHandleMatlab.NextValue/obj.NumOfCPU;
            try
            obj.UsedCPUArrayEplus(obj.NextDataIndex) = obj.ProcPerfCounterHandleEplus.NextValue/obj.NumOfCPU;
            catch exception
                obj.UsedCPUArrayEplus(obj.NextDataIndex) = 0;
            end
            
            % Used Memory            
            obj.UsedMemoryArrayMatlab(obj.NextDataIndex) = obj.MemPerfCounterHandleMatlab.NextValue/1024^2;
            try
            obj.UsedMemoryArrayEplus(obj.NextDataIndex) = obj.MemPerfCounterHandleEplus.NextValue/1024^2;
            catch exception
                obj.UsedMemoryArrayEplus(obj.NextDataIndex) = 0;
            end            
            
            % update pointer            
            obj.NextDataIndex = obj.NextDataIndex + 1;
            
        end % measure
        
        
        function data = get.TimeArray(obj)
            % Get the time array
            data = obj.TimeArray(1:obj.NextDataIndex-1);
        end % get.TimeArray
        
        function data = get.UsedCPUArrayMatlab(obj)
            % Get the used CPU usage array
            data = obj.UsedCPUArrayMatlab(1:obj.NextDataIndex-1);
        end % get.UsedCPUArrayMatlab
        
        function data = get.UsedCPUArrayEplus(obj)
            % Get the used CPU usage array
            data = obj.UsedCPUArrayEplus(1:obj.NextDataIndex-1);
        end % get.UsedCPUArrayMatlab
        
        function data = get.UsedMemoryArrayMatlab(obj)
            % Get the used memory array
            data = obj.UsedMemoryArrayMatlab(1:obj.NextDataIndex-1);
        end % get.UsedMemoryArrayMatlab    
        
        function data = get.UsedMemoryArrayEplus(obj)
            % Get the used memory array
            data = obj.UsedMemoryArrayEplus(1:obj.NextDataIndex-1);
        end % get.UsedMemoryArrayEplus
        
    end % methods    
end % classdef

% util function
function cpuSpeedStr = getCpuSpeed()    
    % get cpu speed in MHz
    cpuSpeedMHz = winqueryreg('HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', '~MHz');
    % convert to GHz
    cpuSpeedGHz = double(cpuSpeedMHz)/1000;
    cpuSpeedStr = sprintf('%.2fGHz', cpuSpeedGHz);
end