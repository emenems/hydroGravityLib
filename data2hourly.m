function [time_out,data_out,check_out] = data2hourly(time,data,convertSwitch,nanSwitch)
%DATA2HOURLY Convert/aggregate input data to hourly means/sums
% User can convert = create hourly means or sums for input time series.
% Use data2monthly function to generate monthly data.
% Use data2daily function to generate daily data.
%
% Input:
%   time        ... time matrix [year,month,day,hour,minute,second]
%   data        ... data matrix or vector.
%   convertSwitch ... 1 = hourly means (e.g., for temperature)
%                   2 = hourly sums (e.g., for precipitation)
%                   3 = hourly minimum (e.g., for ET0)
%                   4 = hourly maximum (e.g., for ET0)
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
%   This function does not require additional function.
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
[timeID,ind] = unique(timeID);    % remove redundant values
% Create output time matrix
time_out = [year(ind),month(ind),day(ind),hour(ind),hour(ind).*0,hour(ind).*0];
clear ind      
% Declare output variables
data_out(1:length(timeID),1:size(data,2)) = NaN;
check_out(1:length(timeID),2) =1/time_resol/24;  % compute 'should' value

%% Run loop for all unique time IDs
% Aux variable showing yyyymmddhh for all input values. This parameter will
% be used to identify all value within j-th hour
time_pattern = year*1000000+month*10000+day*100+hour;
% Set aux parameters to count unique hours and total number of values
% within this hour (c)
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
% Check the last hour (will not be filled by the code above due to the if
% condition in the beginning)
r = find(time_pattern == timeID(end));
if ~isempty(r) 
    check_out(end,1) = length(r); 
    if convertSwitch == 1
        data_out(end,:) = mean(data(r,:),1);
    elseif convertSwitch == 2 
        data_out(end,:) = sum(data(r,:),1);
    elseif convertSwitch == 3 % => find minimum value
        data_out(end,:) = min(data(r,:),[],1);
    elseif convertSwitch ==  4 % => find maximum value
        data_out(end,:) = max(data(r,:),[],1);
    end
end

end

