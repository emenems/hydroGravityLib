function time_out = time2pattern(time_in,resol)
%TIME2PATTERN convert input time vector to time patter (e.g. yyyymmdd)
%
% Input:
%   time_in     ... time vector (datenum) or time matrix
%   resol       ... string switch for output precission:
%                   'day':      yyyymmdd
%                   'hour':     yyyymmddhh
%                   'minute':   yyyymmddhhmm
%                   'second':   yyyymmddhhmmss
%                   'msecond':   yyyymmddhhmmssmm
%
% Output:
%   time_out    ... time pattern (see 'resol' input)
%
% Example:
%   time_out = time2pattern(time_vec,'hour');
%
% M. Mikolaj, mikolaj@gfz-potsdam.de, 10.12.2016
%
%% Check input (vector or matrix)
% Convert to datevec format if necessary
if size(time_in,2) == 1
    time_in = datevec(time_in);
end

%% Convert
% Switch between required output precision
if strcmp(resol,'day')
    multiplier = [10000, 100];
elseif strcmp(resol,'hour')
    multiplier = [1000000,10000,100];
elseif strcmp(resol,'minute')
    multiplier = [100000000,1000000,10000,100];
elseif strcmp(resol,'second')
    multiplier = [10000000000,100000000,1000000,10000,100];
    time_in(:,6) = round(time_in(:,6));
elseif strcmp(resol,'msecond')
    multiplier = [1000000000000,10000000000,100000000,1000000,10000,100];
else
    multiplier = 0;
end
% Create pattern
time_out = 0;
for i = 1:length(multiplier)
    time_out = time_out + time_in(:,i)*multiplier(i);
end
if ~strcmp(resol,'msecond')
    time_out = time_out + time_in(:,i+1);
end

end