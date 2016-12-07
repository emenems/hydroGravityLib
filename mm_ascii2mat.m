function dem = mm_ascii2mat(fileID,varargin)
%MM_ASCII2MAT convert ascii argis to matlab format
%
% Input:
%   fileID        ... full file path
%   varargin{1}   ... output file (will be saved to 'mat' format)
%
% Output:
%   dem           ... matlab structure file: dem.x,dem.y,dem.height
%
% Example1:
%   dem = mm_ascii2mat('Input_file.asc');
%
% Example2:
%   mm_ascii2mat('Input_file.asc','Output_file.mat');
% 
%                                                   M.Mikolaj 18.03.2016

%% Read header
% Open for reading.
fid = fopen(fileID,'r');
% Read first row
row = fgetl(fid);
% Count header
head = 0;
% Read until numeric values
while isnan(str2double(row(1)))
    % Split input/current row
    temp = strsplit(row,' ');
    % Get/read the input parameters. Use case sensitive switch
    switch row(1:3)
        case 'NCO'
            ncols = str2double(temp(end));
        case 'nco'
            ncols = str2double(temp(end));
        case 'NRO'
            nrows = str2double(temp(end));
        case 'nro'
            nrows = str2double(temp(end));
        case 'XLL'
            xll = str2double(temp(end));
        case 'xll'
            xll = str2double(temp(end));
        case 'YLL'
            yll = str2double(temp(end));
        case 'yll'
            yll = str2double(temp(end));
        case 'CEL'
            resol = str2double(temp(end));
        case 'cel'
            resol = str2double(temp(end));
        case 'NOD'
            nodata = str2double(temp(end));
        case 'nod'
            nodata = str2double(temp(end));
    end
    % Read next row
    row = fgetl(fid);
    head = head + 1;
    % Check for empty/unsupported rows
    if length(row) < 3
        row = 'keep looking';
    end
end
% Close the file. The same file will be loaded using dlmread function (much
% faster than fgetl).
fclose(fid);

%% Read body/main part
data = dlmread(fileID,' ',head,0);
% Transpose/flip upside down the input data to be get correct values with
% respect to x,y (meshgrid)
dem.height = flipud(data);
% Compute x, y grid
[dem.x,dem.y] = meshgrid(xll:resol:xll+resol*(ncols-1),...
                         yll:resol:yll+resol*(nrows-1));
% Set NoData values to NaN
if exist('nodata','var')
    dem.height(dem.height==nodata) = NaN;
end
%% Write output
if nargin >= 2
    if ischar(varargin{1})
        dem.source = fileID;
        save(varargin{1},'dem','v7');
    end
end

end % function
