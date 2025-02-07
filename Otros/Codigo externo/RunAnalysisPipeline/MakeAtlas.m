%%% script to build atlas of one type identified by fit-space analysis of
%%% ensembles
%
% Key outputs:
% SpikeMap: a three-dimensional matrix, one two-dimensional (row, column) matrix per recording;  
%           the matrix is a 500x500 grid, each grid square is assigned the 
%           EnsembleTypeID (from the fit-space analysis) of the ensemble at that location 
% spikeTypevG: a matrix describing the functional-physical map for the ensemble-type; 
%              the matrix is a 500x500 grid, each grid square's value is the proportion
%              of times that location contained an ensemble of that type in
%              the data-set.
%
% Mark Humphries 16/6/2014

datapath = 'TestData'; 

% get list of all map files
maplist = dir('*map.mat'); % expects all map files to end in "map"
nMaps = numel(maplist);

% get list of all data-files 
load([datapath '\DataList']);  % list of all data-sets: first column is spike-timing file, second column is neuron position file
nfiles = size(DataList,2);

% get clustering and analysis results
load Dataset_ConsensusClustering Gcon_dataset        % load clusterings of each dataset
load Analyses_Neurons_DataSet_ConsensusClustering groupdata  % load group statistics and IDs
load Analyses_of_Ensemble_Types_DataSet_ConsensusClustering Ccon  % load fit-space results

load([datapath '\diode_template.mat'])    % load diode-template on 500x500 grid  
[nSide xxx] = size(diode_template);  % use nSide for all axis flipping
gstep = 1 / round(nSide/50);  % grid step: 50 is size of diode array - fixed value

% orientations of each recording
load([datapath '\OrientationTableTest.mat'])    

SpikeMap = zeros(nSide,nSide,nMaps);  % for each square, keep its record of types...

%% map rate-regularity types to each location, per-recording
for iM = 1:nMaps
    %% load map and get types
    load([maplist(iM).name]);
    
    % correct reversed y-axis [remove if fixed at source]
    VG = flipud(VG); 
    VGsparse = flipud(VGsparse);
    y = 50 - y;  % 50 is fixed by diode array spacing 
    % end reversed y-axis

    % work out which Dataset ID this map is...
     for iD = 1:numel(DataList)
        k = strfind(DataList(iD).position,maplist(iM).name(1:7));
        if ~isempty(k)  % then matches, so recording file ID is now given by iD
            break
        end
     end
    
    % IDs of this recording in groupdata structure
    ixGrps = find([groupdata(:).Recording] == iD);
    
    % get each rate-regularity type in this recording
    spiketypes = zeros(numel(ixGrps),1);
    for iG = 1:numel(ixGrps)
        spiketypes(iG) = Ccon.Spikes(ixGrps(iG));
    end
    
    % map type-index to each location with a neuron from that ensemble-type
    tempVG = zeros(size(VG));
    for iG = 1:numel(ixGrps)
        tempVG(VG == iG) = spiketypes(iG);
    end
    
    % rotate so that rostral is west (if necessary): this default chosen as
    % most recordings were done with left ganglion, with rostral to the west 
    tempVG = imrotate(tempVG,-90 - OrientationTableTest(iD).RostralDegreesFromNorth);

    if findstr(OrientationTableTest(iD).Side,'Right')
        % Once rotated, then flip map up-down along medio-lateral axis, so that it matches left-ganglion
        % orientation
        tempVG = flipud(tempVG);
    end
    
    % add individual map to master spike map
    ixs = find(tempVG > 0 & diode_template > 0);
    mmap = zeros(size(diode_template)); mmap(ixs) = tempVG(ixs); % ridiculous memory-hungry approach to get around Matlab's lack of mixed subscript+linear indexing
    SpikeMap(:,:,iM) = mmap;

end

%% build final atlas
normSpkType = sum(SpikeMap > 0,3);  % as some squares are off-diode, 
                                    % normalise by number of times this
                                    % square appeared in combined maps  
                                    
typeIDs = 2;  % ID(s) to be mapped - can be array here e.g. [1 3] 
N =  sum(Ccon.Spikes == typeIDs); spkfilename = ['Type_' num2str(typeIDs) '_N=' num2str(N)];

spkTypeVG = zeros(size(VG)); 
for iType = 1:numel(typeIDs)  %
    spkTypeVG = spkTypeVG + sum(SpikeMap == typeIDs(iType),3);
end

% normalise by occurrence
spkTypeVG = spkTypeVG ./ normSpkType; 

% code off-diode as -1
spkTypeVG(diode_template == 0) = -1; 

spkTypeVG = imrotate(spkTypeVG,90);  % rostral to north

% make a color map
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

