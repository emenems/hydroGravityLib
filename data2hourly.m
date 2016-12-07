function [time_out,data_out,check_out] = data2hourly(time,data,convertSwitch,nanSwitch)
%DATA2HOURLY Convert/aggregate input data to hourly means/sums
% User can convert = create dailyy means or sums for input time series.
% Use data2monthly function to generate monthly data.
% Use data2daily function to generate daily data.
%
% Input:
%   time        ... time matrix [year,month,day,hour,minute,second]
%   data        ... data matrix or vector.
%   convertSwitch ... 1 = daily means (e.g., for temperature)
%                   2 = hourly sums (e.g., for precipitation)
%   nanSwitch   ... 0 = NaN on input => NaN on output
%                   1 = NaN on input will be removed => no NaN on output
%
% Output:
%   time_out    ... output time: [year,month,day] matrix. Time refers to
%                   the 60 minute period. Not previous 24 hours, e.g., if
%                   input rain [2000,1,2,13,23,14] = 2 mm, than output 
%                   time = [2000,1,2,13,0,0,0] and data_out = 2 mm!!! 
%   data_out    ... output data matrix or vector (means or sums)
%   check_out   ... number of elements used for the computation of
%                   mean/sum. This is useful as this function computes also
%                   mean/sum for incomplete months!!! The second column of
%                   this variable shows how many elements should be present
%                   if constant sampling used.
% Requirements:
%   This funcion does not require additional function.
%
% Example
%   [time_out,data_out] = data2hourly(time,data,1,0);
%
%                                                   M. Mikolaj, 05.10.2015

%% Prepare data
% Convert input time vector to civil format if not already in such format
if size(time,2) == 1
    [year,month,day,hour,minute,second] = datevec(time);
else
    year = time(:,1);
    month = time(:,2);
    day = time(:,3);
    hour = time(:,4);
    minute = time(:,5);
    second = time(:,6);
end
% Determine the time resolution
time_resol = diff(datenum(year,month,day,hour,minute,second));
time_resol = mode(time_resol);
% Remove NaNs if required
if (nanSwitch == 1)
    % Remove NaNs for ALL columns! (= sum(data,2))
    year(isnan(sum(data,2))) = [];
    month(isnan(sum(data,2))) = [];
    day(isnan(sum(data,2))) = [];
    hour(isnan(sum(data,2))) = [];
    data(isnan(sum(data,2)),:) = [];           
end
% First create unique time ID for each hour = yyyymmddhh
timeID = year*1000000+month*10000+day*100+hour;
timeID = unique(timeID);    % remove redundand values
% converts yyyymmddhh -> [yyyy,mm,dd,hh]
time_out(:,1) = floor(timeID/1000000);
time_out(:,2) = floor((timeID - time_out(:,1)*1000000)/10000);
time_out(:,3) = floor((timeID - time_out(:,1)*1000000 - time_out(:,2)*10000)/100);
time_out(:,4) = timeID-time_out(:,1)*1000000 - time_out(:,2)*10000 - time_out(:,3)*100;
time_out(:,5:6) = 0;
            
% Declare output variables
data_out(1:length(timeID),1:size(data,2)) = NaN;
check_out(1:length(timeID),2) =1/time_resol/24;  % compute 'should' value

%% Run loop for all unique time IDs
time_pattern = year*1000000+month*10000+day*100+hour;
for i = 1:length(timeID)
    % Find all values for current year and month 
    r = find(time_pattern == timeID(i));
    if ~isempty(r)                      % if no data found => output = NaN;
        % Check number of elements used for mean/sum computation and
        % computed the 'should' value.
        check_out(i,1) = length(r);     % = number of elements used for the computation
        switch convertSwitch
            case 1 % => compute daily means
                data_out(i,:) = mean(data(r,:),1);
            case 2 % => aggregate data
                data_out(i,:) = sum(data(r,:),1);
        end
    end
end

end

