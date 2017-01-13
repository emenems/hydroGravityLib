function [dataout,replaced] = replaceNaN(time,data,interval,method)
%REPLACENAN Interpolate (replace) NaN values
% This function will replace all NaNs if the interval of NaNs is within
% given time range. 
% For example if time = [1;2;3;4;5], data = [1;2;NaN;4;5], interval = 1,
% method = 'linear', than dataout = [1;2;3;4;5] and replaced = 3.
% To replace all missing data (not only NaNs) use findTimeStep.m function
% first.
%
% Input:
%   time    ... time vector in matlab (datenum) time format
%   data    ... data vector or matrix (same length as time)
%   interval... maximal time interval in (datenum) time format. !! Final 
%               interval is 2 x interval = time-interval:time+interval !!
%   method  ... interpolation method: 'linear', 'spline', i.e. identical
%               with 'interp1' interpolation method switch.
%
% Output:
%   dataout ... output data vector or matrix (same length as data)
%   replaced... time vector of replaced NaNs
%
% Example:
%   dataout = interpNaN(time,data,1/24,'linear');
%
%                                         M.Mikolaj, mikolaj@gfz-potsdam.de
%
%% Run loop for all columns separately
replaced = [];
dataout = data;
for c = 1:size(dataout,2)
    % Find all NaNs in input data
    r = find(isnan(dataout(:,c))); 
    % Continue only if at least one NaN, but not all NaNs have been found.
    if ~isempty(r) && length(r) < length(time)-2
        for i = 1:length(r)
            % set time limits: for current NaN
            x1 = time(r(i))-interval; 
            x2 = time(r(i))+interval;
            % find the affected data and corresponding time vector
            ytemp = dataout(time>= x1 & time <= x2,c); 
            xtemp = time(time >= x1 & time <= x2); 
            % Remove all NaNs from current interval so NaNs adjacent to the
            % current one are not preventing the interpolation (it is only
            % important that at least two valid values are within the interval,
            % one before and one after current NaN)
            xtemp(isnan(ytemp)) = [];
            ytemp(isnan(ytemp)) = [];
            if length(xtemp) >= 2
                replaced = [replaced;time(r(i))];
                dataout(r(i),c) = interp1(xtemp,ytemp,time(r(i)),method);
            end
            clear xtemp ytemp x1 x2
        end
    end
end % function