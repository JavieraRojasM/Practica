%% Average plot
clear
close all

addpath('Functions');

% Chosee of the data
%[file, path] = uigetfile;
%file_path = fullfile(path, file);

file_path = "C:\Users\javie\OneDrive\Escritorio\Datos\Juvenile\Jul1119_1.mat";
[~, file] = fileparts(file_path);


% Load the file
data = load(file_path);
data_spk = data.spks;
data_maxtime = data.file_length;

% Get the time of application of the stimulus
stimtime = data.stim_time;
stim = sscanf(stimtime, '%d')*60; % Minute to seconds conversion

% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]

% Get the spikes matrix
matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt);


% Initiate the average vector
average = zeros(1, size(matriz_spks,2));

for t = 1:size(matriz_spks,2)
    average(1, t) = sum(matriz_spks(:,t)) / size(matriz_spks,1);
end

total_time = dt:dt:(sscanf(data_maxtime, '%d')*60);

%% Plot
figure;
hold on;

y_smooth = movmean(average, 200); % smoothed points

plot(total_time, y_smooth, 'b', 'LineWidth', 1); % Add tendency line

xlabel('Time (s)');

% Stimulus start marker
x_line = [stim, stim]; 
y_line = [0, max(y_smooth)]; 
plot(x_line, y_line, 'r-', 'LineWidth', 1);
text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);

title(sprintf('Average spike for Neuron of %s with dt = 1 * 10^{-%d}', file, i));
grid on
hold ;
