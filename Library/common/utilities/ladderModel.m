%% parladder: Compute the impedance of a parallel RL ladder
% This function computes the impedance of a parallel ladder circuit of
% the following form:
% 
%    |--R(1)--L(1)--|
% o--|--R(2)--L(2)--|--L(Ext)--o
%    |--R(3)--L(3)--|
%    (etc.)
% 
% The impedance is computed at the specified radian frequencies
% and returned as a complex vector.
% 
% SYNTAX:
%   Z = parladder(RDC, LInt, LExt, w, varargin)
%
% INPUTS:
%   RDC             DC resistance of conductor
%   LInt            Low frequency internal inductance of conductor
%   LExt            External inductance of conductor
%   w               Vector of radian frequencies at which to compute the
%                   ladder impedance
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'w':
%
%   'N', [val]      Number of ladder rungs
%                   (Default = 3)
%   'kR', [val]     Scaling factor for ladder rung resistance
%                   (Default = 3.51)
%   'kL', [val]     Scaling factor for ladder rung inductance
%                   (Default = 3.27)
%
% OUTPUTS:
%   Z = complex impedance of the ladder at each radian frequency in 'w'
%
% NOTES:
% 1. Default values for N, kR, and kL are set to provide an optimal
%    response from DC through 1 decade above the skin effect corner
%    frequency. (See Skin Effect paper.)

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

function Z = ladderModel(RDC, LInt, LExt, w, varargin)
    %% Setup
    % Defaults
	N = 3;
	kR = 3.51;
	kL = 3.27;
    
    % Check non-optional arguments
    argCheck(RDC, 'vName', 'RDC', 'cName', 'ladderModel', ...
        'vType', 'real', '--nonNeg', '--Finite');
    argCheck(LInt, 'vName', 'LInt', 'cName', 'ladderModel', ...
        'vType', 'real', '--nonNeg', '--Finite');
    argCheck(LExt, 'vName', 'LExt', 'cName', 'ladderModel', ...
        'vType', 'real', '--nonNeg', '--Finite');
    argCheck(w, 'vName', 'w', 'cName', 'ladderModel', ...
        'vType', 'real', 'vLen', [], '--nonNeg', '--Finite');
        
    % Parses arguments from 'varargin'
    i = 1;
	while i <= length(varargin)
        % Get name part of name-value pair
		argName = varargin{i}; i = i + 1;
        
        % Get value part of name-value pair
        argVal = varargin{i}; i = i + 1;
        
        % Assign optional values accordingly
        switch lower(argName)
			case {'n'}
                argCheck(argVal, 'vName', 'N', 'cName', 'ladderModel', ...
                    'vType', 'real', 'LB', 2, '--Finite');
                N = argVal;
			case {'kr'}
                argCheck(argVal, 'vName', 'kR', 'cName', 'ladderModel', ...
                    'vType', 'real', 'LB', 1, '--Finite');
                kR = argVal;
			case {'kl'}
                argCheck(argVal, 'vName', 'kL', 'cName', 'ladderModel', ...
                    'vType', 'real', 'LB', 1, '--Finite');
                kL = argVal;
            otherwise
                warning('ACDC:ladderModel:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
	end

    %% Compute Ladder Parameters
    % Resistance
    R1 = RDC * sum( kR .^ -(0:(N-1)) );
    R =  R1 .* ( kR .^ (0:(N-1)) );
    
    % Inductance
    L1 = LInt * sum( kR .^ -(0:(N-1)) )^2 * ...
    	sum( (kL .^ -(0:(N-1))) .* (kR .^ (2*(0:(N-1)))) )^(-1);
    L = L1 .* ( kR .^ -(0:(N-1)) );
    
    %% Compute Ladder Impedance    
    % Compute total parallel admittance
    Y = zeros(size(w));
    for i = 1:N
        Y = Y + 1 ./ (R(i) + 1j.*w.*L(i));
    end
    
    % Take the inverse to get total parallel impedance
    Z = 1 ./ Y + 1j.*w.*LExt;
end