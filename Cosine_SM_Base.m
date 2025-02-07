%% Cosine Similarity Matrix base 

% This script calculates and visualizes the cosine similarity matrix for 
% all the data sets. For each file, the script filters the data based on 
% the stimulus time, and then computes the cosine similarity between neurons 
% based on their spike trains. The diagonal of the similarity matrix 
% (representing self-similarity) is set to zero. 

% Javiera Rojas 7/02/2025

disp('Running Cosine Similarity Matrix base...')

file_name = erase(file_name, ', bin size 1 * 10^0');
% Create a figure
figure;
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact'); % Set up the tiled layout for multiple subplots
sgtitle(sprintf('Similarity matrix%s', file_name), 'FontSize', 14, 'FontWeight', 'bold');  % Set a title for the entire figure

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Get the full path to the subfolder
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get all files with .mat extension in the subfolder
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)

        % Get the file path
        file_path = fullfile(folder_path, file(a).name);

        % Get the file name and construct new name for the data structure
        [~, name, ~] = fileparts(file(a).name);
        of_name = string(folder(f).name) + ", " + name;
        newname = string(folder(f).name) + "_" + name;    
        
        % Load the spike data
        data = load(file_path);
        data_spk = data.spks; 
        data_maxtime = data.file_length;  
        
        % Get the time when the stimulus was applied
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion

        % Filter the spike data based on the stimulus time
        spks = data_spk; 
        spks(spks(:, 2) < stim, :) = [];
        spks(spks(:, 2) > max_time + stim, :) = [];

        % Extract unique neuron IDs
        neurons = unique(spks(:,1), 'stable');
        num_neurons = length(neurons); 
        
        % Count the number of time points for each neuron
        [~, ~, bin_counts] = unique(spks(:,1), 'stable');
        max_time_points = max(accumarray(bin_counts, 1));

        % Create a time series matrix to store the spike times for each neuron
        time_series = nan(num_neurons, max_time_points);  % Initialize matrix with NaN
        
        % Fill the time series matrix with the spike times for each neuron
        for nm = 1:num_neurons
            times = spks(spks(:,1) == neurons(nm), 2);   % Get spike times for each neuron
            time_series(nm, 1:length(times)) = times;    % Store spike times in the matrix
        end
        
        % Replace NaN values with zeros before further processing
        time_series(isnan(time_series)) = 0;
        
        % Normalize each row of the time series matrix (neuron's spike train)
        norm_data = time_series ./ vecnorm(time_series, 2, 2);
        
        % Compute the cosine similarity matrix using the normalized spike trains
        similarity_matrix = norm_data * norm_data';

        % Set the diagonal of the similarity matrix to zero (no self-similarity)
        similarity_matrix(eye(size(similarity_matrix)) == 1) = 0;

        % Visualize the similarity matrix
        nexttile;
        imagesc(similarity_matrix);  
        colorbar;  
        colormap('parula');  
        axis square;
        title(sprintf('%s', of_name), 'FontSize', 12); 
    end
end

%% Save the figure as an image
output_folder = 'Figures_folder\Cosine Similarity Matrix'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'Cosine_SM_base.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to full screen
set(gcf, 'Position', screenSize);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;
