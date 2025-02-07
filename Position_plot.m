%% Position plot by type of neuron

% This script generates position plots for multiple spike data files, 
% displaying the x and y coordinates of each neuron. 
% Neurons are categorized into types (Pauser, Burster, Oscillator, 
% Non-oscillatory) and each type is represented by a different color.

% Javiera Rojas 07/02/2025

disp('Running Position plot by type of neuron...')

% Create a figure with a tiled layout
figure;
tiledlayout(2, 3);

sgtitle('Position plot by type of neuron', 'FontSize', 14, 'FontWeight', 'bold');


% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));
    
    % Iterate over the files inside the subfolder
    for a = 1:length(file)

        % Get the file path
        file_path = fullfile(folder_path, file(a).name);

        % Folder and file names
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + "_" + filename;
        oficial_name = string(folder(f).name) + ", " + filename;
        
        % Load the data from the file
        data = load(file_path);
        data_x = data.x;  % X coordinates of the data points
        data_y = data.y;  % Y coordinates of the data points

        %% Use nexttile to position the plot in the next available tile
        nexttile;  % Automatically positions the plot in the next tile
        hold on;

        % Initialize variables for the legend handles
        hNonOscillatory = [];  % Initialize as empty
        hOscillator = [];
        hBurster = [];
        hPauser = [];
        hNoInfo = [];

        % Iterate over all data points (neurons)
        for n = 1:size(data_x, 2)
            found_in_row = [];  % Variable to store the row where the neuron is found

            % Search for the neuron in the Type_of_Neurons data set
            for row = 2:size(Type_of_Neurons.data_set.(newname), 1)  % Starting from row 2 to avoid headers
                neurons = Type_of_Neurons.data_set.(newname){row, 2};  % Get the list of neuron IDs
                if ismember(n, neurons)  % Check if the neuron is present
                    found_in_row = row;  % Store the row index
                    break;  % Exit the loop once the neuron is found
                end
            end
            
            % If the neuron is found, get its type, otherwise label as 'No info'
            if isempty(found_in_row)
                type = 'No info';
            else
                type = Type_of_Neurons.data_set.(newname){found_in_row, 1};
            end 

            % Select color for the neuron type
            if strcmp(type, 'Non-oscillatory')
                color = colors.type(1,:);
                if isempty(hNonOscillatory)  % Check if handle is assigned
                    hNonOscillatory = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'Oscillator')
                color = colors.type(2,:);
                if isempty(hOscillator)
                    hOscillator = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'Burster')
                color = colors.type(3,:);
                if isempty(hBurster)
                    hBurster = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'Pauser')
                color = colors.type(4,:);
                if isempty(hPauser)
                    hPauser = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'No info')
                color = colors.type(5,:);
                if isempty(hNoInfo)
                    hNoInfo = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            end

            % Plot the corresponding data point for the neuron
            plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');  % Mark the point with the selected color

            % Add the neuron number in the center of the point
            text(data_x(n), data_y(n), num2str(n), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');
        end

        % Add labels and title
        xlabel('X Axis');
        ylabel('Y Axis');
        title(sprintf('Position Plot of %s', oficial_name));  % Title for each plot
        grid on;  % Add grid to the plot

    end 
end

% Add a legend for different neuron types
legend([hPauser, hBurster, hOscillator, hNonOscillatory], ...
            { 'Pauser', 'Burster', 'Oscillator', 'Non-oscillatory'}, ...
            'TextColor', 'black', 'Location', 'best');

% Save the figure as an image
output_folder = 'Figures_folder\PositionPlot_by_Type'; 

% Create the folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the output file path and name
output_file = fullfile(output_folder, 'PositionPlot_by_Type.png');  

% Get the screen dimensions
screenSize = get(0, 'ScreenSize'); 

% Set the figure window to full screen
set(gcf, 'Position', screenSize);  

% Export the figure to the specified output file with a white background
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;
