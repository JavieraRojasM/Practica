%% Rasterplot of all files in one figure
clear
close all

addpath('Functions');

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

% Create a figure
figure;

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
        newname = string(folder(f).name) + ", " + name;
        
        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Get the spikes matrix
        matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt);

        % Add a file in the file count
        file_count = file_count + 1;

        %% SubPlot
        subplot(2, 3, file_count);
        hold on;

        n_neuron = data_spk(end,1);
        for n = 1:n_neuron
            index = (find(matriz_spks(n,:)));
            x = index*dt;
            y = ones(1, size(x,2))* n;
            scatter(x, y, 5, 'filled', 'MarkerFaceColor', [0.1, 0.1, 0.6]);
        end
        
        xlabel('Time (s)');        
        
        ylim([0.5, (n_neuron + 0.5)])
        yticks(0:5:n_neuron+1);
        ylabel('Nº Neuron');
        
        % Stimulus start marker
        x_line = [stim, stim]; 
        y_line = [0.5, n_neuron + 0.5]; 
        plot(x_line, y_line, 'r-', 'LineWidth', 2);
        text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);
        title(sprintf('Raster Plot of %s with dt = 1 * 10^{-%d}', newname, i));
        hold off;

    end
end
