%% Kind of a unit test for all functions
% Numerical or dimension inaccuracies will be displayed. Runtime errors will be 
% thrown in command prompt as usual
clear
close all
clc

% Add folder with library
addpath(fullfile('..'));

% Set if you want to check visually results of functions that create graphical 
% output. If yes, output figures will be printed to 'output' folder
check_plots = 1; % 1 = yes, 0 = no. 

% Set if you want to check results of functions that write inputs to some file
% If yes, output files will be written to 'output' folder.
check_write = 1; % 1 = yes, 0 = no. 

%% Generate time series for testing
total_days = 3;
time_resol = 15/1440;
time_orig = transpose(datenum(2010,1,1):time_resol:datenum(2010,1,total_days));
data_orig = ones(length(time_orig),1);
time = time_orig;
data = data_orig;
% Remove some value
ind_rem = 100;
time(ind_rem,:) = [];
data(ind_rem,:) = [];

%% data2daily
[time_out,data_out] = data2daily(time,data,1,1);
if (length(time_out(:,1))~=total_days)
    disp('data2daily: incorrect output length');
end
if sum(data_orig)/length(time_orig) ~= 1
    disp('data2daily: incorrect output value')
end
[time_out,data_out,check_out] = data2daily(time,data,2,1);
if (length(time_out(:,1))~=total_days)
    disp('data2daily: incorrect output length');
end
if sum(data_orig)~= length(time_orig)
    disp('data2daily: incorrect output value')
end

%% data2hourly
[time_out,data_out] = data2hourly(time,data,1,1);
if (length(time_out(:,1))~=((total_days-1)*24+1))
    disp('data2hourly: incorrect output length');
end
if sum(data_orig)/length(time_orig) ~= 1
    disp('data2hourly: incorrect output value')
end
[time_out,data_out,check_out] = data2hourly(time,data,2,1);
if (length(time_out(:,1))~=((total_days-1)*24+1))
    disp('data2hourly: incorrect output length');
end
if sum(data_orig)~= length(time_orig)
    disp('data2daily: incorrect output value')
end
clear time_out data_out

%% data2monthly
temp_time = transpose(datenum(2016,12,29):1:datenum(2017,3,1));
[time_out,data_out] = data2monthly(temp_time,temp_time*0+1,1,1);
if sum(data_out)~= length(time_out(:,1))
    disp('data2monthly: incorrect output value')
end
[time_out,data_out,check_out] = data2monthly(temp_time,temp_time*0+1,2,1);
if sum(data_out) ~= length(temp_time)
    disp('data2monthly: incorrect output value')
end
clear temp_time time_out data_out

%% demean
out = demean(horzcat([1,2,3,NaN,4,5,6,7]',[1:1:7,4]'));
if size(out,1)~=8 || size(out,2) ~= 2
    disp('demean: incorrect output length');
end
if out(1,1) ~= -3 || out(end,2) ~= 0
    disp('demean: incorrect output value');
end
clear out

%% denan
out = denan(vertcat(data,NaN));
if length(out) ~= length(data)
    disp('denan: incorrect output length');
end

%% detrendNaN
[out,fit] = detrendNaN([time;NaN],vertcat(data,NaN),1);
if round(out(1)*1e+11)/1e+11 ~= 0
    disp('detrendNaN: incorrect output value');
end

%% findTimeStep
[time_out,data_out,id_out,id_in] = findTimeStep(time,data,time_resol);
if length(time_out) ~= length(time_orig)
    disp('findTimeStep: incorrect output length');
end
if id_out(1,2)+1 ~= ind_rem
    disp('findTimeStep: incorrect output value');
end
clear time_out data_out id_out id_in

%% load_SU_meteo
[time_out,data_out] = load_SU_meteo(fullfile('input','SU_meteo_data.asc'));
if length(time_out) ~= 1440
    disp('load_SU_meteo: incorrect output length');
end
if sum(data_out) ~= 0
    disp('load_SU_meteo: incorrect output value');
end
clear time_out data_out

