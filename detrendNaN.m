function out = detrendNaN(t,data,degree)
%DETRENDNAN substract trend from measurements
%   Substract trend from measurements
%   detrendNaN(time,data,degree)

r = find(isnan(data));
thelp = t;dhelp = data;
thelp(r) = [];dhelp(r) = [];
p = polyfit(thelp,dhelp,degree);
out = data - polyval(p,t);

end
