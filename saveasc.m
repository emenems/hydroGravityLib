function saveasc(file_out,grid_x,grid_y,grid_h,out_no_data,varargin)
%SAVEASC Covert/write matlab matrices to arc ascii (txt) file
%   Function requires uniform sampling of input data in both (X,Y) 
%   dirrections. The output precision is set to: %.4f
% 
% Input:
%   file_out    ...     output file name (string)
%   grid_x      ...     x coordinate matrix
%   grid_y      ...     y coordinate matrix
%   grid_h      ...     height matrix
%   out_no_data ...     flagged output data (scalar)
%   varargin{1} ...     (optional) output precission, e.g. '%.4g'
% Example of input data generation:
%   [grid_x,grid_y] = meshgrid([minX:deltaX:maxX],[minY:deltaY:maxY]);
%   grid_h = griddata(inputDem.x,inputDem.y,inputDem.h,grid_x,grid_y);
%  OR
%   grid_h = interp2(inputDem.x,inputDem.y,inputDem.h,grid_x,grid_y);
% 
% Example of function use:
%   saveasc('OutputArcAsciiGrid.asc',dem.x,dem.y,dem.height,9999);  
%
%                                                   M. Mikolaj, 13.3.2014
%                                                   mikolaj@gfz-potsdam.de

grid_h(isnan(grid_h)) = out_no_data;
ncols = size(grid_x,2);
nrows = size(grid_x,1);
cellsize = abs(grid_x(1,1)-grid_x(1,2));
check_size = abs(grid_y(1,1)-grid_y(2,1));
xll = min(min(grid_x))-cellsize/2;
yll = min(min(grid_y))-cellsize/2;
if nargin >= 6
    out_prec = varargin{1};
else
    out_prec = '%g';
end
if round(cellsize*1e+7)/1e+7 == round(check_size*1e+7)/1e+7
    fid = fopen(file_out,'w');
    fprintf(fid,['NCOLS ','%.0f','\nNROWS ','%.0f','\n'],ncols,nrows);
    fprintf(fid,['XLLCORNER ',out_prec,'\nYLLCORNER ',out_prec,'\n'],xll,yll);
    fprintf(fid,['CELLSIZE ',out_prec,'\n'],cellsize);
    fprintf(fid,['NODATA_VALUE ',out_prec,'\n'],out_no_data);
    fclose(fid);
    dlmwrite(file_out,flipud(grid_h),'precision',out_prec,'delimiter',' ','-append');
end

end

