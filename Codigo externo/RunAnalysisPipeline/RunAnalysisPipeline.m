%%% top-level script to run analysis pipeline
% each script can be run independently, given the necessary data

close all; clear all

% explicitly included here for ease of use: add these to your MATLAB path 
addpath Functions\
addpath ConsensusComunityDetectionToolbox\

% scripts expect:
% (i) Data files for spike-times and positions for each recording to be
% stored in a struct called DataList. 
% (ii) within the spike-times file will be a variable "spks" containing a
% two-column array of: [neuronID time]  listing all spikes per neuron in
% the recording
% (iii) within the position file will be "x" and "y" vectors containing
% the x,y position of each neuron. Here we specify neuron positions in
% "diode spacing" units, and plot them onto the diode-array template.
%
% Check all data-files in the "TestData" directory for clarification

% path to folder with data-files
datapath = 'TestData'; 

load([datapath '\DataList']);  % list of all data-sets: struct with fields for spike-timing file and neuron position file
nfiles = size(DataList,2);


%% Analysis pipeline: Figure 1 of paper
% Step 1: consensus community detection - modular deconstruction of each
% functional network
% Plots: ensemble structure of whole recording, one per recording
%Consensus_Cluster_DataSet

% Step 2: statistically characterise spike-trains at neuron and ensemble
% level
%Analyse_Spike_Train_Properties

% Step 3: fit-space: group ensembles by their spike-train statistics
%Types_of_Ensemble_Across_Dataset

% Step I: map ensembles to physical location
% Plots: Voronoi diagrams for neuron and ensemble locations, one each per
% recording
Map_topology_using_Voronoi

% Step II: build atlases
% Plots: atlas for selected ensemble-type
MakeAtlas

%% PCA decompositions
PCA_analyse_Types

%% Supplementary analyses

% A: hierarchy of each functional network
Batch_hierarchy

% B: fit-space: types of neurons in dataset
Types_of_Neurons_Across_Dataset


%% visualising the results - an example: plotting the raster and the ISI and CV2
%% distributions for every ensemble of a particular type

load Analyses_of_Ensemble_Types	Ccon dataset_spikes
load Analyses_Neurons_and_Ensembles groupdata GroupList

typeID = 1;  % which ensemble-type to look at

ixType = find(Ccon.Spikes == typeID);  % all ensembles of this type in the database


% plot every ensemble of this type in data-set as "tick-plot" raster
for iT = 1:numel(ixType)
    ixR = groupdata(ixType(iT)).Recording;   % ID of dataset with this ensemble
    ixNeurons = groupdata(ixType(iT)).IDs;  % IDs of neurons in the current ensemble
    
    load([datapath '\' DataList(ixR).spikes]);  % load spike-trains of this recording
    T = [0 80];  
    
    % for each neuron, pool its properties at ensemble level
    allisis = []; allcv2s = [];
    grpts = []; ctr = 1;
    figure
    for iN = 1:numel(ixNeurons)
        ixAllNeurons = find([neurondata(:).Recording] == ixR & [neurondata(:).ID] == ixNeurons(iN));
        allisis = [allisis; neurondata(ixAllNeurons).isis];
        allcv2s = [allcv2s; neurondata(ixAllNeurons).cv2s];
        currix = find(spks(:,1) == ixNeurons(iN));  % get spikes of this neuron
        ts = spks(currix,2); % spike-times of this train
        ts = ts(ts >= T(1) & ts <= T(2)); % within the analysed period
        
        % plot each spike-train as ticks
        for iSpk = 1:numel(ts-1)
            line([ts(iSpk) ts(iSpk)],[ctr-1 ctr],'Color',[0 0 0],'Linewidth',0.25)
        end
        
        grpts = [grpts; ctr * ones(numel(ts),1) ts];  % make array of spikes
        ctr = ctr + 1;
        
    end
    title(['Ensemble-type: ' num2str(typeID) '; ensemble #' num2str(ixType(iT))])
    
    cens_cv2 = allcv2s; cens_cv2(allcv2s < 1e-6) = []; % remove any rare errors
    figure
    subplot(211),hist(allisis,50); xlabel('ISI (s)'); ylabel('Frequency')
    title(['Ensemble-type: ' num2str(typeID) '; ensemble #' num2str(ixType(iT))])

    subplot(212),hist(cens_cv2,50); xlabel('CV_2'); ylabel('Frequency')
      
end










