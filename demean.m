function out = demean(data)
%DEMEAN substract mean from data
% Input
%   data    ... data vector or matrix
% Output
%   out     ... output vector or matrix (same dimensions as input 'data'). The 
%               mean of 'out' will be zero.
%
%                                             M. Mikolaj, mikolaj@gfz-potsdam.de
out = data;
for i = 1:size(data,2)
	r = find(isnan(data(:,i)));
	if isempty(r)
        out(:,i) = data(:,i) - mean(data(:,i));
	else
		out(:,i) = data(:,i) - mean(data(~isnan(data(:,i)),i));
    end  
	clear r
end

end % Function
