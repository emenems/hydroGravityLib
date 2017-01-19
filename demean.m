function out = demean(data)
%DEMEAN substract mean from data
% Input
%   data    ... data vector or matrix
% Output
%   out     ... output vector or matrix (same dimensions as input 'data'). The 
%               mean of 'out' will be zero.
%
%                                             M. Mikolaj, mikolaj@gfz-potsdam.de
r = find(isnan(data), 1);
out = data;
if isempty(r)
    for i = 1:size(data,2)
        out(:,i) = data(:,i) - mean(data(:,i));
    end     
else
    for i = 1:size(data,2)
        out(:,i) = data(:,i) - mean(data(~isnan(data(:,i)),i));
    end 
end

end % Function
