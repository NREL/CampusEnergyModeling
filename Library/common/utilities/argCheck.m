%% Function: Perform argument checking (i.e. assertions)
% Checks an argument to ensure it is numeric and of the appropriate type.
% Type may be real-valued, complex, or either. Throws an appropriate
% error message if the argument is not of the correct type or if the
% argument violates one or more of a flexible set of assertions (see
% OPTIONAL INPUTS section).
%
% SYNTAX:
%   argCheck(x,varargin)
%
% INPUTS:
%   x =         The argument to check
%   varargin =  (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'x':
%
%   'vName', [val]  The variable name to use if an error message is created
%                   (Default = 'value')
%   'vType', [val]  The number type required, one of 'real' or 'complex'.
%                   Skipped if 'vType' is neither of these.
%                   (Default = undefined, i.e. skip type checking)
%   'vLen', [val]   The data length required, i.e. the number of elements
%                   which must be in the vector 'x'. If negative or
%                   empty, length checking is skipped.
%                   (Default = 1, i.e. require a scalar)
%   'cName', [val]  The name of the class which should be used within
%                   the error message identifier.
%               	(Default = 'general')
%   'LB', [val]     Lower bound on 'x', given either as a scalar or
%                   element-wise along 'x'. Ignored if empty.
%                   Default = undefined, i.e. skip lower bound checking)
%   'UB', [val]     Upper bound on 'x', given either as a scalar or
%                   element-wise along 'x'. Ignored if empty.
%                   Default = undefined, i.e. skip upper bound checking)
%
%   The following optional inputs may be passed as flags following 'x'
%   and interspersed with any name-value pair above:
%
%   '--Pos'         'x' must be strictly positive
%   '--Neg'         'x' must be strictly negative
%   '--nonPos'      'x' must be non-positive
%   '--nonNeg'      'x' must be non-negative
%   '--Finite'      'x' must be finite
%
% COMMENTS:
% 1. This function serves as a multipurpose, flexible assertion that 
%    allows user-inputted data to be vetted prior to trying to do stuff
%    with it. It is intended to be called internally by other functions,
%    and therefore performs no error checking of its own on the optional
%    arguments, including matching of name-value pairs. If you get weird
%    errors when using argCheck(), check for proper name-value pairs.
%
% 2. The function will blindly assert such things as simultaneous strict
%    negativity and positivity (obiviously generating an error for any
%    input), so care should be taken when turning on these assertions.
%
% REFERENCE:
%   S. Frank, "Optimal Design of Mixed AC-DC Distribution Systems for
%   Commercial Buildings," Appendix G, Dissertation, Colorado School of
%   Mines, Golden, CO, 2013. [Online]. Available:
%   http://www.stevefrank.info/publications.html

