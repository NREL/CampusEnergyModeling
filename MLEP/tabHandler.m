function tabHandler( handles , numOn)
% TABHANDLER - This function coordinates the visibility of the different
% panels. This gives the impression that there are tabs. 
% Usage: tabHandler(handles , numOn)
% Inputs:
% handles - Contains the current Table information.
% numOn - Contains a cell with the ExternalInterface Objects or Output
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-06 Started.
%

%
% ERROR HANDLING
%
if size(handles,1) ~= 1
    error('Handle array must be 1 x n');
end
if numOn > 0.5*size(handles,2)
    error('Trying to turn on a tab that does not exist')
end
if numOn < 1
    error('numOn must be positive')
end

%
% TAB SWITCHING
%
num = 0.5*size(handles,2);

for i=1:num
    if i == numOn
        set(handles(i),'Visible','on');
        set(handles(i+num),'Value',1);
    else
        set(handles(i),'Visible','off');
        set(handles(i+num),'Value',0);  
    end
end


end

