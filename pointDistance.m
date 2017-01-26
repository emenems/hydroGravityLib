function dist = pointDistance(varargin)
%POINTDISTANCE compute distance between points (2 or 3D)
% Input: 4 or 6 variables:
%   4 inputs = 2D: (x1,y1,x2,y2)
%   6 inputs = 3D: (x1,y1,z1,x2,y2,z2)
%   x1  ... x coordinate of the first point (m)
%   y1  ... y coordinate of the first point (m)
%   z1  ... z coordinate of the first point (m)
%   x2  ... x coordinates of the second point (m). Can be a matrix.
%   y2  ... y coordinates of the second point (m). Can be a matrix.
%   z2  ... z coordinates of the second point (m). Can be a matrix.
%
% Output:
%   dist... distance in m
%
% Requirements:
%   this function does not require additional functions
% 
% Example:
%   dist = pointDistance(0,1,2,3)
%   dist = pointDistance(0,1,0,2,3,3)
%   
%                                              M.Mikolaj, mikolaj@gfz-potsdam.de
%% Compute distance
if nargin == 4
    dist = sqrt((varargin{1} - varargin{3}).^2 + (varargin{2} - varargin{4}).^2);
elseif nargin == 6
    dist = sqrt((varargin{1} - varargin{4}).^2 + (varargin{2} - varargin{5}).^2  + (varargin{3} - varargin{6}).^2);
else
    dist = NaN;
end
    
end % function