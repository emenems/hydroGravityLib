function out = demean_mat(data_mat)
%DEMEAN_MAT substract mean from data in matrix (column oriented)
%   Substract mean (nanmean) from data
out = data_mat;
for i = 1:size(data_mat,2)
    data = data_mat(:,i);
    r = find(isnan(data), 1);
    if isempty(r)
        out(:,i) = data_mat(:,i) - mean(data);
    else
        out(:,i) = data_mat(:,i) - nanmean(data);
    end
end

end
