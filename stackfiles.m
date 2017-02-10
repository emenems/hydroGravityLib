function [time,data] = stackfiles(varargin)
% MM_STACKFILE Stack files and save/write the result
%
% Input
%   'in'        ... input file. In case 'path' is not set, use full file 
%                   names (may be used multiple times). For multiple files,
%                   use cell array. 
%                   Supportef formats: *.tsf, *.dat (campbell 4 header
%                   lines), *.csv (dygraph datapage)
%   'path'      ... path to input files (optional)
%   'out'       ... output file name (including path). Input and output
%                   files must be in the same file format!
%
% Output
%   'time'      ... stacked time vector (matlab datenum format)
%   'data'      ... stacked data vector/matrix
%
% Example1
%   stackfiles('in',{'F1.tsf','F2.tsf'},'path','Y:\','out','Y:\Data\F_Stacked.tsf');
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de

%% Get input data
% Set default values
path_in = '';
time = [];
data = [];
output_file = [];

% First check if correct number of input arguments
if nargin > 2 && mod(nargin,2) == 0
    % Count input parameters
    in = 1;
    % Try to find input parameters
    while in < nargin
        % Switch between function parameters
        switch varargin{in}
            case 'in'
                file_in = varargin{in+1};
            case 'path'        
                path_in = varargin{in+1};
            case 'out'
                output_file = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
elseif nargin > 0 && mod(nargin,2) ~= 0
    error('Set even number of input parameters')
% else
%     % Get input path
%     path_in = uigetdir('Name','Select folder');
%     % Get input files
%     list_of_files = ls(path_in);
%     [selection,OK] = listdlg('ListString',list_of_files,'Name','Select files','ListSize',[round(160*2),round(300*1.1)]);
%     % Get selected files
%     if OK
%         in = 1;
%         for i = 1:length(selection)
%             if ~strcmp(list_of_files(selection(i),1),'.')
%                 file_in{in} = list_of_files(selection(i),:);
%                 in = in + 1;
%             end
%         end
%     end
%     
%     % Get output file
%     [temp1,temp2] = uiputfile('*.*','Set output file');
%     output_file = fullfile(temp2,temp1);
%     clear temp1 temp2
end

%% Read first input file == reference
% Check version (Octave writes 'NA' instead of 'NaN')
v = version;
if strcmp(v(end),')')
    exclude = {'"NAN"','"-INF"','"INF"','NA'};
else
    exclude = {'"NAN"','"-INF"','"INF"'};
end
% Switch between supported file formats
switch lower(file_in{1}(end-2:end))
    case 'tsf'
        [time,data,channels,units,~,~,~,~,comment] = loadtsf(fullfile(path_in,file_in{1}));
    case 'dat'
        [time,data] = readcsv(fullfile(path_in,file_in{1}),4,',',1,'"yyyy-mm-dd HH:MM:SS"','All',{'"NAN"','"-INF"','"INF"'});
    case 'csv'
        [time,data] = readcsv(fullfile(path_in,file_in{1}),1,',',1,'yyyy/mm/dd HH:MM:SS','All',exclude);
end
increment = time(2)-time(1);
in_length = length(time); % will be used to chech new data was appended
%% Read all other files and stack
for i = 2:length(file_in)
    % Load file
    switch lower(file_in{i}(end-2:end))
        case 'tsf'
            [ctime,cdata] = loadtsf(fullfile(path_in,file_in{i}));
        case 'dat'
            [ctime,cdata] = readcsv(fullfile(path_in,file_in{i}),4,',',1,'"yyyy-mm-dd HH:MM:SS"','All',exclude);
        case 'csv'
            [ctime,cdata] = readcsv(fullfile(path_in,file_in{i}),1,',',1,'yyyy/mm/dd HH:MM:SS','All',exclude);
    end
    % Check time resolution (warn only)
    cincrement = ctime(2)-ctime(1);
    if round(cincrement*86400)/86400~=round(increment*86400)/86400
        fprintf('Warning: First and %02d file do not have same time resolution!\n',i);
    end
    % Check for number of columns
    if size(data,2) == size(cdata,2)
        % Check starting point (no overlapping)
        r = find(ctime <= time(end));
        if isempty(r) % == no overlapping
            % Stack data. In case the 'cdata' does not contain time interval
            % corresponding to last point of 'data'+time resolution, insert
            % NaN. Use 1% precision/tolerance fot time difference
            if (ctime(1)-cincrement*1.01) < time(end)
                data = vertcat(data,cdata);
                time = vertcat(time,ctime);
            else
                data = vertcat(data,data(1,:).*NaN,cdata);
                time = vertcat(time,time(end)+cincrement,ctime);
            end
        else % Overlapping => find next following time stamp
            r = find(ctime>time(end));
            if ~isempty(r) 
                data = vertcat(data,cdata(r,:));
                time = vertcat(time,ctime(r,:));
            else
                fprintf('Warning: %02d file does not contain any new data!\n',i);
            end
        end
    end
end

%% Write result
% write only if some new data was found, and use set the output file
if in_length < length(time) && ~isempty(output_file) 
    switch lower(file_in{i}(end-2:end))
        case 'tsf'
            % Use header from input file
            % fid = fopen(fullfile(path_in,file_in{1})
            % Prepare output header == input
            for i = 1:length(channels)
                header(i,:) = [strsplit(channels{i},':'),units{i}];
            end
            % Prepare comment
            comment{end+1,1} = 'File created via stacking following files:';
            for i = 1:length(file_in)
                comment{end+1,1} = file_in{i};
            end
            % Write result
            writetsf([datevec(time),data],header,output_file,999,comment);
        case 'dat'
            stackfiles_write(time,data,fullfile(path_in,file_in{1}),...
                            output_file,'"%04d-%02d-%02d %02d:%02d:%02d",',...
                            4);
        case 'csv'
            stackfiles_write(time,data,fullfile(path_in,file_in{1}),...
                            output_file,'%04d/%02d/%02d %02d:%02d:%02d,',...
                            1);
    end
end
end % function
%% Aux function to write dat/csv data
function stackfiles_write(time_in,data_in,in_file,out_file,format_out,head)
    fid_in = fopen(in_file,'r');
    fid_out = fopen(out_file,'w');
    for s = 1:head
        row = fgetl(fid_in);
        fprintf(fid_out,'%s\n',row);
    end
    fclose(fid_in);
    for s = 1:size(data_in,2)
        if s ~= size(data_in,2)
            format_out = [format_out,'%.10g',','];
        else
            format_out = [format_out,'%.10g','\n'];
        end
    end
    write_data = [datevec(time_in),data_in];
    for s = 1:length(time_in)
        fprintf(fid_out,format_out,write_data(s,:));
    end
    fclose(fid_out);
end