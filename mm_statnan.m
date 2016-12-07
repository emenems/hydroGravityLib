function [out_std,out_mean,out_min,out_max,out_range] = mm_statnan(in)
%MM_STATNAN Calculate basic statistics for data with NaN
% Input:
%   in      ... data with NaN. Matrix or vector. If Matrix, output shows
%               results for columns.
% Output
%   out_std ... standard deviation
%   out_mean... mean value
%   out_min ... minimum
%   out_max ... maximum
%   out_ramge.. range = abs(maximum - minimum)
%
% Requirements:
%   no further function is required
%
% Example:
%  [out_std,out_mean,out_min,out_max,out_range] = mm_statnan([1 3 -2 NaN 0])
% 
%                                                      M.Mikolaj 08.10.2015

% First, check the input format = vector or matrix. If vector, make sure it
% is column oriented (statistics are computed for each column).
if size(in,1) == 1 && size(in,2) > 1                                        % convert to culmn oriented vector if not on input so
    in = in';
end
% Compute basic statistics for each column
for i = 1:size(in,2)                                                        % compute for all columns
    out_std(1,i) = std(in(~isnan(in(:,i)),i));                              % use only valid data, i.e., without NaNs!
    out_min(1,i) = min(in(~isnan(in(:,i)),i));
    out_max(1,i) = max(in(~isnan(in(:,i)),i));
    out_range(1,i) = abs(out_max(1,i)-out_min(1,i));
    out_mean(1,i) = mean(in(~isnan(in(:,i)),i));
end

end % end of function

