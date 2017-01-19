function [time,effect,pressure] = getAtmacs(atmacs_url_link_loc,atmacs_url_link_glo,varargin)
%GETATMACS Get atmacs effect via URL download
% Input:
%   atmacs_url_link_loc ...     atmacs url to local component (lm). Set
%                               either one string or cell containing all
%                               urls. In such case, the downloaded time
%                               series will be concatenated. Set the links
%                               in chronological order! 
%                               If atmacs_url_link_loc is empty and
%                               atmacs_url_link_glo NOT then global model
%                               covering whole Earth is assumed to be
%                               used.
%   atmacs_url_link_glo ...     atmacs url to global component. Set
%                               either one string or cell containing all
%                               urls. In such case, the downloaded time
%                               series will be concatenated. Set the links
%                               in chronological order!
%   varargin{1}         ...     optional: time vector used to re-interpolate 
%                               (linearly) all output parameters
%   varargin{2}         ...     optional: local pressure vector. Can be used to 
%                               output effect that includes residual pressure 
%                               effect. use 'varargin{3}' to set the admittance 
%                               factor. time vector (varargin{1}) must have the 
%                               same length as local pressure vector.
%   varargin{3}         ...     admittance factor used to compute the residual 
%                               effect (correcting insufficient spatial and 
%                               temporal resolution). By default (if varargin{2} 
%                               has been set) equal to -3 nm/s^2/hPa
%
% Output:
%	time 				...		output time vector in matlab/datenum format
%	effect 				...		total Atmacs effect (not correction) in nm/s^2
%	pressure 			...		Atmacs air pressure vector in hPa
%
% Example1:
%   atmacs_url_link_loc = 'http://atmacs.bkg.bund.de/data/results/lm/we_lm2_12km_19deg.grav';
%   atmacs_url_link_glo = 'http://atmacs.bkg.bund.de/data/results/icon/we_icon384_20deg.grav';  
%   [time,effect,pressure] = getAtmacs(atmacs_url_link_loc,atmacs_url_link_glo);
%
% Example2:
%   atmacs_url_link_loc = {'http://atmacs.bkg.bund.de/data/results/lm/we_lm2_12km_19deg.grav',...
%                          'http://atmacs.bkg.bund.de/data/results/iconeu/we_iconeu_70km.grav'};
%   atmacs_url_link_glo = {'http://atmacs.bkg.bund.de/data/results/icon4lm/we_icon384_19deg.grav',...
%                          'http://atmacs.bkg.bund.de/data/results/icon/we_icon384_20deg.grav'};  
%   [time,effect,pressure] = getAtmacs(atmacs_url_link_loc,atmacs_url_link_glo);
%
% Example3:
%   atmacs_url_link_loc = [];
%   atmacs_url_link_glo = 'http://atmacs.bkg.bund.de/data/results/icongl/we_icon384_200km.grav';  
%   [time,effect,pressure] = getAtmacs(atmacs_url_link_loc,atmacs_url_link_glo,time_in,pressure_in,-3.5);
%
%                                           M. Mikolaj, mikolaj@gfz-potsdam.de
%
%
% Use either user inputs or default values
if nargin >= 3
    time = varargin{1};
else
    time = [];
end
if nargin >= 4
    local_press = varargin{2};
end
if nargin == 4
    admit = -3;
elseif nargin == 5
    admit = varargin{3};
