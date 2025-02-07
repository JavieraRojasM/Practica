%% Rasterplot of all files in one figure

% This script generates a raster plot for multiple spike data files.
% Each file is reduced from the stimulus times to a max_time defined in 
% "Run_Full_Analysis" and plotted in a grid of subplots. 
% Different colors are used for the "Juvenile" and "Old" groups. 
% Each subplot visualizes spike events for neurons, with a red line 
% marking the stimulus application time

% Javiera Rojas 07/02/2025

disp('Running Base Raster Plot...')


% Create a figure with a tiled layout
figure;
tiledlayout(2, 3);  % Create a 2x3 grid layout for the plots

sgtitle(sprintf('Raster Plot with dt = 1 * 10^{-%d}', i), 'FontSize', 14, 'FontWeight', 'bold');

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolder
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        % File path
        file_path = fullfile(folder_path, file(a).name);

        % Folder name
        [~, name, ~] = fileparts(file(a).name);
        of_name = string(folder(f).name) + ", " + name;
        
        % Load the data from the file
        data = load(file_path); 
        data_spk = data.spks;                       % Spike data
        data_stimtime = data.stim_time;             % Stimulus time in the data
        stim = sscanf(data_stimtime, '%d') * 60;    % Minutes to seconds conversion

        % Define the time window for plotting
        min_plottime = stim - 10;
        max_plottime = max_time + stim;

        % Filter spike data to the defined time window
        spks = data_spk;
        spks(spks(:, 2) < min_plottime, :) = []; 
        spks(spks(:, 2) > max_plottime, :) = []; 

        % Create the spike matrix for raster plot
        matrix_spks = RasterPlotFx(spks, max_plottime, dt);

        %% Create plot in next tile
        nexttile;  % Use nexttile to position the plot in the next available tile
        hold on;

        % Choose color based on the folder name (Juvenile or Old)
        if strcmp(folder(f).name, 'Juvenile')
            color = colors.age(1, :);  % Color for "juvenile"
        elseif strcmp(folder(f).name, 'Old')
            color = colors.age(2, :);  % Color for "old"
        end

        % Plot spikes for each neuron
        list_of_neurons = unique(spks(:, 1));

        for n = 1:size(list_of_neurons, 1)
            index = (find(matrix_spks(n,:)));   % Get spike times for each neuron
            x = index * dt;                     % Convert spike times to seconds
            y = ones(1, size(x, 2)) * n;        % Assign y coordinates to neurons
            scatter(x, y, 5, 'filled', 'MarkerFaceColor', color);  % Plot the spikes
        end

        % Set axis labels and limits
        xlabel('Time (s)');
        xlim([min_plottime, max_plottime]); % Time window for x-axis
        ylim([0.5, (n + 0.5)]);             % Number of neurons for y-axis
        ylabel('Neuron Nº');

        % Title for each plot
        title(sprintf('%s', of_name));

        % Plot stimulus start time as a red line
        x_line = [stim, stim];
        y_line = [0.5, n + 0.5];
        plot(x_line, y_line, 'r-', 'LineWidth', 2); 
        text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);

        hold off;

    end
end

%% Save the figure as an image
output_folder = 'Figures_folder\RasterPlot'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'RasterPlot.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to full screen
set(gcf, 'Position', screenSize);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

