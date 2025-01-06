%%% load every map: plot location of group types on correct orientation...
%%% compare maps....
%%% NOTE: 
%%% (1) "Left" ganglion as default for location as majority were left ganglion, so all "right" recordings are flipped
%%% (2) As most recordings were done with "Rostral" to the left, recordings
%%% are rotated onto this orientation to minimise distortion of maps
%%% So: flip up-down to account for map-output issue; rotate to have rostral on left, then flip along medio-lateral axis
%%% if "right" (i.e. flip up-down)

%%% This analysis needs doing with SPARSE Vornoi maps - to show few
%%% ensembles in sector II. 

%%% The grid-locations need re-mapping to account for non-uniform offsets
%%% in diode axes from their limits

clear all; close all

% desktop
analysispath = 'C:\Users\mqbssmhg.DS\Dropbox\paper\'; 
mappath = 'C:\Users\mqbssmhg.DS\Dropbox\paper\map data\';

% laptop
% analysispath = 'C:\Users\Mark\Documents\My Dropbox\paper\';
% mappath = 'C:\Users\Mark\Documents\My Dropbox\paper\map data\';

% load ensemble analysis data
load([analysispath 'Ensemble_Firing_Functions_DataSet_ConsensusClustering_Revised']);
load([analysispath 'Analyses_of_Ensemble_Types_DataSet_ConsensusClustering_Revised']);
load([analysispath 'Analyses_Neurons_DataSet_ConsensusClustering_Revised'],'groupdata'); 

% load template
load([analysispath 'diode_template.mat']);
[nSide xxx] = size(diode_template);  % use nSide for all axis flipping
gstep = 1 / round(nSide/50);  % grid step: 50 is size of diode array - fixed value

% load orientations of all recordings
load([analysispath 'OrientationTable.mat']);

% list of recording data
load([analysispath 'DataSet_ConsensusClustering_Revised'],'FileTable','DataTable');

% list of map data
tmp = dir(mappath);
mapfiles = tmp(3:end);  % ditch folder return entries

nMaps = numel(mapfiles);
if nMaps ~= numel(FileTable) error('Mismatch between map and activity data-sets'); end

nRecordings = numel(FileTable);


% common parameters for exporting figures
format = 'png'; %'tiffn' for submission
color = 'rgb';
dpi = 600;
fontsize = 7;
linewidth = 1;


%%%% ADD OPTION TO MANUALLY OMIT MAPS: not all recordings are useful for
%%%% this combination on common co-ordinates!!

% master maps
[rs,cs] = size(diode_template);
SpikeMap = zeros(rs,cs,nMaps);  % for each square, keep its record of types...
OscMap = zeros(rs,cs,nMaps);  % for each square, keep its record of types...
OscSpreadMap = zeros(rs,cs); % keep count of any occurrence of dispersed oscillators
SpikeMapLargest = zeros(rs,cs,nMaps);  % for each square, keep its record of types...
OscMapLargest = zeros(rs,cs,nMaps);  % for each square, keep its record of types...

D_theta = 0.5; % threshold for counting only largest patch
PL_theta = 0.5; % threshold for counting "strong phase-locking"

%% loop over recordings: load maps...
TypesDensityTable = []; 

