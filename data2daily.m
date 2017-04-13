function [time_out,data_out,check_out] = data2daily(time,data,convertSwitch,nanSwitch)
%DATA2DAILY Convert/aggregate input data to daily means/sums
% User can convert = create daily means or sums for input time series.
% Use data2monthly function to generate monthly data.
%
% Input:
%   time        ... time matrix [year,month,day,hour,minute,second]
%   data        ... data matrix or vector.
%   convertSwitch ... 1 = daily means (e.g., for temperature)
%                   2 = daily sums (e.g., for precipitation)
%                   3 = daily minimum (e.g., for ET0)
%                   4 = daily maximum (e.g., for ET0)
%   nanSwitch   ... 0 = NaN on input => NaN on output
%                   1 = NaN on input will be removed => no NaN on output
%                   for the whole day (output time will miss the days with
%                   NaNs)
%                   2 = NaN on input will be not taken into account when
%                   computing Mean value
%
% Output:
%   time_out    ... output time: [year,month,day] matrix. This time refers
%                   the whole time period of 24 hour. Not previous 24
%                   hours, e.g., if input rain [2000,1,2,13,0,0] = 2 mm,
%                   than output time  = [2000,1,2] and data_out = 2 mm!!!
%   data_out    ... output data matrix or vector (means or sums)
%   check_out   ... number of elements used for the computation of
%                   mean/sum. This is useful as this function computes also
%                   mean/sum for incomplete months!!! The second column of
%                   this variable shows how many elements should be present
%                   if constant sampling used.
% Requirements:
%   This function does not require further function.
%
% Example
%   [time_out,data_out] = data2daily(time,data,1,0);
%
%                                                   M. Mikolaj, 01.10.2015

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
% Remove NaNs in required
if (nanSwitch == 1)
    % Remove NaNs for ALL columns! (= sum(data,2))
    year(isnan(sum(data,2))) = [];
    month(isnan(sum(data,2))) = [];
    day(isnan(sum(data,2))) = [];
    data(isnan(sum(data,2)),:) = [];           
end
% First create unique time ID for each day  = yyyymmdd
timeID = year*10000+month*100+day;
[timeID,ind] = unique(timeID);    % remove redundant values
% converts yyyymmdd -> [yyyy,mm,dd]
% Create output time matrix
time_out = [year(ind),month(ind),day(ind)];
clear ind
% Declare output variables
data_out(1:length(timeID),1:size(data,2)) = NaN;
check_out(1:length(timeID),2) =1/time_resol/24;  % compute 'should' value

%% Run loop for all unique time IDs
% Aux variable showing yyyymmdd for all input values. This parameter will
% be used to identify all value within j-th day
time_pattern = year*10000+month*100+day;
% Set aux parameters to count unique days and total number of values
% within this day (c)
j = 1;
c = 1;
% Starting value
total = data(1,:);
total_ext = data(1,:);
% Loop for all input values
for i = 2:length(data)
    if timeID(j) ~= time_pattern(i)
        if convertSwitch == 1 % Mean
            data_out(j,:) = total./c;
            check_out(j,1) = c;
        elseif convertSwitch == 2  % Total sum
            data_out(j,:) = total;
            check_out(j,1) = c;
        elseif convertSwitch >= 3 && convertSwitch <=4 % minimum | maximum
            data_out(j,:) = total_ext;
            check_out(j,1) = c;
        end
        % Move to next hour
        j = j + 1;
        % Reset counts
        c = 1;
        total = data(i,:);
        total_ext = data(i,:);
    else
        % Otherwise, keep counting
        total = total + data(i,:);
        if convertSwitch==3
            total_ext(data(i,:)<total_ext) = data(i,data(i,:)<total_ext);
        end
        if convertSwitch==4
            total_ext(data(i,:)>total_ext) = data(i,data(i,:)>total_ext);
        end
        c = c + 1;
    end
end
% Check the last day (will not be filled by the code above due to the if
% condition in the beginning)
r = find(time_pattern == timeID(end));
if ~isempty(r)                      
    check_out(end,1) = length(r);
    check_out(end,2) = 1/time_resol;
    % get found values
    temp = data(r,:);
    % Remove or keep NaNs depending on switch
    if nanSwitch == 2
        temp(isnan(sum(temp,2)),:) = [];
    end
    switch convertSwitch
        case 1 % => compute daily means
            data_out(end,:) = mean(temp,1);
        case 2 % => aggregate data
            data_out(end,:) = sum(temp,1);
        case 3 % => find minimum value
            data_out(end,:) = min(min(temp,1));
        case 4 % => find maximum value
            data_out(end,:) = max(max(temp,1));
    end
end

end

