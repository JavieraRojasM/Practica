%% Cosine Similarity Matrix

% Initiate the count and vectors
file_count = 0;
names = [];
total_spks = [];


% Create a figure
figure;
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact'); % Ajuste del diseño
sgtitle(sprintf('Similarity matrix reorganized by type of neuron, %s', file_name), 'FontSize', 14, 'FontWeight', 'bold');

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

        spks(spks(:, 2) > max_time + stim, :) = [];

        % Iterate over each neuron type and select the corresponding neurons
        for type = 2: (size(Type_of_Neurons.data_set.(newname)(:,1), 1) - 1)
            type_name = Type_of_Neurons.data_set.(newname){type, 1};

            % Iterate over each neuron ID within the type
            for indx = 1:size(Type_of_Neurons.data_set.(newname){type,2}, 2)
                id = Type_of_Neurons.data_set.(newname){type,2}(1,indx);
                found_in_row = []; % Variable to store the row where the neuron is found

                % Search for the row containing the current neuron ID
                for row = 1:size(spks, 1) 
                    if ismember(id, spks(row, 1)) % Check if the neuron is present
                        found_in_row = row;  % Store the row index
                        break
                    end
                end
                
                % Collect spike data for the current neuron
                while spks(found_in_row,1) == id
                    spks_org = [spks_org; spks(found_in_row, :)];  % Append spike data
                    found_in_row = found_in_row + 1;
                    if found_in_row > size(spks, 1)
                        break
                    end
                end
            end
        end
        
        spks = spks_org;  % Update the spike data with selected neurons


        % Extraer identificadores de neuronas
        neurons = unique(spks(:,1), 'stable'); % Neuronas únicas
        num_neurons = length(neurons);
        
        [~, ~, bin_counts] = unique(spks(:,1), 'stable'); 
        max_time_points = max(accumarray(bin_counts, 1));

        % Crear una matriz de series temporales (rellenando con NaN)
        %max_time_points = max(histc(spks(:,1), neurons));
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
        
        % Set the diagonal of the similarity matrix to zero (no self-similarity)
        similarity_matrix(eye(size(similarity_matrix)) == 1) = 0;

        fprintf('Mean similarity of %s: %d\n', of_name, mean_similarity);


        % Visualizar la matriz de similitud
        nexttile;
        imagesc(similarity_matrix);
        colorbar;
        colormap('parula');
        axis square;
        title(sprintf('%s', of_name), 'FontSize', 12)


    end
end