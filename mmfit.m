function [out_par,out_sig,out_fit,out_res,fitresult] = mmfit(x,y,fitname)
%MMFIT function for time series fitting
%  Function requires curve fitting toolbox
%
% Input:
%   x       ...     time (in datenum format, i.e. days)
%   y       ...     y values
%   fitname ...     fitting curve abbraviation ('sin1')
% 
% Output:
%   out_par ...     estimated parameters
%   out_sig ...     estimation sigma (standard error)
%   out_fit ...     fitted values (y)
%   out_res ...     residuals
%   fitresult..     matlab fit result variable
% 
% Example:
%   [out_par,out_sig,out_fit,out_res] = mmfit(x,y,'sin1');
% 
% 
%                                                  M.Mikolaj, 06.06.2014

%% Remove possible NaN values
x0 = x;
y0 = y;
y(isnan(x)) = [];
x(isnan(x)) = [];
x(isnan(y)) = [];
y(isnan(y)) = [];

%% Fit
ft = fittype(fitname);
try
    fitresult = fit(x,y,ft);
catch
    fitresult = Fit(x,y,ft);
end

switch fitname
    case 'sin1'
        out_par = vertcat(fitresult.a1,fitresult.b1,fitresult.c1);
        temp_sig = confint(fitresult,0.68);
        out_sig(1,1) = (temp_sig(2,1) - temp_sig(1,1))/2;
        out_sig(2,1) = (temp_sig(2,2) - temp_sig(1,2))/2;
        out_sig(3,1) = (temp_sig(2,3) - temp_sig(1,3))/2;
        out_fit = feval(fitresult,x0);
        out_res = y0 - out_fit;
    case 'sin2'
        out_par = [vertcat(fitresult.a1,fitresult.b1,fitresult.c1),...
                   vertcat(fitresult.a2,fitresult.b2,fitresult.c2)];
        temp_sig = confint(fitresult,0.68);
        out_sig(1,1) = (temp_sig(2,1) - temp_sig(1,1))/2;
        out_sig(2,1) = (temp_sig(2,2) - temp_sig(1,2))/2;
        out_sig(3,1) = (temp_sig(2,3) - temp_sig(1,3))/2;
        out_sig(1,2) = (temp_sig(2,4) - temp_sig(1,4))/2;
        out_sig(2,2) = (temp_sig(2,5) - temp_sig(1,5))/2;
        out_sig(3,2) = (temp_sig(2,6) - temp_sig(1,6))/2;
        out_fit = feval(fitresult,x0);
        out_res = y0 - out_fit;
    case 'sin3'
        out_par = [vertcat(fitresult.a1,fitresult.b1,fitresult.c1),...
                   vertcat(fitresult.a2,fitresult.b2,fitresult.c2),...
                   vertcat(fitresult.a3,fitresult.b3,fitresult.c3)];
        temp_sig = confint(fitresult,0.68);
        out_sig(1,1) = (temp_sig(2,1) - temp_sig(1,1))/2;
        out_sig(2,1) = (temp_sig(2,2) - temp_sig(1,2))/2;
        out_sig(3,1) = (temp_sig(2,3) - temp_sig(1,3))/2;
        out_sig(1,2) = (temp_sig(2,4) - temp_sig(1,4))/2;
        out_sig(2,2) = (temp_sig(2,5) - temp_sig(1,5))/2;
        out_sig(3,2) = (temp_sig(2,6) - temp_sig(1,6))/2;
        out_sig(1,3) = (temp_sig(2,7) - temp_sig(1,7))/2;
        out_sig(2,3) = (temp_sig(2,8) - temp_sig(1,8))/2;
        out_sig(3,3) = (temp_sig(2,9) - temp_sig(1,9))/2;
        out_fit = feval(fitresult,x0);
        out_res = y0 - out_fit;
    case 'poly1'
        out_par = vertcat(fitresult.p1,fitresult.p2);
        temp_sig = confint(fitresult,0.68);
        out_sig(1,1) = (temp_sig(2,1) - temp_sig(1,1))/2;
        out_sig(2,1) = (temp_sig(2,2) - temp_sig(1,2))/2;
        out_fit = feval(fitresult,x0);
        out_res = y0 - out_fit;
    case 'poly2'
        out_par = vertcat(fitresult.p1,fitresult.p2);
        temp_sig = confint(fitresult,0.68);
        out_sig(1,1) = (temp_sig(2,1) - temp_sig(1,1))/2;
        out_sig(2,1) = (temp_sig(2,2) - temp_sig(1,2))/2;
        out_sig(3,1) = (temp_sig(2,3) - temp_sig(1,3))/2;
        out_fit = feval(fitresult,x0);
        out_res = y0 - out_fit;
    case 'poly3'
        out_par = vertcat(fitresult.p1,fitresult.p2);
        temp_sig = confint(fitresult,0.68);
        out_sig(1,1) = (temp_sig(2,1) - temp_sig(1,1))/2;
        out_sig(2,1) = (temp_sig(2,2) - temp_sig(1,2))/2;
        out_sig(3,1) = (temp_sig(2,3) - temp_sig(1,3))/2;
        out_sig(4,1) = (temp_sig(2,4) - temp_sig(1,4))/2;
        out_fit = feval(fitresult,x0);
        out_res = y0 - out_fit;
end
