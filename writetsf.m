function writetsf(data,header,fileout,decimal,varargin)
%WRITETSF write *.tsf file
% Function serves for the writing to tsf format
%
% Input:
%   data   ...  matrix with time and data columns. data(1:6,:) =
%               datevec(time).
%   header ...  cell area representing Site/Instrument/Observation/units
%               header = {'Site','Instrument','Observation1','units1';
%               'Site','Instrument',Observation2','units2';...}
%               header indexing: header(1,1) = 'Site',...
%               if header == [], default values are used
%   fileout...  output file name (eg 'SU_SG052_2011_CORMIN.tsf')
%   decimal...  number of decimal places, between 0 and 6. Higher number
%               will result in use of '%g' precision 
%   varargin{1} comment (will be written below [COMMENT]). It should be a
%               cell area where each element corresponds to new line.
%               Example: {'This is the first line';'This is the second
%               line'}. Set to [] for no comment.
%  
% Output:
%   []
% 
% Example:
%   writetsf(data,{'Site','Instrument','Observation1','units1'},'Out.tsf',2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% M. Mikolaj 22/11/2011 %%%%
% Get output precision
if nargin == 3
    decimal = 3;
end
try
    fid = fopen(fileout,'w'); 
    % Write header
    fprintf(fid,'[TSF-file] v01.0\n\n');
    switch decimal
        case 0
            fprintf(fid,'[UNDETVAL] 9999\n\n');
        case 1
            fprintf(fid,'[UNDETVAL] 9999.9\n\n');
        case 2
            fprintf(fid,'[UNDETVAL] 9999.99\n\n');
        case 3
            fprintf(fid,'[UNDETVAL] 9999.999\n\n');
        case 4
            fprintf(fid,'[UNDETVAL] 9999.9999\n\n');
        case 5
            fprintf(fid,'[UNDETVAL] 9999.99999\n\n');
        case 6
            fprintf(fid,'[UNDETVAL] 9999.999999\n\n');
        otherwise
            fprintf(fid,'[UNDETVAL] 9999.999\n\n');
    end
    fprintf(fid,'[TIMEFORMAT] DATETIME\n\n');
    % Compute time resolution and write to header
    time = datenum(data(:,1:6));
    increment = mode(diff(time))*86400;
    if max(abs(diff(diff(time))))*86400 > 0.001
        disp('Warning: the input data set is not evenly spaced');
    end
    clear time
    fprintf(fid,'[INCREMENT] %6.0f\n\n',increment);   
    % Add channel names and units
    fprintf(fid,'[CHANNELS]\n');
    colu = size(data,2)-6;
    if ~isempty(header) && size(header,1) == colu
        for st = 1:size(header,1)
            fprintf(fid,'  %s:%s:%s\n',char(header(st,1)),char(header(st,2)),char(header(st,3)));
        end
        fprintf(fid,'\n[UNITS]\n');
        for st = 1:size(header,1)
            fprintf(fid,'  %s\n',char(header(st,4)));
        end
    else
        while colu >= 1
            fprintf(fid,'  Site:Instrument:measurements\n');
            colu = colu - 1;
        end
        fprintf(fid,'\n[UNITS]\n');
        colu = size(data,2)-6;
        while colu >= 1
            fprintf(fid,'  ?\n');
            colu = colu - 1;
        end
        colu = size(data,2)-6;
    end
    % Convert NaNs to Flagged values
    switch decimal
        case 0
            data(isnan(data)) = 9999;
            out_prec = '%.0f';
        case 1
            data(isnan(data)) = 9999.9;
            out_prec = '%.1f';
        case 2
            data(isnan(data)) = 9999.99;
            out_prec = '%.2f';
        case 3
            data(isnan(data)) = 9999.999;
            out_prec = '%.3f';
        case 4
            data(isnan(data)) = 9999.9999;
            out_prec = '%.4f';
        case 5
            data(isnan(data)) = 9999.99999;
            out_prec = '%.5f';
        case 6
            data(isnan(data)) = 9999.999999;
            out_prec = '%.6f';
        otherwise
            data(isnan(data)) = 9999.999;
            out_prec = '%g';
    end
    % Add final comment if on input
    if nargin == 5 
        fprintf(fid,'\n[COMMENT]\n');
        if ~isempty(varargin{1})
            for i = 1:length(varargin{1})
                fprintf(fid,'%s\n',char(varargin{1}(i)));
            end
        end
        fprintf(fid,'\n');
    else
        fprintf(fid,'\n[COMMENT]\n\n');
    end
    rows = size(data,1);
    fprintf(fid,'[COUNTINFO] %10.0f\n\n',rows);
    fprintf(fid,'[DATA]\n');

    % % Round time
    % minute_temp = data(:,5);
    % second_temp = round(data(:,6));
    % ms = find(second_temp>=60);
    % if ~isempty(ms)
    %     minute_temp(ms) = minute_temp(ms) + round(second_temp(ms)/60);
    %     data(ms,6) = 0;
    % end
    % ms = find(minute_temp>=60);
    % if ~isempty(ms)
    %     data(ms,4) = data(ms,4) + round(minute_temp(ms)/60);
    %     data(ms,5) = 0;
    % end

    % Prepare output pattern
    output_patt = '%04d %02d %02d %02d %02d %02.0f ';
    for i = 1:colu
        if i ~= colu
            output_patt = [output_patt,out_prec,' '];
        else
            output_patt = [output_patt,out_prec,'\n'];
        end
    end
    % Write data
    for i = 1:rows
        fprintf(fid,output_patt,data(i,:));
    end
    % Close file
    fclose(fid);
catch
    disp('Data NOT written!')
    fclose(fid);
end

end % function