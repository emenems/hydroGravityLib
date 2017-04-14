function [time_out,data_out,check_out] = data2monthly(time,data,convertSwitch,nanSwitch)
%DATA2MONTHLY Convert/aggregate input data to monthly means/sums/min/max
% User can convert = create monthly means or sums for input time series.
%
% Input:
%   time        ... time vector or matrix [year,month,day,hour,minute,second]
%   data        ... data matrix or vector.
%   convertSwitch ... 1 = monthly means (e.g., for temperature)
%                   2 = monthly sums (e.g., for precipitation)
%                   3 = monthly minimum (e.g., for ET0)
%                   4 = monthly maximum (e.g., for ET0)
%   nanSwitch   ... 0 = NaN on input => NaN on output
%                   1 = NaN on input will be removed => no NaN on output
%
% Output:
%   time_out    ... output time: [year,month,day(middle)] matrix
%   data_out    ... output data matrix or vector (means or sums)
%   check_out   ... number of elements used for the computation of
%                   mean/sum. This is useful as this function computes also
%                   mean/sum for incomplete months!!! The second column of
%                   this variable shows how many elements should be present
%                   if constant sampling used.
% Requirements:
%   This function uses:
%       mm_daysInMonth.m
% Example
%   [time_out,data_out] = data2monthly(time,data,1,0);
%
%                                                   M. Mikolaj, 01.10.2015

%% Prepare data
% Convert input time vector to civil format if not already in such format
if size(time,2) == 1
    % Determine the time resolution
    time_resol = diff(time);
    [year,month] = datevec(time);
else
    % resolution
    time_resol = diff(datevec(time));
    % select only necessary parameters
    year = time(:,1);
    month = time(:,2);
end
% Use only most used time resolution (in case non-constant sampling)
time_resol = mode(time_resol);

% Remove NaNs if required
if (nanSwitch == 1)
    % Remove NaNs for ALL columns! (= sum(data,2))
    year(isnan(sum(data,2))) = [];
    month(isnan(sum(data,2))) = [];
    data(isnan(sum(data,2)),:) = [];           
end
% First create unique time ID for each month  = yyyymm
timeID = year*100+month;
timeID = unique(timeID);    % remove redundant values
% Declare output variables
time_out = [floor(timeID/100),timeID-floor(timeID/100)*100]; % converts yyyymm -> [yyyy,mm]
data_out(1:length(timeID),1:size(data,2)) = NaN;
check_out(1:length(timeID),1:size(data,2)) = NaN;

%% Run loop for all unique time IDs
% Aux variable showing yyyymm for all input values. This parameter will
% be used to identify all value within j-th month
time_pattern = year*100+month;
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
        case 1 % => compute monthly means
            data_out(end,:) = mean(temp,1);
        case 2 % => aggregate data
            data_out(end,:) = sum(temp,1);
        case 3 % => find minimum value
            data_out(end,:) = min(min(temp,[],1));
        case 4 % => find maximum value
            data_out(end,:) = max(max(temp,[],1));
    end
end
% Compute days in month
for i = 1:size(check_out,1)
    check_out(i,2) = (datenum(time_out(i,1),time_out(i,2)+1,1,0,0,0) - ...
                        datenum(time_out(i,1),time_out(i,2),1,0,0,0))/time_resol;
end

end

