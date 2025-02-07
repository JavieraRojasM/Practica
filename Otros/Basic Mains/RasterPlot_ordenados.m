%% Rasterplot by type of neuron of all files in one figure

% Initiate the count and vectors
file_count = 0;
names = [];
total_spks = [];


% Create a figure
figure;

sgtitle(sprintf('Raster Plot by type of neuron dt = 1 * 10^{-%d}, %s', i, file_name));

% Definir las referencias para la leyenda
hNonOscillatory = [];  % Inicializar como vacío
hOscillator = [];
hBurster = [];
hPauser = [];

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
        of_name = string(folder(f).name) + ", " + name;

        newname = string(folder(f).name) + "_" + name;
        
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
        

        list_of_neurons = unique(spks(:, 1));

        % Get the spikes matrix
        matriz_spks = RasterPlotFx(spks, max_time + stim, dt);

        % Add a file in the file count
        file_count = file_count + 1;

        %% SubPlot
        subplot(2, 3, file_count);
        hold on;

        n_neuron = 1;
        for type = 2: (size(Type_of_Neurons.data_set.(newname)(:,1), 1) - 1)
            type_name = Type_of_Neurons.data_set.(newname){type, 1};
            color = colors.type(type - 1, :);
            if strcmp(type_name, 'Non-oscillatory')
                if isempty(hNonOscillatory)  % Comprobar si ya se asignó un handle
                    hNonOscillatory = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type_name, 'Oscillator')
                if isempty(hOscillator)
                    hOscillator = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type_name, 'Burster')
                if isempty(hBurster)
                    hBurster = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type_name, 'Pauser')
                if isempty(hPauser)
                    hPauser = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            end 

            for indx = 1:size(Type_of_Neurons.data_set.(newname){type,2}, 2)
                id = Type_of_Neurons.data_set.(newname){type,2}(1,indx);
                index = (find(matriz_spks(id,:)));
                x = index*dt;
                y = ones(1, size(x,2))* n_neuron;
                scatter(x, y, 5, 'filled', 'MarkerFaceColor', color);
                n_neuron = n_neuron + 1;
                
            end
        end


        xlabel('Time (s)');        
        xlim([stim, (max_time + stim)])
        ylim([0.5, (n_neuron + 0.5)])
        %yticks(0:5:n_neuron+1);
        ylabel('Neuron');
        
        title(sprintf('%s', of_name));
        hold off

    end
end

legend([hPauser, hBurster, hOscillator, hNonOscillatory], ...
            { 'Pauser', 'Burster', 'Oscillator', 'Non-oscillatory'}, ...
            'TextColor', 'black', 'Location', 'best');

% Obtener las dimensiones de la pantalla
screenSize = get(0, 'ScreenSize');


