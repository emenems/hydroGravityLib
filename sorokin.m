function dg = sorokin(point_of_computation,Xi,Yi,Hi,density,height,grid)
%SOROKIN Function for the computation of gravitational effect of prism
% Function serves for the computation of gravitational effect of simple 
% prism in Cartesian coordinate system, i.e. in x,y+height and constant 
% density. The prism height is automatically corrected for Earth's 
% curvature using radius = 6371000 m.
% dg = sorokin(point_of_computation,Xi,Yi,Hi,density,height,grid)
% Input:
%   point_of_computation...     [x,y,height] of computation point
%                               vector
%   Xi                  ...     x coordinate of the centre of prism upper 
%                               side scalar or matrix
%   Yi                  ...     y coordinate of the centre of prism upper 
%                               side scalar or matrix
%   Hi                  ...     height of the centre of prism upper side
%                               scalar or matrix
%   density             ...     prism difference density
%                               scalar or matrix
%   height              ...     prism height
%                               scalar or matrix
%   grid                ...     dimensions of prism in x/y direction[dx,dy]
%                               scalar or vector
% 
% Output:
%   dg                  ...     gravitational effect of prism(s),i.e. the 
%                               sum of all prisms in uGal (=10^-8 m/s^2 
%                               =10 nm/s^2) 
%
% Check: 24.10.2012, to Mod3D - OK (for fine grid/resolution),
%                    to Karcolom - OK (1 prism 2x2x1 s const.density).



%% COMPUTATION
R = 6371008;
d = sqrt((point_of_computation(1)-Xi).^2 + (point_of_computation(2)-Yi).^2);
Hi = Hi - ((sqrt(d.^2 + R^2) - R).*R)./(sqrt(d.^2 + R^2));
clear d R;
Hi = -Hi+point_of_computation(:,3);
Xi = Xi-point_of_computation(:,1);
Yi = Yi-point_of_computation(:,2);

if size(grid) == 1;
    grid(2) = grid(1);
end
z1 = Hi;
z2 = Hi+height;clear Hi
x1 = Yi-grid(2)/2;
x2 = Yi+grid(2)/2;
y1 = Xi-grid(1)/2;
y2 = Xi+grid(1)/2;
clear Xi Yi

G = 6.674215*10^-11;

Vz = -G*density.*(x2.*(log((y2+sqrt(x2.^2+y2.^2+z2.^2))./(y2+sqrt(x2.^2+y2.^2+z1.^2)))-log((y1+sqrt(x2.^2+y1.^2+z2.^2))./(y1+sqrt(x2.^2+y1.^2+z1.^2))))-...
             x1.*(log((y2+sqrt(x1.^2+y2.^2+z2.^2))./(y2+sqrt(x1.^2+y2.^2+z1.^2)))-log((y1+sqrt(x1.^2+y1.^2+z2.^2))./(y1+sqrt(x1.^2+y1.^2+z1.^2))))+...
             y2.*(log((x2+sqrt(x2.^2+y2.^2+z2.^2))./(x2+sqrt(x2.^2+y2.^2+z1.^2)))-log((x1+sqrt(x1.^2+y2.^2+z2.^2))./(x1+sqrt(x1.^2+y2.^2+z1.^2))))-...
             y1.*(log((x2+sqrt(x2.^2+y1.^2+z2.^2))./(x2+sqrt(x2.^2+y1.^2+z1.^2)))-log((x1+sqrt(x1.^2+y1.^2+z2.^2))./(x1+sqrt(x1.^2+y1.^2+z1.^2))))+...
             z2.*(atan2((z2.*(x2.^2+y2.^2+z2.^2).^0.5),(x2.*y2))-atan2((z2.*(x1.^2+y2.^2+z2.^2).^0.5),(x1.*y2))-atan2((z2.*(x2.^2+y1.^2+z2.^2).^0.5),(x2.*y1))+atan2((z2.*(x1.^2+y1.^2+z2.^2).^0.5),(x1.*y1)))-...
             z1.*(atan2((z1.*(x1.^2+y1.^2+z1.^2).^0.5),(x1.*y1))-atan2((z1.*(x1.^2+y2.^2+z1.^2).^0.5),(x1.*y2))-atan2((z1.*(x2.^2+y1.^2+z1.^2).^0.5),(x2.*y1))+atan2((z1.*(x2.^2+y2.^2+z1.^2).^0.5),(x2.*y2))));
      
dg = sum(sum(Vz))*10^8;                                                     % final effect in uGal (=10^-8 m/s^2 = 10 nm/s^2)