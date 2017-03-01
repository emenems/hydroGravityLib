Matlab/Octave Library
=====================
This repository contains solely functions supported by both, Matlab and Octave.
The functionality is mainly tested on:
* Matlab R2015b (containing standard toolboxes)
* GNU Octave 4.2.0  

To test the functionality on other versions of Matlab/Octave, run `\test\run_unit_test.m`
Each **function contains help including example usage**. Thus only brief description is provided here. These **functions do not require any other/external library**.
* `correctTimeInterval`: alter selected time intervals (e.g. via input file), i.e., correct steps, set to NaN, or interpolate
* `cylinderEffect`: compute gravity effect of a cylinder
* `data2daily`: resample input time series to daily values using either mean or sum
* `data2hourly`: resample input time series to hourly values using either mean or sum
* `data2monthly`: resample input time series to monthly values using either mean or sum
* `demean`: subtract mean value from input data (vector or matrix)
* `denan`: simple removal of NaNs (by reducing length of the input vector)
* `detrendNaN`: subtract required polynomial fit from input vector
* `findTimeStep`: identify time steps and fill them with NaNs
* `getAtmacs`: get and sum [Atmacs](http://atmacs.bkg.bund.de/docs/data.php) effect
* `getEOPeffect`: get Pol/[EOP](http://hpiers.obspm.fr/iers/eop/eopc04/eopc04_IAU2000.62-now) coordinates and compute Polar motion effect an LOD
* `homogenDataTest`: [test](http://www.fao.org/docrep/X0490E/x0490e0l.htm) input time series for homogeneity
* `loadtsf`: load time series formatted in [TSoft](http://seismologie.oma.be/en/downloads/tsoft) format 
* `load_SU_meteo`: load time series stored in specific format (used by GFZ Section 1.3 in Sutherland)
* `LonLat2psi`: convert [WGS84](https://en.wikipedia.org/wiki/World_Geodetic_System) longitude and latitude to spherical distance
* `mmconv`: convolution tailored for filtering of time series
* `mmcorr`: correlation coefficient computed in different ways
* `mm_ascii2mat`: convert/load DEM in [ascii](https://en.wikipedia.org/wiki/Esri_grid) format to Matlab/Octave binary form
* `mm_filt`: filter time series
* `mm_statnan`: compute basic statistics ignoring NaNs
* `mm_timeExtreme`: find extremes (min,max) and mean values for certain time period
* `pattern2time`: convert time patterns (e.g. yyyymmdd) to [datenum](mathworks.com/help/matlab/ref/datenum.html) format
* `pointDistance`: compute Euclidean distance between two points
* `readcsv`: read csv by specifying header lines, delimiter, time format, etc.
* `replaceNaN`: automatically replace all NaNs by interpolation within given/max. time interval  
* `saveasc`: save DEM to [ascii](https://en.wikipedia.org/wiki/Esri_grid) format
* `showPrism`: show prism by giving its coordinates formatted for `sorokin` function  
* `sorokin`: compute gravity effect of a prism
* `spectralAnalysis`: carry out spectral analysis (fft)
* `stackfiles`: stack multiple files with overlapping (or without) data into one file
* `time2pattern`: convert [datenum](mathworks.com/help/matlab/ref/datenum.html) format to required time pattern, e.g. yyyymmdd
* `write4dygraph`: save/write input time series to [Dygraph](http://dygraphs.com/data.html#csv) format
* `writetsf`: save/write time series to [TSoft](http://seismologie.oma.be/en/downloads/tsoft) format
