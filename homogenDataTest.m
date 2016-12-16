function homogenDataTest(data_miss,data_full,varargin)
%HOMOGENDATATEST test homogeneity of meteorological data
% Input time series (with missing data and the one used to filled the missing 
% periods) must not be of identical length. Important is only that bot time 
% series are overlapped and use identical time resolution, i.e.,use findTimeStep 
% function to re-sample the data prior calling this function.
% The procedure follows the FAO Irrigation and drainage paper 56, 
%   instructions at: 
%   http://www.fao.org/docrep/X0490E/x0490e0l.htm
%
% Dependencies:
%   does not require any other function
%   Tested on GNU Octave 4.2 and Matlab R2015b
%
% Input:
%   data_miss    ... data vector with missing data
%   data_full    ... complete (surrogate) data vector 
% Optional input: will be used to remove intervals with no overlapping
%   vararing{1}  ... time vector corresponding to data_miss
%   vararing{2}  ... time vector corresponding to data_miss
%   
% Example:
%	homogenDataTest(data_miss,data_full,varargin)
%
% M. Mikolaj, mikolaj@gfz-potsdam.de, 13.12.2016
%
%% Cut time series to identical time interval
if nargin == 4
    time_miss = varargin{1};
    time_full = varargin{2};
    min_time(1) = min(time_miss);
    min_time(2) = min(time_full);
    max_time(1) = max(time_miss);
    max_time(2) = max(time_full);
    data_full(time_full<max(min_time) | time_full>min(max_time),:) = [];
    data_miss(time_miss<max(min_time) | time_miss>min(max_time),:) = [];
end
% Remove NaNs present in either of the time series
r_nan = find(isnan(data_full+data_miss));
data_full(r_nan) = [];
data_miss(r_nan) = [];
clear r_nan

%% Compute standard deviations, means, covariance and correlation
x_mean = mean(data_full);
y_mean = mean(data_miss);
x_std  = std(data_full);
y_std  = std(data_miss);
covxy  = cov([data_full,data_miss]);
corxy  = corr([data_full,data_miss]);

%% Regression analysis
%p = polyfit(data_full,data_miss,1);
%b = p(1);a = p(2);
b = covxy(1,2)/x_std^2;
a = y_mean - b*x_mean;
y_surr = a + b*data_full;
%y_surr = polyval(p,data_full);
resid = data_miss - y_surr;
resid_sd = y_std*sqrt(1-corxy(1,2)^2);
resid_cum = cumsum(resid);

figure('Position',[200,400,1000,400],'PaperPositionMode','auto','name','Regression analysis');
subplot(1,2,1);
plot(data_full,data_miss,'k.');hold on
plot(data_full,y_surr,'r-');
legend('input data','regression ');
xlabel('full vector');ylabel('vector with missing data');
title(sprintf('Regression= %.2f (should 0.7 to 1.3), r^2 = %.2f (should >0.7)',b,corxy(2)^2));
xlim([min(data_full),max(data_full)]);
ylim([min(data_full),max(data_full)]);
%axis equal

%% Test homogeneity
% Set p and corresponding zp values: according to FAO: "80% is commonly 
% utilized". zp is standard normal variate for selected probabilities P.
p_val = [80 85 90 95]; zp = [0.84 1.04 1.28 1.64]; % !!change zp if p_val modified!!
n = length(data_full);
alpha(1:length(p_val)) = n/2;
psi = linspace(0,2*pi,120);
for i = 1:length(p_val)
    beta(i)  = n/sqrt(n-1)*zp(i)*resid_sd; 
    % Compute coordinates of probability ellipsis
    X(:,i) = alpha(i)*cos(psi);
    Y(:,i) = beta(i)*sin(psi);
end

subplot(1,2,2);
plot(resid_cum,'r-');hold on
legend('residuals');
for i = 1:length(p_val)
    if mod(i,2) == 1
        plot(X(:,i)+X(i),Y(:,i),'k-','LineWidth',2)
    else
        plot(X(:,i)+X(i),Y(:,i),'k--','LineWidth',0.5)
    end
    text(n/2,beta(i)*1.1,sprintf('P at %d%%',p_val(i)))
end
title('Associated ellipsis for given probabilities');
  
%% Double mass technique
x_cum = cumsum(data_full);
y_cum = cumsum(data_miss);
b2 = sum((x_cum-mean(x_cum)).*(y_cum-mean(y_cum)))/sum((x_cum-mean(x_cum)).^2);
y2_surr = x_cum*b2;
y2_res = y_cum - y2_surr;

figure('Position',[200,400,1000,400],'PaperPositionMode','auto','name','Double mass analysis');
subplot(1,2,1);
plot(x_cum,y_cum,'k.',x_cum,y2_surr,'r-');
legend('input','fit');
title('Double mass: cumulative sums vs regression');
xlabel('full vector');
ylabel('vector with missing data');
axis equal
subplot(1,2,2);
plot(1:1:length(y2_res),y2_res,'k.');
title('Double mass: fit residuals vs record number (should be random)');
ylabel('residuals');
xlabel('record number');

end % function