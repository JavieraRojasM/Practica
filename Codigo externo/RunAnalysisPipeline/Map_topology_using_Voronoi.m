%%% script to compute cluster density and discreteness using Voronoi diagrams
%
% Each set of outputs is saved per map to a separate file
%
% Key outputs:
% V, Vsparse: matrices defining the Voronoi diagram and sparse version for
%             every neuron. The matrix is a 500x500 grid, each grid square
%             assigned the ID of the closest neuron (or in the sparse map 0 if no neuron is
%             sufficiently close)
% VG, VGsparse: matrices defining the Voronoi diagram and sparse version for
%             every ensemble. The matrix is a 500x500 grid, each grid
%             square assigned the ID of the ensemble to which its closest neuron belongs 
%             (or in the sparse map 0 if no neuron is sufficiently close)
% mapD_index: mean discreteness score for the whole map (map-level discreteness)   
% Gproperties: an array of structs, one per detected ensemble in the data-file, each containing 
%              fields describing physical properties of that ensemble
%              Key fields:
%                   .mClustD: "cohesiveness" - the median distance of each neuron from the physical centre of the ensemble
%                   .pClustD_urn: the probability of finding that median
%                                 distance by chance, over all permutations of ensemble membership
%                   .Dindex: proportion of ensemble's neurons in its
%                           largest contiguous patch of space (ensemble-level discreteness)
%                   .N_in_patch: array, one entry per physical patch belonging to that ensemble, 
%                                each number of neurons in each patch
%                   .ixN_in_patch: cell array, one cell per physical patch belonging to that ensemble,
%                                  each an array of neuron IDs in that patch
%                   .patches: cell array, one cell per physical patch belonging to that ensemble,
%                                  each a 2-column array of grid co-ordinates in that patch 
% permdata: an array of structs, one per permuted map, each containing
%           fields describing the map-level properties of that permuted map
%           Key fields: 
%               .Dindex: array, one entry per ensemble, each entry the
%                       ensemble-level discreteness score for the permuted map
%               .map_Dindex : mean discreteness score for that permuted map
%
% Mark Humphries 16/6/2014
datapath = 'TestData/'
load([datapath '\DataList']);  % list of all data-sets: first column is spike-timing file, second column is neuron position file
nfiles = size(DataList,2);

load Dataset_ConsensusClustering Gcon_dataset        % load clusterings of each dataset

load TestData\diode_template.mat    % load diode-template on 500x500 grid  


nDiode = sum(diode_template(:) == 1); % number of grid squares
[rD,cD] = size(diode_template);
nPermute = 1000; % for approximating p-values for cohesiveness
nPermMaps = 20; % for just getting 95% confidence limit for discreteness of whole map

