%% Types Of Neurons

% This script processes spike data, filters it within a defined time window
% and classifies neurons into four categories: non-oscillatory, oscillator, 
% burster, or pauser. 
% The classification is based on the cross-correlation of discretized spike 
% trains and a permutation test. 
% The results are stored in a cell array and saved to a .mat file for further analysis.

% Javiera Rojas 7/02/2025

disp('Running Types Of Neurons...')

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Exclude '.' and '..'

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));
    fprintf('Inside %s\n', string(folder(f).name));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        % File path
        file_path = fullfile(folder_path, file(a).name);

        % Extract the file name (without path and extension)
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + "_" + filename;
        fprintf('Analyzing %s\n', string(file(a).name));

        % Initialize the data_set structure for storing the results
        data_set.(newname) = {'Type', 'Neurons ID', 'Total neurons';
                          'Non-oscillatory', [], [];
                          'Oscillator', [], [];
                          'Burster', [], [];
                          'Pauser', [], []};

        % Load the data from the file
        data = load(file_path);
        data_spk = data.spks; % Spike data
        data_stimtime = data.stim_time; % Stimulus time in data
        stim = sscanf(data_stimtime, '%d')*60; % Convert stimulus time from minutes to seconds
        
        % Define the time window for plotting
        min_plottime = stim - 10;
        max_plottime = max_time + stim;

        % Filter spike data to the defined time window
        spks = data_spk;
        spks(spks(:, 2) < min_plottime, :) = []; % Filter by minimum time
        spks(spks(:, 2) > max_plottime, :) = []; % Filter by maximum time

        % List the unique neurons
        list_of_neurons = unique(spks(:, 1));
        total_neurons = numel(list_of_neurons); % Count of unique neurons

        % Get the minimum and maximum spike times
        data_mintime = min(spks(:,2));
        data_maxtime = max(spks(:,2));

        % Initialize counters for the different types of neuronal behavior
        total_non_osc = 0;
        total_osc = 0;
        total_burs = 0;
        total_paus = 0;

        neuron_row = 1; % Initialize the row index for iterating through spike data
        
        % Iterate through each neuron
        for n = 1:total_neurons
            neuron_data = [];

            % Collect spike data for the current neuron
            while spks(neuron_row, 1) == list_of_neurons(n) && neuron_row < size(spks, 1)
                neuron_data = [neuron_data; spks(neuron_row, :)];
                neuron_row = neuron_row + 1;
            end

            % Define the number of bins and the bins for discretizing the spike train
            max_lag_bins = max_lag / binsize;
            bins = data_mintime:binsize:data_maxtime;

            % Discretize the spike times for the neuron
            spks_times = neuron_data(:, 2)';
            discretized_spks = histcounts(spks_times, bins);

            % Compute the cross-correlation of the spike train
            [corr_spiketrain, lags] = xcorr(discretized_spks, max_lag_bins);

            % Permutation test: shuffle the spike times and recompute the cross-correlation
            matrix_corr_spiketrain = [];
            for perm = 1:max_perm
                isi = diff(spks_times); % Inter-spike intervals
                time_before_start = spks_times(1) - data_mintime;
                time_after_end = data_maxtime - spks_times(end);
                free_time = time_before_start + time_after_end;

                % Randomly shuffle the inter-spike intervals
                new_idx = randperm(numel(isi));
                random_start = data_mintime + ceil(rand * free_time / dt) * dt;
                spiketrain_perm = [random_start, random_start + cumsum(isi(new_idx))];

                % Discretize the shuffled spike train
                discretized_spks_perm = histcounts(spiketrain_perm, bins);
                corr_spks_perm = xcorr(discretized_spks_perm, max_lag_bins);
                matrix_corr_spiketrain = [matrix_corr_spiketrain; corr_spks_perm];
            end

            % Calculate the mean and standard deviation of the permutation results
            mean_perm = mean(matrix_corr_spiketrain, 1);
            std_perm = std(matrix_corr_spiketrain, 0, 1);

            % Compute the Z-scores for the original spike train
            z_scores = (corr_spiketrain - mean_perm) ./ std_perm;
            z_scores(ceil(numel(lags)/2)) = 0; % Remove center bin

            % Check for consecutive bins crossing the thresholds
            down_bot_threshold = find(z_scores < bot_threshold);
            sup_up_threshold = find(z_scores > up_threshold);

            is_down_bot = any(diff(down_bot_threshold) == 1);
            is_sup_up = any(diff(sup_up_threshold) == 1);

            % Classify neurons into four categories based on their spike behavior
            if is_sup_up == 0 && is_down_bot == 0
                % No significant peaks or troughs = "non-oscillatory"
                data_set.(newname){2, 2}(1, end+1) = n;
                total_non_osc = total_non_osc + 1;
            elseif is_sup_up == 1 && is_down_bot == 1
                % Significant peaks and troughs = "oscillator"
                data_set.(newname){3, 2}(1, end+1) = n;
                total_osc = total_osc + 1;
            elseif is_sup_up == 1 && is_down_bot == 0
                % Significant peaks but no significant troughs = "burster"
                data_set.(newname){4, 2}(1, end+1) = n;
                total_burs = total_burs + 1;
            elseif is_sup_up == 0 && is_down_bot == 1
                % No significant peaks but significant troughs = "pauser"
                data_set.(newname){5, 2}(1, end+1) = n;
                total_paus = total_paus + 1;
            end
        end

        % Store the total counts for each classification type
        data_set.(newname){2, 3} = total_non_osc;
        data_set.(newname){3, 3} = total_osc;
        data_set.(newname){4, 3} = total_burs;
        data_set.(newname){5, 3} = total_paus;
        data_set.(newname){6, 3} = total_non_osc + total_osc + total_burs + total_paus;
    end 
end

% Save the results in a file
save([sprintf('NT_CC_maxtime_%d_binsize_e%d', max_time, b)], 'data_set');
Type_of_Neurons_name = sprintf('NT_CC_maxtime_%d_binsize_e%d', max_time, b);


