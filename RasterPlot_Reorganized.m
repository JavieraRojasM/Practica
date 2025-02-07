%% Rasterplot by type of neuron of all files in one figure

% This script generates a raster plot for multiple spike data files. 
% Each file is reduced based on the stimulus times and plotted in a grid 
% of subplots. Neurons are categorized by type (Non-oscillatory, Oscillator, 
% Burster, Pauser), with each type displayed in a different color. 
% A red line indicates the stimulus application time for each file.

% Javiera Rojas 07/02/2025

disp('Running Raster Plot by Type of Neuron...')

% Initialize the count and vectors
file_count = 0;

% Create a figure with a tiled layout
figure;
tiledlayout(2, 3);  % Create a 2x3 grid layout for the plots

sgtitle(sprintf('Raster Plot by type of neuron dt = 1 * 10^{-%d}, %s', i, file_name), 'FontSize', 14, 'FontWeight', 'bold');

% Define references for the legend
hNonOscillatory = [];  % Initialize as empty
hOscillator = [];
hBurster = [];
hPauser = [];

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolder
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        spks_org = [];  % Initialize to store the filtered spike data

        % Increment file count for each processed file
        file_count = file_count + 1;

        % Get the file path
        file_path = fullfile(folder_path, file(a).name);

        % Folder and file names
        [~, name, ~] = fileparts(file(a).name);
        of_name = string(folder(f).name) + ", " + name;

        newname = string(folder(f).name) + "_" + name;
        
        % Load the .mat file containing spike data
        data = load(file_path);
        data_spk = data.spks;  % Extract spike data
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60;  % Convert stimulus time from minutes to seconds

        % Define the time window for plotting
        min_plottime = stim - 10;
        max_plottime = max_time + stim;

        % Filter spike data to the defined time window
        spks = data_spk;
        spks(spks(:, 2) < min_plottime, :) = []; 
        spks(spks(:, 2) > max_plottime, :) = []; 

        % Create the spike matrix for raster plot
        matrix_spks = RasterPlotFx(spks, max_plottime, dt);

        list_of_neurons = unique(spks(:, 1));  % Get unique neuron IDs

        % Create subplot for the raster plot
        nexttile;  % Use nexttile to position the plot in the next available tile
        hold on;

        n_neuron = 1;  % Initialize neuron counter

        % Iterate over each neuron type and select the corresponding neurons
        for type = 2: (size(Type_of_Neurons.data_set.(newname)(:,1), 1) - 1)
            type_name = Type_of_Neurons.data_set.(newname){type, 1};
            color = colors.type(type - 1, :);  % Assign color based on neuron type
            
            % Plot handle for the first occurrence of each neuron type for legend
            if strcmp(type_name, 'Non-oscillatory')
                if isempty(hNonOscillatory)  
                    hNonOscillatory = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type_name, 'Oscillator')
                if isempty(hOscillator)
                    hOscillator = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type_name, 'Burster')
                if isempty(hBurster)
                    hBurster = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type_name, 'Pauser')
                if isempty(hPauser)
                    hPauser = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            end 

            % Iterate through each neuron ID within the type
            for indx = 1:size(Type_of_Neurons.data_set.(newname){type,2}, 2)
                id = Type_of_Neurons.data_set.(newname){type,2}(1,indx);
                index = (find(matrix_spks(id,:)));  % Get the spike index for the neuron
                x = index*dt;  % Convert spike times to seconds
                y = ones(1, size(x,2))* n_neuron;  % Assign y coordinates to the neurons
                scatter(x, y, 5, 'filled', 'MarkerFaceColor', color);  % Plot the spikes
                n_neuron = n_neuron + 1;  % Increment neuron counter
            end
        end

        % Set axis labels and limits
        xlabel('Time (s)');
        xlim([min_plottime, max_plottime]); % Time window for x-axis
        ylim([0.5, (n_neuron + 0.5)]);             % Number of neurons for y-axis
        ylabel('Neuron');

        % Title for each plot
        title(sprintf('%s', of_name));

        % Plot stimulus start time as a red line
        x_line = [stim, stim];
        y_line = [0.5, n_neuron + 0.5];
        plot(x_line, y_line, 'r-', 'LineWidth', 2); 
        text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);

        hold off;
    end
end

% Add a legend for neuron types
legend([hPauser, hBurster, hOscillator, hNonOscillatory], ...
            { 'Pauser', 'Burster', 'Oscillator', 'Non-oscillatory'}, ...
            'TextColor', 'black', 'Location', 'best');

% Save the figure as an image
output_folder = 'Figures_folder\RasterPlot'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'RasterPlot_by_Type.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to full screen
set(gcf, 'Position', screenSize);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

