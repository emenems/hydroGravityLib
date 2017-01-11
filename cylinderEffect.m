function dg = cylinderEffect(z,R,L,density)
%CYLINDEREFFECT Gravity Effect of a prism
% Input:
%   z       ... depth of the cylinder,i.e distance to the upper boundary(m)
%   R       ... radius of the cylinder (m)
%   L       ... lenght of the cylinder (measured from the end of z) (m)
%   density ... denisty (kg/m^3)
% 
% Output:
%   dg ... gravitational effect (uGal, =10^-8 m/s^2 =10 nm/s^2)
% 
% Example:
%   cylinderEffect(1.2,0.5,2,10)

dg = 2*pi*6.674215*10^-11*density.*(L + sqrt(z.^2 + R.^2) - sqrt((z + L).^2 + R.^2))*10^8;

end

