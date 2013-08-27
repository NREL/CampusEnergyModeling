%% FITTRANSFORMERPARAM - Fit transformer equivalent circuit parameters
%
% This function finds the approximate equivalent circuit parameters of a
% transformer parameters based on a set of known characteristics about
% the transformer (those commonly available in manufacturers' data sheets)
% using approximate methods.
%
% This function was originally developed by Stephen Frank at the National
% Renewable Energy Laboratory in connection with Project No. 192, under
% constract from the Bonneville Power Administration, Contract No. 51353 
% and Interagency Agreement No. IAG-11-1801. It was later reused and
% updated, with permission, by Stephen Frank for his dissertation research
% (see REFERENCES). 
%
% SYNTAX:
%   [XSeries, RSeries, XMag, RCore] = fitTransformerParam( ...
%       Z, XRRatio, INL, IMaxEff, varargin)
%
% INPUTS:
%   Z =         Transformer series impedance magnitude at full load [pu]
%   XRRatio =   X/R ratio at full load
%   INL =       No load current (magnitude)                         [pu]
%   IMaxEff =   Load current at which maximum efficiency occurs     [pu]
%   varargin =  (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'IMaxEff':
%
%   'Type', [val]	Transformer type: 'dry' or 'liquid'
%                   (Default = 'dry')
%   'Metal', [val]  Winding metal: 'Al' or 'Cu'
%                   (Default = 'Al')
%   'TAmb', [val]	Ambient temperature [deg C]
%                   (Default = 20)
%   'TRR', [val]	Rated temperature rise [deg C]
%                   (Default = 115 for 'dry' type, 85 for 'liquid' type)
%   'Itol', [val]   Tolerance for current at which maximum efficiency
%                   occurs
%                   (Default = 0.01)
%
% OUTPUTS:
%   XSeries =   Series reactance (at ref. frequency)                [pu]
%   RSeries =   Series resistance at reference temperature          [pu]
%   XMag =      Magnetizing reactance (at ref. frequency)           [pu]
%   RCore =     Core loss resistance                                [pu]
%
% All outputs are in per-unit
%
% COMMENTS:
% 1. Assumes default breakdown of winding, eddy current, and other stray
%    load loss according to the transformer type. No user override is
%    available at this time.
%
% 2. The smaller 'Itol' is, the longer the script will take to run. Set it
%    to something reasonable.
%
% REFERENCES:
%   L. Gentile Polese, S. Frank, M. Alahmad, K. Lee, and C. Waters,
%   "Modeling and power efficiency analysis of building electrical
%   distribution systems," National Renewable Energy Laboratory, Golden,
%   CO, Technical Report TP-5500-52657, Sep. 2011.
%
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

function [XSeries, RSeries, XMag, RCore] = fitTransformerParam( ...
	Z, XRRatio, INL, IMaxEff, varargin)
    %% Process Input Arguments / Set Default Values
    % Argument check required inputs
    argCheck(Z, 'vName', 'Z', ...
        'cName', 'fitTransformerParam', ...
        'vType', 'real', '--Pos', '--Finite');
    argCheck(XRRatio, 'vName', 'XRRatio', ...
        'cName', 'fitTransformerParam', ...
        'vType', 'real', '--Pos', '--Finite');
    argCheck(INL, 'vName', 'INL', ...
        'cName', 'fitTransformerParam', ...
        'vType', 'real', '--nonNeg', '--Finite');
    argCheck(IMaxEff, 'vName', 'IMaxEff', ...
        'cName', 'fitTransformerParam', ...
        'vType', 'real', '--Pos', '--Finite');
    
    % Process varargin arguments
    vals = toStruct(varargin, 'cName', 'fitTransformerParam', ...
            'validArgs', {'Type','Metal','TAmb','TRR','Itol'});
    fnames = fieldnames(vals);
    
    % Type of transformer
    if ismember('Type', fnames)
        assert( any( strcmpi(vals.Type, {'dry','liquid'}) ), ...
            'ACDC:fitTransformerParam:invalidType', ...
            'Transformer ''Type'' must be one of ''dry'' or ''liquid''.');
        Type = vals.Type;
    else
        % Default
        Type = 'dry';
    end
    
    % Type of winding metal
    if ismember('Metal', fnames)
        assert( any( strcmpi(vals.Metal, {'Cu','Al'}) ), ...
            'ACDC:fitTransformerParam:invalidMetal', ...
            ['''Metal'' must be one of ''Cu'' (copper) or ' ...
             '''Al'' (aluminum).'] );
        Metal = vals.Metal;
    else
        % Default
        Metal = 'Al';
    end
    
    % Ambient temperature
    if ismember('TAmb', fnames)
        % User input
        argCheck(vals.TAmb, 'vName', 'TAmb', ...
            'cName', 'fitTransformerParam', ...
            'vType', 'real', 'LB', -273.15, '--Finite');
        TAmb = vals.TAmb;
    else
        % Default
        TAmb = 20;
    end
    
    % Rated temperature rise
    if ismember('TRR', fnames)
        % User input
        argCheck(vals.TRR, 'vName', 'TRR', ...
            'cName', 'fitTransformerParam', ...
            'vType', 'real', '--nonNeg', '--Finite');
        TRR = vals.TRR;
    else
        % Default
        if strcmpi(Type, 'dry')
            TRR = 115;
        else
            TRR = 85;
        end
    end
    
    % Current tolerance
    if ismember('Itol', fnames)
        % User input
        argCheck(vals.Itol, 'vName', 'Itol', ...
            'cName', 'fitTransformerParam', ...
            'vType', 'real', '--Pos', 'UB', 1);
        Itol = vals.Itol;
    else
        % Default
        Itol = 0.01;
    end
    
    %% Setup   
    % Round the max efficiency to the specified tolerance
    IMaxEff = round(IMaxEff / Itol) * Itol;
    
    %% Series X and R
    % Compute 'XSeries' and 'RSeries' based on 'Z' and 'XRRatio'
    % NOTE: These are valid at rated temperature rise
    RSeries = Z * sqrt( 1 / (1 + XRRatio^2) );
    XSeries = Z * sqrt( 1 / (1 + (1/XRRatio)^2) );
    
    %% Split 'RSeries'
    % Split the series resistance into equivalent components based on the
    % transformer type.
    switch lower(Type)
        case 'dry'
            RW_Ref = 0.9 * RSeries;
            REC_Ref = 0.067 * RSeries;
            ROSL_Ref = 0.033 * RSeries;
        case 'liquid'
            RW_Ref = 0.9 * RSeries;
            REC_Ref = 0.033 * RSeries;
            ROSL_Ref = 0.067 * RSeries;
    end
    
    %% Temp. Characeristics
    % Reference temperature
    TRef = TAmb + TRR;
    
    % Temp. coefficient
    switch lower(Metal)
        case 'al'
            TF = 225.0;
        case 'cu'
            TF = 234.5;
    end
    
    %% Core Loss Resistance -- First Guess
    % Without temperature correction, the losses in 'RCore' should be equal
    % to the load losses at the peak efficiency condition:
    %   V^2 / RCore = I^2 * RSeries
    RCore = 1 / (IMaxEff^2 * RSeries);
    
    %% Loop to Find Core Loss Resistance
    % Setup
    I = (0:Itol:1);
    IMaxEff_tar = IMaxEff;
    IMaxEff_calc = -1;
    
    % Iterations
    iter = 0;
    maxIter = 50;
    
    % This loop applies temperature corrections and adjusts 'RCore' until
    % the peak efficiency occurs at 'IMaxEff'
    while IMaxEff_tar ~= IMaxEff_calc
        %% Numerically Compute the Temperatures
        % Solves the implicit function of 'T' to find the device
        % temperature for each loading level.
        
        % The implicit function of T and I
        f = @(T,I) TAmb + ...
                ( ...
                    I^2 * ( ...
                        (T + TF)/(TRef + TF) * (RW_Ref) + ...
                        (TRef + TF)/(T + TF) * (REC_Ref + ROSL_Ref) ...
                    ) + 1.0 / RCore ...
                ) / ( ...
                    (RW_Ref + REC_Ref + ROSL_Ref) + 1.0 / RCore ...
                ) * TRR - T;
                
        % Vector for temperature results
        T = zeros(size(I));
        
        % Find the corresponding temperatures
        for i = 1:length(I)
            T(i) = fzero( @(x) f(x,I(i)), TAmb + I(i)^2 * TRR );
        end
        
        %% Compute the Efficiencies
        % Output power = V * I
        POut = 1.0 * I;
        
        % Loss = V^2 / RCore + I^2 * RSeries [temp. corrected]
        PLoss = 1.0 ./ RCore + I.^2 .* ( ...
            (T + TF)./(TRef + TF) .* (RW_Ref) + ...
            (TRef + TF)./(T + TF) .* (REC_Ref + ROSL_Ref) );
        
        % Efficiency
        Eta = POut ./ (POut + PLoss);
        
        %% Find Max. Efficiency Point
        % Index of maximum efficiency
        [~, maxIdx] = max(Eta);
        
        % Corresponding value of I
        IMaxEff_calc = I(maxIdx);
        
        %% Correct 'RCore'
        % 'RCore' is corrected proportional to the error:
        %   Large 'RCore' moves the max. efficiency loading down
        %       (lower core loss)
        %   Small 'RCore' moves the max. efficiency loading up
        %       (higher core loss)
        % Corrected by a square b/c the load loss depends on current
        % squared.
        RCore = RCore * (IMaxEff_calc / IMaxEff_tar)^2;
        
        %% Max iterations?
        iter = iter + 1;
        assert( iter <= maxIter, ...
            'ACDC:fitTransformerParam:maxIterationsExceeded', ...
            ['Maximum iterations ' int2str(maxIter) ' exceeded before ' ...
             'finding a valid value of RCore. Data may be inconsistent.']);

    end
    
    %% Compute Magnetizing Branch
    % No load equivalent admittance
    YNL = 1.0 * INL;
    GNL = 1 / RCore;
    
    % No load magnetizing reactance
    XMag = 1 / sqrt(YNL^2 - GNL^2);
    
end % End function
    