%% for each data-set: compute (1) cohesiveness and (2) map topography and calculate discreteness
for iR = 1:nfiles
    Gproperties = struct('Gsize',[],'w_x',[],'w_y',[],'mClustD',[],'mIntraClustD',[],'pClustD_location',[],...
                    'pClustD_urn',[],'patches',{},'N_in_patch',[],'ixN_in_patch',{},'patch_x',[],'patch_y',[],'Dindex',[]);

    load([datapath '\' DataList(iR).position])
    
    savefname = [DataList(iR).position '_map'];
    
    G = Gcon_dataset{iR}.grps;
    nG = numel(unique(G(:,2)));
    nN = size(G,1);
    
    %% (1) do cluster density calculations: how physically close are the neuron within an ensemble?
    for iG = 1:nG
        iG
        ixG = find(G(:,2) == iG);  % all neurons in this group
        ixN = G(ixG,1);            % their indices              
        Gproperties(iG).Gsize = numel(ixN);

        % cluster centre
        Gproperties(iG).w_x = mean(x(ixG));
        Gproperties(iG).w_y = mean(y(ixG));

        % cohesiveness / density of cluster in space
        % (1) distance from cluster centre: prefer this one (deals better with
        % elongated shapes)
        clusterD = sqrt((x(ixG) - Gproperties(iG).w_x ).^2 + (y(ixG) - Gproperties(iG).w_y).^2);
        Gproperties(iG).mClustD = median(clusterD);

        % (2) distance from each other
        dvec = [];
        for iN = 1:numel(ixG)
            for iN2 = iN+1:numel(ixG)
                dvec = [dvec; sqrt((x(ixG(iN)) - x(ixG(iN2))).^2 + (y(ixG(iN)) - y(ixG(iN2))).^2)];
            end
        end
        Gproperties(iG).mIntraClustD = median(dvec);


        %%% do controls for distance from centre
        for iP = 1:nPermute
            %%% control#1: distribute same number of neurons uniformly-at-random over the hexagon...
            new_locs = randperm(nDiode);
            new_locs = new_locs(1:numel(ixG));
            [rs,cs] = ind2sub([rD,cD],new_locs);
            xs = rs ./ 10; ys = cs ./ 10;  % diode-template up-sampled by 10 
            pX = mean(xs); yX = mean(ys);   % [x,y] centre of random cluster
            pD = sqrt((xs - pX).^2 + (ys - yX).^2); % distance from centre
            medPD_location(iP) = median(pD);         % median distance

            % control#2 take all actual neuron locations, and distribute at random into groups (urn model)
            new_neurons = randperm(nN);
            new_neurons = new_neurons(1:numel(ixG));
            pX = mean(x(new_neurons)); pY = mean(y(new_neurons));  % centre of randomly chosen group
            pD = sqrt((x(new_neurons) - pX).^2 + (y(new_neurons) - yX).^2); % distance from centre
            medPD_urn(iP) = median(pD);         % median distance from centre

        end

        Gproperties(iG).pClustD_location = sum(medPD_location < Gproperties(iG).mClustD) ./ nPermute; % p that random distribution more clustered than current cluster
        Gproperties(iG).pClustD_urn = sum(medPD_urn < Gproperties(iG).mClustD) ./ nPermute; % p that random distribution more clustered than current cluster

    end


    %% (2) Cluster discreteness in space: Voronoi diagrams

    % get Voronoi diagram on grid: assign each grid-square to 1 neuron
    [V,C] = Voronoi_grid([y' x'],diode_template,0.1); % [y x] in matrix space these are [row,col]...
    [Vsparse,Csparse] = Voronoi_grid([y' x'],diode_template,0.1,'s'); % sparse Voronoi map, for display purposes...


    V(V==0) = -1;  % set off-diode grid squares to some other number
    figure; 
    imagesc(Vsparse); hold on
    title('Voronoi diagram for each neuron')
    plot(x/0.1,y/0.1,'k.')
    % set(gca,'YDir','normal')  % plot so that (0,0) in bottom left-hand corner

    % assign patches to groups; 
    VG = V; VGsparse = Vsparse;
    p_in_patch = zeros(nN,1);
    for iN = 1:nN
        ixPatch = find(V == iN);  % find all grid squares assigned to this neuron
        ixPatchSparse = find(Vsparse == iN);

        % build cluster from grids of all cells
        VG(ixPatch) = G(iN,2);   % assign these neuron's group to all those squares
        VGsparse(ixPatchSparse) = G(iN,2); % as above, but for sparse version 

    end
    
    tempVG = VG; tempVG(VG == -100) = -1;
    figure
    hVG = imagesc(tempVG); hold on
    title('Voronoi diagram for each ensemble')
    plot(x/0.1,y/0.1,'k.')


    %% compute contiguity of patches

    % find out how many discrete patches exist: do on full Voroni grid to
    % account for discontinuties of map
    tic
    props = find_contiguous_patches(G,VG,C,nG);
    toc
    
    % keyboard
    
    % save properties of patches
    [Gproperties(1:numel(props)).N_in_patch] = props.N_in_patch;
    [Gproperties(1:numel(props)).patches] = props.patches;
    [Gproperties(1:numel(props)).ixN_in_patch] = props.ixN_in_patch;


    %% compute discreteness metric: number of patches weighted by number of neurons in those patches...
    for iG = 1:nG
        bgst(iG) = max(Gproperties(iG).N_in_patch);   % largest patch size
        ixbgst = find(Gproperties(iG).N_in_patch == bgst(iG)); % its index

        % (1) centre of that patch (x,y)
        ixN_in_bgst = Gproperties(iG).ixN_in_patch{ixbgst};
        xs = []; ys = [];
        for iN = 1:numel(ixN_in_bgst)
            ix = find(ixN_in_bgst(iN) == G(:,1));
            xs = [xs; x(ix)];
            ys = [ys; y(ix)];
        end
        Gproperties(iG).patch_x = mean(xs);  % largest patch
        Gproperties(iG).patch_y = mean(ys);

        % (2) discreteness
        Gproperties(iG).Dindex = bgst(iG) ./ Gproperties(iG).Gsize; 
    end

    map_Dindex = mean([Gproperties(:).Dindex]);  % average over map...


    % ALSO: take total proportion over map - proportion of neurons in largest
    % patches!!
    TDindex = sum(bgst) ./ nN;  % total proportion of neurons falling in largest physical patches


    save(savefname,'Gproperties','map_Dindex','TDindex','V','C','VG','Vsparse','VGsparse')
    
    % pause

    %% CONTROLS for discreteness (slow)

    %     randomly assign neurons to groups of same size as data
    %     ID each Voronoi cell as belonging to a group
    %     detect patches
    %     compute discreteness (each group and whole map)

    permdata = struct('Dindex',[],'map_Dindex',[],'TDindex',[]);
    for iP = 1:nPermMaps
        iP
        tic
        % new group assignment
        ixs = randperm(nN);
        newG =[G(:,1) G(ixs,1)];    % causes random assignment of groups to original neuron order

        % new clustering of Voronoi diagram
        VGperm = zeros(size(V));
        for iN = 1:nN  % go through neurons
            ixPatch = find(V == iN); % find all grid squares assigned to this neuron
            VGperm(ixPatch) = newG(iN,1); % assign it the randomised group 
        end

        % find patches
        props_perm = find_contiguous_patches(newG,VGperm,C,nG);

        % find discreteness scores
        Dindex = [];
        for iG = 1:nG
            bgst(iG) = max(props_perm(iG).N_in_patch);
            Dindex(iG) = bgst(iG) ./ Gproperties(iG).Gsize; 
        end

        permdata(iP).Dindex = Dindex;
        permdata(iP).map_Dindex = mean(Dindex);
        permdata(iP).TDindex = sum(bgst) ./ nN;
        toc
    end

    % check that data discreteness score exceeds max permuted score (95%)
    max([permdata(:).TDindex])
    max([permdata(:).map_Dindex])

    save(savefname,'permdata','VGperm','-append')

end

