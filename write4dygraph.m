function write4dygraph(time,data,header,output_file)
%WRITE4DYGRAPH Write data to a csv file supported by dygraph
% Input:
%   time        ... time vector or matrix
%   data        ... data vector or matrix
%   header      ... cell with channel names. Can be empty [].
%   output_file ... full output file name
%
% Example:
%   write4dygraph(time,data,{'SM','GW'},'output_file.csv');
%
%% Check input data
if size(time,2) == 1
    time = datevec(time);
end
dataout = [time,data];
if isempty(header)
    for i = 1:size(data)
        header{i} = sprintf('column%1d',i);
    end
end

%% Write file
try
    fid_out = fopen(output_file,'w');
    % write header
    fprintf(fid_out,'date,');
    for i = 1:length(header)
        fprintf(fid_out,'%s',char(header(i)));
        if i ~= length(header)
            fprintf(fid_out,',');
        else
            fprintf(fid_out,'\n');
        end
    end
    % First, create output format
    format_out = '%04d/%02d/%02d %02d:%02d:%02.0f'; % date
    for i = 1:size(data,2);
        format_out = [format_out,',%g']; % other columns
    end
    % add new line character
    format_out = [format_out,'\n']; 
    % write data
    for i = 1:length(time)
        fprintf(fid_out,format_out,dataout(i,:));
    end
    % Close output file
    fclose(fid_out);
catch
    fclose(fid_out);
    disp('Data not written!');
end

end % function