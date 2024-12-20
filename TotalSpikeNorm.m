%% Total spikes standardize
clear
close all

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos";

% Get the minimun duration time after the stimulus between experiments
    % This way, the time in which the number of spikes is counted is normalized.
time = TotalStimTime(main_folder);

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Exclude '.' and '..'

% Initiate the vectors
names = [];
total_spks = [];

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

        % Save the file name
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + ", " + filename;
        names = [names, newname];

        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        
        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stimtime = sscanf(data_stimtime, '%d')*60; % Conversion minutes to seconds

        % Get the amount of spikes between the stimulus and the minimun time
        total_spks_file = sum((stimtime < data_spk(:, 2)) & (data_spk(:, 2) < time));
        total_spks = [total_spks, total_spks_file];
    end

end

%% Plot
% Amount of bars (x)
bars = 1:length(total_spks);

% Bar plot
figure;
bar(bars, total_spks, 'FaceColor', [0.2, 0.6, 0.8]); % Barra con colores personalizados

ylabel('Total number of spikes');
title('Total number of spikes by age and experiment');

xticks(bars); % Bar location
xticklabels(names); % Bar tag

grid on;
hold off;