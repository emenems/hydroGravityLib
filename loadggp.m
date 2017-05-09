function [time,data,header,blocks,blocks_header] = loadggp(varargin)
%LOADGGP load files in ggp (eterna or preterna) format
% Inputs
%   'file_in'   ... input file name (including path)
%   'offset'    ... switch to apply or not the offset (1 = yes, 0 = no ==
%                   default) 
%   'nanval'    ... flagged values to be converted to NaNs (e.g.99999.999).
%                   Set to [] for no offset (or do one set at all)
% Output
%   time        ... time vector in matlab/octave datenum format
%   data        ... data matrix
%   header      ... file header (cell array)
%   blocks_header.. blocks header (cell array for each block)
%   blocks      ... starting time of each block (in matlab/datenu format) +
%                   block offsets (just like in 'writeggp.m')
%
% Warning: Performance not yet optimized
%
% Example:
% [time,data,header,blocks,blocks_header]=loadggp('file_in','data.ggp',...
%                                            'offset',0,'nanval',99999.999) 
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de

%% Default values
time = [];
data = [];
header = [];
blocks = [];
offset_switch = 0;
nanval = [];
blocks_header = {''};

%% Read user input
% First check if correct number of input arguments
if nargin >= 2 && mod(nargin,2) == 0
    % Count input parameters
    in = 1;
    % Try to find input parameters
    while in < nargin
        % Switch between function parameters
        switch varargin{in}
            case 'file_in'
                file_in = varargin{in+1};
            case 'offset'        
                offset_switch = varargin{in+1};
            case 'nanval'
                nanval = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
elseif nargin > 0 && mod(nargin,2) ~= 0
    error('Set even number of input parameters')
end

%% Read header
fid = fopen(file_in,'r');
try
    if fid > 0
        row = fgetl(fid);
        header = {row};
        count = length(row)+2; % count bites
        i = 1;
        % Variable to stack Time and Date for each block (will be converted
        % to matlab/octave datenum at the end)
        time_1 = [];
        time_2 = [];
        block_start = [];
        block_offset = [];
        % Read until finding end of header sign or maximum header number (own
        % definition)
        while ~strcmp(row(1:4),'C***') || i > 200
            row = fgetl(fid);
            count = count + length(row)+1;
            i = i + 1;
            header(i,1) = {row};
            if length(row) < 4
                row = 'not end of header';
            end
        end
        % Remove the C***** from header
        header(end) = [];
        %% Read data
        % Aux variables to count:
        j = 1; % block headers
        k = 1; % block starts
        while ischar(row)
            % Check if data, block or block header
            if isnan(str2double(row(1:2))) && ~strcmp(row(1:4),'C***')
                blocks_header(j,1) = {row};
                j = j + 1;
            else
                if strcmp(row(1:2),'77') % 7777777
                    temp = str2num(row);   
                    block_offset = vertcat(block_offset,temp(2:end));
                    formatSpec = '%f';
                    for l = 1:length(temp)
                        formatSpec = [formatSpec,'%f'];
                    end
                    % Determine the length (in bytes) of one row
                    l1 = ftell(fid);
                    fgetl(fid);
                    l2 = ftell(fid);
                    length_row = l2 - l1;
                    % Reset to point before length has been determined
                    fseek(fid,l1,'bof');clear l1
                    % Read current block
                    dataArray = textscan(fid, formatSpec,...
                                    'CommentStyle',{'99999999'});
                    % Check if one block one not skipped. If so remove all
                    % data from following block (will be read in next loop 
                    % run)
                    r = find(dataArray{1}>33333333);
                    if ~isempty(r)
                        for d = 1:length(dataArray)
                            dataArray{d}(r(1):end) = [];
                        end
                    end
                    % Get the current position in the file (in bytes)
                    count = count + length_row*length(dataArray{1}) + 1;
                    % textscan automatically shift 'fid' to end => needs to
                    % rewind
                    fseek(fid,count,'bof');
                    i = i + length(dataArray{1});
                    time_1 = vertcat(time_1,dataArray{1});
                    time_2 = vertcat(time_2,dataArray{2});
                    % Check if the 888888888 flag is not part of the data
                    if time_1(end)==88888888
                        time_1(end) = [];
                    end
                    data = vertcat(data,cell2mat(dataArray(3:end)));
                    block_start = vertcat(block_start,...
                                    pattern2time(dataArray{1}(1),'day') + ...
                                    pattern2time(dataArray{2}(1),'hhmmss'));
                end
            end
            row = fgetl(fid);
            count = count + length(row)+2;
            i = i + 1;
            if isempty(row)
                row = fgetl(fid);
                count = count + length(row)+2;
                i = i + 1;
            end
        end
        %% Process data
        time = pattern2time(time_1,'day') + ...
               pattern2time(time_2,'hhmmss');
        % Set NaNs
        if ~isempty(nanval)
            data(data==nanval) = NaN;
        end
        if offset_switch == 1
            for i = 1:length(block_start)
                for j = 1:size(data,2)
                    data(time>=block_start(i),j) = data(time>=block_start(i),j) + block_offset(i,j);
                end
            end
        end
        % Prepare output 'blocks'
        blocks = [block_start,block_offset];
        fclose(fid);
    else
        disp('No such file found');
        blocks_header = '';
        blocks = [];
        time = [];
        data = [];
        header = [];
    end
catch out
    blocks_header = '';
    blocks = [];
    time = [];
    data = [];
    header = [];
    fprintf('Coult not read the whole file. Error: \n%s\n',out.message);
    fclose(fid);
end