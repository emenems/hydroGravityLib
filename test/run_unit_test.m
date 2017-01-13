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

%% demean
out = demean(data);
if mean(out)~=0
    disp('demean: incorrect output value');
end
clear out

%% demeanMAT
out = demean_mat([data,data]);
if mean(out(:,1))~=0 || mean(out(:,2)) ~= 0
    disp('demean_mat: incorrect output value');
end
clear out

%% denan
out = denan(vertcat(data,NaN));
if length(out) ~= length(data)
    disp('denan: incorrect output length');
end

%% detrendNaN
out = detrendNaN(time,data,1);
if round(sum(out)*1e+11)/1e+11 ~= 0
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
if time_out(1) ~= datenum(2008,7,15) || data_out(1,1) ~= 0
    disp('readcsv: incorrect output value');
end
clear time_out data_out header

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
end
disp('Test completed.');