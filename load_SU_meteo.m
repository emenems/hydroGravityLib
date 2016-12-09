function [time,data,scale,offset,units,sample] = load_SU_meteo(file_in)
%% LOAD_SU_METEO load Sutherland meteorological data  
% File example:
%Format               GWR_001
%Filename             /pcmcia/data/PCP_20080905_0544.asc
%Station              Sutherland
%Device               Precipitation
%Sample Intervall     60 s
%Scale Factor         -2.010000
%Offset               -0.020000
%Unit                 mm
%C************************************
%20080905 055000   -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0
%20080905 060000   -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0  -0.0
%...
% 
% Input:
%   file_in   input file name
%
%
% Output:
%   time    ... time vector (matlab format)
%   data    ... loaded data
%
%   
%
%% Read file
% Declare output variables
time = [];
data = [];
scale = 1;
offset = 0;
units = [];
sample = 1;
count = 0; % count header lines
try
  fid = fopen(file_in);
  % Read only existing files
  if fid > 0
    % Open file
    row = fgetl(fid);count = count + 1;
    % Get sampling interval
    while ~strcmp(row(1:3),'Sam')
      row = fgetl(fid);count = count + 1;
    end
    temp = strsplit(row,' ');
    sample = str2double(temp{end-1});
    % Get scaling factor
    while ~strcmp(row(1:3),'Sca')
      row = fgetl(fid);count = count + 1;
    end
    temp = strsplit(row,' ');
    scale = str2double(temp{end});
    % Get Offset
    while ~strcmp(row(1:3),'Off')
      row = fgetl(fid);count = count + 1;
    end
    temp = strsplit(row,' ');
    offset = str2double(temp{end});
    % Get Units
    while ~strcmp(row(1:3),'Uni')
      row = fgetl(fid);count = count + 1;
    end
    temp = strsplit(row,' ');
    units = temp{end};
    % Read up to last line of the header
    while ~strcmp(row(1:3),'C**')
      row = fgetl(fid);count = count + 1;
    end
    % Get data: first get number of columns
    row = fgetl(fid);count = count + 1;
    temp = strsplit(row,' ');
    % Create reading pattern
    form = '%04d%02d%02d %02d%02d%02d'; % yyyymmdd hhmmss
    for i = 3:length(temp)
      form = [form,' %f'];
    end
    % Read all data. Close the file to begin reading from start
    fclose(fid);
    fid = fopen(file_in,'r');
    temp = textscan(fid,form,'HeaderLines',count-1);
    fclose(fid);
    % Convert data to output 
    time = datenum(double([cell2mat(temp(1)),cell2mat(temp(2)),cell2mat(temp(3)),...
                   cell2mat(temp(4)),cell2mat(temp(5)),cell2mat(temp(6))]));
    for i = 1:length(time)
        time(i,2:length(temp)-6) = time(i,1) + [1:1:(length(temp)-7)].*sample/86400;
    end
    % Convert matrix to vector
    temp_time = time';
    time = temp_time(:);
    temp_data = transpose(cell2mat(temp(7:end)));
    data = temp_data(:);
  else
      disp(['No such file: ',file_in,' found']);
  end
catch error_mess
  fprintf('An error occured during reading: %s',error_mess.identifier);
  try
    fclose(fid);
  end
end
