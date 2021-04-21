    function plotPsd(P)
    %(aH,F,Psd,VLF,LF,HF,limX,limY,flagVLF,flagLS)
    % plotPsd: plots Psd in the given axis handle
    %
    % Inputs:
    %   aH: axis handle to use for plotting
    %   T,F,Psd: time, freq, and Psd arrays
    %   VLF, LF, HF: VLF, LF, HF freq bands
    %   limX, limY:
    %   flagVLF: (true/false) determines if VLF is area is shaded
    %   flagLS: set to (true) if ploting normalized Psd from LS   
    
    F = 
            
        if nargin<10; flagLS=false; end
        if nargin<9; flagVLF=true; end                
        if isempty(flagVLF); flagVLF=true; end
        if isempty(flagLS); flagLS=false; end
        
        cla(aH)
        if ~flagLS %LS Psd untis are normalized...don't covert
            Psd=Psd./(1000^2); %convert to s^2/hz or s^2
        end       
        
        % find the indexes corresponding to the VLF, LF, and HF bands
        iVLF= find( (F>=VLF(1)) & (F<VLF(2)) );
        iLF = find( (F>=LF(1)) & (F<LF(2)) );
        iHF = find( (F>=HF(1)) & (F<HF(2)) );
        
        %shade areas under Psd curve
        area(aH,F(:),Psd(:),'FaceColor',[.8 .8 .8]); %shade everything grey       
        hold(aH,'on');
        if flagVLF %shade vlf
            area(aH,F(iVLF(1):iVLF(end)+1),Psd(iVLF(1):iVLF(end)+1),...
                'FaceColor',color.vlf);
        end
        %shade lf
        area(aH,F(iLF(1):iLF(end)+1),Psd(iLF(1):iLF(end)+1), ...
            'FaceColor',color.lf);
        %shade hf
        if (iHF(end)+1)>size(Psd,1)
            area(aH,F(iHF(1):iHF(end)),Psd(iHF(1):iHF(end)),...
                'FaceColor',color.hf);         
            %patch([F(iVLF(1)),F(iVLF),F(iVLF(end))],...
            %[0,abs(Psd(iVLF)),0],[0 0 .8])   
        else
            area(aH,F(iHF(1):iHF(end)+1),Psd(iHF(1):iHF(end)+1),...
                'FaceColor',color.hf);
        end
        hold(aH,'off');
        
        limX=[0 (HF(end)*1.1)];
        %set axes limits
        if ~isempty(limX)
            set(aH,'xlim',[limX(1) limX(2)]);
        else
            dx=(max(F)-min(F))*0.01;
            set(aH,'xlim',[0 max(F)+dx]);
        end
        if ~isempty(limY)
            set(aH,'ylim',[limY(1) limY(2)]);
        else
            if max(Psd)~= 0
                dy=(max(Psd)-min(Psd))*0.01;
                set(aH,'ylim',[0 max(Psd)+dy]);
            end
        end
        
        %set event to copy fig on dblclick
         set(aH,'ButtonDownFcn',@copyAxes);
    end   