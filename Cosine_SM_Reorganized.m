%% Cosine Similarity Matrix base 

% This script calculates and visualizes the cosine similarity matrix for 
% all the data sets with the neurons reorganized by type. 
% For each file, the script filters the data based on the stimulus time, 
% and then computes the cosine similarity between neurons based on their 
% spike trains. The diagonal of the similarity matrix (representing 
% self-similarity) is set to zero. 

% Javiera Rojas 7/02/2025

disp('Running Cosine Similarity Matrix Reorganized...')

% Create a figure 
figure;
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');  
sgtitle(sprintf('Similarity matrix reorganized by type of neuron%s', file_name), 'FontSize', 14, 'FontWeight', 'bold');

% Initiate vectors
mean_similarity = [];   % Vector for the mean similarity
names = [];
file_count = 0;         % Counter for files

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Get the full path to the subfolder
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get all files with .mat extension in the subfolder
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        spks_org = [];  % Variable to store filtered spike data for the current file

        % Get the file path
        file_path = fullfile(folder_path, file(a).name);

        
        % Folder and file names
        [~, name, ~] = fileparts(file(a).name);
        of_name = string(folder(f).name) + ", " + name;
        newname = string(folder(f).name) + "_" + name;    
        names = [names, of_name];

        file_name = string(file(a).name);
        
        % Increment file count for each file processed
        file_count = file_count + 1;

        % Create color vector for bar plot
        if strcmp(folder(f).name, 'Juvenile')
            colors_bar(file_count, :) = colors.age(1, :); % Color for "juvenile"
        
        elseif strcmp(folder(f).name, 'Old')
            colors_bar(file_count, :) = colors.age(2, :); % Color for "old"
        end


        % Load the .mat file containing spike data
        data = load(file_path);
        data_spk = data.spks;  % Extract spike data
        data_maxtime = data.file_length;  % Maximum time of the experiment
        
        % Get the time when the stimulus was applied
        data_stimtime = data.stim_time;
        stim = sscanf(data_stimtime, '%d') * 60;  % Minutes to seconds conversion

        % Filter the spike data based on the stimulus time
        spks = data_spk; 
        spks(spks(:, 2) < stim, :) = [];  % Filter by minimum time (before stimulus)
        spks(spks(:, 2) > max_time + stim, :) = [];  % Filter by maximum time (after stimulus)

        % Iterate over each neuron type and select the corresponding neurons
        for type = 2: (size(Type_of_Neurons.data_set.(newname)(:,1), 1) - 1)
            type_name = Type_of_Neurons.data_set.(newname){type, 1};  % Neuron type name

            % Iterate over each neuron ID within the type
            for indx = 1:size(Type_of_Neurons.data_set.(newname){type,2}, 2)
                id = Type_of_Neurons.data_set.(newname){type,2}(1,indx);  % Get the neuron ID
                found_in_row = [];  % Initialize variable to store the row where the neuron is found

                % Search for the row containing the current neuron ID in the spike data
                for row = 1:size(spks, 1) 
                    if ismember(id, spks(row, 1))  % Check if the neuron ID is present
                        found_in_row = row;  % Store the row index
                        break
                    end
                end
                
                % Collect spike data for the current neuron
                while spks(found_in_row,1) == id
                    spks_org = [spks_org; spks(found_in_row, :)];  % Append spike data for the neuron
                    found_in_row = found_in_row + 1;
                    if found_in_row > size(spks, 1)
                        break
                    end
                end
            end
        end
        
        spks = spks_org;  % Update the spike data with selected neurons

        % Extract unique neuron IDs
        neurons = unique(spks(:,1), 'stable');  % Get unique neuron IDs
        num_neurons = length(neurons);  % Number of neurons
        
        % Count the number of time points for each neuron
        [~, ~, bin_counts] = unique(spks(:,1), 'stable');
        max_time_points = max(accumarray(bin_counts, 1));  % Maximum number of time points for any neuron

        % Create a time series matrix to store the spike times for each neuron
        time_series = nan(num_neurons, max_time_points); 
        
        % Fill the time series matrix with the spike times for each neuron
        for nm = 1:num_neurons
            times = spks(spks(:,1) == neurons(nm), 2);   % Get spike times for each neuron
            time_series(nm, 1:length(times)) = times;    % Store spike times in the matrix
        end
        
        % Replace NaN values with zeros before further processing
        time_series(isnan(time_series)) = 0;
        
        % Normalize each row of the time series matrix (neuron's spike train)
        norm_data = time_series ./ vecnorm(time_series, 2, 2);
        
        % Calculate the cosine similarity matrix
        similarity_matrix = norm_data * norm_data';
        
        % Set the diagonal of the similarity matrix to zero (no self-similarity)
        similarity_matrix(eye(size(similarity_matrix)) == 1) = 0;

        mean_similarity_dataset = mean(mean(similarity_matrix));

        mean_similarity = [mean_similarity, mean_similarity_dataset];


        % Visualize the cosine similarity matrix
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
output_file = fullfile(output_folder, 'Cosine_SM_reorganized.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to full screen
set(gcf, 'Position', screenSize);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

% Bar plot
figure;
hold on 
for b = 1:length(mean_similarity)
    bar(bars(b), mean_similarity(b), 'FaceColor', colors_bar(b, :));
    %text(bars(b), mean_similarity(b), num2str(mean_similarity(b)), ...
        %'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

ylabel('Mean similarity');
title('Mean Similarity', 'FontSize', 14, 'FontWeight', 'bold');
xticks(bars);           % Bar location
xticklabels(names);     % Bar tag
rounded_up_yMax = max(mean_similarity);
ylim([0, rounded_up_yMax + 0.1]);
grid on;


%% Save the figure as an image

% Define the output file path and name
output_file = fullfile(output_folder, 'Mean_similarity.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to half full screen
set(gcf, 'Position', screenSize/2);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