end
%% Read Atmacs data: either comprising global and local component or global
% component only (covering also local zone)
if isempty(atmacs_url_link_loc) && ~isempty(atmacs_url_link_glo)
    % number of header characters (not rows!)
    url_header = 1;
    % number of characters in a row (now data columns!)        
    url_rows = 64;
    % Run loop for all input links. The time series will be than
    % concatenated. First though, check if user set one url link 
    % (=> not a cell) or number of links as cell 
    if ~iscell(atmacs_url_link_glo)
        % Convert to cell so it can be used in following loop (= go
        % through all links in the cell array)
        atmacs_url_link_glo = {atmacs_url_link_glo};
    end
    % Declare vector for appending
    time_total = [];
    l_total = [];
    g_total = [];
    d_total = [];
    p_total = [];
    for i = 1:length(atmacs_url_link_glo)
        % get url string
        str = urlread(atmacs_url_link_glo{i});   
        % cut off header (useful only if only if url_header ~= 1)
        str = str(url_header:end);         
        % reshape to row oriented matrix
        str_mat = reshape(str,url_rows,length(str)/url_rows);   
        % Get/extract all columns
        year = str_mat(1:4,:)';
        month = str_mat(5:6,:)';
        day = str_mat(7:8,:)';
        hour = str_mat(9:10,:)';
        p_str = str_mat(12:25,:)';
        l_str = str_mat(26:38,:)';
        g_str = str_mat(39:50,:)';
        d_str = str_mat(51:63,:)';
        % Declare variables
        time_glo(1:size(year),1) = NaN;
        p(1:size(year),1) = NaN;
        l(1:size(year),1) = NaN;
        g(1:size(year),1) = NaN;
        d(1:size(year),1) = NaN;
        % convert strings to doubles
        for li = 1:size(year,1)    
            % time vector (in matlab format)
            time_glo(li,1) = datenum(str2double(year(li,:)),str2double(month(li,:)),str2double(day(li,:)),str2double(hour(li,:)),0,0); 
            % pressure in Pa!
            p(li,1) = str2double(p_str(li,:));     
            % local part (m/s^2)
            l(li,1) = str2double(l_str(li,:)); 
            % global part (m/s^2)
            g(li,1) = str2double(g_str(li,:));   
            % Deformation part
            d(li,1) = str2double(d_str(li,:));   
        end
        % Concatenate
        if isempty(time_total) % for the first data set
            time_total = time_glo;
            l_total = l;
            g_total = g;
            d_total = d;
            p_total = p;
        else
            % Check date (for overlapping or missing data)
            r = find(time_total(end) == time_glo);
            % No such time exist => check how big is the gap
            if isempty(r)
                time_diff = time_total(end) - time_glo(1);
                time_res = time_total(end) - time_total(end-1);
                % If the missing data is > then model resolution insert
                % NaN (for further interpolation). Multiply by 2 to
                % take increase of resolution into account
                if (time_diff*-1 > time_res*2) && (time_diff < 0)
                    time_total = vertcat(time_total,time_total(end)+time_res,time_glo);
                    l_total = vertcat(l_total,NaN,l);
                    g_total = vertcat(g_total,NaN,g);
                    d_total = vertcat(d_total,NaN,d);
                    p_total = vertcat(p_total,NaN,p);
                elseif (time_diff*-1 <= time_res*2) && (time_diff < 0)
                    time_total = vertcat(time_total,time_glo);
                    l_total = vertcat(l_total,l);
                    g_total = vertcat(g_total,g);
                    d_total = vertcat(d_total,d);
                    p_total = vertcat(p_total,p);
                elseif time_diff > 0
                    % In case the current time series starts before
                    % already loaded + no overlapping
                    time_total = vertcat(time_total,time_total(end)+time_res);
                    l_total = vertcat(l_total,NaN);
                    g_total = vertcat(g_total,NaN);
                    d_total = vertcat(d_total,NaN);
                    p_total = vertcat(p_total,NaN);
                end  
            else
                % In case overlapping exist, check for offsets
                l_diff = l_total(end) - l(r);
                g_diff = g_total(end) - g(r);
                d_diff = d_total(end) - d(r);
                p_diff = p_total(end) - p(r);
                % Apply offsets
                time_total = vertcat(time_total,time_glo(r+1:end));
                l_total = vertcat(l_total,l(r+1:end)+l_diff);
                g_total = vertcat(g_total,g(r+1:end)+g_diff);
                d_total = vertcat(d_total,d(r+1:end)+d_diff);
                p_total = vertcat(p_total,p(r+1:end)+p_diff);
            end
        end
        clear l_diff g_diff d_diff p_diff l g d p time_glo year month day hour g_str d_str l_str p_str str str_mat li
    end
    % Add all effects + interpolate to output time vector + convert to
    % nm/s^2 | hPa
    if nargin >= 3
        pressure = interp1(time_total,p_total,time)/100;
        % Use '-' to convert correction to effect.
        effect = -interp1(time_total,l_total+g_total+d_total,time)*1e+9;
    else
        pressure = p_total/100;
        effect = -(l_total+g_total+d_total)*1e+9;
        time = time_total;
    end
    % Compute residual effect if required
    if nargin >= 4
        dp = local_press - pressure;
        effect = effect + admit*dp;
    end
    
