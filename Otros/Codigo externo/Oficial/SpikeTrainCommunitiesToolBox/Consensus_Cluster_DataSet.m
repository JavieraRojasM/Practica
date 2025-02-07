%%% cluster each recording in data-set
% this script expects that data-files always contain variable "spks"
% rename "spks" to the array name used for your spike-trains
%
% Key outputs:
% Gcon_dataset: a cell array, each cell containing the consensus community detection clustering for that
%               data-file of spike-trains (format: [TrainID, group#])
% Gmax_datatset: a cell array, each cell containing the community detection clustering maximising
%                modularity (Q) for that data-file of spike-trains (format: [TrainID, group#])
% Sxy_dataset: a cell array, each cell containing the similarity matrix for that data-file of spike-trains
% spkfcn_dataset: a cell array, each cell containing the set of convolved
%                 spike-trains (one spike-train per column; time in rows; time-steps set
%                 according to the quantisation value Qt - typically 1 ms)
% DataTable: a summary table of properties for the dataset, one row per
%            data-file
%
% Mark Humphries 31/10/2014
clear all; close all

datapath = 'TestData_uno\';

save_fname = ['DataSet_ConsensusClustering_TEST_OF'];  % save-file for clustering results

% analysis parameters
% proportional region of recording
startts = 0;    % proportion of time from start of recording to begin analysis [0=first spike]
endts = 1;      % proportion of time from end of recording to end analysis [1 = final spike]

% cluster analysis function arguments
binlessopts.Dmeth = 'corrcoef';
binlessopts.BLmeth = 'Gaussian';
binlessopts.modopts = {{'sqEuclidean'},100};  % use 100 repetitions of k-means with Euclidean distance as basis for consensus
binlessopts.BLpars = 1; % width of convolution window, in seconds (here SD of Gaussian)

Qt = 0.01; % (seconds) time-resolution for convolution window : here 10 ms

load([datapath 'DataList.mat'])  % load list of data file names
nfiles = numel(DataList); 

%% load data-set one at a time and cluster

Dctr = 0; DataTable = []; Cxy_spread_dataset = {}; stateDt_dataset = {};

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the count and vectors
file_count = 0;

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));
    fprintf('Inside %s\n', string(folder(f).name));
    % Iterate over the files inside the subfolder
    for loop = 1:length(file)
        % File path
        file_path = fullfile(folder_path, file(loop).name);

        % Folder and file name
        name = string(folder(f).name) + ", " + string(file(loop).name);
        newname = erase(name, ".mat");
        fprintf('Analyzing %s\n', string(file(loop).name));

        % Load the file
        data = load(file_path);
        spks = data.spks;
        data_maxtime = data.file_length;

    %for loop = 1:nfiles    
        Dctr = Dctr + 1 % number of recordings in data-set
        
    
        %load([datapath '\' DataList(loop).spikes]);  % load data file
        % check that data-file contains spikes
        %if ~exist('spks','var') error(['Data-file ' DataList(loop).spikes ' does not contain spks variable']); end  
    
        % IDs of trains
        allcellIDs = unique(spks(:,1));
        nallIDs = numel(allcellIDs);
    
        T_start_recording = min(spks(:,2));
        T_end_recording = max(spks(:,2));
        T_period = T_end_recording - T_start_recording;
    
        % fix start and end times of data-set to use
        T = [T_start_recording + startts*T_period T_start_recording + endts*T_period]; 
    
        % now restrict spike-times to that range
        thesespks = spks(spks(:,2) >= T(1) & spks(:,2) <= T(2),:);
    
        %%%%%% now cluster %%%%%%%%%%%%%%%%%%%
        [Gmax,Gcon,Sxy,spkfcn] = consensus_cluster_spike_data_binless(newname, thesespks,allcellIDs,T,Qt,binlessopts);


        % plot each in order of intra-group similarity (top-botom = high-low)
        % alternate gray/black colouring for each group
        [newG,Sgrp,Sin,Sout] = sortbysimilarity(Gcon.grps,Sxy{1});
%         ngrps = numel(unique(newG(:,2)));
%         hall = plot_clusters(spks,newG,ngrps,T,'3B');  % plot in alternating grey/black to see all groups
%         title(sprintf('Data-set %s in increasing similarity (bottom-to-top)', newname));
        % title(['Data-set '  newname ' in increasing similarity (bottom-to-top) aa'])
            
        % store everything     
        G_dataset{Dctr} = Gmax; Gcon_dataset{Dctr} = Gcon; Sxy_dataset{Dctr} = Sxy{1}; spkfcn_dataset{Dctr} = spkfcn{1};
        DataTable = [DataTable; nallIDs T binlessopts.BLpars Gmax(1).ngrps Gmax(1).Q Gcon(1).ngrps Gcon(1).Q]; 
        Sgrp_dataset{Dctr} = Sgrp; % store all mean similarities of ensembles    
    end 
end % end files loop

save(save_fname,'binlessopts','G_dataset','Gcon_dataset','Sxy_dataset','Sgrp_dataset','DataTable');
save([save_fname '_spkfcnOF'],'spkfcn_dataset') % separately save convolved spike-train functions as they are massive

clear spkfcn_dataset binlessopts NetworkCxy_dataset Vec_Times G_dataset Gcon_dataset Sxy_dataset DataTable Cxy_spread_dataset stateDt_dataset

