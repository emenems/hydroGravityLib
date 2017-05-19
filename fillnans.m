function [data,id_time,id_col] = fillnans(varargin)
%FILLNANS Fill NaNs in an equally sampled vector with interpolated values
% NaNs will be replaced by linearly interpolated values as long as the 
% NaN interval is shorter than by user given frame. 
% Warning: It is advisable to correct the input time series for missing 
%          data using 'findTimeSteps.m' prior to running this function.
%
% Input:
%   'time'  ... input time vector in matlab/octave datenum format, or x
%               coordinate. Must be equally sampled (use 'findTimeSteps.m')
%   'data'  ... input data (y) matrix or vector (equally sampled!)
%   'max_wind'. maximal window length/frame to be filled by interpolation
%               Use the same units as in 'time'. 
%               Example: if time(2)-time(1) = 1 second => set 'max_wind' to
%               10 for filling 10 second window at max.
%
% Output:
%   data    ... corrected output matrix/vector
%   id_time ... time staps of the interpolated values
%   id_col  ... column indices that have been interpolated for particular 
%               id_time
%
% Example:
%   time_in = [datenum(2000,1,1):1/24:datenum(2000,1,2)]';
%   data_in = time_in*0+1;
%   data_in(10:11) = NaN; % will be interpolated
%   data_in(17:24) = NaN; % will Not be interpolated
%   max_wind = 3; % => 3 hours
%   [data,id_time,id_col] = fillnans('time',time_in,'data',data_in,...
%                               'max_wind',max_wind);
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de

%% Default values
time = [];
data = [];
fill_missing = 0;
id_time = [];
id_col = [];

%% Read user input
% First check for correct number of input arguments
if nargin >= 6 && mod(nargin,2) == 0
    % Count input parameters
    in = 1;
    % Try to find input parameters
    while in < nargin
        % Switch between function parameters
        switch varargin{in}
            case 'time'
                time = varargin{in+1};
            case 'data'        
                data = varargin{in+1};
            case 'max_wind'
                fill_missing = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
elseif nargin < 6 || mod(nargin,2) ~= 0
    error('Set even number of input parameters. Minimum: time, data, max_wind');
end

%% Main code
col_num = size(data,2);
% Find where at least one column contains NaNs
r_nan = find(isnan(sum(data,2)));
if ~isempty(r_nan)
    for r = 1:length(r_nan)
        % To avoid trying the interpolation in long intervals with
        % missing data compare the length to given maximum possible
        % interval. First check if the current NaN is at tail or 
        % head and adjust the 'temp_interval' accordingly
        temp_interval_l = fill_missing;
        temp_interval_r = fill_missing;
        if r_nan(r) <= fill_missing
            temp_interval_l = r_nan(r) - 1;
        end
        if r_nan(r) >= length(time) - fill_missing
            temp_interval_r = length(time) - r_nan(r);
        end
        % Check which column contains NaN
        temp_index = isnan(data(r_nan(r),:));
        id_col = vertcat(id_col,zeros(1,col_num));
        for i = 1:col_num
            % Proceed only for NaN columns
            if temp_index(i)
                % Check if at least 2 data points are available for
                % interpolation (+ do not try for first and last row in
                % data matrix)
                ytemp = data(r_nan(r)-temp_interval_l:r_nan(r)+temp_interval_r,i);
                ytemp(isnan(ytemp)) = [];
                if length(ytemp) >= 2 && r_nan(r) ~= 1 && r_nan(r) ~= length(time)
                    % Try to interpolate the data keeping in mind the maximum
                    % possible interval (=window). Shift the Xtimes the window from
                    % right to left until NaN is removed or the window is at the
                    % edge
                    temp_shift = 1; % one time unit/index
                    while temp_shift < fill_missing
                        temp_index_r = r_nan(r)+(fill_missing-temp_shift);
                        temp_index_l = r_nan(r)- temp_shift;
                        if temp_index_l < 1
                            temp_interval_l = 1;
                        end
                        if temp_index_r > length(data)
                            temp_index_r = length(data);
                        end
                        ytemp = data(temp_index_l:temp_index_r,i); % find the affected data
                        xtemp = time(temp_index_l:temp_index_r,:); % get selected time interval 
                        % Remove all NaNs from current interval so NaNs adjacent to the
                        % current one are not preventing the interpolation (it is only
                        % important that at least two valid values are within the interval,
                        % one before and one after current NaN)
                        xtemp(isnan(ytemp)) = [];
                        ytemp(isnan(ytemp)) = [];
                        % at least two data points required
                        if length(xtemp) >= 2
                            % Interpolate values for the affected interval 
                            % only (use r_nan(r) as index)
                            data(r_nan(r),i) = interp1(xtemp,ytemp,time(r_nan(r)),'linear'); 
                            if ~isnan(data(r_nan(r),i))
                                id_time = vertcat(id_time,time(r_nan(r)));
                                id_col(end,i) = 1;
                                % End current while loop
                                temp_shift = fill_missing+10; % ==break
                            end
                        end
                        temp_shift = temp_shift + 1;
                        clear xtemp ytemp
                    end
                end
            end
        end
        % Correct output IDs if NaN has not been removed
        if sum(id_col(end,:)) == 0
            id_col(end,:) = [];
        end
    end
end
if ~isempty(id_time)
    id_time = unique(id_time);
end
end % function

