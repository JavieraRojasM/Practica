%% Rasterplot of all files in one figure
clear
close all

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the count and vectors
file_count = 0;
names = [];
total_spks = [];

% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]


min_stim = 120000;
min_max_time = 10000000;

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

        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion 
      
        if stim < min_stim
            min_stim = stim;
        end

        % Get the maximun time before the stimulus
        max_time = sscanf(data_maxtime, '%d')*60; % Minutes to seconds conversion
        time_befstim = max_time - stim;
        if time_befstim < min_max_time
            min_max_time = time_befstim;
        end
    end
end

% Create a figure
figure;
legendEntries = {};
h = []; % Vector para almacenar los "handles" de las curvas

% Iterate (Again) over the subfolders inside the main folder
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
        newname = string(folder(f).name) + ", " + name;
        
        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Get the spikes matrix
        matrix_spks = RasterPlotFx(data_spk, data_maxtime, dt);

        % Trim matrix spiks

        % Add a file in the file count
        file_count = file_count + 1;

        total_time = -min_stim:dt:(min_max_time-dt);

        % Initiate the average vector
        average = zeros(1, size(total_time,2));
        
        % Trim of the matrix
        
        start = stim - min_stim;
        endd = stim + min_max_time;
           
        matrix_spks(:, [(endd/dt +1):end]) = [];
        size(matrix_spks);

        matrix_spks(:, [1:(start/dt)]) = [];
        size(matrix_spks);


        for t = 1:size(matrix_spks,2)
            average(1, t) = sum(matrix_spks(:,t)) / size(matrix_spks,1);
        end

        
        

        %% Plot
        y_smooth = movmean(average, 200); % smoothed points
        
        % Stimulus start marker
        x_line = [0, 0]; 
        y_line = [0, max(y_smooth)+0.02]; 
        plot(x_line, y_line, 'k--', 'LineWidth', 1);
        text(0, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'black', 'FontSize', 8);
        
        % Tendency line for spikes
        h(end+1) = plot(total_time, y_smooth, 'LineWidth', 1); % Add tendency line
        hold on;
        legendEntries{end+1} = [newname];
        legend(h, legendEntries)

        % Plot and axis tittles
        ylabel('Total spikes / total neurons');
        xlabel('Time (s)');
        title(sprintf('Average spike for Neuron with dt = 1 * 10^{-%d}', i));
        grid on
    end
end

hold off