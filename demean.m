function out = demean(data)
%DEMEAN substract mean from data
%   Substract mean (nanmean) from data
r = find(isnan(data), 1);
if isempty(r)
    out = data - mean(data);
else
    out = data - mean(data(~isnan(data)));
end

end
