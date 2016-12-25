function [timeout,dataout,id_out,id_in] = findTimeStep(time,data,orig_step)
%FINDTIMESTEP Function for identifying steps and filling them with NaN
% Input:
%   time        ...     input time vector
%   data        ...     input data vector or matrix
%   orig_step   ...     sampling rate in days (datenum), e.g. 1/24 for 1
%                       hour sampling
% 
% Output:       
%   timeout     ...     output time (equally spaced with given 'orig_step' 
%                       sampling)
%   dataout     ...     output data (equally spaced with given 'orig_step' 
%                       sampling)
%   id_in       ...     id matrix (Nx2) with starting and ending rows of
%                       input time/data
%   id_out      ...     id matrix (Nx2) with starting and ending rows of
%                       output timeout/dataout
% 
% Requires: time2pattern.m function
%
% Example:
%   [timeout,dataout,id_out,id_in] = findTimeStep(time,data,1/1440)
%
%                                                    M.Mikolaj, 18.2.2016
%                                                    mikolaj@gfz-potsdam.de

% Sort data (in case not already sorted)
[time,inde] = sort(time);
data = data(inde,:);
% Remove redundant data
[time,inde] = unique(time);
data = data(inde,:);
clear inde
% Remove possible time NaNs
data(isnan(time),:) = [];
time(isnan(time),:) = [];
% Create output time vector.
timeout = transpose(time(1):orig_step:time(end));
% Check the time resolution precision (either in
% seconds or milliseconds. If latter, use 0.01 sec precision)
if round(orig_step*86400) ~= orig_step*86400
    convert_switch = 'msecond';    
else
    convert_switch = 'second';
    % Round to seconds also the output vector (the creation in 38th row is
    % limited to double precision)
    timeout_mat = datevec(timeout); 
    timeout_mat(:,end) = round(timeout_mat(:,end));
    timeout = datenum(timeout_mat); 
    clear timeout_mat;
end
timepattern = time2pattern(timeout,convert_switch);
timeID = time2pattern(time,convert_switch);
% Declare output variables
dataout(1:length(timeout),1:size(data,2)) = NaN;
% Aux variables to count indices
j = 1;id_in = 1;id_out = [1 1];
% Run loop comparing regular and actual time
for i = 1:length(timepattern)
    if timepattern(i) == timeID(j)
        dataout(i,:) = data(j,:);
        j = j + 1;
        if (id_out(end,2) ~= i-1) && i ~= 1;
           id_out(end+1,1) = i;
        end
        id_out(end,2) = i;
        
    else
        if id_in(end) ~= j
           id_in = vertcat(id_in,j);
        end
    end
end
if length(id_in)>1
    id_in(:,2) = vertcat(id_in(2:end,1)-1,size(data,1));
else
    id_in(1,2) = size(data,1);
end


end % end of function