for iM = 1:nMaps  % PLOTTING maps per recording
    %% load map and get types
    load([mappath mapfiles(iM).name]);
    
    % correct reversed y-axis [remove if fixed at source]
    VG = flipud(VG); 
    VGsparse = flipud(VGsparse);
    y = 50 - y;  % 50 is fixed by diode array spacing 
    % end reversed y-axis

    % work out which Dataset ID this map is...  (why? because not all maps are used)
     for iD = 1:numel(FileTable)
        k = strfind(FileTable{iD},mapfiles(iM).name(1:7));
        if ~isempty(k)  % then matches, so recording file ID is now given by iD
            break
        end
    end
    
    recording_index_of_map(iM) = iD;  % store the mapping between map-file order and data-file order

    % diagnose maps by their discreteness overall - if poor, then something
    % amiss...
    medDensity(iM) = mean([Gproperties.Dindex]);    

    % IDs of this recording in groupdata structure
    ixGrps = find([groupdata(:).Recording] == iD);

    % group types: index of 0 indicates not retained...
    osctypes = zeros(numel(ixGrps),1); spiketypes = zeros(numel(ixGrps),1);
    changetypes = zeros(numel(ixGrps),1); alltypes = zeros(numel(ixGrps),1); Dretained = zeros(numel(ixGrps),1);
    for iG = 1:numel(ixGrps)
        if any(ixGrps(iG) == ixRetain)
            osctypes(iG) = grpType.Oscillations.grps(ixGrps(iG),2);
            spiketypes(iG) = grpType.Spikes.grps(ixGrps(iG),2);
            changetypes(iG) = grpType.Change.grps(ixGrps(iG),2);
            alltypes(iG) = grpType.All.grps(ixGrps(iG),2);
            Dretained(iG) =  Gproperties(iG).Dindex;
        end
    end
    
    % store types and density of each type...
    TypesDensityTable = [TypesDensityTable; Dretained spiketypes osctypes changetypes alltypes];


    %% plot each set of types on map as: (a) ensemble patches; (b) neuron locations only

    %% (1) spike types: every patch, and only largest patch
    tempVG = zeros(size(VG));
    tempVGlargest = zeros(size(VG));
    
    nSpkTypes = numel(unique(spiketypes));
    
    % map of spike-types
    for iG = 1:numel(ixGrps)
        tempVG(VG == iG) = spiketypes(iG);
        % restrict to largest patch for each group
        % loop over each group, and apply spiketypes index only to its
        % largest patch...
        if Gproperties(iG).Dindex > D_theta
            ixbgst = find(Gproperties(iG).N_in_patch == max(Gproperties(iG).N_in_patch));
            % deal with y-axis flip
            tempVGlargest(sub2ind(size(VG),nSide - Gproperties(iG).patches{ixbgst}(:,2),Gproperties(iG).patches{ixbgst}(:,1))) = spiketypes(iG);
        else
            tempVGlargest(VG == iG) = 0;  % otherwise ignore group - plot only localised groups
        end
    end
    tempVGlargest(VG==0) = -1; % diode border

    % rotate so that rostral is left: note "reversed" rotation to deal with
    % y-axis flip.
    tempVG = imrotate(tempVG,-90 - OrientationTable(iD).RostralDegreesFromNorth);
    tempVGlargest = imrotate(tempVGlargest,-90 - OrientationTable(iD).RostralDegreesFromNorth);
    
    if findstr(OrientationTable(iD).Side,'Right')
        % Once rotated, then flip map up-down along medio-lateral axis, so that it matches left-ganglion
        % orientation
        tempVG = flipud(tempVG);
        tempVGlargest = flipud(tempVGlargest);
    end
%     figure
%     hVG = imagesc(tempVG); colormap(hot); set(get(hVG,'Parent'),'YDir','normal');
%     figure
%     hVG = imagesc(tempVGrot); colormap(hot); set(get(hVG,'Parent'),'YDir','normal');
%
%     text(50,475,'Medial','FontSize',9,'Color',[1 1 1])
%     text(10,125,'Rostral','FontSize',9,'Color',[1 1 1],'Rotation',90)  % set this according to recording side...
%     title([FileTable{iD} ': spike types'])

    % add to master spike map
    ixs = find(tempVG > 0 & diode_template > 0);
    mmap = zeros(size(diode_template)); mmap(ixs) = tempVG(ixs); % ridiculous memory-hungry approach to get around Matlab's lack of mixed subscript+linear indexing
    SpikeMap(:,:,iM) = mmap;
 
    ixs = find(tempVGlargest > 0 & diode_template > 0);
    mmap = zeros(size(diode_template)); mmap(ixs) = tempVGlargest(ixs); % ridiculous memory-hungry approach to get around Matlab's lack of mixed subscript+linear indexing
    SpikeMapLargest(:,:,iM) = mmap;

    %% (2) Osc types 
    tempVG = zeros(size(VG));
    tempVGspread = zeros(size(VG));
    tempVGlargest = zeros(size(VG));
    
    nOscTypes = numel(unique(osctypes));
    
    % map all oscillation types
    for iG = 1:numel(ixGrps)
        tempVG(VG == iG) = osctypes(iG);
        % map only largest patch, if group is discrete
        if Gproperties(iG).Dindex > D_theta
            ixbgst = find(Gproperties(iG).N_in_patch == max(Gproperties(iG).N_in_patch));
            % deal with y-axis flip
            tempVGlargest(sub2ind(size(VG),nSide - Gproperties(iG).patches{ixbgst}(:,2),Gproperties(iG).patches{ixbgst}(:,1))) = osctypes(iG);
        else
            tempVGlargest(VG == iG) = 0;  % otherwise ignore group - plot only localised groups
        end

        % also map specific combinations: dispersed phasic oscillators
        PLs = ensembleRate{iD}.PhaseLocking(:,iG); PLs(PLs == 0) = [];
        thisDispersed =  zeros(size(VG));
        if osctypes(iG) == 2 & Gproperties(iG).Dindex <= D_theta & mean(PLs) > PL_theta
            tempVGspread(VG == iG) = 1; % ID all squares in this recording
            % store the IDed ensembles for individual plotting...
