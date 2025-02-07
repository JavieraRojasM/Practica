%% Pie plot of type of neurons

% This script generates pie plots for the different types of neurons 
% (Non-oscillatory, Oscillator, Burster and Pauser) of all data sets.
% Each type of neuron has its own color assigned.

% Javiera Rojas 7/02/2025

disp('Running Pie plot of type of neurons...')

% Create a figure
figure;
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
sgtitle(sprintf('Pie plot of type of neuron, %s', file_name), 'FontSize', 14, 'FontWeight', 'bold');

% Legend labels for neuron types
legend_labels = { 'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser', 'No info'};

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    folder_path = fullfile(main_folder, folder(f).name);
    file = dir(fullfile(folder_path, '*.mat'));
    
    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        file_path = fullfile(folder_path, file(a).name);
        [~, filename, ~] = fileparts(file(a).name);

        newname = string(folder(f).name) + "_" + filename;  
        oficial_name = string(folder(f).name) + ", " + filename; 

        % Loop through neuron types and accumulate total counts
        for row = 2:size(Type_of_Neurons.data_set.(newname), 1)
            type = Type_of_Neurons.data_set.(newname){row, 1};
            
            % Assign the total neuron count for each type
            if strcmp(type, 'Non-oscillatory')
                total_non_osc = Type_of_Neurons.data_set.(newname){row, 3};
            elseif strcmp(type, 'Oscillator')
                total_osc = Type_of_Neurons.data_set.(newname){row, 3};
            elseif strcmp(type, 'Burster')
                total_burs = Type_of_Neurons.data_set.(newname){row, 3};
            elseif strcmp(type, 'Pauser')
                total_paus = Type_of_Neurons.data_set.(newname){row, 3};
            elseif strcmp(type, 'No info')
                total_noinfo = Type_of_Neurons.data_set.(newname){row, 3};
            end
        end
        
        % Create the subplot for this specific file
        nexttile;
        hold on;

        % Values for the pie chart (number of neurons for each type)
        total_data = [total_non_osc, total_osc, total_burs, total_paus];

        % Filter values that are zero (avoid displaying them in the pie chart)
        valid_idx = total_data > 0;
        filtered_values = total_data(valid_idx);
        filtered_colors = colors.type(valid_idx, :);  % Assign colors based on the neuron type
        filtered_labels = legend_labels(valid_idx);

        % Create the pie chart
        h = pie(filtered_values);
        
        % Apply colors and format labels
        for k = 1:length(filtered_values)
            set(h(2*k-1), 'FaceColor', filtered_colors(k, :));  % Set the color for each sector
            textHandle = h(2*k);                                % Get the label for each slice
            textHandle.FontSize = 10;                           % Set font size for labels
            textHandle.FontWeight = 'bold';                     % Make the font bold
            textHandle.Color = 'k';                             % Set text color to black for better visibility
            
            % Move the label inside the slice
            pos = textHandle.Position;          % Get the original label position
            textHandle.Position = pos * 0.6;    % Adjust the position closer to the center
        end

        % Remove grid and axes for a clean pie chart
        axis off;
        
        % Title for each subplot
        title(sprintf('%s', oficial_name), 'FontWeight', 'bold');
        
        hold off;
    end
end

% Add a general legend for the plot
lgd = legend(legend_labels, 'Orientation', 'vertical', 'Location', 'east', 'FontSize', 12);
lgd.Layout.Tile = 'east'; 

%% Save the figure as an image
output_folder = 'Figures_folder\Pie Plot'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'Pie_plot_of_type_of_Neuron.png');  

figPos = get(gcf, 'Position');  % Get the current position of the figure
figWidth = figPos(3);           % Width of the figure
figHeight = figPos(4);          % Keep the default height of MATLAB figure

% Adjust the size of the figure
set(gcf, 'Position', [0, 1, figWidth*2.2, figHeight*1.8]);

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;
