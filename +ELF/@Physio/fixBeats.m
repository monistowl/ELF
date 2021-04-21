function fixBeats(P)
%fixBeats: Hand-edit auto-detected RR inter-beat intervals
%   Hastily adapted from Greg Siegle's scripts
% Plots ECG with beats in a scrolling window with sliders 
% controlling the center of the region and the zoom
% ratio. Allows you to add or remove beats.
% Each column is a line
% The add/remove functionality assumes that the first column of the matrix is
%    0's and 1's which index something (e.g., heart beats).
% Clicking the 
%   REMOVE button will remove beats within 50ms of the click
%   ADD button will make the clicked point 1 in the first column of the matrix
%   SAVE button saves the modified IBI series to the PhysioData object
%
% Physio.fixBeats % Open beat-fixing GUI for Physio
%
%See also: ELF/Physio


    invert=0;

    xaxis = (1:length(P.ecg));
    data = fliplr(P.ecg_with_beats_tt.Variables);
    ctr=0;
%     for i=1:length(data(:,1))
%         if data(i,1); data(i,1)=0; ctr=i+5; end
%         if i==ctr; data(i,1)=1; end
%     end

    %zoomfun=sprintf('zoomslider(%d)',invert);
    
    %MAIN FIGURE
    h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normalized', ...
        'FileName','./scrollplot.m', ...
...%         'PaperPosition',[18 180 576 432], ...
...%         'PaperUnits','points', ...
        'Position',[0.1 0.1 0.8 0.8], ...
        'Tag','Fig2', ...
        'ToolBar','none', ...
        'UserData',[1 5 2 4]);
    
    %PLOT AXES
    h1 = axes('Parent',h0, ...
        'Units','normalized', ...
        'Box','on', ...
        'CameraUpVector',[0 1 0], ...
        'Color',[1 1 1], ...
        'Position',[0.05 0.32 0.9 0.6], ...
        'Tag','Axes1', ...
        'XColor',[0 0 0], ...
        'XLim',[1 5], ...
        'XLimMode','manual', ...
        'YColor',[0 0 0], ...
        'YLim',[-0.2 0.4], ...
        'YLimMode','manual', ...
        'ZColor',[0 0 0]);
    
    h2 = line('Parent',h1, ...
        'Color',[0 0 1], ...
        'Tag','Axes1Line1', ...
        'XData',[1 2 3 4 5], ...
        'YData',[2 3 4 3 2]);
    
    

    
    %REGION SLIDER
    h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
        'Callback',{@zoomslider,invert}, ...
        'ListboxTop',0, ...
        'Position',[0.05 0.2 0.9 0.05], ...
        'Style','slider', ...
        'Tag','RegionSlider', ...
        'Value',0);
    
    h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
        'ListboxTop',0, ...
        'Position',[0.05 0.25 0.9 0.02], ...
        'FontName', 'FixedWidth', ...
        'String','<----earlier          SCROLL            later---->', ...
        'Style','text', ...
        'Tag','StaticText1');

    
    %ZOOM SLIDER
    h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
        'Callback',{@zoomslider,invert}, ...
        'ListboxTop',0, ...
        'Position',[0.05 0.05 0.9 0.05], ...
        'Style','slider', ...
        'Tag','ZoomSlider', ...
        'Value',0.01);
    
     h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
        'ListboxTop',0, ...
        'Position',[0.05 0.1 0.9 0.02], ...
        'FontName', 'FixedWidth', ...
        'String','<----in           ZOOM          out---->', ...
        'Style','text', ...
        'Tag','StaticText2');
    
    %REMOVE POINT BUTTON
    h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'Callback',@clickplot_removepoint, ...
        'ListboxTop',0, ...
        'Position',[0.05 0.94 0.2 0.04], ...
        'String','Remove Point', ...
        'Tag','RemovePointButton');
    
    %ADD POINT BUTTON
    h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'Callback',@clickplot_addpoint, ...
        'ListboxTop',0, ...
        'Position',[0.29 0.94 0.2, 0.04], ...
        'String','Add Point', ...
        'Tag','AddPointButton');
    
    %SAVE BUTTON
    h1 = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'Callback',{@saveIbis,P}, ...
        'ListboxTop',0, ...
        'Position',[0.75 0.94 0.2 0.04], ...
        'String','Save', ...
        'Tag','ExportButton');
    
    
    if nargout > 0, fig = h0; end

    axes(gca)

    plot(xaxis,data);
    ylim([-0.1 0.25]);
    %axis tight
    if invert,  view(0,270); end
    set(gcf,'UserData',axis);
    zoomslider_init;