%% loadtsf
[tout,dout,~,units,channel_names] = loadtsf(fullfile('input','tsf_data.tsf'));
if length(tout) ~= 10
    disp('loadtsf: incorrect output length');
end
if sum(dout(:,1)) ~= 0
    disp('loadtsf: incorrect output value');
end
if ~isnan(dout(1,2)) ~= 0
    disp('loadtsf: incorrect output value');
end
if ~strcmp(strrep(units{1},' ',''),'units1')
    disp('loadtsf: units not read correctly');
end
if ~strcmp(strrep(channel_names{2},' ',''),'Measurement2')
    disp('loadtsf: channel names not read correctly');
end
clear tout dout units channel_names

%% LonLat2psi
psi = LonLat2psi(0,0,0,0);
if psi ~= 0
    disp('LonLat2psi: incorrect output value');
end
psi = LonLat2psi(1,0,0,0);
if round(psi*1000000)/1000000 ~= 1
    disp('LonLat2psi: incorrect output value');
end
clear psi

%% mm_ascii2mat
dem = mm_ascii2mat(fullfile('input','mm_ascrii2mat_data.asc'));
if length(find(isnan(dem.height))) ~= 4
    disp('mm_ascii2mat: incorrect output value');
end
if ((dem.x(1,1) - dem.x(1,2)) ~= -50) || (dem.y(1,1) - dem.y(2,1)) ~= -50
    disp('mm_ascii2mat: incorrect output value');
end
clear dem

%% time2pattern
time_out = time2pattern([2010,02,03,04,05,06],'second');
if time_out ~= 20100203040506
    disp('time2pattern: incorrect output value');
end
clear time_out

%% pattern2time
time_out = pattern2time(20100203040506,'second');
if time_out ~= datenum([2010,02,03,04,05,06])
    disp('pattern2time: incorrect output value');
end
clear time_out

