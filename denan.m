function [out r] = denan(varargin)
%DENAN remove NaN
%   Remove NaN and identified only valid values so the SD can by calculated
data = varargin{1};
if length(varargin) == 2
    refdata = varargin{2};
    r = find(~isnan(refdata));
    out = data(r);
else
    r = find(~isnan(data));
    out = data(r);
end


end
