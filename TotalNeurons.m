%% Total number of Neurons

% This script calculates and plots the total number of neurons involved, 
% categorizing them by age group ("Juvenile" and "Old") with different 
% colors for visual distinction

% Javiera Rojas 07/02/2025

disp('Running Total number of Neurons...')

% Initiate the count and vectors
file_count = 0;     % Initialize a counter for files
names = [];         % Initialize an empty array for file names
total_neurons = []; % Initialize an empty array for total neuron counts

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

        % Create color vector based on subfolder name
        if strcmp(folder(f).name, 'Juvenile')
            bar_color(file_count, :) = colors.age(1, :); % Color for "juvenile"
        
        elseif strcmp(folder(f).name, 'Old')
            bar_color(file_count, :) = colors.age(2, :); % Color for "old"
        end

        % Load the file
        data = load(file_path);
        data_spk = data.spks;
        
        % Get the number of spikes after the stimulus and within the minimum time
        total_neurons_file = data_spk(end, 1);
        total_neurons = [total_neurons, total_neurons_file];
    end

end

%% Plot
% Number of bars (x-axis)
bars = 1:length(total_neurons);

% Create a bar plot
figure;
hold on 
for tn = 1:length(total_neurons)
    bar(bars(tn), total_neurons(tn), 'FaceColor', bar_color(tn, :));
    text(bars(tn), total_neurons(tn), num2str(total_neurons(tn)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

% Plot settings
title('Total number of neurons by age and experiment', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Number of neurons');
xticks(bars);                                           % Set bar locations
xticklabels(names);                                     % Set bar labels
rounded_up_yMax = ceil( max(total_neurons) / 10) * 10;
ylim([0, rounded_up_yMax + 10]);                        % Adjust y-axis limit for better visualization
grid on;


%% Save the figure as an image
output_folder = 'Figures_folder\TotalNeurons'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'Total_Neurons.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to half full screen
set(gcf, 'Position', screenSize/2);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

