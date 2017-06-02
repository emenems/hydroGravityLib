function doy = dayofyear(varargin)
%DAYOFYEAR Calculate day of year for given date and time 
%
% Input:
%   varargin{1} ... datenum vector/scalar OR year
%   varargin{2} ... month vector/scalar
%   varargin{3} ... day vector/scalar
%   varargin{4} ... hour vector/scalar
%   varargin{5} ... minute vector/scalar
%   varargin{6} ... second vector/scalar
%       
% Output:
%    doy        ... day of year (including fraction of day if hour/min/seconds 
%                   are on input
% 
% Example1:
%    doy = dayofyear(736845);
% Example2:
%    doy = dayofyear(2017,5,30,12,0,0);
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de

%% Read user input
if nargin == 1
    time = varargin{1};
    [year,month,day,hour,minute,second] = datevec(time);
else  
    if nargin >= 2 
        year = varargin{1};
        month = varargin{2};
    end
    if nargin >= 3 
        day = varargin{3};
    else 
        minute = day.*0;
    end
    if nargin >= 4 
        hour = varargin{4};
    else
        hour = year.*0;
    end    
    if nargin >= 5 
        minute = varargin{5};
    else 
        minute = year.*0;
    end    
    if nargin == 6 
        second = varargin{6};
    else 
        second = year.*0;
    end
    time = datenum(year,month,day,hour,minute,second);
end    

%% Convert 
doy = time - datenum(year,1,1) + 1;

end % function  