%             thisDispersed(diode_template == 0) = -1;
%             thisDispersed(VG==iG) = 1; % new map per detected dispersed oscillator
%             % rotate so that rostal is left and flip to left-hand side
%             thisDispersed = imrotate(thisDispersed,-90 - OrientationTable(iD).RostralDegreesFromNorth);
%             if findstr(OrientationTable(iD).Side,'Right')  thisDispersed = flipud(thisDispersed); end
%             % plot dispersed oscillators:
%               
%             figure
%             hVG = imagesc(thisDispersed); colormap(hot) 
%             title([FileTable{iD} ': dispersed oscillator'])
        end
    end
    
    
    % rotate so that rostral is left
    tempVG = imrotate(tempVG,-90 - OrientationTable(iD).RostralDegreesFromNorth);
    tempVGspread = imrotate(tempVGspread,-90 - OrientationTable(iD).RostralDegreesFromNorth);
    tempVGlargest = imrotate(tempVGlargest,-90 - OrientationTable(iD).RostralDegreesFromNorth);
   
    if findstr(OrientationTable(iD).Side,'Right')
        % then flip map along medial-lateral, so that it matches left-ganglion
        % orientation
        tempVG = flipud(tempVG);
        tempVGspread = flipud(tempVGspread); tempVGlargest = flipud(tempVGlargest);
    end
    
%     % plot dispersed oscillators
%     figure
%     hVG = imagesc(tempVG); colormap(hot)
%     text(50,475,'Medial','FontSize',9,'Color',[1 1 1])
%     text(10,125,'Rostral','FontSize',9,'Color',[1 1 1],'Rotation',90)  % set this according to recording side...
%     title([FileTable{iD} ': osc types'])

    % add to master osc map
    ixs = find(tempVG > 0 & diode_template > 0);
    mmap = zeros(size(diode_template)); mmap(ixs) = tempVG(ixs); % ridiculous memory-hungry approach to get around Matlab's lack of mixed subscript+linear indexing
    OscMap(:,:,iM) = mmap;

    ixs = find(tempVGlargest > 0 & diode_template > 0);
    mmap = zeros(size(diode_template)); mmap(ixs) = tempVGlargest(ixs); % ridiculous memory-hungry approach to get around Matlab's lack of mixed subscript+linear indexing
    OscMapLargest(:,:,iM) = mmap;

    OscSpreadMap = OscSpreadMap + tempVGspread;  % running total
    
    %% (3) Change types: need to strongly define these

end

% AFTER THIS POINT: all maps should be pointing rostral = left, and flipped
% to be on left-hand side orientation. So 

%% MASTER MAPS: dominant type in each location

nSpkTypes = numel(unique(TypesDensityTable(:,2)));

for iT = 1:nSpkTypes
    pSpkTypes(iT) = sum(TypesDensityTable(:,2) == iT) ./ length(TypesDensityTable);
end

normSpkType = sum(SpikeMap > 0,3);  % as some squares are off-diode, 
MasterSpkTypeVG = zeros(size(VG)); 

