function [ET0,time_out] = et0calc(varargin)
%MM_ET0 Calculate potential evapotranspiration rates
%
% Inputs:
%   method       	... method switch: 
%                   'PM-FAO': Penman-Monteith reference ET,
%                       see http://www.fao.org/docrep/X0490E/X0490E00.htm. 
%                       This method requires following inputs: temperature,
%                       humidity, radiation, radiation_units, wind_speed,
%                       wind_height, time, time_resolution, longitude,
%                       longitude_TZ, latitude, altitude
%                   NOT Implemented yet 'Thornthwaite': Thornthwaite 
%                       equation (1948) time, temperature, humidity, 
%                       radiation, wind_speed, latitude.
%   temperature     ... tempearture vecotor in degC
%   humidity        ... humidity vector in %
%   radiation       ... solar (global) radiation vector in 'radiation_units'
%   radiation_units ... string with radiation units: 'W.m^-2' or 'MJ.m^-2'
%                       or J.m^-2. Note that input in 'MJ.m^2/hour will not
%                       be converted to daily values (must be done outside
%                       of this fuction)!
%   wind_speed      ... wind speed vector in 'm.s^-1' or 'km.h^-1' (see
%                       'wind_units') 
%   wind_units      ... wind speed units: 'm.s^-1' or 'km.h^-1'
%   wind_height     ... height of wind measurements (with respect to
%                       surface). Must be a scalar, e.g. 2.
%   time            ... time vector in matlab (datenum) format.
%   time_resolution ... time resolution string switch: 'day' or 'hour'
%   longitude       ... site longitude in degrees (east of Greenwich, 
%                       between 0 & 360)
%   longitude_TZ    ... longitude of the Time Zone (east of Greenwich, 
%                       between 0 & 360)
%   latitude        ... latitude of the site in degrees (between -90 & 90)
%   altitude        ... site altitude in m
%   pressure        ... (optional) pressure vector in 'pressure_units'
%   pressure_units  ... (optional) pressure units: 'hPa' or 'kPa'
%   Cn              ... (optional) reference crop type (e.g. 900). Will be 
%                        devided by 24 In case of hourly values.
%   Cd              ... (optional) Denominator for daytime, nighttime
%                       (e.g., [0.24 0.96])
%   Cs              ... (optional) Soil heat flux coefficient (for hourly
%                       resolution only, e.g., [0.1 0.5]) 
%   RsRso           ... (optional) Relative shortwave radiation constant
%                       used when Rs/Rso=0. Approx. alternative (FAO): 
%                       Rs/Rso = 0.4 to 0.6 during nighttime periods in 
%                       humid and subhumid climates and Rs/Rso = 0.7 to 0.8 
%                       in arid and semiarid climates. A value of Rs/Rso 
%                       0.3 presumes total cloud cover, 1 = clear sky. 
%                       Default value = 0.5.
%   output_file     ... (optional) output file name (e.g., out.tsf)
%
% Output:
%   ET0             ... computed potential/reference evapotranspiration in
%                       mm/input time resolution
%   time_out        ... output time vector in matlab/datenum format. Time
%                       points to previous 24 | or 1 hour. Just like
%                       precipitation 
%
%
% Tested using FAO examle (see unit test):
% http://www.fao.org/docrep/x0490e/x0490e08.htm#eto calculated with different time steps
% Test3/Example: Compare to campbell scientific logger output for 
% Sutherland hourly estimations: 2 year long time series, set ('Cn',888,'Cd',[0.24 0.96],
% 'Cs',[0.1 0.5],'longitude_TZ',15,'wind_height',1.6,'radiation_units',
% 'MJ.m^-2','longitude',20.81125,'latitude',-32.38163, 'altitude',1762)
% Resulting differences:   
%   STD = 0.037 mm
%   Max error  = 0.47 mm 
%   min error = -0.34 mm 
%   mean = 0.002 mm
%   Cumulative sum error for 2015-2017 = -30 mm (overestimation) ==> ~0.8%
% 
% Requirements/dependency ('matlab_octave_library'):
%   data2*.m + writetsf.m
% 
%                                                    M.Mikolaj
%                                                    mikolaj@gfz-potsdam.de
%% Set default values
method = '';
pressure_units = 'hPa';
wind_units = 'm.s^-1';
ET0 = [];
% Relative shortwave radiation constant
RsRso0 = 0.5;
% Soil heat flux coefficient (for hourly resolution only)
Cs = [0.1 0.5]; % [daytime, nightime]

