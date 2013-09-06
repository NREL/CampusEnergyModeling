%% FITRECTIFIERMODEL - Fit injection current model for a passive rectifier
%
% Fits an interpolation-based model for a passive rectifier based on
% multiple sets of time-domain simulation data. The interpolation models
% injection currents as a piecewise linear function of total harmonic
% voltage distortion (THDV).
%
% Input data must provide a set of waveforms for the same rectifier with a
% fixed source voltage and fixed source X/R but varying source impedance.
% This will produce a set of harmonic spectra with associated values of
% THDV with which to build an iterpolation model.
%
% The simulation data should be in .CSV format with the following fields:
%                                   Single-phase        Three-phase
%   Time                            Time                Time
%   AC rectifier input current      Iin                 IA
%   AC rectifier input voltage      Vin                 VA
%   DC rectifier load current       Iload               Iload
%   DC rectifier load voltage       Vload               Vload
%
% These may be in any order and other fields may be present.
%
% SYNTAX:
%   model = fitRectifierModel(files, f, tStart, dt, ...)
%
% INPUTS:
%   files =     Cell array of files names containing the data
%   VRated =    Rated phase (line-to-neutral) voltage for rectifier 
%               (used to normalize data)
%   f =         Fundamental frequency [Hz]
%   tStart =    Start time to use for FFT [s] (same for all files)
%   dt =        Time step between consecutive data points [s]
%   ... =       (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below) 
%   
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'x':
%
%   'type', [val]   Either 'P' for constant power or 'I' for constant
%                   current
%                   (Default = 'P')
%   'NPhase', [val]	Number of phases for the rectifier model
%                   (Default = 1)
%   'H', [val]      Set of harmonics of interest to extract
%                   (Default = determined by threshold
%   'thr', [val]    Relative threshold with respect to the fundamental for
%                   determining harmonics of interest.
%                   (Default = 1e-2)
%   'rndoff', [val] Roundoff threshold; used to avoid very small magnitude
%                   THD values resulting from numerical errors in the FFT.
%                   (Default = 1e-4)
%
% OUTPUTS:
%   model =     A structure with fields          
%                   vals        A matrix of frequency-domain data
%                   names       Column names for the matrix
%                   H           The set of harmonics included in the output
%                   VRated      Rated line-to-neutral voltage
% 
% COMMENTS:
% 1. 'NPhase' has no effect on the creation of the interpolation table, but
%    does govern which fields are examined in the input files. If 'NPhase'
%    is 3, then the function looks for 'VA' and 'IA' instead of 'Vin' and
%    'Iin'.
%
% 2. If 'H' is specified, then the function will return currents only at
%    the fundamental and the values in 'H'. Otherwise, the function will
%    automatically calculate an appropriate vector 'H' such that all
%    harmonics with at least a magnitude of I1*thr are included.
%
% 3. Any harmonic voltage or current magnitudes below the fundamental times
%    'rndoff' get rounded to zero.
%
% 4. AC values are reported as RMS (i.e. corrected by sqrt(2)).
%
% 5. Text in names in 'varargin' is not case sensitive, but fields in the
%    .CSV are case senstitive.
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

function model = fitRectifierModel(files,VRated,f,tStart,dt,varargin)
    %% Setup
    % Set defaults
    type = 'P';
    NPhase = 1;
    H = [];
    thr = 1e-2;
    rndoff = 1e-4;
    
    % Check input arguments
    assert( iscell(files), ...
        'ACDC:fitRectifierModel:ivalidFileList', ...
        '''files'' must be a cell array of file name strings.');
    argCheck(VRated, 'vName', 'VRated', 'cName', 'fitRectifierModel', ...
        'vType', 'real', '--Pos', '--Finite');
    argCheck(f, 'vName', 'f', 'cName', 'fitRectifierModel', ...
        'vType', 'real', '--Pos', '--Finite');
    argCheck(tStart, 'vName', 'tStart', 'cName', 'fitRectifierModel', ...
        'vType', 'real', '--Finite');
    argCheck(dt, 'vName', 'dt', 'cName', 'fitRectifierModel', ...
        'vType', 'real', '--Pos', '--Finite');
    
    % Compute data characteristics
    T = 1/f;        % Fundamental period
    N = T/dt;       % Number of data points to extract
    
    % Warn if non-integer number of data points
    if mod(N,1) > 0
        warning('ACDC:fitRectifierModel:timestepMismatch', ...
            ['The specified time step does not produce an integral ' ...
             'number of data points for the specified period.']);
        N = round(N);
    end

    %% Process Optional Arguments
    % Check for valid list
    if mod(length(varargin),2) > 0
        error('ACDC:fitRectifierModel:mismatchedArgList', ...
            'All optional arguments must form name-value pairs');
    end
    
    % Parses arguments from 'varargin'
    i = 1;
	while i <= length(varargin)
        % Get name part of name-value pair (or, a standalone flag)
		argName = varargin{i}; i = i + 1;
        
        % Get value part of name-value pair
        argVal = varargin{i}; i = i + 1;
        
        % Assign optional values accordingly
        switch lower(argName)
			case {'type'}
                assert( any( strcmpi(type, {'P','I'}) ), ...
                    'ACDC:fitRectifierModel:invalidType', ...
                    ['Rectifier type must be ''P'' (constant power) ' ...
                     'or ''I'' (constant current).']);
                type = upper(argVal);
			case {'nphase'}
                assert( argVal == 1 || argVal == 3, ...
                    'ACDC:fitRectifierModel:invalidNumberOfPhases', ...
                    'Number of phases ''NPhase'' must be either 1 or 3.');
                NPhase = argVal;
			case {'h'}
                assert( ~isempty(argVal), ...
                    'ACDC:fitRectifierModel:invalidHarmonicVector', ...
                    '''H'', if specified, must be nonempty.');
                argCheck(argVal, 'vName', 'H', ...
                    'cName', 'fitRectifierModel', ...
                    'vLen', length(argVal), 'vType', 'real', ...
                    '--Pos', '--Finite');
                H = argVal(:);
			case {'thr'}
                argCheck(argVal, 'vName', 'thr', ...
                    'cName', 'fitRectifierModel', ...
                    'vType', 'real', '--Pos', '--Finite');
                thr = argVal;
			case {'rndoff'}
                argCheck(argVal, 'vName', 'rndoff', ...
                    'cName', 'fitRectifierModel', ...
                    'vType', 'real', '--Pos', '--Finite');
                rndoff = argVal;
            otherwise
                warning('ACDC:fitRectifierModel:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
	end
    
    %% Data Import
    % Get names of columns in the data
    fid = fopen( files{1} );
    names = regexp(fgetl(fid), ',', 'split');
    fclose(fid);
    
    % Check names
    if NPhase == 1
        validnames = {'Time','Vin','Iin','Vload','Iload'};
    else
        validnames = {'Time','VA','IA','Vload','Iload'};
    end
    assert( all( ismember(validnames, names) ), ...
        'ACDC:fitRectifierModel:missingFields', ...
        'Some required fields are missing from the simulation data.');
    
    % Set up data structure
    d = struct();
    d.names = { 1:N, names, files };
    d.vals = zeros( N, length(names), length(files) );

    % Import data
    for i = 1:length(files)
        % Get names of columns in the data
        fid = fopen( files{i} );
        n2 = regexp(fgetl(fid), ',', 'split');
        fclose(fid);
        
        % Check for consistency
        assert( all( strcmp(n2, names) ), ...
            'ACDC:fitRectifierModel:inconsistentFields', ...
            ['File ' files{i} 'has inconsistent field names.']);
        
        % Raw data
        x = dlmread( files{i}, ',', 1, 0 );

        % Find index of start time
        n = find( x(:, strcmp(names, 'Time') ) >= tStart, 1);
        
        % Check for sufficient data
        assert( ~isempty(n) && ...
            length( x(:, strcmp(names, 'Time') ) ) >= n + N, ...
            'ACDC:fitRectifierModel:insufficientData', ...
            ['Time domain data in ' files{i} ' has insufficient data ' ...
             'points after specified start time.']);

        % Extract data
        d.vals( :, :, i) = x( n:(n+N-1), : );
    end
    
    %% Extract Frequency Data
    % Set up FFT
    [~, HH, ~] = timeToFreq( d.vals(:, strcmp(names,'Time'), 1), dt );
    FFT = struct( 'names', {{'h','Vin','Iin'}} );
    FFT.vals = zeros( length(HH), 3, length(d.names{3}) );

    % Which columns
    if NPhase == 1
        Vidx = find( strcmp( d.names{2}, 'Vin' ), 1 );	% AC input voltage
        Iidx = find( strcmp( d.names{2}, 'Iin' ), 1 );	% AC input current
    else
        Vidx = find( strcmp( d.names{2}, 'VA' ), 1 );	% AC input voltage
        Iidx = find( strcmp( d.names{2}, 'IA' ), 1 );	% AC input current
    end

    % Perform FFT
    for i = 1:length( d.names{3} )
        % Harmonics
        FFT.vals( :, 1, i) = HH;
        
        % Voltage
        Vt = d.vals(:, Vidx, i);
        [~, ~, V] = timeToFreq( Vt, dt );
        FFT.vals( :, 2, i) = V;

        % Current
        It = d.vals(:, Iidx, i);
        [~, ~, I] = timeToFreq( It, dt );
        FFT.vals( :, 3, i) = I;
    end
    
    %% Analyze Frequency Data
    % Find harmonics of interest; store in 'H'
    if isempty(H)
        H = 1;
        h1 = find(HH == 1, 1);
        for i = 1:length( d.names{3} )
            I = FFT.vals( :, strcmp(FFT.names, 'Iin'), i);
            I1 = I(h1);
            Hidx = abs(I) >= (abs(I1) * thr) ;
            H = union(H, HH(Hidx));
        end
    else
        H = union(H, 1);
    end
    
    % All row indices of interest
    Hidx = ismember(HH, H);

    % Create table for interpolation data
    model = struct( 'names', {cell(1,length(H)+3)} );
    model.names(1:3) = {'THDV','Vload','Iload'};
    for i = 1:length(H)
        model.names{i + 3} = ['I' int2str(H(i))];
    end
    model.vals = zeros( length(d.names{3}), length(model.names) );
    
    % Extract data
    for i = 1:length( d.names{3} )
        % AC voltage
        V = FFT.vals( Hidx, 2, i) / sqrt(2);
        V1 = V(H == 1);
        Vh = V; Vh(H == 1) = [];

        % AC current
        I = FFT.vals( Hidx, 3, i) / sqrt(2);
        I1 = I(H == 1);
        Ih = I; Ih(H == 1) = [];

        % Normalize AC current for AC voltage magnitude
        if strcmp(type, 'P')
            % Constant power -> Correct fundamental (I1 : 1/V1)
            I1 = I1 / (VRated / abs(V1));
        else
            % Constant current -> Correct harmonics (Ih : Vh)
            Ih = Ih / (abs(V1) / VRated);
        end

        % Normalize AC current for AC voltage angle
        I1 = I1 * exp(-1j*angle(V1));
        Ih = Ih .* exp(-1j.*angle(V1).*H(H ~= 1));
        
        % DC load voltage
        Vload = mean( d.vals( :, strcmp( d.names{2}, 'Vload' ), i) );

        % Normalize DC load voltage for AC voltage magnitude
        if strcmp(type, 'P')
            % Constant power -> Correct fundamental (Vload : V1)
            Vload = Vload / (abs(V1) / VRated);
        end

        % DC load current
        Iload = mean( d.vals( :, strcmp( d.names{2}, 'Iload' ), i) );

        % Normalize DC load current for AC voltage magnitude
        if strcmp(type, 'P')
            % Constant power -> Correct fundamental (Iload : 1/V1)
            Iload = Iload / (VRated / abs(V1));
        end

        % Harmonic distortion
        THDV = sqrt( sum(Vh .* conj(Vh)) ) / abs(V1);

        % Store data
        model.vals( i, :) = [THDV, Vload, Iload, I1, transpose(Ih)];
    end

    % Round THDV values off at specified threshold
    model.vals(:,strcmp(model.names,'THDV')) = round( ...
        model.vals(:,strcmp(model.names,'THDV')) ./ rndoff ) .* rndoff;
    
    %% Finish
    % Sort model by THDV (to get ordered data points for interpolation)
    model.vals = ...
        sortrows( model.vals, find( strcmp(model.names,'THDV'), 1) );
    
    % Set of harmonics used
    model.H = H;
    
    % Rated voltage used
    model.VRated = VRated;
end

        
        