for iR = 1:rs
    for iC = 1:cs
        if VG(iR,iC) > 0   % 0 for off-diode; -1 for on-diode but unclaimed
            % have to include "0" in the histogram, or gets folded into Type 1...
            ftypes = hist(squeeze(SpikeMap(iR,iC,:)),0:nSpkTypes);  % number of occurrences of each type
            Wtypes = ftypes(2:end) .* (1-pSpkTypes);  % weighted by rareness of each type
            IDtype = find(Wtypes == max(Wtypes)); % not working: almost all are tied
            % IDtype = find(ftypes == max(ftypes));
            if numel(IDtype) == 1
                MasterSpkTypeVG(iR,iC) = IDtype;
            else
                MasterSpkTypeVG(iR,iC) = 0;  % for now just leave blank...
            end
            % keyboard
        end
    end
end
MasterSpkTypeVG(diode_template == 0) = -1;
MasterSpkTypeVG = imrotate(MasterSpkTypeVG,90);  % rostral to north (reversed rotation due to flip of y-axis

pTypes = unique(MasterSpkTypeVG);
nClrs = numel(pTypes);
clrmap = [0 0 0; jet(nClrs-1)];  % off-diode is black, no entries is white

figure
hVG = imagesc(MasterSpkTypeVG); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
%title('Master Spike Type Map')
hc = colorbar
set(hc,'YLim',[0 8])
set(hc,'YTick',(1:nSpkTypes) - 0.5)
set(hc,'YTickLabel',{'Bimodal, both','Unimodal CV_2','Unimodal ISI','Bimodal, both','Noise','Uniform CV_2','Unimodal ISI','Noise'})
axis off
set(gca,'FontName','Helvetica','FontSize',8);
set(gca,'Box','off','TickDir','out','LineWidth',1);

save Atlases MasterSpkTypeVG nSpkTypes pSpkTypes 

%% MASTER MAPS: oscillation types

nOscTypes = numel(unique(TypesDensityTable(:,3)));

for iT = 1:nOscTypes
    pOscTypes(iT) = sum(TypesDensityTable(:,3) == iT) ./ length(TypesDensityTable);
end

normOscType = sum(OscMap > 0,3);  % as some squares are off-diode, 
MasterOscTypeVG = zeros(size(VG)); 

for iR = 1:rs
    for iC = 1:cs
        if VG(iR,iC) > 0   % ) for off-diode; -1 for on-diode but unclaimed
            ftypes = hist(squeeze(OscMap(iR,iC,:)),0:nOscTypes);  % number of occurrences of each type
            Wtypes = ftypes(2:end) .* (1-pOscTypes);  % weighted by rareness of each type
            IDtype = find(Wtypes == max(Wtypes));
            if numel(IDtype) == 1
                MasterOscTypeVG(iR,iC) = IDtype;
            else
                MasterOscTypeVG(iR,iC) = 0;  % for now just leave blank...
            end
            % keyboard
        end
    end
end
MasterOscTypeVG(diode_template == 0) = -1;
MasterOscTypeVG = imrotate(MasterOscTypeVG,90);  % rostral to north

pTypes = unique(MasterOscTypeVG);
nClrs = numel(pTypes);
clrmap = [0 0 0; 1 1 1; jet(nClrs-2)];  % off-diode is black, no entries is white

figure
hVG = imagesc(MasterOscTypeVG); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
title('Master Oscillation Type Map')
colorbar
axis off

save Atlases MasterOscTypeVG nOscTypes pOscTypes -append


%% global maps: Spikes, per chosen sub-set of spike types

% TO FIX: should normalise by number of recordings which captured this
% spike-type!!

normSpkType = sum(SpikeMap > 0,3);  % as some squares are off-diode, 
                                    % normalise by number of times this
                                    % square appeared in combined maps  
                                    
mask = normSpkType == nMaps;  % look only at common area 

% typeIDs = [1,2,8];  spkfilename = 'BimodalBoth'; % bimodal both ISI and CV2
% typeIDs = [4,9];  spkfilename = 'UniModalISI'; % unimodal ISI
typeIDs = 7;    spkfilename = 'UniformCV2'    % uniform CV2

