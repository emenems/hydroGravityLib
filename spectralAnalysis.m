function [f,amp,pha,h] = spectralAnalysis(data,fs,varargin)
%SPECTRALANALYSIS perform spectral analysis
% This function removes signal trend automatically.
% 
% Input:
%   data  	...     input time series (vector or matrix)
%   fs      ...     frequency sampling (scalar, Hz)
% Optional input:
%   'window'...     set window function = 'none'(default)|'hann'|'hamm'.
%   'lenFFT'...     length of the FFT (scalar), 
%                   default = 2^nextpow2(length(signal))
%   'plot'  ...     plot (1), do not plot (0), or use axes handle to 
%                   plot to a certain axes. Default = 0
%   'detrend'..     de-trend signal before FFT. 1 = yes (default),0 = no
% 
% Output:
%   f       ...     output FFT frequency (vector in Hz)
%   amp     ...     computed FFT amplitudes (matrix if signal matrix too)
%   pha     ...     computed FFT phase
%   h       ...     line handle (if 'plot' = 1)
% 
% Example1:
%   [f,amp,pha] = plotGrav_spectralAnalysis(signal,1/60);
%
% Example2:
%   ax = subplot(2,1,1);
%   plotGrav_spectralAnalysis(signal,1/60,'window','hann','plot',ax,'detrend',0);
%
%                                              M.Mikolaj, mikolaj@gfz-potsdam.de
%   
%% Set default values (can be overwritten by user input)
% check if row vector is on input
if size(data,1)==1 && size(data,2)>1
    data = data';
end
lenFFT = 2^nextpow2(size(data,1)); % default length of FFT
win = 'none';
plot_onoff = 0;
det = 1; 

%% Read user input
% Depending on the user input set function parameters.
if nargin > 2 && mod(nargin,2) == 0
    in = 1; % starting value
    while in < nargin-2 
        switch varargin{in}
            case 'window'
                win = varargin{in+1};
            case 'lenFFT'
                lenFFT = varargin{in+1};
            case 'plot'
                plot_onoff = varargin{in+1};
            case 'detrend'
                det = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
end

%% Compute
amp = zeros(lenFFT,1);
pha = zeros(lenFFT,1);
for i = 1:size(data,2)
    if det == 1
        signal = detrend(data(:,i));
    else
        signal = data(:,i);
    end
    switch win
        case 'hann'
            signal = signal.*hann(length(signal));
        case 'hamm'           
            signal = signal.*hamming(length(signal));
    end
    y = fft(signal,lenFFT)/length(signal);
    amp(:,i) = 2*abs(y);
    amp(1,i) = amp(1,i)/2;
    pha(:,i) = unwrap(angle(y));
    clear y signal
end
% One frequency vector for all columns
f = transpose((0:lenFFT-1)*(fs/lenFFT));

%% Plot (only if required)
if plot_onoff == 1	
    figure    
    ax = axes;
elseif plot_onoff ~= 0
    ax = plot_onoff;
end
if plot_onoff ~= 0
	h = plot(ax,(1./f)/86400,amp);
    % max x limit (length of the signal in days)
	xmax = ((1/fs)*length(data(:,1)))/86400;
    % min x limit (half of the freq. sampling)
	xmin = (1/(fs/2))/86400;
	xlim(ax,[xmin xmax]);
	xlabel(ax,'days');
	ylabel(ax,'amplitude');
else
	h = NaN;
end

end % function
