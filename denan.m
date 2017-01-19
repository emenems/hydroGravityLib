function [out,id] = denan(data,varargin)
%DENAN remove NaN form input data
% Input:
%   data            ... input data vector that will be corrected
%   varargin{1}     ... optional: additonal vector that will be used to
%                       find rows with NaNs and removed from input 'data'
% Output:
%   out             ... out vector without NaNs
%   id              ... rows without NaNs in input data
%
% Example:
%   out = denan(data);
%
%                                        M. Mikolaj, mikolaj@gfz-potsdam.de
%% Remove NaN and identified only valid values so the SD can by calculated
if nargin == 2
    refdata = varargin{1};
    id = find(~isnan(refdata));
    out = data(id);
else
    id = find(~isnan(data));
    out = data(id);
end

end % function
