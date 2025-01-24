%% Types Of Neurons
clear
close all

addpath('Functions');

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

file_path = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data\Old\Dec1622_1.mat";
[~, file] = fileparts(file_path);

% main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";
% 
% % Get the subfolders within the main folder
% folder = dir(main_folder);
% folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the count and vectors
%names = [];

% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]

% Parameters
max_perm = 100;
max_lag = 20;
up_threshold = 3;
bot_threshold = -2;
max_time = 90;

tags = {'Non-oscillatory', 'Oscillator', 'Burster','Pauser'};

% Iterate over the subfolders inside the main folder
% for f = 1:length(folder)
%     % Subfolder path
%     folder_path = fullfile(main_folder, folder(f).name);
%     
%     % Get the files within the subfolders
%     file = dir(fullfile(folder_path, '*.mat'));
%     fprintf('Inside %s\n', string(folder(f).name));
%     % Iterate over the files inside the subfolder
%     for a = 1:length(file)
%         % File path
%         file_path = fullfile(folder_path, file(a).name);

        % Folder name
%         [~, filename, ~] = fileparts(file.name);
%         newname = filename;
        newname = file;
        fprintf('Analyzing %s\n', file);
        % Create the cell array
        set.(newname) = {'Type', 'Neurons ID', 'Total neurons';
                          'Non-oscillatory', [], [];
                          'Oscillator', [], [];
                          'Burster', [], [];
                          'Pauser', [], []};

        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        total_neurons = data_spk(end, 1);

        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Filtrar spks_reduced
        data_maxtime = max_time + stim;

        spks = data_spk; % Copia de los datos originales
        spks(spks(:, 2) < stim, :) = []; % Filtrar por tiempo mínimo
        spks(spks(:, 2) > max_time + stim, :) = []; % Filtrar por tiempo máximo

        
        % Get the spikes matrix
        spiketrain = RasterPlotFx(spks, data_maxtime, dt);


        
%         figure
%         hold on;
% 
%         n_neuron = data_spk(end,1);
%         for n = 1:n_neuron
%             index = (find(spiketrain(n,:)));
%             x = index*dt;
%             y = ones(1, size(x,2))* n;
%             scatter(x, y, 5, 'filled', 'MarkerFaceColor', [0.1, 0.1, 0.6]);
%         end
%         
%         xlabel('Time (s)');        
%         
%         ylim([0.5, (n_neuron + 0.5)])
%         yticks(0:5:n_neuron+1);
%         ylabel('Nº Neuron');

        
        total_non_osc = 0;
        total_osc = 0;
        total_burs = 0;
        total_paus = 0;
        
        for n = 1:total_neurons
            spiketrain(n, :);
        
            [corr_spiketrain, lags]  = xcorr(spiketrain(n, :), max_lag);
        
            cell_isi = GetISI(spiketrain(n, :))
            
            isi = cell_isi{1}
                
            perm_isi = Perm_ISI(isi, max_perm);
            
            % Buscar el vector en la matriz
            [idx] = ismember(isi, perm_isi, 'rows');
                
            perm_isi(idx, :) = []; 
                
                
            matrix_perm_spiketrain = zeros((size(perm_isi,1)-1), size(spiketrain,2));
            matrix_corr_spiketrain = zeros((size(perm_isi,1)-1), size(corr_spiketrain,2));
            
            for isi = 2:size(perm_isi,1)
                isi_test = perm_isi(isi, :); % 1, 2, 2
                
                spiketrain_perm = FromISItoSpiketrain(isi_test, spiketrain(n, :));
                
                matrix_perm_spiketrain(isi-1, :) = spiketrain_perm;
                    
                corr_spiketrain_perm = xcorr(spiketrain_perm, max_lag);
                
                matrix_corr_spiketrain(isi-1, :) = corr_spiketrain_perm;
            end
                
            % Calcular la media y desviación estándar de las permutaciones
            mean_perm = mean(matrix_corr_spiketrain, 1)
            std_perm = std(matrix_corr_spiketrain, 0, 1)
                
            % Calcular el Z-score para el spike train original
            z_scores = (corr_spiketrain - mean_perm) ./ std_perm
                
        
            %%% consecutive bins crossing threshold
            down_bot_threshold = find(z_scores < bot_threshold) 
            sup_up_threshold = find(z_scores > up_threshold)
        
            is_down_bot = any(diff(down_bot_threshold)==1)
            is_sup_up = any(diff(sup_up_threshold)==1)
        

            
            % four possible outcomes: 
            if is_sup_up == 0 && is_down_bot == 0
                % (1) no significant peaks or troughs = "non-oscillatory"
                set.(newname){2, 2}(1, end+1) = n;
                total_non_osc = total_non_osc + 1
        
            elseif is_sup_up == 1 && is_down_bot == 1
                % (2) significant peaks and troughs = "oscillator"
                set.(newname){3, 2}(1, end+1) = n;  
                total_osc = total_osc + 1
        
            elseif is_sup_up == 1 && is_down_bot == 0    
                % (3) significant peaks but no significant troughs = "burster"
                set.(newname){4, 2}(1, end+1) = n;
                total_burs = total_burs + 1
        
            elseif is_sup_up == 0 && is_down_bot == 1    
                % (4) no significant peaks but significant troughs = "pauser"
                set.(newname){5, 2}(1, end+1) = n;       
                total_paus = total_paus + 1
            end 
        
        
            
        end
        
        set.(newname){2, 3} = total_non_osc;
        set.(newname){3, 3} = total_osc;
        set.(newname){4, 3} = total_burs;
        set.(newname){5, 3} = total_paus;
        set.(newname){6, 3} = total_non_osc + total_osc + total_burs + total_paus;

%     end 
%     
% end


save([sprintf('Types_of_Neurons_CP_dt%d', i)],'set');