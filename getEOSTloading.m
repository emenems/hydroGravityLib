function [time,data,channels] = getEOSTloading(url_link,varargin)
%GETEOSTLOADING Get EOST loading time series via URL download
% Input:
%   url_link ...  link to EOST loading time series. Can be Ocean,
%                 Atmosphere or Hydrological loading.
%                 See: http://loading.u-strasbg.fr/GGP
%   varargin{1}.  time vector used to interpolate the downloaded time
%                 series to required time
%   varargin{2}.  output file name
%
% Output:
%   time     ...  output time vector
%   data     ...  output data matrix
%   channels ...  channel names
%
% Example1:
%   url_link = 'http://loading.u-strasbg.fr/GGP/hydro/OPERA/AP09166h.hyd';
%   [time,data,chan] = getEOSTloading(url_link);
%
% Example2:
%   url_link = 'http://loading.u-strasbg.fr/GGP/ocean/ECCO1/BE931612.oce';
%   time_out = datenum(2010,1,1):1/24:datenum(2011,1,1);
%   [time,data,chan] = getEOSTloading(url_link,time_out,save_as);
%
% Example3:
%   url_link = 'http://loading.u-strasbg.fr/GGP/atmos/0.10/AP02163h.mog';
%   save_as 'EOTS_to_tsf.tsf';
%   [time,data,chan] = getEOSTloading(url_link,[],save_as);
%
% Warning: downloading huge file such as MERRA2 (hourly resolution since
% 1980) may take some time (couple of minutes).
%
%                                        M. Mikolaj, mikolaj@gfz-potsdam.de
% Download whole string
str = urlread(url_link); 
% Declare default values
ind.fil = [];ind.fil = [];ind.lat = [];ind.lon = [];
ind.loa = [];ind.mod = [];ind.unit = [];ind.radi = [];
ind.radi = [];ind.colu = [];ind.aut = [];ind.head = [];ind.flag = [];
% Read header assuming max. characters in header < 1000
for i = 1:1000
    temp = lower(strrep(str(i:i+7),' ',''));
    switch temp
        case 'filename'
            ind.fil = i;
        case 'latitude'
            ind.lat = i;
        case 'longitud'
            ind.lon = i;
        case 'loading'
            ind.loa = i;
        case 'model'
            ind.mod = i;
        case 'unit'
            ind.unit = i;
        case 'local ra'
            ind.radi = i;
        case 'local ad'
            ind.radi = i;
        case 'column'
            ind.colu = i;
        case 'author'
            ind.aut = i;
        case 'c*******'
            ind.head = i;
        case '77777777'
            ind.flag = i;
    end
end
% Declare output variables
if nargin >= 2
    time_in = varargin{1};
else
    time_in = [];
end
if nargin >= 3
    output_file = varargin{2};
else
    output_file = [];
end
time = [];
data = [];
channels = [];
if ~isempty(ind.flag)
    % Get number of columns
    if ~isempty(ind.colu) && ~isempty(ind.aut)
        temp = str(ind.colu+13:ind.aut-1);
        temp = strrep(temp,':','');
        temp = strrep(temp,'&',',');
        channels = strsplit(temp,',');
    else
        channels{1} = 'total';
    end
    % Cut header and 7777777
    str = str(ind.flag+8:length(str)-10);
    % Reshape string according to number of columns
    if length(channels) == 3
        url_colu = 46;
    else
        url_colu = 26;
    end
    str_mat = reshape(str,url_colu,length(str)/url_colu);  
    % Get datetime and values
    yymmdd = str_mat(1:9,:)';
    hhmmss = str_mat(11:16,:)';
    for i = 1:length(channels)
       datastr{i} = str_mat(16+(i-1)*10+1:26+(i-1)*10,:)'; 
       channels{i} = strrep(channels{i},' ','');
       channels{i} = strrep(channels{i},'\n','');
    end
    % Declare output variable
    time(1:size(yymmdd),1) = NaN;
    data(1:size(yymmdd),1:length(channels)) = NaN;
    % Convert either 1 | 3 columns/channels
    if length(channels) == 1
        for i = 1:length(time)
            time(i,1) = pattern2time(str2double(yymmdd(i,:)),'day');
            time(i,1) = time(i,1) + pattern2time(str2double(hhmmss(i,:)),'hhmmss');
            data(i,1) = str2double(datastr{1}(i,:));
        end
    else
        for i = 1:length(time)
            time(i,1) = pattern2time(str2double(yymmdd(i,:)),'day');
            time(i,1) = time(i,1) + pattern2time(str2double(hhmmss(i,:)),'hhmmss');
            data(i,1) = str2double(datastr{1}(i,:));
            data(i,2) = str2double(datastr{2}(i,:));
            data(i,3) = str2double(datastr{3}(i,:));
        end
    end
end
% Interpolate if required
if ~isempty(time) && ~isempty(time_in)
    data = interp1(time,data,time_in);
    time = time_in;
end
% Save as tsf if required
if ~isempty(time) && ~isempty(output_file)
    for i = 1:length(channels)
        header(i,1:4) = {'Site','EOTS loading',sprintf('%s',channels{i}),'nm/s^2'};
    end
    comment{1} = ['Download link: ',url_link];
    writetsf([datevec(time),data],header,output_file,99,comment);
end