function [time_out,data_out] = mm_timeExtreme(time,data,resol,varargin)
%MM_timeExtremes find extremes within given time interval (day,hour,minute)
% Input:
%   time        ... time vector in matlab (datenum) format
%   data        ... data vector
%   resol       ... time resolution = 'day', 'hour', or 'minute'
%   varargin{1} ... additional options: 'nonan' (optional)
%
% Output:
%   time_out    ... output time vector (shows the midpoint not the range)
%   data_out    ... output matrix with following columns: [min,max,mean]
%
% Requirements:
%   Statistical toolbox 
% 
% Example1:
%   [time_out,data_out] = mm_timeExtreme(time,data,'day');
% Example2:
%   [time_out,data_out] = mm_timeExtreme(time,data,'day','nonan');
%
%                                                   M.Mikolaj, 22.04.2016

%% Prepare time
% Convert input time to civil date. This will be used to create output time
% vector in given resolution. Only first and last value will be used.
[year,month,day,hour,minute,~] = datevec(time([1,end]));
% Create new/output time vector
switch resol
    case 'day'
        time_step = 1;
        time_out = [datenum(year(1),month(1),day(1),0,0,0):time_step:datenum(year(end),month(end),day(end),0,0,0)]';
    case 'hour'
        time_step = 1/24;
        time_out = [datenum(year(1),month(1),day(1),hour(1),0,0):time_step:datenum(year(end),month(end),day(end),hour(end),0,0)]';
    case 'minute'
        time_step = 1/1440;
        time_out = [datenum(year(1),month(1),day(1),hour(1),minute(1),0):time_step:datenum(year(end),month(end),day(end),hour(end),minute(end),0)]';
    case '10min'
        time_step = 1/144;
        time_out = [datenum(year(1),month(1),day(1),hour(1),0,0):time_step:datenum(year(end),month(end),day(end),hour(end),minute(end),0)]';
    otherwise
        time_out = [];
        time_step = 0;
        disp('Invalide RESOL switch');
end

%% Compute
% Check additional user options
if nargin == 4
    switch varargin{1}
        case 'nonan'
            % Remove NaNs
            time(isnan(data)) = [];
            data(isnan(data),:) = [];
    end
end
% Declare output variable
data_out(1:length(time_out)-1,1:3) = NaN;

% Run loop for all time epochs
if ~isempty(time_step)
    for i = 1:length(time_out)-1
        % Get temporary data storing all data points within current
        % day/hour/minute
        temp = data(time>time_out(i) & time<=time_out(i+1),:);
        if ~isempty(temp)
            % Store minimum value
            data_out(i,1) = min(temp);
            % Store maximum value
            data_out(i,2) = max(temp);
            % Store mean value
            data_out(i,3) = mean(temp);
        end
    end
    % Update time
    % Set the output time to midpoint. Do not use the last one as that time
    % epoch was not computed (see for loop)
    time_out = time_out(1:end-1) + time_step/2;
else
    disp('Invalide RESOL switch');
    data_out = [];
end


end % function