%% License %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimization of Mixed AC-DC Building Electrical Distribution Systems    %
% Copyright (C) 2013  Stephen M. Frank (stephen.frank@ieee.org)           %
%                                                                         %
% This program is free software: you can redistribute it and/or modify    %
% it under the terms of the GNU General Public License as published by    %
% the Free Software Foundation, either version 3 of the License, or       %
% (at your option) any later version.                                     %
%                                                                         %
% This program is distributed in the hope that it will be useful,         %
% but WITHOUT ANY WARRANTY; without even the implied warranty of          %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           %
% GNU General Public License for more details.                            %
%                                                                         %
% You should have received a copy of the GNU General Public License       %
% along with this program.  If not, see <http://www.gnu.org/licenses/>.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function argCheck(x,varargin)
    %% Set Some Defaults   
    % Flags - all false
    Pos = false;
    Neg = false;
    nonPos = false;
    nonNeg = false;
    Finite = false;
    
    % Bounds - set to NaN (undefined)
    LB = NaN;
    UB = NaN;


    %% Process Optional Arguments
    % Parses arguments from 'varargin'
    i = 1;
	while i <= length(varargin)
        % Get name part of name-value pair (or, a standalone flag)
		argName = varargin{i}; i = i + 1;
        
        % Check for flags first
        % (For flags, the value assigned is irrelevant, as only the
        % existance of the flag is checked.)
        switch argName
            case {'--Pos'}
                Pos = true;         % Enforce strict positivity
                continue;
			case {'--Neg'}
                Neg = true;         % Enforce strict negativity
                continue;
			case {'--nonPos'}
                nonPos = true;      % Enforce non-positivity
                continue;
			case {'--nonNeg'}
                nonNeg = true;      % Enforce non-negativity
                continue;
			case {'--Finite'}
                Finite = true;      % Enforce finiteness (is this a word?)
                continue;
        end
        
        % Get value part of name-value pair
        argVal = varargin{i}; i = i + 1;
        
        % Assign optional values accordingly
        switch argName
			case {'vName'}
                vName = argVal;     % Name of argument for error message
			case {'vType'}
                vType = argVal;     % Required numeric type of argument
			case {'vLen'}
                vLen = argVal;      % Required length of argument
			case {'cName'}
                cName = argVal;     % Name of class for error message
			case {'LB'}
                LB = argVal;        % Lower bound
			case {'UB'}
                UB = argVal;        % Upper bound
            otherwise
                warning('ACDC:argCheck:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
	end
    
    
    %% More Defaults
    % These are checked/corrected after optional arguments are processed
    
    % Argument name
    if ~exist('vName','var')
        vName = 'value';
    end
    
    % Class name
    if ~exist('cName','var')
        cName = 'general';
    end
    
    % Argument length
    if ~exist('vLen','var')
        vLen = 1;
    elseif isempty(vLen)
        vLen = -1;
    end
    
    % Argument Type
    if ~exist('vType','var')
        vType = '';
    end
    
    
    %% Perform Requested Assertions
    % Required to be numeric
    assert( isnumeric(x), ...
        ['ACDC:' cName ':invalidDataType'], ...
        ['Argument ''' vName ''' must be numeric.']);
    
    % Correct length
    if vLen == 1 && length(x) ~= 1
        error(['ACDC:' cName ':invalidDataLength'], ...
            ['Argument ''' vName ''' must be a scalar.']);
    elseif vLen > 1  && length(x) ~= vLen 
        error(['ACDC:' cName ':invalidDataLength'], ...
            ['Argument ''' vName ''' must be of length ' ...
            num2str(vLen) '.']);
    end
    
    % Finite number
    if Finite && any( ~isfinite(x) )
        error(['ACDC:' cName ':dataNotFinite'], ...
            ['Argument ''' vName ''' must be finite.']);
    end
        
    % Correct type of number (real or complex)
    if strcmp(vType,'real') && ~isreal(x)
        error(['ACDC:' cName ':invalidNumberType'], ...
            ['Argument ''' vName ''' must be real-valued.']);
    elseif strcmp(vType,'complex') && isreal(x)
        error(['ACDC:' cName ':invalidNumberType'], ...
            ['Argument ''' vName ''' must be complex.']);
    end
        
    % Non-negativity, non-positivity, etc.
    if Pos && any(x <= 0)
        error(['ACDC:' cName ':strictPositivityViolation'], ...
            ['Argument ''' vName ''' must be strictly positive.']);
    elseif Neg && any(x >= 0)
        error(['ACDC:' cName ':strictNegativityViolation'], ...
            ['Argument ''' vName ''' must be strictly negative.']);
    elseif nonPos && any(x > 0)
        error(['ACDC:' cName ':nonpositivityViolation'], ...
            ['Argument ''' vName ''' must be non-positive.']);
    elseif nonNeg && any(x < 0)
        error(['ACDC:' cName ':nonnegativityViolation'], ...
            ['Argument ''' vName ''' must be non-negative.']);
    end
    
    % Bounds
    if ~isnan(LB) && any(x < LB)
        error(['ACDC:' cName ':lowerBoundViolation'], ...
            ['Argument ''' vName ''' must be greater than or equal to ' ...
             num2str(LB) '.']);
    elseif ~isnan(UB) && any(x > UB)
        error(['ACDC:' cName ':upperBoundViolation'], ...
            ['Argument ''' vName ''' must be less than or equal to ' ...
             num2str(UB) '.']);
    end
end