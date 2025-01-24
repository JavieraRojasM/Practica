close all
clear 

addpath('Functions');

file_path = "C:\Users\javie\OneDrive\Escritorio\Datos\Old\Dec1622_1.mat";
[~, file] = fileparts(file_path);


% Load the file
data = load(file_path);
data_spk = data.spks;
data_maxtime = data.file_length;
total_neurons_file = data_spk(end, 1);


% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]

% Get the spikes matrix
spiketrain = RasterPlotFx(data_spk, data_maxtime, dt);

max_perm = 100;
max_lag = 20;
up_threshold = 3;
bot_threshold = -2;

total_non_osc = 0;
total_osc = 0;
total_burs = 0;
total_paus = 0;


cell_array = {'Type', 'Neurons ID', 'Total neurons'};

% Code
name{2, 1} = 'Non-oscillatory';
name{3, 1} = 'Oscillator';
name{4, 1} = 'Burster';
name{5, 1} = 'Pauser';
    
name{2, 2} = [];
name{3, 2} = [];
name{4, 2} = [];
name{5, 2} = [];



for n = 1:total_neurons_file
    spiketrain(n, :);

    [corr_spiketrain, lags]  = xcorr(spiketrain(n, :), max_lag);

    cell_isi = GetISI(spiketrain(n, :));
    
    isi = cell_isi{1};
        
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
    mean_perm = mean(matrix_corr_spiketrain, 1);
    std_perm = std(matrix_corr_spiketrain, 0, 1);
        
    % Calcular el Z-score para el spike train original
    z_scores = (corr_spiketrain - mean_perm) ./ std_perm;
        

    %%% consecutive bins crossing threshold
    down_bot_threshold = find(z_scores < bot_threshold); 
    sup_up_threshold = find(z_scores > up_threshold);

    is_down_bot = any(diff(down_bot_threshold)==1);
    is_sup_up = any(diff(sup_up_threshold)==1);

    % four possible outcomes: 
    if is_sup_up == 0 && is_down_bot == 0
        % (1) no significant peaks or troughs = "non-oscillatory"
        cell_array{2, 3}(1, end+1) = n;
        total_non_osc = total_non_osc + 1;

    elseif is_sup_up == 1 && is_down_bot == 1
        % (2) significant peaks and troughs = "oscillator"
        cell_array{3, 3}(1, end+1) = n;  
        total_osc = total_osc + 1;

    elseif is_sup_up == 1 && is_down_bot == 0    
        % (3) significant peaks but no significant troughs = "burster"
        cell_array{4, 3}(1, end+1) = n;
        total_burs = total_burs + 1;

    elseif is_sup_up == 0 && is_down_bot == 1    
        % (4) no significant peaks but significant troughs = "pauser"
        cell_array{5, 3}(1, end+1) = n;       
        total_paus = total_paus + 1;
    end 


    
end

cell_array{2, 4} = total_non_osc;
cell_array{3, 4} = total_osc;
cell_array{4, 4} = total_burs;
cell_array{5, 4} = total_paus;
