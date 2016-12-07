function showPrism(xi,yi,hi,grid,hand,color)
%SHOWPRISM Plot 3D polygon of prism
%
% Input: 
%   xi      ... x coordinate of prism CENTER
%   yi      ... y coordinate of prism CENTER
%   hi      ... z coordinate of prism CENTER
%   grid    ... prism resolution in [x,y,z] direction, the z = prism height 
%               (measured from hi, i.e. is upper level)
%   hand    ... 0 = no plot, 1 = new figure, otherwise a handle to axes.
%   color   ... prism color ('g' = green). Either one string or cell for fill 
%               and edgecolor ({'w','k'}); Octave (4.2.0) does not support
%				the fill function, thus only edges will be visible.
% 
%
% Example:
%   showPrism(0,0,0.5,hi[5,7,3],gca,'k')
%                                                   M.Mikolaj, 27.02.2014

%% Prepare axes
% check if figure/axes exist, if not create new one
if hand == 1
    figure
elseif hand ~= 0
    axes(hand);
    hold on;
end
% Check the size of the input grid, if one number (=cube) set dy, and dz values
if length(grid) == 1
    grid(2) = grid(1);
    grid(3) = grid(1);
end
height = grid(3);

%% Compute x coordinates (will be plotted as a filled object)
x = [xi-grid(1)/2,xi+grid(1)/2,xi+grid(1)/2,xi-grid(1)/2,xi-grid(1)/2;...
     xi-grid(1)/2,xi+grid(1)/2,xi+grid(1)/2,xi-grid(1)/2,xi-grid(1)/2;...
     xi-grid(1)/2,xi+grid(1)/2,xi+grid(1)/2,xi-grid(1)/2,xi-grid(1)/2;...
     xi-grid(1)/2,xi+grid(1)/2,xi+grid(1)/2,xi-grid(1)/2,xi-grid(1)/2;...
     xi-grid(1)/2,xi-grid(1)/2,xi-grid(1)/2,xi-grid(1)/2,xi-grid(1)/2;...
     xi+grid(1)/2,xi+grid(1)/2,xi+grid(1)/2,xi+grid(1)/2,xi+grid(1)/2;...
     ];
y = [yi-grid(2)/2,yi-grid(2)/2,yi+grid(2)/2,yi+grid(2)/2,yi-grid(2)/2;...
     yi-grid(2)/2,yi-grid(2)/2,yi+grid(2)/2,yi+grid(2)/2,yi-grid(2)/2;...
     yi-grid(2)/2,yi-grid(2)/2,yi-grid(2)/2,yi-grid(2)/2,yi-grid(2)/2;...
     yi+grid(2)/2,yi+grid(2)/2,yi+grid(2)/2,yi+grid(2)/2,yi+grid(2)/2;...
     yi-grid(2)/2,yi-grid(2)/2,yi+grid(2)/2,yi+grid(2)/2,yi-grid(2)/2;...
     yi-grid(2)/2,yi-grid(2)/2,yi+grid(2)/2,yi+grid(2)/2,yi-grid(2)/2;...
     ];
z = [hi-height,hi-height,hi-height,hi-height,hi-height;...
     hi,hi,hi,hi,hi;...
     hi-height,hi-height,hi,hi,hi-height;...
     hi-height,hi-height,hi,hi,hi-height;...
     hi-height,hi,hi,hi-height,hi-height;...
     hi-height,hi,hi,hi-height,hi-height;...
     ];

     
% Octave does not support fill3
v = version;

if hand ~= 0
  % Use either one color for fill (= no edge color), or different color for fill 
  % and edges. 
    if length(color)>1
        if strcmp(v(end),')')
            f = fill3(x',y',z',color{1});
            set(f,'EdgeColor',color{2});
        else
            plot3(x,y,z,color{end});
        end
    else
        if strcmp(v(end),')')
            f = fill3(x',y',z',color);
            set(f,'EdgeColor','none');
        else
            plot3(x,y,z,color);
        end
    end
end


end % function