end


function clickplot_removepoint(src,event)
    % removes a point from clickplot

    [x,y]=ginput(1);
    fprintf('Removing data at x=%d\n',x);

    % change the data at that x coordinate
    ax=get(gca);
    dat=get(ax.Children(end));
    beats=dat.YData;
    % must convert to indices from supplied X axis
    %minxax=min(dat.XData); maxax=max(dat.XData);
    xind=findclosestindex(x,dat.XData);
    beats(xind-50:xind+50)=0;
    set(ax.Children(end),'YData',beats);

end

function clickplot_addpoint(src,event)
    % removes a point from clickplot

    [x,y]=ginput(1);
    fprintf('Adding data at x=%d\n',x);

    % change the data at that x coordinate
    ax=get(gca);
    dat=get(ax.Children(end));
    beats=dat.YData;
    xind=findclosestindex(x,dat.XData);
    beats(round(xind))=1;
    set(ax.Children(end),'YData',beats);
end

function saveIbis(src,event,P)
    % exports from clickplot to P

    % change the data at that x coordinate
    ax=get(gca);
    dat=get(ax.Children(end));
    rpeaks = find(dat.YData);
    rr = [rpeaks rpeaks(end)]-[0 rpeaks]; %get inter-beat intervals
    rr = rr(1:end-1)'; %trim missing vals from beginning/end
    
    P.ibis = rr./P.Fs; %output in seconds
    
    close;
end

function zoomslider(src,event,invert)
    % slider for scrollplot
    if nargin<1, invert=0; end

    axisdata=get(gcf,'UserData');
    axes(gca);
    
    range=axisdata(2)-axisdata(1);
    RegionSlider=findobj('Tag','RegionSlider');
    curpos=get(RegionSlider,'value');
    if length(curpos)>1; curpos = curpos{1}; end

    ZoomSlider=findobj('Tag','ZoomSlider');
    zslideval = get(ZoomSlider,'value');
    if length(zslideval)>1; zslideval = zslideval{1}; end
    
    curzoom=max(zslideval,.00001);
    middle=1+curpos.*(range-1);
    %lbd=max(1,middle-(range./2)*curzoom);
    lbd=middle-(range./2)*curzoom;
    ubd=lbd+range.*curzoom;
    %ubd=min(size(data,2),lbd+range.*curzoom);
    set(gca,'xlim',[lbd ubd]);

    axis([lbd ubd axisdata(3) axisdata(4)]);
    if invert
      view(0,270);
    end
end

function indwav=findclosestindex(wav,inds,getall)
% usage: indwav=findclosestindex(wav,inds,getall)
% given a waveform and a set of indices, maps the waveform
% to the position of the closest indices.
% note: wav and inds MUST be row vectors
    if nargin<3, getall=0; end

    indsmat=repmat(inds', 1,length(wav));
    wavmat=repmat(wav,length(inds),1);
    if size(indsmat,1)~=size(wavmat,1)
        indsmat=indsmat';
    end

    [val,indwav]=min(abs(wavmat-indsmat));
    % give highest rather than lowest fit if there is one
    if getall
      if (length(wav)==1)
        indmatches=find(val==abs(wavmat-indsmat));
        indwav=indmatches;
      end
    end
end

function zoomslider_init(invert)
    % silly hack to fire on first open for sane zoom
    if nargin<1, invert=0; end

    axisdata=get(gcf,'UserData');
    axes(gca);
    range=axisdata(2)-axisdata(1);
    
    RegionSlider=findobj('Tag','RegionSlider');
    curpos=get(RegionSlider,'value');
    if length(curpos)>1; curpos = curpos{1}; end
    
    ZoomSlider=findobj('Tag','ZoomSlider');
    zslideval = get(ZoomSlider,'value');
    if length(zslideval)>1; zslideval = zslideval{1}; end
    
    curzoom=max(zslideval,.001);
    middle=1+curpos.*(range-1);
    %lbd=max(1,middle-(range./2)*curzoom);
    lbd=middle-(range./2)*curzoom;
    ubd=lbd+range.*curzoom;
    %ubd=min(size(data,2),lbd+range.*curzoom);
    set(gca,'xlim',[lbd ubd]);
    axis([lbd ubd axisdata(3) axisdata(4)]);
    if invert
      view(0,270);
    end
end