%% Read inputs
if mod(nargin,2) == 0
    in = 1; % starting value to count inputs
    % Read all inputs
    while in < nargin
        % Switch between function parameters
        switch varargin{in}
            case 'method'
                method = varargin{in+1};
            case 'temperature'
                temperature = varargin{in+1};
            case 'humidity'
                humidity = varargin{in+1};
            case 'radiation'
                radiation = varargin{in+1};
            case 'radiation_units'
                radiation_units = varargin{in+1};
            case 'wind_speed'
                wind_speed = varargin{in+1};
            case 'wind_units'
                wind_units = varargin{in+1};
            case 'wind_height'
                wind_height = varargin{in+1};
            case 'time'
                time_in = varargin{in+1};
            case 'time_resolution'
                time_resolution = varargin{in+1};
            case 'longitude'
                LON = varargin{in+1};
            case 'longitude_TZ'
                LON_TZ = varargin{in+1};
            case 'latitude'
                LAT = varargin{in+1};
            case 'altitude'
                Z = varargin{in+1};
            case 'pressure'
                pressure = varargin{in+1};
            case 'pressure_units'
                pressure = varargin{in+1};
            case 'Cn'
                Cn = varargin{in+1};
            case 'Cd'
                Cd = varargin{in+1};
            case 'Cs'
                Cs = varargin{in+1};
            case 'RsRso'
                RsRso0 = varargin{in+1};
            case 'output_file'
                output_file = varargin{in+1};
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
end

