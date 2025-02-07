%% Mean spikes normalized

% This script calculates the number of spikes normalized by the number of 
% neurons across the entire dataset and plots how neural activity evolves 
% throughout the experiment, averaging the spikes into a single representative 
% curve for each file.

% Javiera Rojas 07/02/2025

disp('Running Mean spikes normalized by number of neurons...')

% Initialize counters and vectors
file_count = 0;           % Counter for files
juvenile_count = 0;       % Counter for "Juvenile" group
old_count = 0;            % Counter for "Old" group
legendEntries = {};         % Cell array for legend entries
h = [];                     % Vector to store plot handles (for legend)
AverageoftheAverage = [];   % Vector for the Average of the Average data
names = [];

min_time = GetMinTime(folder, main_folder);  
min_stim = min_time(1,1);   % Minimum stimulus time of all files

% Time vector for plotting
total_time = -min_stim:dt:(max_time-dt); 

% Create a figure
figure;

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

        % Create color vector for bar plot
        if strcmp(folder(f).name, 'Juvenile')
            colors_bar(file_count, :) = colors.age(1, :); % Color for "juvenile"
        
        elseif strcmp(folder(f).name, 'Old')
            colors_bar(file_count, :) = colors.age(2, :); % Color for "old"
        end


        % Create color variations for each file based on its group (Juvenile/Old)
        if strcmp(folder(f).name, 'Juvenile')
            % Modify color shade based on juvenile count
            base_color = colors.age(1, :);      % Base color for "juvenile"
            variation = juvenile_count / 1.2;   % Adjust variation scale
            color_var(file_count, :) = min(base_color + variation * [0.2, 0.3, 0.5], 1); % Limit to [0,1]
            juvenile_count = juvenile_count + 1;
        
        elseif strcmp(folder(f).name, 'Old')
            % Modify color shade based on old count
            base_color = colors.age(2, :);      % Base color for "old"
            variation = old_count / 1.2;        % Adjust variation scale
            color_var(file_count, :) = min(base_color + variation * [0.3, 0.2, 0.1], 1); % Limit to [0,1]
            old_count = old_count + 1;
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

        %% Plot
        y_smooth = movmean(AverageMatrix, 200); % Smooth the spike data for the tendency line


        % Plot stimulus start marker
        x_line = [0, 0];
        y_line = [0, max(y_smooth) + 0.02];
        plot(x_line, y_line, 'r--', 'LineWidth', 1);  % Vertical dashed line at stimulus
        text(0, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);

        % Plot the tendency line for the spikes
        line_color = color_var(file_count, :);  % Set line color based on group
        h(end+1) = plot(total_time, y_smooth, 'LineWidth', 1, 'Color', line_color);  % Plot the smoothed spike data
        hold on;
        
        % Add entry to the legend
        legendEntries{end+1} = [of_name];
        legend(h, legendEntries);  % Update legend

    end
end


% Plot settings
ylabel('Total spikes / total neurons');
xlabel('Time (s)');

title(sprintf('Average spike for Neuron with dt = 1 * 10^{-%d}', i), 'FontSize', 14, 'FontWeight', 'bold');
grid on;
hold off;


%% Save the figure as an image
output_folder = 'Figures_folder\Average spike for Neuron'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'Average_spike_for_Neuron.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to full screen
set(gcf, 'Position', screenSize);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

%% Plot
% Amount of bars (x)
bars = 1:length(AverageoftheAverage);

% Bar plot
figure;
hold on 
for b = 1:length(AverageoftheAverage)
    bar(bars(b), AverageoftheAverage(b), 'FaceColor', colors_bar(b, :));
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

% Define the output file path and name
output_file = fullfile(output_folder, 'Average_of_the_average_spike_for_Neuron.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to half full screen
set(gcf, 'Position', screenSize/2);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;