%% mm_convol
[time_out,data_out] = mmconv(time_orig,data_orig,[0 0 0 1 0 0 0]','valid');
if length(time_out) ~= length(time_orig)-6
    disp('mmconv: wrong output length');
end
if sum(data_out) ~= length(data_out)
    disp('mmconv: incorrect output value');
end
clear time_out data_out

%% mm_filt
[time_out data_out] = mm_filt(time,data,[0 0 0 1 0 0 0]',time_resol);
if length(time_out) ~= length(time_orig)-6*2+1 % contains NaN => 2 times filter
    disp('mm_filt: wrong output length');
end
if sum(data_out(~isnan(data_out))) ~= length(data_out)-2
    disp('mm_filt: incorrect output value');
end
clear time_out data_out

%% mm_statnan
[out_std,out_mean,out_min,out_max,out_range] = mm_statnan(data);
if out_std~=0 || out_mean~= 1 || out_min~= 1 || out_max~= 1 || out_range ~= 0
    disp('mm_statnan: incorrect output value');
end
clear out_std out_mean out_min out_max out_range

%% mm_timeExtreme
[time_out,data_out] = mm_timeExtreme(time_orig(1:4:end,:),...
                        data_orig(1:4:end,:),'hour');
if sum(sum(data_out)) ~= length(data_out)*3
    disp('mm_statnan: incorrect output value');
end
clear time_out data_out

%% mmcorr
[r_stand,~,ptest] = mmcorr([1 2 3 4],[0 3 2 1]);
if round(r_stand*10000)/10000 ~= 0.2 || round(ptest*10000)/10000 ~= 0.8
    disp('mmcorr: incorrect output value');
end
clear r_stand ptest

%% sorokin
dg = sorokin([0,0,1],0,0,0,1000,1,[100000 100000]);
dg_compare = 2*pi*6.674e-11*1000*1*10^8;
if round(dg*100)/100 ~= round(dg_compare*100)/100
    disp('sorokin: incorrect output value');
end
clear dg

%% cylinderEffect
dg = cylinderEffect(1,100000,1,1000);
if round(dg*100)/100 ~= round(dg_compare*100)/100
    disp('cylinderEffect: incorrect output value');
end
clear dg

%% replaceNaN
data_replace = data;
data_replace([123,150:160]) = NaN;
[dataout,replaced] = replaceNaN(time,data_replace,time_resol,'linear');
if length(replaced) ~= 1
    disp('replaceNaN: wrong output length');
end
if replaced(1) ~= time(123) || ~isnan(dataout(150))
    disp('replaceNaN: incorrect value replaced');
end
if isnan(dataout(123))
    disp('replaceNaN: value not replaced');
end
clear dataout replaced

%% readcsv
[time_out,data_out,header] = readcsv(fullfile('input','readcsv_data.dat'),4,...
    ',',1,'"yyyy-mm-dd HH:MM:SS"','All',{'"NAN"'});
if length(time_out) ~= 5
    disp('readcsv: wrong output length');
end
if time_out(1) ~= datenum(2008,7,15,16,15,0) || data_out(1,1) ~= 0
    disp('readcsv: incorrect output value');
end
clear time_out data_out header

%% getAtmacs
atmacs_loc = 'http://atmacs.bkg.bund.de/data/results/lm/we_lm2_12km_19deg.grav';
atmacs_glo = 'http://atmacs.bkg.bund.de/data/results/icon/we_icon384_20deg.grav'; 
time_known = datenum(2016,01,14,0,0,0); 
[time_out,effect,pressure] = getAtmacs(atmacs_loc,atmacs_glo,time_known);
if length(time_out) ~= 1 || length(effect) ~=1 || length(pressure) ~= 1
    disp('getAtmacs: wrong output length');
end
if pressure~=958.704 || round(effect*1000)/1000 ~= round(-18.159*1000)/1000
    disp('getAtmacs: incorrect output value');
end
clear time_out effect pressure atmacs_url_link_loc atmacs_url_link_glo time_known

%% getEOPeffect
[~,pol,lod] = getEOPeffect(90,0,datenum(2010,1,1));
if round(pol*1e+10)/1e+10 ~= 0 || round(lod*1e+10)/1e+10 ~= 0
    disp('getEOPeffect incorrect output value');
end
[time_out,pol,lod] = getEOPeffect(45,10,datenum(2010,1,1),0);
if round(pol*1e+10)/1e+10 ~= 0 || round(lod*1e+10)/1e+10 ~= 0
    disp('getEOPeffect incorrect output value');
end
if length(time_out) ~= 1
    disp('getEOPeffect incorrect output length');
end

%% correctTimeInterval
% Insert NaN that will be replaced within the function by interpolated
% values. In addition 'correct step' = 10.
data(20:30) = NaN;
corMatrix = [3,1,datevec(time(19)),datevec(time(31)),NaN,NaN;...
             1,1,datevec(time(end-10)),datevec(time(end-10)),10,0];
data_out = correctTimeInterval(time,data,corMatrix);
if length(data_out(:)) ~= length(data(:))
    disp('correctTimeInterval incorrect output length');
end
if isnan(sum(data_out(20:30))) || (data_out(end-9)-data_out(end-11))~=10
    disp('correctTimeInterval incorrect output value');
end
clear data_out corMatrix

%% pointDistance
dist = pointDistance([0;0],[1;0],[0;0],[0;0]);
if dist(1) ~= 1 || dist(2) ~= 0
    disp('pointDistance incorrect output value');
end
dist = pointDistance(1,1,1,2,3,3);
if dist ~= 3
    disp('pointDistance incorrect output value');
end
clear dist

%% WRITE OUTPUT
if check_write == 1
    % Check if output folder exist
    %% saveasc
    [grid_x,grid_y] = meshgrid(-1:1:1,2:1:4);
    saveasc(fullfile('output','saveasc_test.asc'),grid_x,grid_y,grid_x.*0,9999);
    clear grid_x grid_y
    disp('Check output/saveasc_test.asc');
    
    %% write4dygraph
    write4dygraph(time_orig(1:10,1),[data_orig(1:10,:),data_orig(1:10,:)./10],...
    {'DataOut=1','DataOut=0.1'},fullfile('output','write4dygraph_test.csv'));
    disp('Check output/write4dygraph_test.csv file');
    
    %% writetsf
    header = {'Location1','Instrument1','DataOut=1','units1';...
              'Location2','Instrument2','DataOut=0.1','units2'};
    comment = {'This is test comment1';'This is test comment2'};
    dataout = [datevec(time_orig(1:10,1)),data_orig(1:10,:),data_orig(1:10,:)./10];
    writetsf(dataout,header,fullfile('output','writetsf_test.tsf'),10,comment);
    clear comment dataout header
    disp('Check output/writetsf_test.tsf file');
    
    %% stackfiles
    [time_out,data_out] = stackfiles('in',{fullfile('input','tsf_data.tsf'),...
                                    fullfile('input','tsf_data_stack.tsf')},...
                                    'out',fullfile('output','stackfiles_test.tsf'));
    if length(time_out) ~= 14 || size(data_out,2) ~= 2
        disp('stackfiles incorrect (tsf) output size');
    end
    if sum(data_out(end,:)) ~= 11 || ~isnan(data_out(end-3,1))
        disp('stackfiles incorrect (tsf) output value');
    end
    clear data_out time_out
    disp('Check output/stackfiles_test.tsf file');
    [time_out,data_out] = stackfiles('in',{fullfile('input','readcsv_data.dat'),...
                                    fullfile('input','readcsv_data_stack.dat')},...
                                    'out',fullfile('output','stackfiles_test.dat'));
    if length(time_out) ~= 7 || size(data_out,2) ~= 4
        disp('stackfiles incorrect (dat) output size');
    end
    if data_out(5,2) ~= 0.1
        disp('stackfiles incorrect (dat) output value');
    end
    clear data_out time_out
    disp('Check output/stackfiles_test.dat file');
    [time_out,data_out] = stackfiles('in',{fullfile('input','mglobe_data.txt'),...
                                    fullfile('input','mglobe_data_stack.txt')},...
                                    'out',fullfile('output','stackfiles_test.txt'));
    if length(time_out) ~= 12 || size(data_out,2) ~= 6
        disp('stackfiles incorrect (txt) output size');
    end
    if data_out(7,1) ~= 11 || data_out(8,1) ~= 12 || ~isnan(data_out(9,1))
        disp('stackfiles incorrect (txt) output value');
    end
    clear data_out time_out
    disp('Check output/stackfiles_test.txt file');
end

%% PLOTS: VISUAL CHECK
if check_plots == 1
    %% showPrism
    showPrism(-0.5,-1,3,[1,2,3],1,'k')
    hold on
    title('!!showPrism: Edges must be at 0, and 1,2,3!!');
    print(gcf,fullfile('output','showPrism_test.jpg'),'-djpeg','-r300');
    close
    disp('Check output/showPrism_test.jpg file');
    
    %% homogenDataTest
    signal1 = sin(2*pi*[1:.01:3]');
    signal2 = signal1 * 2 + randn(length(signal1),1)/30;
    homogenDataTest(signal2,signal1);
    clear signal1 signal2
    print(gcf,fullfile('output','homogenDataTest_test2.jpg'),'-djpeg','-r300');
    close
    print(gcf,fullfile('output','homogenDataTest_test1.jpg'),'-djpeg','-r300');
    close
    disp('Check output/homogenDataTest_test*.jpg file');
    
    %% spetralAnalysis
    x = 1:1:365*10;
    y(:,1) = sin(2*pi*1/365*x);
    y(:,2) = 0.5*sin(2*pi*1/100*x);
    spectralAnalysis(y,1/86400,'plot',1,'lenFFT',50000,'wind','hann');
    title('2 peaks: at 100 and 365 (2*higher) days');
    xlim([1,450]);
    print(gcf,fullfile('output','spectralAnalysis_test.jpg'),'-djpeg','-r300');
    close
    disp('Check output/spectralAnalysis_test.jpg file');
end
disp('Test completed.');