typeIDs = 9; N =  sum(TypesDensityTable(:,2) == typeIDs); spkfilename = ['Type_' num2str(typeIDs) '_N=' num2str(N)];

spkTypeVG = zeros(size(VG)); spkTypeVGLargest = zeros(size(VG));
for iType = 1:numel(typeIDs)
    spkTypeVG = spkTypeVG + sum(SpikeMap == typeIDs(iType),3);
    spkTypeVGLargest = spkTypeVGLargest + sum(SpikeMapLargest == typeIDs(iType),3); 
end
spkTypeVG = spkTypeVG ./ normSpkType; spkTypeVGLargest = spkTypeVGLargest ./ normSpkType; 

spkTypeVG(diode_template == 0) = -1; spkTypeVGLargest(diode_template == 0) = -1;

spkTypeVG = imrotate(spkTypeVG,90);  % rostral to north
spkTypeVGLargest = imrotate(spkTypeVGLargest,90);  % rostral to north

% create mask for grid squares only in all recordings...
mask = imrotate(mask,90);  % rostral to north
spkMask = zeros(size(VG));
spkMask(mask) = spkTypeVG(mask);

% generate suitable colormaps: black for off-diode; smooth colour for all
% else...
pTypes = unique(spkTypeVG);
nClrs = numel(pTypes);
clrmap = [];
if any(pTypes == -1) clrmap = [clrmap; 0 0 0]; end % off-diode is black
if any(pTypes == 0) clrmap = [clrmap; 1 1 1]; end  % no entries is white
nHere = nClrs - any(pTypes==-1) - any(pTypes==0);  % number of types present
clrmap = [clrmap; jet(nHere)];  
for iC = nClrs:-1:1
    spkTypeVG(spkTypeVG == pTypes(iC)) = iC; % remap to indexing
end

figure
hVG = image(spkTypeVG); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
title(['Spike Type:' num2str(typeIDs)])
hc = colorbar
set(hc,'YLim',[2 nClrs]+0.5)
set(hc,'YTick',-(nHere-nClrs)+1:nClrs)
set(hc,'YTickLabel',round(pTypes(-(nHere-nClrs)+1:end)*100))
axis off

save(['Atlas_Spikes_' spkfilename],'spkTypeVG','pTypes','clrmap')
exportfig(gcf,['Atlas_Spikes_' spkfilename],'Color',color,'Format',format,'Resolution',dpi)


% and for largest-patch only
pTypes = unique(spkTypeVGLargest);
nClrs = numel(pTypes);
clrmap = [];
if any(pTypes == -1) clrmap = [clrmap; 0 0 0]; end % off-diode is black
if any(pTypes == 0) clrmap = [clrmap; 1 1 1]; end  % no entries is white
nHere = nClrs - any(pTypes==-1) - any(pTypes==0);  % number of types present
clrmap = [clrmap; jet(nHere)];  
for iC = nClrs:-1:1
    spkTypeVGLargest(spkTypeVGLargest == pTypes(iC)) = iC; % remap to indexing
end
figure
hVG = image(spkTypeVGLargest); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
title(['Spike Type:' num2str(typeIDs) ' (Discrete patch only)'])
axis off

% with mask on...
pTypes = unique(spkMask);
nClrs = numel(pTypes);
clrmap = [];
if any(pTypes == -1) clrmap = [clrmap; 0 0 0]; end % off-diode is black
if any(pTypes == 0) clrmap = [clrmap; 1 1 1]; end  % no entries is white
nHere = nClrs - any(pTypes==-1) - any(pTypes==0);  % number of types present
clrmap = [clrmap; jet(nHere)];  
for iC = nClrs:-1:1
    spkMask(spkMask == pTypes(iC)) = iC; % remap to indexing
end

figure
hVG = image(spkMask); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
% title(['Spike Type:' num2str(typeIDs)])
hc = colorbar
set(hc,'YLim',[2 nClrs]+0.5)
set(hc,'YTick',[3:nClrs])
set(hc,'YTickLabel',round(pTypes(3:end)*100))
axis off


%% global maps: Oscs
normOscType = sum(OscMap > 0,3);  % as some squares are off-diode, 
                                    % normalise by number of times this
                                    % square appeared in combined maps

