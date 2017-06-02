function time = doy2datenum(year,doy)
%DOY2DATENUM Convert day of year to datenum time
%
% Input:
%   year    ... year scalar (or vector)
%   doy     ... day of year scalar or vector. Can be a fraction of time.
% 
% Output:
%   time    ... time in datenum format
%
% Example:
%   time = doy2datenum(2017,33);

time = datenum(year,1,1) + doy - 1;

end