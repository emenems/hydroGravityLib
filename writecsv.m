function writecsv(time,data,header,out_file,varargin)
%WRITECSV Write data to Dygraph csv file
%
% Input:
%   time        ... time vector (datenum) or matrix
%   data        ... data matrix
%   header      ... cell area containing header
%   out_file    ... output file name
%   varargin{1} ... output precision. Default '%.3f'
% Example:
%   writecsv(time,data,{'channel1','channel2'},'OutDygraph.csv')
%
%

if size(time,2) == 1
    dataout = [datevec(time),data];
else
    dataout = [time,data];
end
fid_out = fopen(out_file,'w');
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
if nargin >= 5
    prec = char(varargin{1});
else
    prec = '%.3f';
end
% write data
% First, create output format
format_out = '%04d/%02d/%02d %02d:%02d:%02.0f'; % date
for i = 1:size(data,2);
    format_out = [format_out,',',prec]; % other columns
end
% add new line character
format_out = [format_out,'\n']; 
% convert matlab time to standard format
for i = 1:length(time)
    fprintf(fid_out,format_out,dataout(i,:));
end
% Close output file
fclose(fid_out);

end % function