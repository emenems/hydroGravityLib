function out = humidityConvert(humid,temp,varargin)
%HUMIDITYCOnVERT Convert Relative -> Absolute humidity/Dew point
%
% Input:
%   humid   ... relative humidity vector or scalar (%)
%   temp    ... temperature in degrees Celsius (vector or scalar)
%   varagin{1}. computation/output switch: 'absolute' or 'dew' (for dew
%               point)
%
% Output:
%   out     ... output absolute humidity in kg/m^3 or dew point in DegC
%
% Example:
%   out = humidityCovert(60,25,'absolute')
%   out = humidityCovert(5,87,'dew')
%
% Checked using http://www.dpcalc.org and http://planetcalc.com/2167/
%
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de                                            

if nargin == 2
    type = 'absolute';
else
    type = varargin{1};
end
switch type
    case 'absolute'
        % Compute. See https://carnotcycle.wordpress.com/2012/08/04/how-to-convert-relative-humidity-to-absolute-humidity/
         out = (6.112.*exp((17.67*temp)./(temp+243.5)).*humid*18.02)./...
               ((273.15+temp)*100*0.08314);
        % Convert to kg/m^3
         out = out./1000;
    case 'dew'
        % Convert rel. humidity + temperature to DewPoint
        % See https://en.wikipedia.org/wiki/Dew_point 
        b = 18.678;c = 257.14;d=234.5;
        ym = log((humid./100).*exp((b - temp./d).*(temp./(c + temp))));
        out = (c.*ym)./(b - ym);
end
end % function