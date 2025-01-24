%% Total average of the average spike for neuron of all files in one figure
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
AverageoftheAverage = [];
colors = [];

% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]


min_time = GetMinTime(folder, main_folder);
min_stim = min_time(1,1);
min_total = min_time(1,2);


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

        % Save the file name
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + ", " + filename;
        names = [names, newname];

        % Add a file in the file count
        file_count = file_count + 1;

        % Create color vector
        if strcmp(folder(f).name, 'Juvenile')
            colors(file_count, :) = [0.2, 0.6, 0.8]; % Color para "juvenile"
        
        elseif strcmp(folder(f).name, 'Old')
            colors(file_count, :) = [0.8, 0.4, 0.2]; % Color para "old"
        end

        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        

        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Get the spikes matrix
        matrix_spks = RasterPlotFx(data_spk, data_maxtime, dt);

        % Get the total duration of the experiment after the trim
        total_time = -min_stim:dt:(min_total-dt);
        
        % Get the matrix with the percent of total spikes
        AverageMatrix = AverageMatrixFx(min_stim, min_total, matrix_spks, dt, stim);

        AverageoftheAverage_file = mean(AverageMatrix);
        AverageoftheAverage = [AverageoftheAverage, AverageoftheAverage_file];

    end
end


%% Plot
% Amount of bars (x)
bars = 1:length(AverageoftheAverage);

% Bar plot
figure;
hold on 
for b = 1:length(AverageoftheAverage)
    bar(bars(b), AverageoftheAverage(b), 'FaceColor', colors(b, :));
    text(bars(b), AverageoftheAverage(b), num2str(AverageoftheAverage(b)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

ylabel('Total spikes / total neurons');
title(sprintf('Average of the average of spike for Neuron with dt = 1 * 10^{-%d}', i));
xticks(bars); % Bar location
xticklabels(names); % Bar tag
rounded_up_yMax = max(AverageoftheAverage);
ylim([0, rounded_up_yMax + 0.1]);
grid on;
hold off;