%% Penman-monteith
if strcmp(method,'PM-FAO')
    % Check for required input time series
    if exist('temperature','var') && exist('humidity','var') && exist('radiation','var') &&...
       exist('radiation_units','var') && exist('wind_speed','var') && exist('wind_height','var') &&...
       exist('time_in','var') && exist('time_resolution','var') && exist('LON','var') &&...
       exist('LON_TZ','var') && exist('Z','var') && exist('LAT','var')
        % Check for optional inputs (assign default values only if not on
        % input)
        % Reference crop type
        if ~exist('Cn','var')
            Cn = 900;
        end
        % Denominator for daytime, nighttime
        if ~exist('Cd','var') 
            % switch between daily and hour resolution
            if strcmp(time_resolution,'hour')
                Cd = [0.24 0.96];   % [daytime, nightime]
            else
                Cd = [0.34 NaN];    % [daytime, nightime]
            end
        end
        
        
        %% Step0: prepare data
        % Transform Longitude to degrees west of Greenwich
        LON = 360 - LON;
        LON_TZ = 360 - LON_TZ;
        % Convert Latitud to radians  
        phi = LAT*pi/180;
        % Get numerical value of time resolution
        switch time_resolution
            case 'day'
                t0 = 1; % will be used to convert reference crop type constant Cn
            case 'hour'
                t0 = 1/24;
                t1 = 1; % will be used for extraterrestrial radiation (step 10)
            otherwise
                error('Wrong input units: output time resolution');
        end
        
        %% Step1: Mean temperature
        % Find Min and Max temperature values
        switch time_resolution
            case 'day'
                [time_out,Tmin] = data2daily(time_in,temperature,3,1);
                time_out = datenum(time_out) + 0.5;
                [~,Tmax] = data2daily(time_in,temperature,4,1);
                Tmean = (Tmin + Tmax)./2;
            case 'hour'
                [time_out,Tmean] = data2hourly(time_in,temperature,1,1);  
                time_out = datenum(time_out) + 0.5/24;
        end
        
        %% Step2: Mean radiation
        % Remove unrealistic values
        radiation(radiation<0) = 0;
        % Compute mean
        switch time_resolution
            case 'day'
                [~,Rs] = data2daily(time_in,radiation,1,1);
            case 'hour'
                [~,Rs] = data2hourly(time_in,radiation,1,1);
        end
        % Convert units
        switch radiation_units
            case 'W.m^-2'
                % CHECK!!! Tested only with 'W
                switch time_resolution
                    case 'day'
                        Rs = Rs * 86400/10^6; % convert to days and Mega-Joule (1 W.m^-2 == 1 J.s^-1.m^-2)
                    case 'hour'
                        Rs = Rs * 3600/10^6;
                    case '10min'
                        Rs = Rs * 600/10^6;
                end
            case 'MJ.m^-2'
                Rs = Rs*1;
            case 'J.m^-2'
                Rs = Rs./10^6;
            otherwise
                error('Wrong input units: radiation');
        end
        
        %% Step3: Wind speed
        % Remove unrealistic values
        wind_speed(wind_speed<0) = 0;
        % Interpolate wind speed to required time resolution
        switch time_resolution
            case 'day'
                [~,Uh] = data2daily(time_in,wind_speed,1,1);
            case 'hour'
                [~,Uh] = data2hourly(time_in,wind_speed,1,1);
        end
        % Must be measured at 2 m, if not covert
        if wind_height ~= 2
            % Convert units if required
            if strcmp(wind_units,'km.h^-1')
                Uh = Uh./3.6; % to m/s
            end
            U2 = Uh*(4.87./log(67.8*wind_height - 5.42));
        else
            U2 = Uh;
        end

        %% Step4: Slope of saturation vapor pressure curve
        delta = (4098*(0.6108.*exp((17.27*Tmean)./(Tmean+237.3))))./(Tmean+237.3).^2;

        %% Step5: Atmospheric pressure
        % Use standard pressure if no input
        if ~exist('pressure','var')
            P(1:length(time_out),1) = 101.3.*((293 - 0.0065*Z)./293).^5.26;
        else
            % Interpolate pressure to required time resolution
            switch time_resolution
                case 'day'
                    [~,P] = data2daily(time_in,pressure,1,1);
                case 'hour'
                    [~,P] = data2hourly(time_in,pressure,1,1);
            end
            % Convert Units if required (default: hPa);
            if strcmp(pressure_units,'hPa')
                P = P./10;
            elseif strcmp(pressure_units,'kPa')
                P = P*1;
            else
                error('Wrong input units: pressure');
            end
        end

        %% Step6: Psychrometric constant
        omega = 0.000664742*P; % kPa.degC^-1

        %% Step7: Mean saturation vapor pressure
        switch time_resolution
            case 'day'
                emax = 0.6108.*exp((17.27*Tmax)./(Tmax + 237.3));
                emin = 0.6108.*exp((17.27*Tmin)./(Tmin + 237.3));
                es = (emax + emin)./2;
            otherwise
                es = 0.6108.*exp((17.27*Tmean)./(Tmean + 237.3));
        end

        %% Step8: Actual vapor pressure
        if ~isempty(humidity)
            humidity(humidity<0) = 0;
            humidity(humidity>100) = 100;
            switch time_resolution
                case 'day'
                    [~,RHmin] = data2daily(time_in,humidity,3,1);
                    [~,RHmax] = data2daily(time_in,humidity,4,1);
                    ea = (emin.*(RHmax./100) + emax.*(RHmin./100))./2;
                otherwise
                    [~,RHdata] = data2hourly(time_in,humidity,1,1);
                    ea = es.*RHdata./100;
            end
        else
            ea = 0.6108.*exp((17.27*Tmin)./(Tmin + 237.3));
        end

        %% Step9: The inverse relative distance Earth-Sun and declination
        % Compute julian day
        [year,month,day,hour,minute] = datevec(time_out);
        J = datenum(year,month,day) - datenum(year,1,1) + 1;
        % Compute inverse distance and declination
        dr = 1 + 0.033.*cos((2*pi)/365.*J);
        declin = 0.409*sin((2*pi/365).*J - 1.39);

        %% Step10: Sunset hour angle
        if strcmp(time_resolution,'day')
            ws = acos(-tan(phi)*tan(declin));
        else
            ws = acos(-tan(phi)*tan(declin));
        %     X = 1 - tan(phi).^2*tan(declin).^2;
        %     X(X<=0) = 0.00001;
        %     ws = pi/2 - atan((-tan(phi).*tan(declin))./X.^0.5);
            % See http://www.fao.org/docrep/x0490e/x0490e07.htm
            t = hour + minute/60; % data2hourly returns 0 minute but was adjusted in previous section
            b = (2*pi*(J - 81))./364;
            Sc = 0.1645*sin(2*b) - 0.1255*cos(b) - 0.025*sin(b);
            w = (pi/12)*((t + 0.06667.*(LON_TZ - LON) + Sc) - 12);
            w1 = w - pi*t1/24;
            w2 = w + pi*t1/24;
        end

        %% Step11: Extraterrestrial radiation
        Gsc = 0.0820; % MJ.^-2.min^-1
        % Use correct time resolution
        if strcmp(time_resolution,'day')
            Ra = 24*60/pi*Gsc.*dr.*((ws.*sin(phi).*sin(declin)) + (cos(phi).*cos(declin).*sin(ws)));
        else % for all higher resolution (hour and higher)
            Ra = 12*60/pi*Gsc.*dr.*((w2 - w1).*sin(phi).*sin(declin) + (cos(phi).*cos(declin).*(sin(w2) - sin(w1))));
            % Additional condition (sun below horizon)
            Ra(w<-ws) = 0;
            Ra(w>ws) = 0;
            Ra(Ra<0) = 0;
        end

        %% Step12: clear sky radiation
        Rso = (0.75 + Z*2e-5)*Ra;

        %% Step13: Net solar or net shortwave radiation
        Rns = (1 - 0.23)*Rs; % 0.23 = albedo

        %% Step14: Net outgoing long wave solar radiation
        % First compute the reation Rs/Rso and set to max. possible value
        Rs_Rso = Rs./Rso; 
        Rs_Rso(Rs_Rso>1) = 1;
        Rs_Rso(Rso==0) = RsRso0; % 0.33=> dense cloud cover, 1=clear sky
        if strcmp(time_resolution,'day')
            Rnl = 4.903e-9.*t0.*(0.5.*((Tmax + 273.16).^4 + (Tmin + 273.16).^4)).*(0.34 - 0.14*sqrt(ea)).*(1.35.*Rs_Rso - 0.35);
        else
            Rnl = 4.903e-9.*t0.*((Tmean + 273.16).^4).*(0.34 - 0.14*sqrt(ea)).*(1.35.*Rs_Rso - 0.35);
        end
        Rnl(Rnl<0) = 0;
        
        %% Step15: Net radiation
        Rn = Rns - Rnl;
        if ~strcmp(time_resolution,'day')
            G = Ra.*0;
            G(Ra==0) = Cs(2)*Rn(Ra==0); % nighttime
            G(Ra~=0) = Cs(1)*Rn(Ra~=0); % daytime
            % Aerodynamic resistivity
            CdU2 = U2.*0;
            CdU2(Ra==0) = Cd(2)*U2(Ra==0); % nighttime
            CdU2(Ra~=0) = Cd(1)*U2(Ra~=0); % daytime
        else
            G = 0;
            CdU2 = Cd(1)*U2;
        end

        %% FinalStep: Overall ET0 equation
        ET0 = (0.408.*delta.*(Rn - G) + omega*Cn.*t0.*U2.*(es - ea)./(Tmean + 273))./...
              (delta + omega.*(1 + CdU2));

        % Correct anomalous/unrealistic values
        ET0(ET0<0) = 0;
        ET0(isinf(ET0)) = 0; % if denominator == 0
        % ET0(isnan(ET0)) = 0;
        
        % Set time to point to previous 24 | 1 hour
        switch time_resolution
            case 'day'
                time_out = time_out + 0.5; % 0.5 was added already once
                tsf_out = '24 hours';
            case 'hour'
                time_out = time_out + 0.5/24; % 0.5 was added already once
                tsf_out = 'hour';
        end
        %% Save results
        % Save only if required + use corresponding output format
        if exist('output_file','var')
            if strcmp(output_file(end-2:end),'mat')
                data.time = time_out;
                data.data = [ET0,cumsum(ET0)];
                data.channels = {'ET0','ET0sum'};
                data.units = {'mm','mm'};
                data.settings(1,:) = {'resolution','LAT','LON','LON_TZ','altitude','WindHeight','Cn','CdDay','CdNight','CsDay','CsNight','Rs/Rso'};
                data.settings(2,:) = {time_resolution,LAT,LON+360,LON_TZ+360,Z,wind_height,Cn,Cd(1),Cd(2),Cs(1),Cs(2),RsRso0};
                save(output_file,'data');
            else
                writetsf([datevec(time_out),ET0,cumsum(ET0)],...
                    {'Site','RefEvap','ET0','mm';...
                     'Site','RefEvap','ET0_CumSum','mm'},output_file,3,...
                     {'Created by et0calc.m ';...
                      sprintf('Time stamp points to previous %s (just like precipitation)',tsf_out);...
                      'Following setting have been used:';...
                      sprintf('TimeResulion: %s',time_resolution);...
                      sprintf('Latitude: %g deg',LAT);...
                      sprintf('Longitude: %g deg',LON+360);...
                      sprintf('Longitude Zone: %g deg',LON_TZ+360);...
                      sprintf('Altitude: %g m ',Z);...
                      sprintf('WindHeight: %g m',wind_height);...
                      sprintf('Eq. Constant Cn: %g',Cn);...
                      sprintf('Eq. Constant Cd [day, night]: %g, %g',Cd(1),Cd(2));...
                      sprintf('Eq. Constant Cs [day, night]: %g, %g',Cs(1),Cs(2));...
                      sprintf('Relative shortwave radiation constant (Rs/Rso): %g',RsRso0);...
                      });
            end
        end
    else
        error('Set all required input parameters for Penman-Monteith FAO ET0');
    end
end
end % function