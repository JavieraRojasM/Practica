%% Types Of Neurons
clear
close all

addpath('Functions');



Type_of_Neurons_name = "NT_EC_maxtime_90";
%Type_of_Neurons_name = "NT_CC_maxtime_90_binsize_e0";
%Type_of_Neurons_name = "NT_CC_maxtime_90_binsize_e1";

Type_of_Neurons = load(Type_of_Neurons_name);

if contains(Type_of_Neurons_name, 'EC')
    file_name = erase(Type_of_Neurons_name, '_');
    file_name = erase(file_name, 'NT');
    file_name = erase(file_name, 'maxtime');
    file_name = replace(file_name, 'EC', 'External Code, maximun analysis time ');
elseif contains(Type_of_Neurons_name, 'CC')
    file_name = erase(Type_of_Neurons_name, '_');
    file_name = erase(file_name, 'NT');
    file_name = erase(file_name, 'maxtime');
    file_name = erase(file_name, 'binsize');
    file_name = replace(file_name, 'e', '[s], bin size 1 * 10^');
    file_name = replace(file_name, 'CC', 'Custom Code, maximun analysis time ');

end

%% Rasterplot of all files in one figure

addpath('Functions');
% cluster analysis function arguments
binlessopts.Dmeth = 'corrcoef';
binlessopts.BLmeth = 'Gaussian';
binlessopts.modopts = {{'sqEuclidean'},100};  % use 100 repetitions of k-means with Euclidean distance as basis for consensus
binlessopts.BLpars = 1; % width of convolution window, in seconds (here SD of Gaussian)


% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the count and vectors
file_count = 0;
names = [];
total_spks = [];
max_time = 90; %[s]

% The time step is 10^-i
% Select i:
i = 3;
% Time step
dt = 1*10^-i; %[s]

% Create a figure
figure;
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact'); % Ajuste del diseño

sgtitle(sprintf('Similarity matrix reorganized by type of neuron, %s', file_name));

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        spks_org = [];
        % Add a file in the file count
        file_count = file_count + 1;

    %for a = 1:length(file)
     % File path
        file_path = fullfile(folder_path, file(a).name);

        % Folder name
        [~, name, ~] = fileparts(file(a).name);
        of_name = string(folder(f).name) + ", " + name;
        newname = string(folder(f).name) + "_" + name;    
 
        file_name = string(file(a).name);

        fprintf('Analyzing %s\n', file_name);
        
        
        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion


        % Crear y filtrar spks_reduced
        spks = data_spk; % Copia de los datos originales
        spks(spks(:, 2) < stim, :) = []; % Filtrar por tiempo mínimo
        spks(spks(:, 2) > max_time + stim, :) = []; % Filtrar por tiempo máximo

        % IDs of trains
        allcellIDs = unique(spks(:,1));
        nallIDs = numel(allcellIDs);

        % fix start and end times of data-set to use
        T = [stim, max_time + stim]; 
    
        % now restrict spike-times to that range
        %thesespks = spks(spks(:,2) >= T(1) & spks(:,2) <= T(2),:);
    
        for type = 2: (size(Type_of_Neurons.data_set.(newname)(:,1), 1) - 1)
            type_name = Type_of_Neurons.data_set.(newname){type, 1};

            for indx = 1:size(Type_of_Neurons.data_set.(newname){type,2}, 2)
                id = Type_of_Neurons.data_set.(newname){type,2}(1,indx);
                found_in_row = []; % Variable para guardar la fila donde se encuentra

                for row = 1:size(spks, 1) 
                    if ismember(id, spks(row, 1)) % Verificar si la neurona está presente
                        found_in_row = row; % Guardar la fila donde se encuentra
                        break
                    end
                end
                                
                
                while spks(found_in_row,1) == id
                    
                    spks_org = [spks_org; spks(found_in_row, :)];                   
                    found_in_row = found_in_row + 1;
                    if found_in_row > size(spks, 1)
                        break
                    end
                end
           
            end
        end


        %%%%%% now cluster %%%%%%%%%%%%%%%%%%%
        consensus_cluster_spike_data_binless_mod(file_count, of_name, spks_org, allcellIDs,T,dt,binlessopts);



    end
end


% Guardar la figura como imagen
output_folder = 'C:\Users\javie\OneDrive\Escritorio\GitHub\Practica\TestFigures2\Similarity Matrix\Reorganized';

% Crear la carpeta si no existe
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


output_file = fullfile(output_folder, sprintf('SM_%s.png', Type_of_Neurons_name));

% Obtener las dimensiones de la pantalla
screenSize = get(0, 'ScreenSize');

% Establecer la ventana de la figura en pantalla completa
set(gcf, 'Position', screenSize*0.8);
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');
hold off;

