%% Convert FD spectrum to TD waveform
% This function sythesizes a single period of a time-domain
% waveform given the supplied (one-sided) complex harmonic
% spectrum. The harmonic spectrum is assumed to be _sine_
% referenced (and is converted to cosine reference prior applying
% FFT). The first element of the spectrum corresponds to the DC
% component of the spectrum, the second element is the fundamental
% component corresponding to frequency 'f', and the subsequent
% elements correspond to harmonics of 'f'. The returned time series
% waveform is upsampled such that the sampling interval is at least
% as small as 'dt'. (It may be smaller if the specified 'dt' is too
% large to accomodate the harmonic content of the signal.)
%
% This function was originally developed by Stephen Frank at the National
% Renewable Energy Laboratory in connection with Project No. 192, under
% constract from the Bonneville Power Administration, Contract No. 51353 
% and Interagency Agreement No. IAG-11-1801. Permission has been granted to
% reuse this material in connection with Stephen Frank's dissertation
% research.
%
% SYNTAX:
%   [x t] = freqToTime(f, Y, dt)
%
% INPUTS:
%   f = Fundamental frequency
%   Y = Complex representation of harmonic spectrum
%       (sine referenced)
%   dt = desired maximum sampling interval of 'x'
%
% OUTPUTS:
%   x = data values of synthesized time domain waveform
%   t = time values of synthesized time domain waveform
%
% COMMENTS:
%   This function is the equivalent of performing the time domain
%   reconstruction documented in the timeToFreq() method.
%
%   Note also that the 't' vector returned has times running from 
%   t=0 to (T-dt). In other words, it represents exactly 1 period
%   worth of data, since time t=T represents the start of a second
%   period.
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

function [x t] = freqToTime(f, Y, dt)
    %% Setup
    T = 1/f;                    % Fundamental period
    n = length(Y);              % Number of samples in input vector
    N = max(ceil(T/dt), 2*n);   % Required number of samples

    % Ensure 'Y' is a row vector
    [row col] = size(Y);
    if row < col,
        Y = transpose(Y);
    end

    %% Frequency spectrum - DC Term
    % Construct DC term of discrete frequency vector
    Ydc = Y(1);

    %% Frequency spectrum - Lower half of vector
    % Construct lower half of discrete frequency vector (minus DC term)
    Ylow = N * -1j * Y ./ 2;    % Apply -90 deg. operator (to
                                % convert to cosine reference)
                                % and adjust magnitude
    Ylow(1) = [];               % Remove DC term
    Ylow = transpose(Ylow);     % Transpose to row vector

    % Zero pad to achieve required number of data points
    Ylow = [Ylow zeros(1,floor(N/2-n+1))];
        % Even N ->     Length = N/2    
        % Odd N ->      Length = (N-1)/2

    %% Frequency spectrum - Upper half of vector 
    % Construct upper half of discrete frequency vector by conjugate
    % mirroring.
    Yhigh = fliplr(conj(Ylow));

    % Adjust length to be correct
    if mod(N,2) == 0,
        Yhigh(1) = [];  % Trim one element ->   Length = N/2 - 1
    end                 % Otherwise ->          Length = (N-1)/2

    %% Construct discrete frequency vector
    Ynew = [Ydc Ylow Yhigh];

    %% Perform inverse FFT and compute output values
    % Inverse FFT for data output vector
    x = transpose( ifft(Ynew) );

    % Construct time output vectors
    t = transpose( (0:(N-1)) / N * T );
end

% NOTE: For a quick summary of FFT, see:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/279074