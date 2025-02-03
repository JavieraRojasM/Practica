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

sgtitle('Base Cosine Similarity matrix', 'FontWeight', 'bold');

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



        % Extraer identificadores de neuronas
        neurons = unique(spks(:,1)); % Neuronas únicas
        num_neurons = length(neurons);
        
        % Crear una matriz de series temporales (rellenando con NaN)
        max_time_points = max(histc(spks(:,1), neurons));
        time_series = nan(num_neurons, max_time_points); % Matriz de datos
        
        % Rellenar la matriz con los tiempos de cada neurona
        for i = 1:num_neurons
            times = spks(spks(:,1) == neurons(i), 2);
            time_series(i, 1:length(times)) = times; % Guardar en la matriz
        end
        
        % Reemplazar NaN con ceros antes del cálculo
        time_series(isnan(time_series)) = 0;
        
        % Normalizar los vectores fila para calcular la similitud del coseno
        norm_data = time_series ./ vecnorm(time_series, 2, 2);
        
        % Calcular la matriz de similitud del coseno
        similarity_matrix = norm_data * norm_data';
        
        % Visualizar la matriz de similitud
        nexttile;
        imagesc(similarity_matrix);
        colorbar;
        colormap('parula');
        axis square;
        title(sprintf('%s', of_name), 'FontSize', 12)
%         
%         % Etiquetas de ejes
%         xticks(1:num_neurons);
%         yticks(1:num_neurons);
%         xlabel('Neuron Index', 'FontSize', 12);
%         ylabel('Neuron Index', 'FontSize', 12);


    end
end


% Guardar la figura como imagen
output_folder = 'C:\Users\javie\OneDrive\Escritorio\GitHub\Practica\TestFigures2\Similarity Matrix';

% Crear la carpeta si no existe
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


output_file = fullfile(output_folder, 'CSM_Base.png');

% Obtener las dimensiones de la pantalla
screenSize = get(0, 'ScreenSize');

% Establecer la ventana de la figura en pantalla completa
set(gcf, 'Position', screenSize*0.8);
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');
hold off;
