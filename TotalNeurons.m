%% Total spikes standardize
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
folder = folder(~ismember({folder.name}, {'.', '..'})); % Exclude '.' and '..'

% Initiate the count and vectors
file_count = 0;
names = [];
total_neurons = [];
colors = [];

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
        
       
        % Get the amount of spikes between the stimulus and the minimun time
        total_neurons_file = data_spk(end, 1);
        total_neurons = [total_neurons, total_neurons_file];
    end

end

%% Plot
% Amount of bars (x)
bars = 1:length(total_neurons);

% Bar plot
figure;
hold on 
for i = 1:length(total_neurons)
    bar(bars(i), total_neurons(i), 'FaceColor', colors(i, :));
    text(bars(i), total_neurons(i), num2str(total_neurons(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

title('Total number of neurons by age and experiment');
ylabel('Number of neurons');
xticks(bars); % Bar location
xticklabels(names); % Bar tag
rounded_up_yMax = ceil( max(total_neurons) / 10) * 10;
ylim([0, rounded_up_yMax + 10]);
grid on;
hold off;