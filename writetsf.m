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
%   decimal...  number of decimal places (between 1 and 6)
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

if nargin == 3
    decimal = 3;
end
vypis = fopen(fileout,'w'); 
fprintf(vypis,'[TSF-file] v01.0\n\n');
switch decimal
    case 0
        fprintf(vypis,'[UNDETVAL] 9999\n\n');
    case 1
        fprintf(vypis,'[UNDETVAL] 9999.9\n\n');
    case 2
        fprintf(vypis,'[UNDETVAL] 9999.99\n\n');
    case 3
        fprintf(vypis,'[UNDETVAL] 9999.999\n\n');
    case 4
        fprintf(vypis,'[UNDETVAL] 9999.9999\n\n');
    case 5
        fprintf(vypis,'[UNDETVAL] 9999.99999\n\n');
    case 6
        fprintf(vypis,'[UNDETVAL] 9999.999999\n\n');
    otherwise
        fprintf(vypis,'[UNDETVAL] 9999.9999999\n\n');
end
fprintf(vypis,'[TIMEFORMAT] DATETIME\n\n');
cas = datenum(data(:,1:6));
increment = mode(diff(cas))*86400;
if max(abs(diff(diff(cas))))*86400 > 0.001
    disp('Warning: the input data set is not evenly spaced');
end
fprintf(vypis,'[INCREMENT] %6.0f\n\n',increment);              %Definovat casovy rozostup medzi bodmi
fprintf(vypis,'[CHANNELS]\n');
ss = size(data,2)-6;
if ~isempty(header) && size(header,1) == ss
    for st = 1:size(header,1)
        fprintf(vypis,'  %s:%s:%s\n',char(header(st,1)),char(header(st,2)),char(header(st,3)));
    end
    fprintf(vypis,'\n[UNITS]\n');
    for st = 1:size(header,1)
        fprintf(vypis,'  %s\n',char(header(st,4)));
    end
else
    while ss >= 1
        fprintf(vypis,'  Site:Instrument:measurements\n');
        ss = ss - 1;
    end
    ss = size(data,2)-6;
    fprintf(vypis,'\n[UNITS]\n');
    while ss >= 1
        fprintf(vypis,'  ?\n');
        ss = ss - 1;
    end
end
switch decimal
    case 0
        data(isnan(data)) = 9999;
    case 1
        data(isnan(data)) = 9999.9;
    case 2
        data(isnan(data)) = 9999.99;
    case 3
        data(isnan(data)) = 9999.999;
    case 4
        data(isnan(data)) = 9999.9999;
    case 5
        data(isnan(data)) = 9999.99999;
    case 6
        data(isnan(data)) = 9999.999999;
    otherwise
        data(isnan(data)) = 9999.9999999;
end
if nargin == 5 
    fprintf(vypis,'\n[COMMENT]\n');
    if ~isempty(varargin{1})
        for i = 1:length(varargin{1})
            fprintf(vypis,'%s\n',char(varargin{1}(i)));
        end
    end
    fprintf(vypis,'\n');
else
    fprintf(vypis,'\n[COMMENT]\n\n');
end
cas = datenum(data(:,1:6));
% casi = cas(1):increment/86400:cas(end);
fprintf(vypis,'[COUNTINFO] %10.0f\n\n',length(cas));
fprintf(vypis,'[DATA]\n');
ss = size(data,2)-6;
r = size(data,1);
% Round time
minute_temp = data(:,5);
second_temp = round(data(:,6));
ms = find(second_temp>=60);
if ~isempty(ms)
    minute_temp(ms) = minute_temp(ms) + round(second_temp(ms)/60);
    data(ms,6) = 0;
end
ms = find(minute_temp>=60);
if ~isempty(ms)
    data(ms,4) = data(ms,4) + round(minute_temp(ms)/60);
    data(ms,5) = 0;
end

for i = 1:r
    % Write date
    fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f ',...
                data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6));
    % Write remaining columns
    for j = 1:ss
         fprintf(vypis,'%g ',data(i,6+j));
    end
    fprintf(vypis,'\n');
end
% 
% switch ss
%     case 1
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7));
%         end
%     case 2
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8));
%         end
%     case 3
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9));
%         end
%     case 4
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10));
%         end
%     case 5
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11));
%         end
%     case 6
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12));
%         end
%     case 7
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f \n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13));
%         end
%     case 8
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14));
%         end
%     case 9
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15));
%         end
%     case 10
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16));
%         end
%     case 11
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17));
%         end
%     case 12
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18));
%         end
%     case 13
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19));
%         end
%     case 14
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20));
%         end
%     case 15
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21));
%         end
%     case 16
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22));
%         end
%     case 17
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23));
%         end
%     case 18
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24));
%         end
%     case 19
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24),data(i,25));
%         end
%     case 20
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24),data(i,25),data(i,26));
%         end
%     case 21
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24),data(i,25),data(i,26),data(i,27));
%         end
%     case 22
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24),data(i,25),data(i,26),data(i,27),data(i,28));
%         end
%     case 23
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24),data(i,25),data(i,26),data(i,27),data(i,28),data(i,29));
%         end
%     case 24
%         for i=1:r;
%             fprintf(vypis,'%4d %02d %02d %02d %02.0f %02.0f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',...
%                 data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),data(i,9),data(i,10),data(i,11),data(i,12),data(i,13),data(i,14),data(i,15),data(i,16),data(i,17),data(i,18),data(i,19),data(i,20),data(i,21),data(i,22),data(i,23),data(i,24),data(i,25),data(i,26),data(i,27),data(i,28),data(i,29),data(i,30));
%         end
%     otherwise
%         disp('Too many channels')
% end

fclose('all');
end