%% Read Global and local data
else
    url_header = 1;
    url_rows = 51;
    % Run loop for all input links. The time series will be than
    % concatenated. First though, check if user set one url link 
    % (=> not a cell) or number of links as cell 
    if ~iscell(atmacs_url_link_loc)
        % Convert to cell so it can be used in following loop (= go
        % through all links in the cell array)
        atmacs_url_link_loc = {atmacs_url_link_loc};
    end
    % Do the same with Global links
    if ~iscell(atmacs_url_link_glo)
        atmacs_url_link_glo = {atmacs_url_link_glo};
    end
    % Declare vector for appending
    time_total_loc = [];
    time_total_glo = [];
    l_total = [];
    r_total = [];
    p_total = [];
    d_total = [];
    g_total = [];
    for i = 1:length(atmacs_url_link_loc)
        % get url string
        str = urlread(atmacs_url_link_loc{i});                                         
        str = str(url_header:end);
        str_mat = reshape(str,url_rows,length(str)/url_rows);
        year = str_mat(1:4,:)';
        month = str_mat(5:6,:)';
        day = str_mat(7:8,:)';
        hour = str_mat(9:10,:)';
        p_str = str_mat(12:25,:)';
        l_str = str_mat(26:38,:)';
        r_str = str_mat(39:50,:)';
        % Prepare variables
        time_loc(1:size(year),1) = NaN;
        p(1:size(year),1) = NaN;
        l(1:size(year),1) = NaN;
        r(1:size(year),1) = NaN;
        % Convert to doubles
        for li = 1:size(year,1) 
            % time vector (in matlab format)
            time_loc(li,1) = datenum(str2double(year(li,:)),str2double(month(li,:)),str2double(day(li,:)),str2double(hour(li,:)),0,0); 
            % pressure (Pa)
            p(li,1) = str2double(p_str(li,:));   
            % local part (m/s^2)
            l(li,1) = str2double(l_str(li,:));
            % regional part (m/s^2)
            r(li,1) = str2double(r_str(li,:));                                      
        end
        % Concatenate
        if isempty(time_total_loc) % for the first data set
            time_total_loc = time_loc;
            l_total = l;
            r_total = r;
            p_total = p;
        else
            % Check date (for overlapping or missing data)
            rf = find(time_total_loc(end) == time_loc);
            % No such time exist => check how big is the gap
            if isempty(rf)
                time_diff = time_total_loc(end) - time_loc(1);
                time_res = time_total_loc(end) - time_total_loc(end-1);
                % If the missing data is > then model resolution insert
                % NaN (for further interpolation). Multiply by 2 to
                % take increase of resolution into account
                if (time_diff*-1 > time_res*2) && (time_diff < 0)
                    time_total_loc = vertcat(time_total_loc,time_total_loc(end)+time_res,time_loc);
                    l_total = vertcat(l_total,NaN,l);
                    r_total = vertcat(r_total,NaN,r);
                    p_total = vertcat(p_total,NaN,p);
                elseif (time_diff*-1 <= time_res*2) && (time_diff < 0)
                    time_total_loc = vertcat(time_total_loc,time_loc);
                    l_total = vertcat(l_total,l);
                    r_total = vertcat(r_total,r);
                    p_total = vertcat(p_total,p);
                elseif time_diff > 0
                    % In case the current time series starts before
                    % already loaded + no overlapping
                    time_total_loc = vertcat(time_total_loc,time_total_loc(end)+time_res);
                    l_total = vertcat(l_total,NaN);
                    r_total = vertcat(r_total,NaN);
                    p_total = vertcat(p_total,NaN);
                end  
            else
                % In case overlapping exist, check for offsets
                l_diff = l_total(end) - l(rf);
                r_diff = r_total(end) - r(rf);
                p_diff = p_total(end) - p(rf);
                % Apply offsets
                time_total_loc = vertcat(time_total_loc,time_loc(rf+1:end));
                l_total = vertcat(l_total,l(rf+1:end)+l_diff);
                r_total = vertcat(r_total,r(rf+1:end)+r_diff);
                p_total = vertcat(p_total,p(rf+1:end)+p_diff);
            end
        end
        clear year month day hour p_str l_str r_str str str_mat li l r p rf time_diff time_res time_loc
    end

    % Read Atmacs Global data
    url_header = 1;
    url_rows = 37;
    for i = 1:length(atmacs_url_link_glo)
        % get url string
        str = urlread(atmacs_url_link_glo{i}); 
        str = str(url_header:end);
        str_mat = reshape(str,url_rows,length(str)/url_rows);
        year = str_mat(1:4,:)';
        month = str_mat(5:6,:)';
        day = str_mat(7:8,:)';
        hour = str_mat(9:10,:)';
        g_str = str_mat(11:24,:)';
        d_str = str_mat(25:36,:)';
        % Prepare variables
        time_glo(1:size(year),1) = NaN;
        g(1:size(year),1) = NaN;
        d(1:size(year),1) = NaN;
        % Convert to doubles
        for li = 1:size(year,1)
            time_glo(li,1) = datenum(str2double(year(li,:)),str2double(month(li,:)),str2double(day(li,:)),str2double(hour(li,:)),0,0);
            g(li,1) = str2double(g_str(li,:)); % global attraction (m/s^2)
            d(li,1) = str2double(d_str(li,:)); % deformation part part (m/s^2)
        end
        % Concatenate
        if isempty(time_total_glo) % for the first data set
            time_total_glo = time_glo;
            g_total = g;
            d_total = d;
        else
            % Check date (for overlapping or missing data)
            rf = find(time_total_glo(end) == time_glo);
            % No such time exist => check how big is the gap
            if isempty(rf)
                time_diff = time_total_glo(end) - time_glo(1);
                time_res = time_total_glo(end) - time_total_glo(end-1);
                % If the missing data is > then model resolution insert
                % NaN (for further interpolation). Multiply by 2 to
                % take increase of resolution into account
                if (time_diff*-1 > time_res*2) && (time_diff < 0)
                    time_total_glo = vertcat(time_total_glo,time_total_glo(end)+time_res,time_glo);
                    g_total = vertcat(g_total,NaN,g);
                    d_total = vertcat(d_total,NaN,d);
                elseif (time_diff*-1 <= time_res*2) && (time_diff < 0)
                    time_total_glo = vertcat(time_total_glo,time_glo);
                    g_total = vertcat(g_total,g);
                    d_total = vertcat(d_total,d);
                elseif time_diff > 0
                    % In case the current time series starts before
                    % already loaded + no overlapping
                    time_total_glo = vertcat(time_total_glo,time_total_glo(end)+time_res);
                    g_total = vertcat(g_total,NaN);
                    d_total = vertcat(d_total,NaN);
                end  
            else
                % In case overlapping exist, check for offsets
                g_diff = g_total(end) - g(rf);
                d_diff = d_total(end) - d(rf);
                % Apply offsets
                time_total_glo = vertcat(time_total_glo,time_glo(rf+1:end));
                g_total = vertcat(g_total,g(rf+1:end)+g_diff);
                d_total = vertcat(d_total,d(rf+1:end)+d_diff);
            end
        end
        clear g_diff d_diffg d g time_glo year month day hour g_str d_str str str_mat li time_diff time_res rf time_glo
    end
    % Add all effects + interpolate to output time vector + convert to
    % nm/s^2 | hPa
    if nargin >= 3
        pressure = interp1(time_total_loc,p_total,time)/100;
        % Use '-' to convert correction to effect.
        effect = -(interp1(time_total_loc,l_total+r_total,time) + ...
                    interp1(time_total_glo,g_total+d_total,time))*1e+9;
    else
        pressure = p_total/100;
        time = time_total_loc;
        effect = -(l_total + r_total + interp1(time_total_glo,g_total+d_total,time))*1e+9;
    end
    % Compute residual effect if required
    if nargin >= 4
        dp = local_press - pressure;
        effect = effect + admit*dp;
    end
end


end % function