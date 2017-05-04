function [data,id_time,id_col] = fillnans(varargin)
%FILLNANS Fill NaNs in an equally sampled vector with interpolated values
% NaNs will be replaced by interpolated values as long as the NaN interval
% is shorter than by user given frame. 
% Warning: It is advisable to correct the input time series for missing 
%          data using 'findTimeSteps.m' prior to running this function.
%
% Input:
%   'time'  ... input time vector in matlab/octave datenum format, or x
%               coordinate. Must be equally sampled (use 'findTimeSteps.m')
%   'data'  ... input data (y) matrix or vector (equally sampled!)
%   'method'... interpolation method. Default: 'linear'
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
int_method = 'linear';
fill_missing = 0;
id_time = [];
id_col = [];

%% Read user input
% First check for correct number of input arguments
if nargin >= 2 && mod(nargin,2) == 0
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
            case 'method'
                int_method = varargin{in+1};
            case 'max_wind'
                fill_missing = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
elseif nargin > 0 && mod(nargin,2) ~= 0
    error('Set even number of input parameters')
end

%% Main code
r_nan = find(isnan(sum(data,2)));
% Aux. variable to compute the length of the NaN sequence
d_nan = [fill_missing+1;diff(r_nan)];
if ~isempty(r_nan)
    for r = 1:length(r_nan)
        % To avoid trying the interpolation in long intervals with
        % missing data compare the length to given maximum possible
        % interval. 
        % First check if the current NaN is at tail or head and adjust
        % the 'temp_interval' accordingly
        temp_interval_l = fill_missing;
        temp_interval_r = fill_missing;
        if r <= fill_missing
            temp_interval_l = r-1;
        end
        if r >= length(r_nan) - fill_missing
            temp_interval_r = length(r_nan) - r;
        end
        % Now check the sum of differences between NaN indices. If all
        % neighbors of the current NaNs are also within the maximum
        % interp. interval also NaNs, than the sum of the difference is
        % equal to the count.
        if sum(d_nan(r-temp_interval_l:r+temp_interval_r)) ~= (temp_interval_r+temp_interval_l)+1
            % Check what data is missing (i.e. what column is affected)
            temp_index = [];
            for j = 1:size(data,2)
                if isnan(data(r_nan(r),j))
                    temp_index(j) = 1;
                else
                    temp_index(j) = 0;
                end
            end
            temp_index = logical(temp_index);
            % Try to interpolate the data keeping in mind the maximum
            % possible interval (=window). Shift the Xtimes the window from
            % right to left until NaN is removed or the window is at the
            % edge
            temp_shift = 1; % one time unit/index
            while temp_shift < fill_missing
                ytemp = data(r_nan(r)- temp_shift: r_nan(r)+(fill_missing-temp_shift),temp_index); % find the affected data
                xtemp = time(r_nan(r)- temp_shift: r_nan(r)+(fill_missing-temp_shift),:); % get selected time interval 
                % Remove all NaNs from current interval so NaNs adjacent to the
                % current one are not preventing the interpolation (it is only
                % important that at least two valid values are within the interval,
                % one before and one after current NaN)
                xtemp(isnan(sum(ytemp,2)),:) = [];
                ytemp(isnan(sum(ytemp,2)),:) = [];
                % at least two data points required
                if length(xtemp) >= 2
                    % Interpolate values for the affected interval only (use r as index)
                    data(r_nan(r),temp_index) = interp1(xtemp,ytemp,time(r_nan(r)),int_method); 
                    if ~isnan(sum(data(r_nan(r),temp_index)))
                        id_time = vertcat(id_time,time(r_nan(r)));
                        id_col = vertcat(id_col,temp_index);
                        break;
                    end
                end
                temp_shift = temp_shift + 1;
                clear xtemp ytemp x1 x2 otime 
            end
            clear fprintf_string temp_index temp_shift
        end
    end
end
clear j r_nan  

end % function

