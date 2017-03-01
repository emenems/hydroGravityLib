function [time,data] = stackfiles(varargin)
% MM_STACKFILE Stack files and save/write the result
%
% Input
%   'in'        ... input file. In case 'path' is not set, use full file 
%                   names (may be used multiple times). For multiple files,
%                   use cell array. 
%                   Supportef formats: *.tsf, *.dat (campbell 4 header
%                   lines), *.csv (dygraph datapage), and *.txt (mGlobe 
%					output)
%   'path'      ... path to input files (optional)
%   'out'       ... output file name (including path). Input and output
%                   files must be in the same file format!
%	'tolerance' ... set tolerance of difference between stacked data. By 
%					default, files are stacked only if data points in i-th 
%					and i+1 file are identical. Tolerance will set maximum
%					(absolute) difference. Set either scalar or vector for each 
%                   data column.
%
% Output
%   'time'      ... stacked time vector (matlab datenum format)
%   'data'      ... stacked data vector/matrix
%
% Example1
%   stackfiles('in',{'F1.tsf','F2.tsf'},'path','Y:\','out','Y:\F_Stacked.tsf');
%
% Example2
%   stackfiles('in',{'F1.tsf','F2.tsf'},'path','Y:\','out',...
%               'Y:\F_Stacked.tsf','tolerance',0.1);
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de

%% Get input data
% Set default values
path_in = '';
time = [];
data = [];
output_file = [];
tolerance  = 0;

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
            case 'tolerance'
                tolerance = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
elseif nargin > 0 && mod(nargin,2) ~= 0
    error('Set even number of input parameters')
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
    case 'txt'
        temp = load(fullfile(path_in,file_in{1}));
        time = temp(:,1);
        data = temp(:,2:end);clear temp
end
% Prepare variables used inside loop
if length(tolerance)~= size(data,2)
    tolerance = zeros(size(data,2),1) + tolerance(1);
end
increment = time(2)-time(1);
in_length = length(time); % will be used to check new data was appended
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
        case 'txt'
            temp = load(fullfile(path_in,file_in{i}));
            ctime = temp(:,1);
            cdata = temp(:,2:end);clear temp
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
        else % Overlapping => find next following time stamp and check if the 
            % the 'data' does not contain NaN at such epoch (in that case 
            % overwrite it with 'cdata')
            r = find(ctime>time(end));
            data_length = length(time);
            if ~isempty(r) 
                last_data = sum(data(data_length,:),2);
                conc = r(1);
                while isnan(last_data) && data_length > 1 && conc > 1
                    conc = conc - 1;
                    data_length = data_length - 1;
                    last_data = sum(data(data_length,:),2);
                end
                % Stack only if overlapping data fullfill the requirements
                % in terms of telerance. 
                test_val = 1;
                for t = 1:size(data,2)
                    if abs(data(data_length,t) - cdata(conc-1,t)) > abs(tolerance(t))
                        test_val = 0;
                    end
                end
                if test_val == 1
                    data = vertcat(data(1:data_length,:),cdata(conc:end,:));
                    time = vertcat(time(1:data_length,:),ctime(conc:end,:));
                else
                    fprintf('Not stacked: %02d (count) file does not contain identical data!\n',i);
                end
            else
                fprintf('Warning: %02d (count) file does not contain any new data!\n',i);
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
        case 'txt'
            stackfiles_write(time,data,fullfile(path_in,file_in{1}),...
                            output_file,'%12.6f   \t%08.0f  \t%06.0f\t',...
                            []);
            % Cut 'yyyymmdd' and 'hhmmdd' from data output
            data = data(:,3:end);
            
    end
end
end % function
%% Aux function to write dat/csv data
function stackfiles_write(time_in,data_in,in_file,out_file,format_out,head)
    % mGlobe output
    % determine header first if not set (== for 'txt/mGlobe' only)
    if isempty(head)
        fid_in = fopen(in_file,'r');
        row = fgetl(fid_in);
        head_write{1} = row;
        head = 0;
        while strcmp(row(1),'%')
            head = head + 1;
            row = fgetl(fid_in);
            head_write{head+1} = row;
        end
        fclose(fid_in);
        clear row 
        row = head_write;
        for s = 1:size(data_in,2)-2 % -2 => yyyymmdd and hhmmss are already in format_out
            if s ~= size(data_in,2)-2
                format_out = [format_out,'%12.7g\t'];
            else
                format_out = [format_out,'%12.7g\n'];
            end
        end
        write_data = [time_in,data_in];
    else
        % dat and csv output
        fid_in = fopen(in_file,'r');
        for s = 1:head
            row{s} = fgetl(fid_in);
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
    end
    fid_out = fopen(out_file,'w');
    for s = 1:head
        fprintf(fid_out,'%s\n',row{s});
    end
    for s = 1:length(time_in)
        fprintf(fid_out,format_out,write_data(s,:));
    end
    fclose(fid_out);
end