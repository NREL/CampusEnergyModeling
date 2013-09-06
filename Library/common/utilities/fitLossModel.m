%% FITLOSSMODEL - Fit a quadratic loss model for a power elec. converter
%
% Fits a quadratic loss model for a power electronics converter given a set
% of input/output power data (in one of several possible formats) using
% linear least squares.
%
% SYNTAX:
%   [alpha, beta, gamma] = fitLossModel(convention, ...)
%
% INPUTS:
%   convention =	Specify either 'source' or 'load'; see comments.
%   ... =           A set of exactly two of the following possible 
%                   name-value pairs of data vectors for the converter:
%                       'Pin', [val]    Per-unit input power
%                       'Pout', [val]   Per-unit output power
%                       'Ploss', [val]  Per-unit converter loss
%                       'Eff', [val]    Efficiency (as a fraction)
%                   See COMMENTS.
%
% OUTPUTS:
%   alpha =         Constant loss term for converter loss model
%   beta =          Linear loss term for converter loss model
%   gamma =         Quadratic loss term for converter loss model
% 
% COMMENTS:
% 1. The form of the fit depends on the specified convention. For the
%    source convention,
%       Pout = Pin - alpha - beta * Pin - gamma * Pin^2
%    For the load convention,
%       Pin = Pout + alpha + beta * Pout + gamma * Pout^2
%    The difference is subtle, but fitted values will differ between the
%    conventions, especially if the losses are large.
%
% 2. Only two of the four possible data vectors need to be specified; the
%    other two are calculated automatically according to the relationships:
%       Pin = Pout + Ploss
%       Eff = Pout / Pin
%
% 3. Text in names is not case sensitive.
%
% REFERENCE:
%   S. Frank, "Optimal Design of Mixed AC-DC Distribution Systems for
%   Commercial Buildings," Appendix G, Dissertation, Colorado School of
%   Mines, Golden, CO, 2013. [Online]. Available:
%   http://www.stevefrank.info/publications.html

%% License %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This MATLAB function is reused with permission from:                    %
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

function [alpha, beta, gamma] = fitLossModel(convention,varargin)
    %% Setup
    % Check for valid convention
    assert( any( strcmpi(convention, {'source','load'}) ), ...
        'ACDC:fitLossModel:unknownInputDataName', ...
        'Convention must be one of ''source'' or ''load''' );
    
    % Check for valid data
    assert( length(varargin) == 4, ...
        'ACDC:fitLossModel:invalidInputData', ...
        'Exactly two name-value pairs of data vectors are required!' );
    assert( any( strcmpi(varargin{1}, {'Pin','Pout','Ploss','Eff'}) ), ...
        'ACDC:fitLossModel:unknownInputDataName', ...
        ['Valid names for input data are ', ...
         '''Pin'', ''Pout'', ''Ploss'', and ''Eff''.'] );
    assert( any( strcmpi(varargin{3}, {'Pin','Pout','Ploss','Eff'}) ), ...
        'ACDC:fitLossModel:unknownInputDataName', ...
        ['Valid names for input data are ', ...
         '''Pin'', ''Pout'', ''Ploss'', and ''Eff''.'] );
     assert( all( size(varargin{2}) == size(varargin{4}) ), ...
        'ACDC:fitLossModel:invalidDataLength', ...
        'Input data vectors must be of identical size.' );
    
    % Parse input data into a structure
    d = struct();
    i = 1;
	while i <= length(varargin)
		dName = lower( varargin{i} ); i = i + 1;
        dName(1) = upper(dName(1));
        dVal = varargin{i}; i = i + 1;
        d.(dName) = dVal(:);
	end
    
    %% Compute Pin/Pout
    % Check for Pout; compute if missing
    if ~isfield(d, 'Pout')
        % Have: Pin + Ploss
        if isfield(d, 'Pin') && isfield(d, 'Ploss')
            d.Pout = d.Pin - d.Ploss;
        
        % Have: Pin + Eff
        elseif isfield(d, 'Pin') && isfield(d, 'Eff')
            d.Pout = d.Pin .* d.Eff;
            
        % Have: Ploss + Eff
        elseif isfield(d, 'Ploss') && isfield(d, 'Eff')
            d.Pout = d.Ploss .* ( d.Eff ./ (1 - d.Eff) );
            d.Pin = d.Pout + d.Ploss;
            
        end
    end
    
    % Check for Pin; compute if missing
    if ~isfield(d, 'Pin')
        % Have: Pout + Ploss
        if isfield(d, 'Pout') && isfield(d, 'Ploss')
            d.Pin = d.Pout + d.Ploss;
        
        % Have: Pout + Eff
        elseif isfield(d, 'Pout') && isfield(d, 'Eff')
            d.Pin = d.Pout ./ d.Eff;
            
        end
    end
    
    % At this point, we know we have both Pout and Pin, which is all we
    % need to compute alpha, beta, and gamma.
    
    %% Perform Least Squares Fit
    % Source convention
    if strcmpi( convention, 'source' )
        % The functional form to fit is:
        %   Pout = Pin - alpha - beta * Pin - gamma * Pin^2
        % or
        %   alpha + beta * Pin + gamma * Pin^2 = Pin - Pout 
        %
        % The corresponding least squares problem is:
        %   min sum(
        %       ( (Pin - Pout) - (alpha + beta * Pin + gamma * Pin^2) )^2
        %       )

        % Formulate linear least squares problem in form A*x = b
        % where x = [alpha; beta; gamma]
        N = length(d.Pin);
        A = [ones(N, 1), d.Pin, d.Pin.^2];
        b = d.Pin - d.Pout;

        % Solve using MATLAB's linear least squares function
        x = lscov(A,b);
        alpha = x(1); beta = x(2); gamma = x(3);
        
    % Load convention
    else
        % The functional form to fit is:
        %   Pin = Pout + alpha + beta * Pout + gamma * Pout^2
        % or
        %   alpha + beta * Pout + gamma * Pout^2 = Pin - Pout 
        %
        % The corresponding least squares problem is:
        %   min sum(
        %       ( (Pin - Pout) - (alpha + beta * Pout + gamma * Pout^2) )^2
        %       )

        % Formulate linear least squares problem in form A*x = b
        % where x = [alpha; beta; gamma]
        N = length(d.Pout);
        A = [ones(N, 1), d.Pout, d.Pout.^2];
        b = d.Pin - d.Pout;

        % Solve using MATLAB's linear least squares function
        x = lscov(A,b);
        alpha = x(1); beta = x(2); gamma = x(3);
    end
end

        
        