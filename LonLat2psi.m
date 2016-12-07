function psi = LonLat2psi(lonS,latS,lonP,latP)
%LONLAT2PSI Function for the calculation of spherical distance
% Function calculate the spherical distance between given poinst S and P. 
% Resulting spherical distance (psi) is in radians. 
% 
% Input:
%   LonS    ...     longitude of point S (radians), WGS84
%   LatS    ...     latitude of point S (radians), WGS84
%   LonS    ...     longitude of point/matrix P  (radians), WGS84
%   LonS    ...     latitude of point/matrix P  (radians), WGS84
% 
% Output:
%   psi     ...     spherical distance in radians (scalar or matrix)
% 
%                                                       M. Mikolaj

%% Constant
a = 6378137;                %m
b = 6356752.314245;
e = sqrt((a^2-b^2)/a^2);
%% Transform to XYZ
NS = a./(1-e^2*sin(latS).^2).^0.5;
NP = a./(1-e^2*sin(latP).^2).^0.5;
Xs = NS.*cos(latS).*cos(lonS);
Ys = NS.*cos(latS).*sin(lonS);
Zs = (NS.*(1-e^2)).*sin(latS);
Xp = NP.*cos(latP).*cos(lonP);
Yp = NP.*cos(latP).*sin(lonP);
Zp = (NP.*(1-e^2)).*sin(latP);
%% Transform to sphere
latSg = atan(Zs./(Xs.^2+Ys.^2).^0.5);
lonSg = lonS;
latPg = atan(Zp./(Xp.^2+Yp.^2).^0.5);
lonPg = lonP;
%% Calc spherical distance
psi = acos(sin(latSg).*sin(latPg) + cos(latSg).*cos(latPg).*cos(lonSg-lonPg));

end