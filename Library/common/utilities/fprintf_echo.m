%% FPRINTF_ECHO - Write to file via fprint() and echo to standard out
%
% Writes a message to one or more files using fprintf() and simultaneously
% echos the message to the standard output.
%
% SYNTAX:
%   fprintf_echo(fid, ...)
%
% INPUTS:
%   fid =       Vector of file identifiers for log output
%   ... =       All other arguments typically passed to fprintf
%
% EXAMPLES:
%   % Writes 'test message 1' to files test1.log and test2.log
%   f1 = fopen('test1.log','w');
%   f2 = fopen('test2.log','w');
%   fprintf_echo([f1 f2], '%s %d', 'test message', 1)
%   fclose(f1);
%   fclose(f2);

function fprintf_echo(fid, varargin)
    % Output to files
    arrayfun(@(x) fprintf(x, varargin{:}), fid);
    
    % Output to standard out
    fprintf( varargin{:} );
end