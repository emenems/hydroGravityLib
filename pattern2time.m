function [time_pat] = pattern2time(time_pat,resol)
%PATTERN2TIME convert time pattern to datenum time
%
% Input:
%   time_in     ... time pattern vector (created by time2pattern.m)
%   resol       ... string switch for input precission:
%                   'day':      yyyymmdd
%                   'hour':     yyyymmddhh
%                   'minute':   yyyymmddhhmm
%                   'second':   yyyymmddhhmmss
%                   'msecond':   yyyymmddhhmmssmm
% Output:
%   time        ... time in datenum format
%
% Example:
%   time = pattern2time(2017011702,'hour');
%
%                                       M. Mikolaj, mikolaj@gfz-potsdam.de

%% Convert
% Default values
hour = time_pat.*0;
minute = time_pat.*0;
second = time_pat.*0;
% Switch between required output precision
if strcmp(resol,'day')
    year = floor(time_pat/10000);
    month= floor((time_pat - year*10000)/100);
    day  = floor((time_pat - year*10000 - month*100));
elseif strcmp(resol,'hour')
    year = floor(time_pat/1000000);
    month= floor((time_pat - year*1000000)/10000);
    day  = floor((time_pat - year*1000000 - month*10000)/100);
    hour = floor((time_pat - year*1000000 - month*10000 - day*100));
elseif strcmp(resol,'minute')
    year = floor(time_pat/100000000);
    month= floor((time_pat - year*100000000)/1000000);
    day  = floor((time_pat - year*100000000 - month*1000000)/10000);
    hour = floor((time_pat - year*100000000 - month*1000000 - day*10000)/100);
    minute=floor((time_pat - year*100000000 - month*1000000 - day*10000 - hour*100));
elseif strcmp(resol,'second')
    year = floor(time_pat/10000000000);
    month= floor((time_pat - year*10000000000)/100000000);
    day  = floor((time_pat - year*10000000000 - month*100000000)/1000000);
    hour = floor((time_pat - year*10000000000 - month*100000000 - day*1000000)/10000);
    minute=floor((time_pat - year*10000000000 - month*100000000 - day*1000000 - hour*10000)/100);
    second=round((time_pat - year*10000000000 - month*100000000 - day*1000000 - hour*10000 - minute*100));
elseif strcmp(resol,'msecond')
    year = floor(time_pat/1000000000000);
    month= floor((time_pat - year*1000000000000)/10000000000);
    day  = floor((time_pat - year*1000000000000 - month*10000000000)/100000000);
    hour = floor((time_pat - year*1000000000000 - month*10000000000 - day*100000000)/1000000);
    minute=floor((time_pat - year*1000000000000 - month*10000000000 - day*100000000 - hour*1000000)/10000);
    second=round((time_pat - year*1000000000000 - month*10000000000 - day*100000000 - hour*1000000 - minute*10000));
end
time_pat = datenum(year,month,day,hour,minute,second);

end

