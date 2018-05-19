function [r_stand,r_boots,ptest,ttest] = mmcorr(signal1,signal2,varargin)
%MMCORR compute correlation coefficient
% This function computes Person's correlation coefficients including p and
% t test + bootstrap method.
% Recommended literature: Trauth, 2010, Matlab recipies for Earth sciences.
% 
% Input:
%   signal1     ...     input vector
%   signal2     ...     input vector
%   varargin    ...     optional switch with number for bootstrapping
% 
% Output:
%   r_stand     ...     Person's correlation coefficient (scalar)
%   r_boots     ...     Person's correlation coefficient computed using
%                       bootstrap sampling (1000 data sets). Does NOT work with 
%                       OCTAVE!!
%   ptest       ...     p value (value close to 0 => significant r_stand,
%                                value close to 1 => not significant)
%   ttest       ...     t-test statistic (vector). Null hypothesis: there
%                       is no correlation. Significance level = 0.05,
%                       degree of freedom = n-2.
%                       t(1) = estimated value
%                       t(2) = critical value
%                       We can reject the null hypothesis, i.e. there is no 
%                       correlation, if t(1)>t(2)
%
% Example:
%   [r_stand,r_boots,p,t] = mmcorr(signal1,signal2)
% 
%                                               M. Mikolaj, 11.2.2015
%                                               mikolaj@gfz-potsdam.de

%% Prepare data
r = find(isnan(signal1+signal2));
signal1(r) = [];
signal2(r) = [];
clear r;

%% Standard method
% Switch between matlab and octave
v = version;
if strcmp(v(end),')') || strcmp(v,'4.4.0')% matlab
    [r_stand,ptest] = corrcoef(signal1,signal2);
else % octave < 4.4.0
    r_stand(1,2) = corr(signal1,signal2);
    temp = cor_test(signal1,signal2);
    ptest(1,2) = temp.pval;
end
if ~isempty(r_stand) % empty if input length == 0 (e.g., all removed with singal(r) = [];
    r_stand = r_stand(1,2);
    ptest = ptest(1,2);
else
    r_stand = NaN;
    ptest = ptest(1,2);
end
%% T test
ttest(1) = r_stand*((length(signal1)-2)/(1-r_stand^2))^0.5;
ttest(2) = tinv(0.95,length(signal1)-2);

%% Bootstrap
if nargin == 3 && strcmp(v(end),')')
    r_boots = bootstrp(varargin{1},@corrcoef,signal1,signal2);
    r_boots = r_boots(:,2);
else
    r_boots = NaN;
end

end % end of function