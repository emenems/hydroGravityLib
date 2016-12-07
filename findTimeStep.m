function [timeout,dataout,id_out,id_in] = findTimeStep(time,data,orig_step)
%FINDTIMESTEP Function for identifying steps and filling them with NaN
% Input:
%   time        ...     input time vector
%   data        ...     input data vector
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
%                                                    M.Mikolaj, 18.2.2016
%                                                    mikolaj@gfz-potsdam.de

% Round input time resolution to 0.01 seconds. This is done to overcome
% possible numberic issues.
orig_step = orig_step*86400;                                                % convert to seconds
orig_step = round(orig_step*100)/100;                                       % round to two decimal places
orig_step = orig_step/86400;                                                % convert back to days
time_mat = datevec(time);                                                   % create input time matrix (date+time)
time_mat(:,end) = round(time_mat(:,end));                                   % round seconds (one second accuracy!)
time = datenum(time_mat);                                                   % transform back to Matlab format (vector)
time(isnan(data)) = [];                                                     % remove NaNs from input time vector
data(isnan(data)) = [];                                                     % remove NaNs from input data vector
timeout = [time(1):orig_step:time(end)]';                                   % create new/output time vector

timeout_mat = datevec(timeout);                                             % do the same for output time, i.e., convert to matrix, round, convert back to vector
timeout_mat(:,end) = round(timeout_mat(:,end));
timeout = datenum(timeout_mat);                                             

dataout_i = interp1(time,data,timeout,'linear');                            % interpolate to new/output time 
df = vertcat(orig_step,diff(time));                                         % compute time step
r = find(abs(df)>orig_step*1.05);                                           % find time steps > given resolution (+5% tolerance)
if ~isempty(r)                                                              % if such time steps are found
    id_in = [1,r(1)-1];                                                     % first time interval
    rout = find(timeout == time(r(1)-1));                                   % find where the first step time epoch == output time
    id_out = [1,rout];                                                      % store the found index 
    if length(r) > 1
        for i = 2:length(r)                                                 % do the same for all other steps                                                 
            id_in(i,:) = [r(i-1),r(i)-1];
            rout = find(timeout == time(r(i-1)));
            id_out(i,1) = rout;
            rout = find(timeout == time(r(i)-1));
            id_out(i,2) = rout;
        end
    end
    id_in(end+1,:) = [r(end),length(data)];                                 % last time step
    rout = find(timeout == time(r(end)));
    id_out(end+1,:) = [rout,length(timeout)];
    dataout(1:length(dataout_i),1) = NaN;
    
    for i = 1:size(id_in,1)
        dataout(id_out(i,1):id_out(i,2)) = dataout_i(id_out(i,1):id_out(i,2)); % rearange the output data
    end
else                                                                        % no steps > given resolution found
    dataout = data;                                                         % output = input
    timeout = time;
    id_out = [1,length(data)];
    id_in =  [1,length(data)];
end


%% OLD CODE
% timeout = [time(1):orig_step:time(end)]';
% time(isnan(data)) = [];
% data(isnan(data)) = [];
% time = (round(time*1000000)/1000000);
% timeout = (round(timeout*1000000)/1000000);
% dataout_i = interp1(time,data,timeout,'linear');
% df = vertcat(orig_step,diff(time));
% r = find(abs(df)>orig_step*1.5);
% if ~isempty(r)
%     id_in = [1,r(1)-1];
%     rout = find(timeout == time(r(1)-1));
%     id_out = [1,rout];
%     for i = 2:length(r)
%         id_in(i,:) = [r(i-1),r(i)-1];
%         rout = find(timeout == time(r(i-1)));
%         id_out(i,1) = rout;
%         rout = find(timeout == time(r(i)-1));
%         id_out(i,2) = rout;
%     end
%     id_in(end+1,:) = [r(end),length(data)];
%     rout = find(timeout == time(r(end)));
%     id_out(end+1,:) = [rout,length(timeout)];
%     dataout(1:length(dataout_i),1) = NaN;
%     for i = 1:size(id_in,1)
%         dataout(id_out(i,1):id_out(i,2)) = dataout_i(id_out(i,1):id_out(i,2));
%     end
% else
%     dataout = data;
%     id_out = [1,length(data)];
%     id_in =  [1,length(data)];
% end



end % end of fuction

