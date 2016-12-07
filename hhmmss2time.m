function [time] = hhmmss2time(input)
%HHMMSS2TIME Funkcia prevedie cas vo forme hhmmss ma [hh mm ss]
%   Na vstupe je vektor, na vystupe je matica [hh mm ss]

time(:,1) = floor(input./10000);
time(:,2) = floor((input - time(:,1).*10000)./100);
time(:,3) = (input - time(:,1).*10000 - time(:,2).*100);
end

