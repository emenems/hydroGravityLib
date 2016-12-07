function [tit_o,xlab_o,ylab_o,leg_o] = mm_setaxes(ax,varargin)
%MM_SETAXES Set axis properties
%
% Input:
%   ax          ...     axis handle (scalar)
% Optional inputs (case sensitive):
%   'fontsize'  ...     Font size. Scalar or vector. If vector: element
%                       1 = title font size, 2 = axis, 3 = xlabel, 
%                       4 = ylabel, 5 = legend. Input either one number or
%                       vector with 5 elements!
%   'title'     ...     title (string)
%   'xlabel'    ...     x label (string, use '' for no label)
%   'ylabel'    ...     y label (string, use '' for no label)
%   'legend'    ...     legend (cell array with name for each plotted line)
%   'legend_loc'...     legend location (string, e.g., 'northeast')
%   'xlim'      ...     x limits (vector [min, max])
%   'ylim'      ...     y limits (vector [min, max])
%   'xtick'     ...     x ticks (vector or [] for no ticks)
%   'ytick'     ...     y ticks (vector or [] for no ticks)
%   'xticklabel'...     x tick labels (vector or [] for no labels)
%   'yticklabel'...     x tick labels (vector or [] for no labels)
%   'grid'      ...     grid on/off 
%   'hold'      ...     hold on/off 
%   'dateformat'...     datetick format (string or [] for off), e.g
%                             'mm/yyyy'
% 
% Output:
%   tit_o       ...     title handle 
%   xlab_o      ...     x label handle
%   ylab_o      ...     y label handle
%   leg_o       ...     legend handle
%
% Examples:
%   mm_axes_settings(plot_axes,'fontsize',12,'title','Time Series','xlabel',...
%                    'time','ylabel','nm/s^2','legend',{'PE','WE'},...
%                    'xlim',[datenum(2000,1,1),datenum(2001,1,1)],'ylim',[-100 100],...
%                    'xtick',datenum(2000,1:1:12,1),'ytick',-100:20:100,'grid','on',...
%                    'hold','off','dateformat','dd.mm.yyyy');
%
%   mm_axes_settings(plot_axes,'xlim',[datenum(2000,1,1),datenum(2001,1,1)],'xticklabel',[],'dateformat',')
%
%                                                   M. Mikolaj, 15.03.2016


%% Read user input
% Depending on the user input switch set function parameters.
% Do so only if odd number of inputs (minimum 1 is required + pairs of
% parameters = switch and value)
if nargin > 1 && mod(nargin,2) == 1
    in = 1; % starging value (varargin starts with 1 not with 2 as first input is mandatory)
    % Read all inputs
    while in < nargin-1 % 1 => ax is mandatory input
        % Switch between function parameters
        switch varargin{in}
            case 'title'
                tit = varargin{in+1};
            case 'xlabel'
                xlab = varargin{in+1};
            case 'ylabel'
                ylab = varargin{in+1};
            case 'legend'
                leg = varargin{in+1};
            case 'legend_loc'
                leg_loc = varargin{in+1};
            case 'xlim'
                xl = varargin{in+1};
            case 'ylim'
                yl = varargin{in+1};
            case 'xtick'
                xt = varargin{in+1};
            case 'ytick'
                yt = varargin{in+1};
            case 'xticklabel'
                xtl = varargin{in+1};
            case 'yticklabel'
                ytl = varargin{in+1};
            case 'grid'
                gr = varargin{in+1};
            case 'hold'
                hl = varargin{in+1};
            case 'dateformat'
                dateformat = varargin{in+1};
            case 'fontsize'
                font_size = varargin{in+1};
                if length(font_size) ~= 5 
                    font_size(end:5) = font_size(1);% set fontsize of legend
                end
        end
        % Increase by 2 as parameters are in pairs!
        in = in + 2;
    end
end

% Set fontsize in case user didn't do it
if exist('font_size','var') == 0
    font_size(1:5) = 9;
end
% Set axis (set this first as this settings affects in R2015b also title)
set(ax,'FontSize',font_size(2));
% Set title
if exist('tit','var')
    tit_o = title(ax,tit,'FontSize',font_size(1));
else
    tit_o = [];
end
% X label
if exist('xlab','var')
    xlab_o = xlabel(ax,xlab,'FontSize',font_size(3));
else
    xlab_o = [];
end
% Y label
if exist('ylab','var')
    ylab_o = ylabel(ax,ylab,'FontSize',font_size(4));
else
    ylab_o = [];
end
% Legend
if exist('leg','var')
    if ~isempty(leg)
        leg_o = legend(ax,leg);
        set(leg_o,'FontSize',font_size(5));
        if exist('leg_loc','var')
            if ~isempty(leg_loc)
                set(leg_o,'location',leg_loc);
            end
        end
    else
        leg_o = [];
    end
else
    leg_o = [];
end
% Y limits
if exist('yl','var')
    set(ax,'YLim',yl);
end
% X ticks
if exist('xt','var')
    set(ax,'XTick',xt);
end
% Y ticks
if exist('yt','var')
    set(ax,'YTick',yt);
end
% X tick labels (on/off)
if exist('xtl','var')
    set(ax,'XTickLabels',xtl);
end
% Y tick labels (on/off)
if exist('ytl','var')
    set(ax,'YTickLabels',ytl);
end
% X limits
if exist('xl','var')
    set(ax,'XLim',xl);
end
% Grid on/off
if exist('gr','var')
    grid(ax,gr)
end
% Hold on/off
if exist('hl','var')
    hold(ax,hl)
end
% Datetick
if exist('dateformat','var')
    % First set dateticks
    datetick(ax,'x',dateformat,'keepticks');
    % Then ensure the limits are set correctly
    if exist('xl','var')
        set(ax,'XLim',xl);
    end
end

end % end of function