function [time,pol,lod] = getEOPeffect(Lat,Lon,varargin)
%GETEOPEFFECT compute polar motion and LOD effect on surface gravity
% Important remarks:
% * Function requires access to internat in order to download the lates EOP time 
%   series
%
% Input:
%   Lat                 ...     latitude of the gravimter (degrees)
%   Lon                 ...     longitude of the gravimter (degrees)
%   varargin{1}         ...     optional: time vector in matlab datenum format 
%                               used to re-interpolate (linearly) the output 
%                               effects
%   varargin{2}         ...     optional: amplitude vactor, by default set 
%                               to 1.16
%
% Output:
%	time        		...		output time vector in matlab/datenum format
%	effect 				...		total Atmacs effect (not correction) in nm/s^2
%	pressure 			...		Atmacs air pressure vector in hPa
%
% Example1:
%   Latitude = 49; Longitude = 12;
%   [time_vec,pol_effect,lod_effect] = getEOPeffect(Latitude,Longitude);
%
% Example2:
%   time_in = datenum(2010,1,1);
%   [time_vec,pol_effect,lod_effect] = getEOPeffect(49.2,12.1,time_in,1.164);
%
%                                             M. Mikolaj, mikolaj@gfz-potsdam.de
%
%% Main settings
% Use either user inputs or default values
if nargin >= 3
    time = varargin{1};
else
    time = [];
end
if nargin >= 4
    amp_factor = varargin{2};
else
    amp_factor = 1.16;
end
% Constants: angular velocity & radius of replacement sphere (m)
w = 72921151.467064/10^12;
R = 6371008;
% url to EOP data
url_link_pol = 'http://hpiers.obspm.fr/iers/eop/eopc04/eopc04_IAU2000.62-now';  
% number of neader characters (not rows!)
url_header = 674;
% number of characters in a row (now data columns!)        
url_rows = 156;            
%% Start reading                                                 
str = urlread(url_link_pol);
str = str(url_header:end);
% reshape to row oriented matrix
str_mat = reshape(str,url_rows,length(str)/url_rows);
%% Transform time
year = str_mat(1:4,:)';
month = str_mat(6:8,:)';
day = str_mat(9:12,:)';
x_str = str_mat(20:30,:)';
y_str = str_mat(31:41,:)';
lod_str = str_mat(54:65,:)';
% prepare variables
time_eop(1:size(year,1),1) = NaN;
x(1:size(year,1),1) = NaN;
y(1:size(year,1),1) = NaN;
lod(1:size(year,1),1) = NaN;
% convert strings to doubles
for li = 1:size(year,1)                                                    
    time_eop(li,1) = datenum(str2double(year(li,:)),str2double(month(li,:)),str2double(day(li,:))); % time vector (in matlab format)
    x(li,1) = str2double(x_str(li,:));% x pol
    y(li,1) = str2double(y_str(li,:));% y pol
    lod(li,1) = str2double(lod_str(li,:));% length of day
end
% convert to radians
x = (x/3600)*pi/180;
y = (y/3600)*pi/180;
% to milisec
lod = lod*1000; 
% aux variable
domega = (-0.843994809*lod)/10^12; 
% polar motion
pol = amp_factor*R*w^2*sind(2*Lat)*(x*cosd(Lon) - y*sind(Lon))*10^9;       
% LOD
lod = -amp_factor*2*w*R*cosd(Lat)^2*domega*10^9;                              
%% Interpolate if required
if nargin >= 3
    pol = interp1(time_eop,pol,time);
    lod = interp1(time_eop,lod,time);
else
    time = time_eop;
end

end % function