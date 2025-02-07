%% Global average spike rate for neuron

% This script calculates the average of the average spike activity for 
% each file across the entire dataset, where each file represents 
% an individual experiment. The spike data is averaged over time 
% for each file, and then the mean of these averaged values is computed 
% to summarize the overall neural activity. The results are plotted 
% as a bar chart, showing the global average spike activity for 
% each file or experimental condition.

% Javiera Rojas 07/02/2025

disp('Running Global average spike rate for neuron...')

% Initialize counters and vectors
file_count = 0;           % Counter for files
juvenile_count = 0;       % Counter for "Juvenile" group
old_count = 0;            % Counter for "Old" group
names = [];               % Vector for the files names    
AverageoftheAverage = []; % Vector for the Average of the Average data

min_time = GetMinTime(folder, main_folder);  
min_stim = min_time(1,1);   % Minimum stimulus time of all files

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Path to the subfolder
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the list of files in the subfolder
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files in the subfolder
    for a = 1:length(file)
        % Full file path
        file_path = fullfile(folder_path, file(a).name);

        % Extract the file name
        [~, name, ~] = fileparts(file(a).name);
        of_name = string(folder(f).name) + ", " + name;
        names = [names, of_name];
        
        % Increment file count for each file processed
        file_count = file_count + 1;

        % Create color vector
        if strcmp(folder(f).name, 'Juvenile')
            colors_var(file_count, :) = [0.2, 0.6, 0.8]; % Color para "juvenile"
        
        elseif strcmp(folder(f).name, 'Old')
            colors_var(file_count, :) = [0.8, 0.4, 0.2]; % Color para "old"
        end

        % Load the data from the file
        data = load(file_path);
        data_spk = data.spks;                       % Spike data
        data_stimtime = data.stim_time;             % Stimulus time in data
        stim = sscanf(data_stimtime, '%d') * 60;    % Minutes to seconds conversion

        % Define the time window for plotting
        min_plottime = stim - min_stim;  
        max_plottime = max_time + stim; 

        % Filter spike data to include only data within the defined time window
        spks = data_spk;
        spks(spks(:, 2) < min_plottime, :) = [];  % Filter by minimum time
        spks(spks(:, 2) > max_plottime, :) = [];  % Filter by maximum time

        % Create the spike matrix for raster plot
        matrix_spks = RasterPlotFx(spks, max_plottime, dt, min_plottime);

        % Get the matrix with the percent of total spikes
        AverageMatrix = AverageMatrixFx(matrix_spks);

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
    bar(bars(b), AverageoftheAverage(b), 'FaceColor', colors_var(b, :));
    text(bars(b), AverageoftheAverage(b), num2str(AverageoftheAverage(b)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

ylabel('Total spikes / total neurons');
title(sprintf('Average of the average of spike for Neuron with dt = 1 * 10^{-%d}', i), 'FontSize', 14, 'FontWeight', 'bold');
xticks(bars);           % Bar location
xticklabels(names);     % Bar tag
rounded_up_yMax = max(AverageoftheAverage);
ylim([0, rounded_up_yMax + 0.1]);
grid on;


%% Save the figure as an image
output_folder = 'Figures_folder\Average of the average'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'Average_of_the_average_spike_for_Neuron.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to half full screen
set(gcf, 'Position', screenSize/2);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;