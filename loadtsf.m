function [time,data,channels,units,channel_names,undetval,increment,countinfo,comment] = loadtsf(input_tsf)
%LOADTSF load tsf outputs to matlab
% Input:
%  input_tsf    ...     full file name 
%
% Output:
%   time        ...     matlab time (vector)
%   data        ...     data matrix (for all channels)
%   channels    ...     channels info (cell array)
%   units       ...     units for each channel (cell array)
%   channel_names..     channels names (cell array)
%   undetval    ...     undefined values (scalar)
%   increment   ...     time step in seconds (scalar)
%   countinfo   ...     total number of observations (scalar)
%   comment     ...     comment (cell array)
% 
% Example:
%   [time,data] = loadtsf('VI_gravity.tsf');
% 
%                                                   M.Mikolaj, 27.1.2015
%                                                   mikolaj@gfz-potsdam.de

if isempty(input_tsf)
   [name,path] = uigetfile({'*.tsf'},'Select a TSoft file');
   input_tsf = fullfile(path,name);
end
%% Initialize
time = [];
data = [];
channels = [];
units = [];
undetval = [];
increment = [];
countinfo = [];
comment = [];
channel_names = [];

%% Get undetval
cr = 0;
num_chan = 1;
fid = fopen(input_tsf);
row = fgetl(fid);cr = cr+1;
% Get UNDETVAL
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[UNDET')
            undetval = str2double(row(11:end));
            break;
        elseif strcmp(row(1:6),'[DATA]')
            break;
        end
    end
    row = fgetl(fid);
    cr = cr+1;
end
fclose(fid);
fid = fopen(input_tsf);
row = fgetl(fid);cr = cr+1;
% Get INCREMENT
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[INCRE')
            increment = str2double(row(12:end));
            break;
        elseif strcmp(row(1:6),'[DATA]')
            break;
        end
    end
    row = fgetl(fid);cr = cr+1;
end
fclose(fid);
fid = fopen(input_tsf);
row = fgetl(fid);cr = 1;
% Get CHANNELS
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[CHANN')
            row = fgetl(fid);cr = cr+1;
            while ~strcmp(row(1),'[')
                channels{num_chan,1} = row;num_chan = num_chan+1;
                row = fgetl(fid);cr = cr+1;
                if isempty(row)
                    row = '[';
                end
            end
            break;
        elseif strcmp(row(1:6),'[DATA]')
            break;
        end
    end
    row = fgetl(fid);cr = cr+1;
end
fclose(fid);
fid = fopen(input_tsf);
row = fgetl(fid);cr = 1;
% Get UNITS
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[UNITS')
            num_mm = 1;
            row = fgetl(fid);cr = cr+1;
            while ~strcmp(row(1),'[')
                units{num_mm,1} = row;num_mm = num_mm+1;
                row = fgetl(fid);cr = cr+1;
                if isempty(row)
                    row = '[';
                end
            end
            break;
        elseif strcmp(row(1:6),'[DATA]')
            break;
        end
    end
    row = fgetl(fid);cr = cr+1;
end
fclose(fid);
fid = fopen(input_tsf);
row = fgetl(fid);cr = 1;
% Get COUNT
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[COUNT')
                countinfo = str2double(row(12:end));
                break;
        elseif strcmp(row(1:6),'[DATA]')
            break;
        end
    end
    row = fgetl(fid);cr = cr+1;
end
fclose(fid);
fid = fopen(input_tsf);
row = fgetl(fid);cr = 1;
% Get COMMENT
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[COMME')
            num_mm = 1;
            row = fgetl(fid);cr = cr+1;
            if isempty(row)
                row = '[';
            end
            while ~strcmp(row(1),'[')
                comment{num_mm,1} = row;num_mm = num_mm+1;
                row = fgetl(fid);cr = cr+1;
                if isempty(row)
                    row = '[';
                end
            end
            break;
        elseif strcmp(row(1:6),'[DATA]')
            break;
        end
    end
    row = fgetl(fid);cr = cr+1;
end
fclose(fid);
fid = fopen(input_tsf);
row = fgetl(fid);cr = 1;
% Get DATA (stop)
while ischar(row)
    if length(row) >= 6
        if strcmp(row(1:6),'[DATA]')
            data_start = cr;
            break;
        end
    end
    row = fgetl(fid);cr = cr+1;
end
fclose(fid);
% create format specification and get channel names only ('channels'
% contain also info about Site:Measurement:Name
formatSpec = '%d%d%d%d%d%d';
for i = 1:length(channels);
    temp = strsplit(channels{i},':');
    channel_names{i,1} = char(temp(end));
    formatSpec = [formatSpec,'%f'];
end
try 
    % Get Data
    
    try                                                                     % assumed, file contains COUNTINFO 
        fid = fopen(input_tsf,'r');
        for i = 1:data_start
            row = fgetl(fid);
        end
        if isempty(countinfo)
            count = 0;
            row = fgetl(fid);
            if isempty(row)
                while isempty(row)
                    row = fgetl(fid);
                    data_start = data_start + 1;
                end
            end
            while ischar(row)
                row = fgetl(fid);
                count = count + 1;
            end
            fclose(fid);
            fid = fopen(input_tsf,'r');
            countinfo = count;
            for i = 1:data_start
                row = fgetl(fid);
            end
        end
        dataArray = textscan(fid, formatSpec, countinfo);
        time = datenum(double(dataArray{1,1}),double(dataArray{1,2}),double(dataArray{1,3}),double(dataArray{1,4}),double(dataArray{1,5}),double(dataArray{1,6}));
        data = cell2mat(dataArray(7:end));
        if ~isempty(undetval)
            data(round(data*1e+9)./1e+9 == round(undetval*1e+9)./1e+9) = NaN;
        end
        fclose(fid);
    catch   
        dataArray = dlmread(input_tsf,'',data_start,0); % warning no footer info are allowed
        time = datenum(dataArray(:,1:6));
        data = dataArray(:,7:end);
        if ~isempty(undetval)
            data(data == undetval) = NaN;
        end
    end
        
%     % Get footer info
%     row = fgetl(fid);
%     while ischar(row)
%         if length(row) >= 5
%         end
%         row = fgetl(fid);
%     end
catch
    fprintf('Could not load the required file. Checkt the format (file must contain: COUNTINFO, CHANNEL, UNITS, UNDETVAL)\n');
end
end