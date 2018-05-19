function data = correctTimeInterval(time,data,varargin)
%CORRECTTIMEINTERVAL correct selected time intervals
% Correct time intervals either setting them to NaNs or interpolate value.
% In addition, steps in input time series can by corrected.
%
% Input:
%   time        ... time vector (in datenum format)
%   data        ... data vector or matrix
%   varargin{1} ... input file (=string) or matrix corresponding to read 
%                   input file (see below)
%   varargin{2} ... switch to use either C2 (see below) == 0, or selected
%                   column, e.g. ==2 (=>correct second column in input data
%                   matrix)
% Input file (or matrix) format:
%   % Header starts with '%'
%   % C1 C2 C3   C4 C5 C6 C7 C8   C9  C10 C11 C12 C13 C14  C15  C15 C16
%     3  1  2015 03 30 00 14 04   2015 03  30  05  23 29   NaN	NaN	Comment
%     1  1  2015 04 16 18 11 57   2015 04  16  18  28 42   0.0  1.3 Step
% Where:
%   C1     is correction type: 
%          1 = remove steps, 2 = set time interval to NaN, 
%          3 = interpolate intervals linearly, 4 = interpolate using spline
%   C2     data column to be corrected
%   C3-C8  date+time of the start of the interval = YYYY MM DD HH MM SS
%   C9-C14 date+time of the end of the interval  = YYYY MM DD HH MM SS
%   C15    value before step (used only if C1 == 1, otherwise use NaN)
%   C16    value after step (used only if C1 == 1, otherwise use NaN)
%   C17    string (without empty space, e.g. thisIsComment). Not used if
%          correction matrix is set!
%   
%
% Output:
%   data        ... corrected time interval
%
% Example1:
%   data = correctTimeInterval(time,data,'correction_file.txt');
% Example2:
%   corMatrix = [1,1,2015,04,16,18,11,57,2015,04,16,18,28,42,0.0,1.3];
%   data = correctTimeInterval(time,data,corMatrix);
%
%                                        M. Mikolaj, mikolaj@gfz-potsdam.de
%% Read correction file
% Read or use user input matrix
if ischar(varargin{1})
    % Open and read
    fileid = fopen(varargin{1},'r');
    if fileid>0
        in_cell = textscan(fileid,'%d %d %d %d %d %d %d %d %d %d %d %d %d %d %f %f %s','CommentStyle','%'); 
        % convert cell aray (standard textscan output) to matrix with double precision
        in = horzcat(double(cell2mat(in_cell(1:14))),double(cell2mat(in_cell(15:16))));
        fclose(fileid);
    else
        in = [];
    end
else
    in = varargin{1};
end
if nargin == 4
    if varargin{2} > 0
        in(:,2) = varargin{2};
    end
end
%% Run the correction algorithm for all correctors
if ~isempty(in)
    % Read channe indices (fixed file structure)
    channel = in(:,2);
    % Read starting point/time of the correction + convert to datenum format 
    x1 = datenum(in(:,3:8));
    % Read ending point/time of the correction
    x2 = datenum(in(:,9:14));
    % Read staring point/Y Value of the correction (used especially for step
    % correction). The value itself is no so important. Only the difference
    % y2-y1 is used.   
    y1 = in(:,15);
    % Read ending point/Y Value of the correction (used especially for step
    % correction).  
    y2 = in(:,16);
    for i = 1:size(in,1)
        % switch between correction types (1 = steps, 2 = remove interval, >=3
        % = local fit). Switch is always stored in the first column of the
        % correction file.  
        switch in(i,1)                                  
            case 1 % Step removal. 
                % continue only if such channel exists
                if channel(i) <= size(data,2)
                    % find points recorded after the step occur.
                    r = find(time >= x2(i));
                    % check if given or computed difference should be
                    % applied 
                    if ~isnan(y1(i)) && isnan(y2(i))
                        applyDiff = interp1(time,data(:,channel(i)),x2(i)) - ...
                                    interp1(time,data(:,channel(i)),x1(i)) - ...
                                    y1(i);
                    else 
                        applyDiff = (y2(i)-y1(i));
                    end
                    % continue only if some points have been found
                    if ~isempty(r)
                        % remove the step by SUBTRACTING the given difference.
                        data(r,channel(i)) = data(r,channel(i)) - applyDiff; 
                    end                         
                end
            case 2 % Interval removal. Values between given dates => set to NaN  
                % Find points within the selected interval
                r = find(time>x1(i) & time<x2(i)); 
                % continue only if some points have been found
                if ~isempty(r)
                    % remove selected interval = set to NaN!
                    data(r,channel(i)) = NaN;
                end
            case 3 % Interpolate interval: Linearly. 
                % find points within the selected interval. 
                r = find(time>x1(i) & time<x2(i)); 
                if ~isempty(r)
                    % copy the affected column to temporary variable. Directly
                    % remove the values within the interval. Will be used for
                    % interpolation.   
                    ytemp = data(time<x1(i) | time>x2(i),channel(i));  
                    % get selected time interval 
                    xtemp = time(time<x1(i) | time>x2(i));       
                    % Interpolate values for the affected interval only (use r as index)
                    data(r,channel(i)) = interp1(xtemp,ytemp,time(r),'linear'); 
                end
            case 4  % Interpolate interval: Spline. 
                r = find(time>x1(i) & time<x2(i)); 
                if ~isempty(r)
                    ytemp = data(time<x1(i) | time>x2(i),channel(i));
                    xtemp = time(time<x1(i) | time>x2(i));
                    data(r,channel(i)) = interp1(xtemp,ytemp,time(r),'spline');
                end
            case 5 % Set range to given values 
                r = find(time>=x1(i) & time<=x2(i)); 
                if ~isempty(r)
                    rep_val = linspace(y1(i),y2(i),length(r));
                    data(r,channel(i)) = rep_val;
                end
        end
    end
end

end % function