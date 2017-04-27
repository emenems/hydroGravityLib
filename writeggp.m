function writeggp(varargin)
%WRITEGGP write time/data to ggp (eterna or preterna) format
% The output format follows the recommendation of IGETS Report:
%   DOI: http://doi.org/10.2312/GFZ.b103-16087
%
% Inputs
%   'time'        ... time vector in matlab datenum format
%   'data'        ... data vector or matrix
%   'channels'    ... channel/column names 
%   'units'       ... channel/column units
%   'output_file' ... output file name (full with path)
% Optional inputs:
%   'blocks'      ... data blocks matrix [time_start,offset_channel1,...]
%                     time_start must be in matlab/octave datenum format
%                     the number of columns in 'blocks' must be equal to
%                     number of columns in 'data' + 1 (time)
%   'header'      ... header lines. Should be a cell array containing left 
%                     and right site of the header (header_offset is used 
%                     to delimit the sites) 
%   'header_offset'.. column offset (default = 21)
%   'header_add'  ... Add final comment after formated header 
%                     (no 'offset' and splitting into right and left is 
%                     used in this case = no limitation) 
%   'blocks_header'.. Insert text between blocks (e.g. for Eterna34-V60).
%                     Warning: the first entry will be inserted at the 
%                     beginning of the file and the second to the start of the
%                     first block! => set length(blocks)+1 headers!
%                     Or, setting cell with one row = same block header for 
%                     all block start. 
%                     Explanation for ET34-ANA-V60 (same for all blocks):
%                     {'instrument','calib','calibSD','lag','Number of
%                     Chebychev polynomial bias parameter'};
%   'precision'   ... number of output decimal places. Scalar or vector (for each 
%                     column). Example: '%10.4f' => all values with 4 decimals; 
%                     {'%10.2f','%10.1f}, => two decimals for the first column 
%                     and one decimal place for the second column. 
%                     default = '%10.6f';
%   'format'      ... 'preterna' (=ggp=default) or 'eterna'
%   'nanval'      ... replace NaN with (default 9999.999)
%
% Example:
%  time = transpose(datenum(2010,1,1):1/24:datenum(2010,2,1));
%  data = horzcat(ones(length(time),1)+randn(length(time),1),...
%                  zeros(length(time),1)+0.1);
%  header_in = {'Filename','file.data';...
%            'Station','Wettzell';...
%            'Instrument','iGrav';...
%            'N. Latitude (deg)','49.14354';...
%            'E. Longitude (deg)','12.87866';...
%            'Elevation MSL (m)','613.7+1.05';...
%            'Author','M. Mikolaj (mikolaj@gfz-potsdam.de)'};
%  header_add = {'This is a test of the writeggp.m function';...
%                    'Michal Mikolaj, mikolaj@gfz-potsdam.de'};
%  output_file = 'f:\mikolaj\download\test.ggp';
%  
%  writeggp('time',time,'data',data,'header_offset',21,'header',header_in,...
%           'header_add',header_add,'channels',{'gravity','pressure'},...
%           'units',{'V','hPa'},'output_file',output_file,'out_precision','%10.6f',...
%           'format','preterna','blocks',[datenum(2010,1,7,12,0,0),10,20],...
%           'blocks_header',{'iGrav006',1.0,1.0,0.0,3},'nanval',9999.999);
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de
%% Set default values
header = '';
header_add = '';
blocks_header = '';
header_offset = 21;
channels = '';
units = '';
file_format = 'preterna';
time = [];
data = [];
blocks = [];
output_file = [];
out_precision = '%10.6f';
nanvalues = 9999.999;

%% Read user input
% First check if correct number of input arguments
if nargin > 2 && mod(nargin,2) == 0
    % Count input parameters
    in = 1;
    % Try to find input parameters
    while in < nargin
        % Switch between function parameters
        switch varargin{in}
            case 'header'
                header = varargin{in+1};
            case 'header_add'        
                header_add = varargin{in+1};
            case 'blocks_header'
                blocks_header = varargin{in+1};
            case 'channels'
                channels = varargin{in+1};
            case 'units'
                units = varargin{in+1};
            case 'file_format'
                file_format = varargin{in+1};
            case 'time'
                time = varargin{in+1};
            case 'data'
                data = varargin{in+1};
            case 'blocks'
                blocks = varargin{in+1};
            case 'output_file'
                output_file = varargin{in+1};
            case 'out_precision'
                out_precision = varargin{in+1};
            case 'nanval'
                nanvalues = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
elseif nargin > 0 && mod(nargin,2) ~= 0
    error('Set even number of input parameters')
end

%% Write file
% Open for writing
fid = fopen(output_file,'w');
try
    % Insert header
    if ~isempty(header)
        % Create header string format
        temp_format = sprintf('%%-%ds: %%s\n',header_offset);
        for i = 1:size(header,1)
            % Remove possible longer then fix header column offset
            if length(header{i,1}) > header_offset
                fprintf(fid,temp_format,header{i,1}(1:header_offset),header{i,2});
            else
                fprintf(fid,temp_format,header{i,1},header{i,2});
            end
        end
    end
    % Add head footer
    if ~isempty(header_add)
        for i = 1:size(header_add,1)
            fprintf(fid,'%s\n',header_add{i});
        end
    end
    clear temp_format i
    % Add date,time and channel names(units). 
    fprintf(fid,'yyyymmdd hhmmss');
    for i = 1:length(channels)
        fprintf(fid,' %s(%s)',channels{i},units{i});  
    end
    fprintf(fid,'\nC*******************************************************\n');
    % Check if ouput precision has been specified
    temp_format = '';
    if ~isempty(out_precision)
        if ~iscell(out_precision)
            out_precision = {out_precision};
        end
        for i = 1:size(data,2)
            if length(out_precision) > 1 && length(out_precision) == size(data,2)
                temp_format = [temp_format,' ',out_precision{i}];
            else 
                temp_format = [temp_format,' ',char(out_precision)];
            end
        end    
    end
    temp_format = [temp_format,'\n'];
    % Convert matlab time to yyyymmdd...
    [yyyy,mm,dd,hh,mi,ss] = datevec(time);
    % Remplace NaNs and prepare for writing
    data(isnan(data)) = nanvalues;
    data = [yyyy,mm,dd,hh,mi,ss,data];
    out_format = ['%04d%02d%02d %02d%02d%02.0f',temp_format];
    % Find blocks in time/data
    j = 1;
    block_start = 1;
    block_value = zeros(1,size(data,2)-6);
    if ~isempty(blocks)
        for i = 1:size(blocks,1)
            temp = find(time>= blocks(i));
            if ~isempty(temp)
                j = j + 1;
                block_start(j) = temp(1);
                block_stop(j-1) = temp(1)-1;
                block_value(j,:) = blocks(i,2:end);
            end
        end
        block_stop(end+1) = length(time);
    else
        block_stop = length(time);
    end
    % Write data
    for j = 1:length(block_start)
        % Add header of the block
        if ~isempty(blocks_header)
            if size(blocks_header,1) == 1
                fprintf(fid,'%10s%15.4f%10.4f%10.3f%10d\n',...
                    blocks_header{1},blocks_header{2},blocks_header{3},...
                    blocks_header{4},blocks_header{5});
            elseif size(blocks_header,1) == 1
                fprintf(fid,'%10s%15.4f%10.4f%10.3f%10d\n',...
                    blocks_header{j,1},blocks_header{j,2},...
                    blocks_header{j,3},blocks_header{j,4},...
                    blocks_header{j,5});
            end
        end
        % Start block
        fprintf(fid,'77777777       ');
        fprintf(fid,temp_format,zeros(1,size(data,2)-6));
        for i = block_start(j):block_stop(j)
            fprintf(fid,out_format,data(i,:));
        end
        % End block
        fprintf(fid,'99999999\n');
    end
    % Add 88888888 for eterna format only
    if strcmp(file_format,'eterna')
         fprintf(fid,'88888888\n');
    end
    fclose(fid);
catch out
    fclose(fid);
    fprintf('Coult not write file. Error:\n%s\n',out.message);
end         
          
