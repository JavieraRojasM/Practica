%% Average spike for neuron of all files in one figure
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
juvenile_count = 0;
old_count = 0;
names = [];
total_spks = [];

% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]


min_time = GetMinTime(folder, main_folder);
min_stim = min_time(1,1);
min_total = min_time(1,2);


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
        
        % Add a file in the file count
        file_count = file_count + 1;

        % Create color vector
        if strcmp(folder(f).name, 'Juvenile')
            % Variar tonos de celeste/azul en función de juvenile_count
            base_color = [0, 0.1, 1]; % Color base para "juvenile"
            variation = juvenile_count / 1.2; % Escala de variación (ajustable)
            colors(file_count, :) = min(base_color + variation * [0.2, 0.3 0.5], 1); % Limitar a [0, 1]
            juvenile_count = juvenile_count + 1;
        elseif strcmp(folder(f).name, 'Old')
            % Variar tonos de naranjo/rojo en función de old_count
            base_color = [0.8, 0.4, 0.2]; % Color base para "old"
            variation = old_count / 1.2; % Escala de variación (ajustable)
            colors(file_count, :) = min(base_color + variation * [0.3, 0.2, 0.1], 1); % Limitar a [0, 1]
            old_count = old_count + 1;
        end

        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Get the spikes matrix
        matrix_spks = RasterPlotFx(data_spk, data_maxtime, dt);

        % Get the total duration of the experiment after the trim
        total_time = -min_stim:dt:(min_total-dt);
        
        % Get the matrix with the percent of total spikes
        AverageMatrix = AverageMatrixFx(min_stim, min_total, matrix_spks, dt, stim);

        %% Plot
        y_smooth = movmean(AverageMatrix, 200); % smoothed points
        
        % Stimulus start marker
        x_line = [0, 0]; 
        y_line = [0, max(y_smooth)+0.02]; 
        plot(x_line, y_line, 'k--', 'LineWidth', 1);
        text(0, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'black', 'FontSize', 8);
             

        % Tendency line for spikes
        line_color = colors(file_count, :);
        h(end+1) = plot(total_time, y_smooth, 'LineWidth', 1, 'Color', line_color); % Add tendency line
        hold on;
        legendEntries{end+1} = [newname];
        legend(h, legendEntries)    


    end
end
   

% Plot and axis tittles
ylabel('Total spikes / total neurons');
xlabel('Time (s)');
title(sprintf('Average spike for Neuron with dt = 1 * 10^{-%d}', i));
grid on


hold off