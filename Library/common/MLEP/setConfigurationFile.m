function varargout = setConfigurationFile(varargin)
% SETCONFIGURATIONFILE MATLAB code for setConfigurationFile.fig
%      SETCONFIGURATIONFILE, by itself, creates a new SETCONFIGURATIONFILE or raises the existing
%      singleton*.
%
%      H = SETCONFIGURATIONFILE returns the handle to a new SETCONFIGURATIONFILE or the handle to
%      the existing singleton*.
%
%      SETCONFIGURATIONFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETCONFIGURATIONFILE.M with the given input arguments.
%
%      SETCONFIGURATIONFILE('Property','Value',...) creates a new SETCONFIGURATIONFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setConfigurationFile_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setConfigurationFile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setConfigurationFile

% Last Modified by GUIDE v2.5 16-Aug-2013 09:01:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @setConfigurationFile_OpeningFcn, ...
    'gui_OutputFcn',  @setConfigurationFile_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before setConfigurationFile is made visible.
function setConfigurationFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setConfigurationFile (see VARARGIN)

% Choose default command line output for setConfigurationFile
handles.output = hObject;

% Get Inputs
handles.filename = varargin{2};
if size(varargin,2) > 2
    if strcmpi(varargin{3}, 'mainHandles')
        handles.mainHandles = varargin{4};
    end
end
[status,prop] = fileattrib(handles.filename);
handles.fullfilename = prop.Name;

% Display E+ File Name
set(handles.Variable_FileEdit, 'String', handles.fullfilename);

% Get Inputs/Outputs for MLE+ from parsed IDF.
[handles.InputMlep, handles.OutputMlep] = retrieveInOutIDF(handles.fullfilename);

% Get Input Table
handles.InputTable = {};
set(handles.Variable_InputTable, 'ColumnEditable', true);
set(handles.Variable_InputTable, 'Data', handles.InputTable);

% Get Output Table
handles.OutputTable = {};
set(handles.Variable_OutputTable, 'ColumnEditable', true);
set(handles.Variable_OutputTable, 'Data', handles.OutputTable);

% Show in Listbox
if ~isempty(handles.InputMlep)
    set(handles.ExternalInterfaceListbox, 'String', handles.InputMlep(:,4));
    set(handles.ExternalInterfaceListbox, 'Value', 1);
    handles.ExternalInterfaceListbox_value = get(handles.ExternalInterfaceListbox, 'Value');
end
if ~isempty(handles.OutputMlep)
    set(handles.OutputVariableListbox, 'String', handles.OutputMlep(:,4));
    set(handles.OutputVariableListbox, 'Value', 1);
    handles.OutputVariableListbox_value = get(handles.OutputVariableListbox, 'Value');
end

% Get to Project Directory
[dirPath, filename, ext] = fileparts(handles.fullfilename);
handles.projectPath = dirPath;
cd(handles.projectPath);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setConfigurationFile wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setConfigurationFile_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in writeConfig.
function writeConfig_Callback(hObject, eventdata, handles)
% hObject    handle to writeConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get Latest Tables
handles.InputTable = get(handles.Variable_InputTable, 'Data');
handles.OutputTable = get(handles.Variable_OutputTable, 'Data');

% Get Path Parts
[dirPath, name, ext] = fileparts(handles.fullfilename);
% Write Config File (variables.cfg)
result = writeConfigFile(handles.InputTable, handles.OutputTable, dirPath);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Close GUI
delete(handles.figure1);

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in OutputVariableListbox.
function OutputVariableListbox_Callback(hObject, eventdata, handles)
% hObject    handle to OutputVariableListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OutputVariableListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OutputVariableListbox
handles.OutputVariableListbox_value = get(handles.OutputVariableListbox, 'Value');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function OutputVariableListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputVariableListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in AddOutput.
function AddOutput_Callback(hObject, eventdata, handles)
% hObject    handle to AddOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OutputTable = get(handles.Variable_OutputTable, 'Data');
handles.OutputTable = addInOutMlep(handles.OutputTable, handles.OutputMlep, handles.OutputVariableListbox_value, 'outputs');
set(handles.Variable_OutputTable, 'Data', handles.OutputTable);

% Update Main
if isfield(handles, 'mainHandles')
    updateMainHandles(handles.mainHandles, handles.InputTable, handles.OutputTable);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in DeleteOutput.
function DeleteOutput_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OutputTable = get(handles.Variable_OutputTable, 'Data');
handles.OutputTable = deleteInOutMlep(handles.OutputTable);
set(handles.Variable_OutputTable, 'Data', handles.OutputTable);

% Update Main
if isfield(handles, 'mainHandles')
    updateMainHandles(handles.mainHandles, handles.InputTable, handles.OutputTable);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in ReplicateOutput.
function ReplicateOutput_Callback(hObject, eventdata, handles)
% hObject    handle to ReplicateOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in ExternalInterfaceListbox.
function ExternalInterfaceListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ExternalInterfaceListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ExternalInterfaceListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ExternalInterfaceListbox
handles.ExternalInterfaceListbox_value = get(handles.ExternalInterfaceListbox, 'Value');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ExternalInterfaceListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExternalInterfaceListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddInput.
function AddInput_Callback(hObject, eventdata, handles)
% hObject    handle to AddInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.InputTable = get(handles.Variable_InputTable, 'Data');
handles.InputTable = addInOutMlep(handles.InputTable, handles.InputMlep, handles.ExternalInterfaceListbox_value, 'inputs');
set(handles.Variable_InputTable, 'Data', handles.InputTable);

% Update Main
if isfield(handles, 'mainHandles')
    updateMainHandles(handles.mainHandles, handles.InputTable, handles.OutputTable);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in DeleteInput.
function DeleteInput_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.InputTable = get(handles.Variable_InputTable, 'Data');
handles.InputTable = deleteInOutMlep(handles.InputTable);
set(handles.Variable_InputTable, 'Data', handles.InputTable);

% Update Main
if isfield(handles, 'mainHandles')
    updateMainHandles(handles.mainHandles, handles.InputTable, handles.OutputTable);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in ReplicateInput.
function ReplicateInput_Callback(hObject, eventdata, handles)
% hObject    handle to ReplicateInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update handles structure
guidata(hObject, handles);



function Variable_FileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to Variable_FileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Variable_FileEdit as text
%        str2double(get(hObject,'String')) returns contents of Variable_FileEdit as a double


% --- Executes during object creation, after setting all properties.
function Variable_FileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Variable_FileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in Variable_InputTable.
function Variable_InputTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Variable_InputTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Edit Input Table
handles.InputTable = get(handles.Variable_InputTable, 'Data');

% Update Main
if isfield(handles, 'mainHandles')
    updateMainHandles(handles.mainHandles, handles.InputTable, handles.OutputTable);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in Variable_OutputTable.
function Variable_OutputTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Variable_OutputTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Edit Output Table
% Edit Input Table
handles.OutputTable = get(handles.Variable_OutputTable, 'Data');

% Update Main
if isfield(handles, 'mainHandles')
    updateMainHandles(handles.mainHandles, handles.InputTable, handles.OutputTable);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in Variable_saveInputOutput.
function Variable_saveInputOutput_Callback(hObject, eventdata, handles)
% hObject    handle to Variable_saveInputOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputTable = handles.InputTable;
outputTable = handles.OutputTable;
save('InOutMlep.mat', 'inputTable', 'outputTable');

% Update handles structure
guidata(hObject, handles);