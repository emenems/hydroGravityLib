function [out,fit] = detrendNaN(time,data,degree)
%DETRENDNAN subtract trend from input data
% Input:
%	time 	... input time vector or x coordinate
%	data 	... input data vector or y coordinate
%	degree 	... degree of polynomial used to approximate data
%
% Output:
%	out 	... output data (same dimensions as time and 'data')
%				after trend subtraction
%	fit 	... fitted data vector
%
% Example:
%   out = detrendNaN(time,data,degree);
%
%                                        M. Mikolaj, mikolaj@gfz-potsdam.de

%% Compute
p = polyfit(time(~isnan(data)),data(~isnan(data)),degree);
fit = polyval(p,time);
out = data - fit;

end % function
