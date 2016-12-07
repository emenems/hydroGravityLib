function [timeout,dataout] = mm_filt(timein,datain,impulsein,orig_step)
%MM_FILT Function for filtering time series with missing or NaN data
%   This function used standard convolution for filtering.  However, the
%   input time series is filtered piecewise in case missing data or NaN
%   exist in the input data
%
%
% Input:
%   timein      ...     input time vector
%   datain      ...     input data vector or matrix
%   impulsein   ...     filter impulse response (vector)
%   orig_step   ...     sampling rate in days (datenum), e.g. 1/24 for 1
%                       hour sampling
%
% Output:
%   timeout     ...     output time vector. May differ from 'timein'!!
%   dataout     ...     filtered vector. The length differ from 'datain'!!
%
% Requirement (additional functions):
%   findTimeStep.m
%   mmconv.m
% 
% Example:
%   [timeout,dataout] = mm_filt(timein,datain,impulsein,orig_step)

% Run for all columns
for c = 1:size(datain,2)
	% First find missing data or NaNs
	[timeout0,dataout0,id] = findTimeStep(timein,datain(:,c),orig_step); 
	dout = [];                                                                  % aux. data variable
	tout = [];                                                                  % aux. time variable
	% Run a loop for all time intervals without NaNs or missing data separately
	% (filter between time steps that have been found using findTimeStep function) 
	for i = 1:size(id,1)                                                         
		if length(dataout0(id(i,1):id(i,2))) > length(impulsein)*2  % filter only if the current time interval is long enough
			[ftime,fgrav] = mmconv(timeout0(id(i,1):id(i,2)),dataout0(id(i,1):id(i,2)),impulsein,'valid'); % use mmconv = Convolution function (outputs only valid time interval, see nnconv function for details)
		else
			ftime = timeout0(id(i,1):id(i,2)); % if the interval is too short, set to NaN 
			fgrav(1:length(ftime),1) = NaN;
		end
		dout = vertcat(dout,fgrav,NaN); % stack the aux. data vertically + NaN to mark holes between fillering sequences
		tout = vertcat(tout,ftime,...   % stack the aux. time vertically. Do NOT add NaNs!
				ftime(end)+orig_step); % this last part is for a NaN that has been apended to 'dout' (see above)  
		clear ftime fgrav
	end
	if c == 1
		timeout = tout;
	end
	dataout(:,c) = dout;
	clear tout dout timeout0 dataout0 id i
end