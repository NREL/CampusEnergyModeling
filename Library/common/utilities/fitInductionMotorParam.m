%% FITINDUCTIONMOTORPARAM - Fit an induction motor equivalent circuit
%
% This function finds the approximate equivalent circuit parameters of an
% induction motor based on the nameplate data. The parameters are returned
% in per-unit relative to the motor's full load output power rating.
%
% This function was originally developed by Keun Lee at the National
% Renewable Energy Laboratory in connection with Project No. 192, under
% constract from the Bonneville Power Administration, Contract No. 51353 
% and Interagency Agreement No. IAG-11-1801. It was later reused and
% updated, with permission, by Stephen Frank for his dissertation research
% (see REFERENCES). 
%
% SYNTAX:
%   [R1, R2, RC, RStray, X1, X2, XM] = fitInductionMotorParam( ...
%       VRated, PRated, Eff, PF, s, Design, Code, varargin)
%
% INPUTS:
%   VRated =  	Rated motor terminal voltage (line-to-line) [V]
%              	NOTE: Vrated is also used as the per-unit voltage base
%   PRated =  	Rated motor output power [kW]
%              	NOTE: Pout is also used as the per-unit power base
%   Eff =     	Motor rated efficiency at full load [pu]
%   PF =      	Motor rated power factor at full load [pu]
%   s =       	Motor slip at full load [pu]
%   Design =  	NEMA design class: A, B, C, D, or W (Wound rotor)
%   Code =      NEMA code letter (gives kVA/HP)
%   varargin =  (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'Code':
%
%   'FStray', [val] Stray load loss as a fraction of *rated power*
%                   (Default = Computed from kVA rating)
%   'FCore', [val]  Core loss as a fraction of total loss
%                   (Default = 0.12)
%   'FMech', [val]  Mechanical loss as a fraction of total loss
%                   (Default = 0.14)
%   'tol', [val]    Convergence tolerance
%                   (Default = sqrt(eps))
%
% OUTPUTS:
%   R1 =        Stator resistance
%   R2 =        Rotor resistance
%   RC =        Core loss equivalent resistance
%   RStray =    Stray load loss equivalent resistance
%   X1 =        Stator reactance
%   X2 =        Rotor reactance
%   XM =        Magnetizing reactance
%
% All outputs are in per-unit with VBase = VRated and SBase = POut
%
% REFERENCES:
%   K. Lee, S. Frank, P. K. Sen, L. Gentile Polese, M. Alahmad, and C.
%   Waters, "Estimation of induction motor equivalent circuit parameters
%   from nameplate data," in Proc. 2012 North American Power Symposium
%   (NAPS), Urbana, IL, Sep. 2012, pp. 1–6. Available:
%   http://dx.doi.org/10.1109/NAPS.2012.6336384.
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

function [R1, R2, RC, RStray, X1, X2, XM] = fitInductionMotorParam( ...
	VRated, PRated, Eff, PF, s, Design, Code, varargin)
    %% Process Input Arguments / Set Default Values
    % Argument check required inputs
    argCheck(VRated, 'vName', 'VRated', 'cName', 'fitInductionMotor', ...
        'vType', 'real', '--Pos', '--Finite');
    argCheck(PRated, 'vName', 'PRated', 'cName', 'fitInductionMotor', ...
        'vType', 'real', '--Pos', '--Finite');
    argCheck(Eff, 'vName', 'Eff', 'cName', 'fitInductionMotor', ...
        'vType', 'real', '--Pos', 'UB', 1.0);
    argCheck(PF, 'vName', 'PF', 'cName', 'fitInductionMotor', ...
        'vType', 'real', '--Pos', 'UB', 1.0);
    argCheck(s, 'vName', 's', 'cName', 'fitInductionMotor', ...
        'vType', 'real', '--Pos', 'UB', 1.0);
    
    % Process varargin arguments
    vals = toStruct(varargin, 'cName', 'fitInductionMotor', ...
            'validArgs', {'FStray','FCore','FMech','tol'});
    fnames = fieldnames(vals);
        
    % Stray loss as a fraction of *rated load* (not of total loss)
    if ismember('FStray', fnames)
        % User input
        argCheck(vals.FStray, 'vName', 'FStray', ...
            'cName', 'fitInductionMotor', ...
            'vType', 'real', '--nonNeg', 'UB', 1.0);
        FStray = vals.FStray;
    else
        % Default
        if PRated <= 90
                FStray = 0.018;	
        elseif PRated > 90 && PRated <= 375
                FStray = 0.015;	
        elseif PRated > 375 && PRated <= 1850
                FStray = 0.012;	
        elseif PRated > 1850
                FStray = 0.009;	
        end
    end
        
    % Assumed core loss as a fraction of *total loss*
    if ismember('FCore', fnames)
        % User input
        argCheck(vals.FCore, 'vName', 'FCore', ...
            'cName', 'fitInductionMotor', ...
            'vType', 'real', '--nonNeg', 'UB', 1.0);
        FCore = vals.FCore;
    else
        % Default (Saidur 2010)
        FCore = 0.12;
    end
    
    % Assumed mechanical loss as a fraction of *total loss*
    if ismember('FMech', fnames)
        % User input
        argCheck(vals.FMech, 'vName', 'FMech', ...
            'cName', 'fitInductionMotor', ...
            'vType', 'real', '--nonNeg', 'UB', 1.0);
        FMech = vals.FMech;
    else
        % Default (Saidur 2010)
        FMech = 0.14;
    end
    
    % Convergence tolerance
    if ismember('tol', fnames)
        % User input
        argCheck(vals.tol, 'vName', 'tol', ...
            'cName', 'fitInductionMotor', ...
            'vType', 'real', '--nonNeg', '--Finite');
        tol = vals.tol;
    else
        % Default
        tol = sqrt(eps);
    end
    
    %% Setup
    % Per-unit power + voltage
    POut = 1.0;
    VIn = 1.0;
    
    % X1/XLR from NEMA design type
    switch upper(Design)
        case 'A' 
            Xratio = 0.5;
        case 'B' 
            Xratio = 0.4;
        case 'C' 
            Xratio = 0.3;
        case 'D' 
            Xratio = 0.5;
        case 'W' 
            Xratio = 0.5;
        otherwise
            error('ACDC:fitInductionMotor:invalidOption',...
                'Invalid NEMA design type.');
    end
    
    % Locked rotor current from NEMA letter code
    % (Assumed value is median point of corresponding region, except for
    % 'A' which is assumed at the high value and 'V' which is assumed at
    % the low value.)
    switch upper(Code)
        case 'A' 
            kVAperHP = 3.15;        % 0-3.15 kVA/HP
        case 'B' 
            kVAperHP = 3.35;        % 3.15-3.55 kVA/HP
        case 'C' 
            kVAperHP = 3.78;        % 3.55-4.00 kVA/HP
        case 'D' 
            kVAperHP = 4.25;        % 4.00-4.50 kVA/HP
        case 'E' 
            kVAperHP = 4.75;        % 4.50-5.00 kVA/HP
        case 'F' 
            kVAperHP = 5.30;        % 5.00-5.60 kVA/HP
        case 'G' 
            kVAperHP = 5.95;        % 5.60-6.30 kVA/HP
        case 'H' 
            kVAperHP = 6.70;        % 6.30-7.10 kVA/HP
        case 'J' 
            kVAperHP = 7.55;        % 7.10-8.00 kVA/HP
        case 'K' 
            kVAperHP = 8.50;        % 8.00-9.00 kVA/HP
        case 'L' 
            kVAperHP = 9.50;        % 9.00-10.00 kVA/HP
        case 'M' 
            kVAperHP = 10.60;       % 10.00-11.20 kVA/HP
        case 'N' 
            kVAperHP = 11.85;       % 11.20-12.50 kVA/HP
        case 'P' 
            kVAperHP = 13.25;       % 12.50-14.00 kVA/HP
        case 'R' 
            kVAperHP = 15.00;       % 14.00-16.00 kVA/HP
        case 'S' 
            kVAperHP = 17.00;       % 16.00-18.00 kVA/HP
        case 'T' 
            kVAperHP = 19.00;       % 18.00-20.00 kVA/HP            
        case 'U' 
            kVAperHP = 21.20;       % 20.00-22.40 kVA/HP
        case 'V' 
            kVAperHP = 22.40;       % > 22.40 kVA/HP        
        otherwise
            error('Invalid NEMA code letter.');
    end
    ILR = kVAperHP * (1/0.746);
    
    %% Calculate Power Values
    % Input power
    PIn = POut / Eff;
    
    % Assumed loss values
    PLoss = PIn - POut;         	% Total loss
    PStray = POut * FStray;     	% Stray loss
    PMech = PLoss * FMech;          % Mechanical loss
    PCore = PLoss * FCore;          % Core loss
    
    % Power at various points in the machine
    P_Conv = POut + PMech + PStray; % EM converted power
    P_AG   = P_Conv / (1 - s);      % Air gap power
    
    % Computed losses
    % P_RCL = P_AG - P_Conv;        % Rotor copper loss (not needed)
    P_SCL = PIn - P_AG - PCore;   	% Stator copper loss
    
    %% Calculate Known Parameters
    % These can be determined exactly based on known data
    
    % Input reactive and apparent power
    QIn = PIn * sqrt((1/PF)^2 - 1); 
    SIn = PIn + 1j * QIn;
    
    % Input current
    I1 = conj(SIn / VIn);
    
    % Stator resistance
    R1 = P_SCL / (abs(I1)^2);
    
    %% Iteration to Find Unknown Parameters
    % Setup
    maxChange = 2*tol;
    iter = 1;
    maxIter = 50;
    
    % Initial guesses of E and I2
    E = VIn;
    I2 = real(I1);
    
    % Set values of all unknowns to 0 to ensure that they change on the
    % first iteration
    R2 = 0;
    RC = 0;
    X1 = 0;
    X2 = 0;
    XM = 0;
    
    % Loop to convergence
    while( (maxChange > tol) && (iter <= maxIter) )
        % Store old values
        R2old = R2;
        RCold = RC;
        X1old = X1;
        X2old = X2;
        XMold = XM;

        % Update R2
        EMag = abs(E);
        R2 = s * (EMag^2 + sqrt(EMag^4 - 4 * P_AG^2 * X2^2)) / (2*P_AG);
        
        % Update estimate of XLR
        XLR = sqrt( (VIn/ILR)^2 - (R1 + R2)^2 );

        % Assign values to X1 and X2 based on XLR
        X1 = Xratio * XLR;
        X2 = (1 - Xratio) * XLR;
        
        % Update XM according to the required magnetizing reactive power
        QM = QIn - ( X1*abs(I1)^2 + X2*abs(I2)^2 );
        XM = abs(E)^2 / QM;
        
        % Update RC according to the required core loss
        RC = abs(E)^2 / PCore;
        
        % Update estimates of I2 and E
        E = VIn - I1 * (R1 + 1j*X1);
        I2 = E / (R2/s + 1j*X2);
        
        % Evaluate change
        maxChange = norm( [R2 - R2old, RC - RCold, ...
            X1 - X1old, X2 - X2old, XM - XMold ], Inf);
        
        % Update counter
        iter = iter + 1;
        
        % Maximum iterations?
        assert( iter <= maxIter, ...
            'ACDC:fitTransformerParam:maxIterationsExceeded', ...
            ['Maximum iterations ' int2str(maxIter) ' exceeded ' ...
             'before finding a valid equivalent circuit. ' ...
             'Data may be inconsistent.']);
    end
    
    % Compute RStray
    RStray = R2 * (1 - s)/s * FStray/(1 + FStray);
    
end % End function
    