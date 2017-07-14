Matlab/Octave HydroGravity Library: **hydroGravityLib**
=====================
This repository contains functions related to loading/writing/analysis or visualization of hydro-gravimetry (or other) data. Only functions **supported by both, Matlab and Octave** are part of this repository.

To test the functionality, run `\test\run_unit_test.m`  
Each **function contains help including example usage**. Thus, only brief description is provided here.  
These **functions do not require any other/external library**, although some toolboxes may be required when running in Matlab (no external package needed in Octave).   
**List of functions:**
* `correctTimeInterval`: alter selected time intervals in user specified way, i.e., correct steps, set to certain interval to NaN, or interpolate
* `cylinderEffect`: compute gravity effect of a cylinder
* `data2daily`: resample input time series to daily values using either mean or sum
* `data2hourly`: resample input time series to hourly values using either mean or sum
* `data2monthly`: resample input time series to monthly values using either mean or sum
* `dayofyear`: compute day of year (returns fraction of day if hour, minute or seconds on input)
* `doy2datenum`: convert year and day of year input to [datenum](mathworks.com/help/matlab/ref/datenum.html) format
* `demean`: subtract mean value from input data (vector or matrix)
* `denan`: simple removal of NaNs (by reducing length of the input vector). See `fillnans` for an alternative approach without reducing input vectors
* `detrendNaN`: subtract required polynomial fit from input vector containing NaNs  
* `et0calc`: compute potential/reference evapotranspiration using Penman-Monteith FAO equation
* `fillnans`: replace NaNs in (regularly sampled) input data by linearly interpolated values while setting maximal missing time interval that can be filled
* `findTimeStep`: identify time steps/irregular sampling and fill/re-sample while using NaNs for missing data
* `getAtmacs`: get/download total [Atmacs](http://atmacs.bkg.bund.de/docs/data.php) effect
* `getEOPeffect`: get Pol/[EOP](http://hpiers.obspm.fr/iers/eop/eopc04/eopc04_IAU2000.62-now) coordinates and compute Polar motion effect an LOD effect
* `getEOSTloading`: get loading products (gravity effects) as provided by [EOST](http://loading.u-strasbg.fr) Loading Service
* `homogenDataTest`: [test](http://www.fao.org/docrep/X0490E/x0490e0l.htm) input time series for homogeneity
* `humidityConvert`: convert relative humidity to either absolute or dew point
* `loadtsf`: load time series formatted in [TSoft](http://seismologie.oma.be/en/downloads/tsoft) format
* `loadggp`: load time series formatted in [GGP/IGETS](http://doi.org/10.2312/GFZ.b103-16087) format
* `load_SU_meteo`: load time series stored in specific format (used by GFZ Section 1.3 in Sutherland)
* `LonLat2psi`: convert [WGS84](https://en.wikipedia.org/wiki/World_Geodetic_System) longitude and latitude to spherical distance
* `mmconv`: convolution tailored for filtering of time series
* `mmcorr`: correlation coefficient, p-value and t-test
* `mm_ascii2mat`: convert/load DEM in [ascii](https://en.wikipedia.org/wiki/Esri_grid) format to structure array
* `mm_filt`: filter time series
* `mm_statnan`: compute basic statistics ignoring NaNs
* `mm_timeExtreme`: find extremes (min,max) and mean values for certain time period
* `pattern2time`: convert time patterns (e.g. yyyymmdd) to [datenum](mathworks.com/help/matlab/ref/datenum.html) format
* `pointDistance`: compute Euclidean distance between two points
* `readcsv`: read csv by specifying header lines, delimiter, time format, etc.
* `saveasc`: save DEM to [ascii](https://en.wikipedia.org/wiki/Esri_grid) format
* `showPrism`: show prism by giving its coordinates formatted for `sorokin` function  
* `sorokin`: compute gravity effect of a prism
* `spectralAnalysis`: carry out spectral analysis (fft)
* `stackfiles`: stack multiple files with overlapping (or without) data into one file
* `time2pattern`: convert [datenum](mathworks.com/help/matlab/ref/datenum.html) format to required time pattern, e.g. yyyymmdd
* `write4dygraph`: save/write input time series to [Dygraph](http://dygraphs.com/data.html#csv) format
* `writeggp`: save/write time series to [GGP/IGETS](http://doi.org/10.2312/GFZ.b103-16087) format
* `writetsf`: save/write time series to [TSoft](http://seismologie.oma.be/en/downloads/tsoft) format
