%% Types Of Neurons
clear
close all

addpath('Functions');

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the count and vectors
%names = [];

% The time step is 10^-i
% Select i:
i = 4;
% Time step
dt = 1*10^-i; %[s]

% Parameters
max_perm = 100;

% Select b:
b = 1;
% Time step
binsize = 1*10^-b; %[s]

max_lag = 20; %[s]
up_threshold = 3;
bot_threshold = -2;
max_time = 90; %[s]

tags = {'Non-oscillatory', 'Oscillator', 'Burster','Pauser'};

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

        % Folder name
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + "_" + filename;
        fprintf('Analyzing %s\n', string(file(a).name));
        % Create the cell array
        data_set.(newname) = {'Type', 'Neurons ID', 'Total neurons';
                          'Non-oscillatory', [], [];
                          'Oscillator', [], [];
                          'Burster', [], [];
                          'Pauser', [], []
                          'No Info', [], []};

        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        

        % Crear y filtrar spks_reduced
        spks = data_spk; % Copia de los datos originales
        spks(spks(:, 2) < stim, :) = []; % Filtrar por tiempo mínimo
        spks(spks(:, 2) > max_time + stim, :) = []; % Filtrar por tiempo máximo
        

        list_of_neurons = unique(spks(:, 1));
        total_neurons = size(list_of_neurons);

        data_mintime = min(spks(:,2));
        data_maxtime = max(spks(:,2));

        total_non_osc = 0;
        total_osc = 0;
        total_burs = 0;
        total_paus = 0;

        neuron_row = 1;
        
        for n = 1:total_neurons
            neuron_data = [];

            while spks(neuron_row, 1) == list_of_neurons(n)

                neuron_data = [neuron_data; spks(neuron_row, :)];
                if neuron_row < size(spks, 1)
                    neuron_row = neuron_row + 1;
                elseif neuron_row >= size(spks, 1)
                    break
                end
              
            end
            
            max_lag_bins = max_lag / binsize; % 20s / 1s = 20 bins
            bins = data_mintime:binsize:data_maxtime; % Bins de 1 segundo como se especifica

            spks_times = neuron_data(:, 2)';        

            % Create discretized signals
            discretized_spks = histcounts(spks_times, bins);

            [corr_spiketrain, lags] = xcorr(discretized_spks, max_lag_bins);

            % Permutation test 
            matrix_corr_spiketrain = [];
            for perm = 1:max_perm
                isi = diff(spks_times);                              % inter-event intervals for train
                time_before_start = spks_times(1) - data_mintime;
                time_after_end = data_maxtime - spks_times(end);  % time before first event; time after last

                free_time = time_before_start + time_after_end;                      % total amount of free time before first and after last event
                new_idx = randperm(numel(isi));                    % randomly shuffle indices of intervals in train
                random_start = data_mintime + ceil(rand * free_time / dt) * dt;      % randomly chosen start time, quantised to original spike-time resolution
                spiketrain_perm = [random_start, random_start + cumsum(isi(new_idx))];  % starting from randomly chosen start time, the times of new events in shuffled train 1,
                % Supongamos que tenemos dos trenes de spikes (en segundos)

                % Crear señales discretizadas (vector binario)
                discretized_spks_perm = histcounts(spiketrain_perm, bins);
               
                corr_spks_perm = xcorr(discretized_spks_perm, max_lag_bins);
                matrix_corr_spiketrain = [matrix_corr_spiketrain; corr_spks_perm];

            end

            % Calcular la media y desviación estándar de las permutaciones
            mean_perm = mean(matrix_corr_spiketrain, 1);
            std_perm = std(matrix_corr_spiketrain, 0, 1);

            % Calcular el Z-score para el spike train original
            z_scores = (corr_spiketrain - mean_perm) ./ std_perm;
            z_scores(ceil(numel(lags)/2)) = 0;    % remove centre bin

            %%% consecutive bins crossing threshold
            down_bot_threshold = find(z_scores < bot_threshold);
            sup_up_threshold = find(z_scores > up_threshold);

            is_down_bot = any(diff(down_bot_threshold)==1);
            is_sup_up = any(diff(sup_up_threshold)==1);

            % four possible outcomes:
            if is_sup_up == 0 && is_down_bot == 0
                % (1) no significant peaks or troughs = "non-oscillatory"
                data_set.(newname){2, 2}(1, end+1) = n;
                total_non_osc = total_non_osc + 1;

            elseif is_sup_up == 1 && is_down_bot == 1
                % (2) significant peaks and troughs = "oscillator"
                data_set.(newname){3, 2}(1, end+1) = n;
                total_osc = total_osc + 1;

            elseif is_sup_up == 1 && is_down_bot == 0
                % (3) significant peaks but no significant troughs = "burster"
                data_set.(newname){4, 2}(1, end+1) = n;
                total_burs = total_burs + 1;

            elseif is_sup_up == 0 && is_down_bot == 1
                % (4) no significant peaks but significant troughs = "pauser"
                data_set.(newname){5, 2}(1, end+1) = n;
                total_paus = total_paus + 1;
            end



        end
        data_set.(newname){2, 3} = total_non_osc;
        data_set.(newname){3, 3} = total_osc;
        data_set.(newname){4, 3} = total_burs;
        data_set.(newname){5, 3} = total_paus;
        data_set.(newname){6, 3} = total_non_osc + total_osc + total_burs + total_paus;

    
    end 

end

save([sprintf('NT_CC_maxtime_%d_binsize_e%d',max_time, b)],'data_set');
clear

