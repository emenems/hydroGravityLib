function [time,data,header,blocks,blocks_header] = loadggp(varargin)
%LOADGGP load files in ggp (eterna or preterna) format
% Inputs
%   'file_in'   ... input file name (including path)
%   'offset'    ... switch to apply or not the offset (1 = yes, 0 = no ==
%                   default) 
%   'nanval'    ... flagged values to be converted to NaNs (e.g. 9999.999).
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
%                                             'offset',0,'nanval',9999.999) 
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
        i = 1;
        % Read until finding end of header sign or maximum header number (own
        % definition)
        while ~strcmp(row(1:4),'C***') || i > 200
            row = fgetl(fid);
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
        i = 1; % data values
        j = 1; % block headers
        k = 1; % block starts
        while ischar(row)
            % Check if data, block or block header
            if isnan(str2double(row(1:2))) && ~strcmp(row(1:4),'C***')
                blocks_header(j,1) = {row};
                j = j + 1;
            else
                % Start reading blocks
                if strcmp(row(1:2),'77') % 7777777
                    % Split the string and get block values (not date)
                    temp = strsplit(row);
                    block_offset(k,:) = str2double(temp(2:end));
                    % Read the next line to get block start date+time
                    row = fgetl(fid);
                    temp = strsplit(row);
                    block_start(k,1) = pattern2time(str2double(temp{1}),'day') + ...
                                        pattern2time(str2double(temp{2}),'hhmmss');
                    k = k + 1;
                    % Read data
                    while ~strcmp(row(1:2),'88') && ~strcmp(row(1:2),'99')
                        if ~isnan(str2double(row(1:2)))
                            data_all(i,:) = str2double(strsplit(row));
                            i = i + 1;
                        end
                        row = fgetl(fid);
                    end
                end
            end
            row = fgetl(fid);
        end

        %% Process data
        time = pattern2time(data_all(:,1),'day') + ...
               pattern2time(data_all(:,2),'hhmmss');
        data = data_all(:,3:end);
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