% typeID = 1; oscfilename = 'Tonic'; % tonic                                    
% typeID = 2; oscfilename = 'Oscillators'; % % Oscillators (peaks and troughs)
% typeID = 3; oscfilename = 'Bursters'; % % Bursters (peak, no trough) 
typeID = 4; oscfilename = 'Pausers'; %% pausers (troughs no peaks)

oscTypeVG = sum(OscMap == typeID,3) ./ normOscType ;
oscTypeVGLargest = sum(OscMapLargest == typeID,3) ./ normOscType ;

oscTypeVG(diode_template == 0) = -1;
oscTypeVGLargest(diode_template == 0) = -1;

oscTypeVG = imrotate(oscTypeVG,90);  % rostral to north
oscTypeVGLargest = imrotate(oscTypeVGLargest,90);  % rostral to north

pTypes = unique(oscTypeVG);
nClrs = numel(pTypes);
clrmap = [];
if any(pTypes == -1) clrmap = [clrmap; 0 0 0]; end % off-diode is black
if any(pTypes == 0) clrmap = [clrmap; 1 1 1]; end  % no entries is white
nHere = nClrs - any(pTypes==-1) - any(pTypes==0);  % number of types present
clrmap = [clrmap; jet(nHere)];  
for iC = nClrs:-1:1
    oscTypeVG(oscTypeVG == pTypes(iC)) = iC; % remap to indexing
end

figure
hVG = imagesc(oscTypeVG); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270) 
title(['Oscillation Type:' num2str(typeID)])
hc = colorbar
set(hc,'YLim',[2 nClrs]+0.5)
set(hc,'YTick',-(nHere-nClrs)+1:nClrs)
set(hc,'YTickLabel',round(pTypes(-(nHere-nClrs)+1:end)*100))
axis off

save(['Atlas_Oscs_' oscfilename],'oscTypeVG','pTypes','clrmap')


% and for largest-patch only
pTypes = unique(oscTypeVGLargest);
nClrs = numel(pTypes);
clrmap = [];
if any(pTypes == -1) clrmap = [clrmap; 0 0 0]; end % off-diode is black
if any(pTypes == 0) clrmap = [clrmap; 1 1 1]; end  % no entries is white
nHere = nClrs - any(pTypes==-1) - any(pTypes==0);  % number of types present
clrmap = [clrmap; jet(nHere)];  
for iC = nClrs:-1:1
    oscTypeVGLargest(oscTypeVGLargest == pTypes(iC)) = iC; % remap to indexing
end
figure
hVG = image(oscTypeVGLargest); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
title(['Oscillation Type:' num2str(typeID) ' (Discrete patch only)'])
axis off
%% global maps: dispersed oscillators
normOscType = sum(OscMap > 0,3);  % as some squares are off-diode, 

oscSpreadVG = OscSpreadMap ./ normOscType;  % normalise occurrence...
oscSpreadVG(diode_template == 0) = -1;

oscSpreadVG = imrotate(oscSpreadVG,90);  % rostral to north

pSpreads = unique(oscSpreadVG);
nClrs = numel(pSpreads);
clrmap = [];
if any(pSpreads == -1) clrmap = [clrmap; 0 0 0]; end % off-diode is black
if any(pSpreads == 0) clrmap = [clrmap; 1 1 1]; end  % no entries is white
nHere = nClrs - any(pSpreads==-1) - any(pSpreads==0);  % number of types present
clrmap = [clrmap; jet(nHere)];  
% for iC = nClrs:-1:1
%     oscSpreadVG(oscSpreadVG == pSpreads(iC)) = iC; % remap to indexing
% end

figure
hVG = imagesc(oscSpreadVG); colormap(clrmap); set(get(hVG,'Parent'),'YDir','normal');
text(10,475,'Rostral','FontSize',9,'Color',[1 1 1])
text(490,75,'Medial','FontSize',9,'Color',[1 1 1],'Rotation',270)  % set this according to recording side...
title('Oscillation: Dispersed Phasic')
colorbar
axis off

%% ANALYSE TYPE vs DENSITY relationships...

TypesDensityTable(TypesDensityTable(:,2) == 7,:)

