clear
close all

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the count and vectors
max_time = 20;

% Carpeta de salida
new_folder = "C:\Users\javie\OneDrive\Escritorio\Datos";
output_folder = fullfile(new_folder, "Reduced_Data_prueba");

% Crear la carpeta "Reduced_Data" si no existe
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        % File path
        file_path = fullfile(folder_path, file(a).name);

        % Folder name
        [~, name, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + "_" + name;
        
        fprintf('Reducing %s\n', newname);
            
        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        data_x = data.x;
        data_y = data.y;

        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Create new file
        

        % Crear y filtrar spks_reduced
        spks = data_spk; % Copia de los datos originales
        spks(spks(:, 2) < stim, :) = []; % Filtrar por tiempo mínimo
        spks(spks(:, 2) > max_time + stim, :) = []; % Filtrar por tiempo máximo

        pos_x = data_x;
        pos_y = data_y;
        stim_time = data_stimtime;

        % Generar el nuevo nombre de archivo en la carpeta "TestData"
        output_file_path = fullfile(output_folder, newname + ".mat");

        % Guardar únicamente la variable spks_reduced en el archivo .mat
        save(output_file_path, 'spks', 'pos_x', 'pos_y', 'stim_time');
    end
end
