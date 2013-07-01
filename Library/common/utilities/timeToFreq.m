%% Convert TD waveform to FD spectrum
% This function extracts and returns the harmonic spectrum for a
% time series given the data values and the sampling interval.
% Results are reported with respect to the fundamental frequency,
% which is returned in 'f'. The fundamental period (the reciprocal
% of the fundamental frequency) is assumed to be the (time) length
% of the data sample, T = 1/f = length(x) * dt. The phase angles of
% the resulting complex spectrum are referenced to the _sine_
% function.
%
% This function was originally developed by Stephen Frank at the National
% Renewable Energy Laboratory in connection with Project No. 192, under
% constract from the Bonneville Power Administration, Contract No. 51353 
% and Interagency Agreement No. IAG-11-1801. Permission has been granted to
% reuse this material in connection with Stephen Frank's dissertation
% research.
%
% SYNTAX:
%   [f h Y] = timeToFreq(x, dt)
%
% INPUTS:
%   x = Vector of time series data
%   dt = Sampling interval (assumed to be uniform)
%
% OUTPUTS:
%   f = Fundamental frequency
%   h = Vector of harmonic order (0 = DC component)
%   Y = Complex representation of harmonic spectrum
%       (sine referenced)
%
% COMMENTS:
%   Note that 'Y' has a DC term in the first position and that Y(2)
%   actually corresponds to h = 1.
%   
%   To reconstruct the time series signal...
%                  hmax
%   x(t) = mag_0 + SUM mag_h * sin(2*pi*f*h*t + phase_h)
%                  h=1
%   
%   where...
%       mag_0 = abs(Y(1))
%       mag_h = abs(Y(h+1))
%       phase_h = angle(Y(h+1))
%
%   The freqToTime() method performs this reconstruction via inverse FFT.
% 

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

function [f h Y] = timeToFreq(x, dt)
    %% Setup
    N = length(x);      % Number of data points
    T = N*dt;           % Fundamental period
    f = 1/T;            % Fundamental frequency

    %% Perform FFT
    Y = fft(x);

    %% Perform scaling and compute output
    % Harmonic spectrum (complex representation)
    Y = Y/N;                            % First, normalize by N
    Y = Y(1:floor(N/2));                % Extract lower half of vector
    Y(2:length(Y)) = 2*Y(2:length(Y));  % Scale non-DC components

    % Apply 90 deg. operator to convert to sine reference
    Y(2:length(Y)) = 1j * Y(2:length(Y));

    % Associate harmonic values
    h = transpose( 0:(length(Y)-1) );
end

% NOTE: For a quick summary of FFT, see:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/279074