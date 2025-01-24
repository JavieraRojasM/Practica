%% Mean spikes standardize
clear
close all

addpath('Functions');

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos";

% Get the minimun duration time after the stimulus between experiments
    % This way, the time in which the number of spikes is counted is normalized.
time = TotalStimTime(main_folder);

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% Initiate the vectors
names = [];
total_spks = [];

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)

    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));

    % Save the folder name
    names = [names, string(folder(f).name)]

    % Iterate over the files inside the subfolder
    for a = 1:length(file)

        % File path
        file_path = fullfile(folder_path, file(a).name);

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

    % Get the mean between the spikes of the same age group
    mean_spks(f) = mean(total_spks);

    % Get the standar deviation and standar error between the spikes of the same age group
    std_deviation(f) = std(total_spks);
    std_error(f) = std_deviation(f) / sqrt(length(total_spks));
end

%% Plot
% Amount of bars (x)
bars = 1:length(folder);

% Bar plot
figure;
hold on;
bar(bars, mean_spks, 'FaceColor', [0.2, 0.6, 0.8]); % Barra con colores personalizados

% Add the error bar
errorbar(bars, mean_spks, std_error, 'k.', 'LineWidth', 1.5);

%xlabel('Age group');
ylabel('Average number of spikes');
title('Average number of spikes by age');

xticks(bars); % Bar location
xticklabels(names); % Bar tag

grid on;
hold off;