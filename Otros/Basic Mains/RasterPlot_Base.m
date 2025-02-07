%% Rasterplot
clear
close all

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

%% Raster Plot
figure;
hold on;

n_neuron = data_spk(end,1);
for n = 1:n_neuron
    index = (find(matriz_spks(n,:)));
    x = index*dt;
    y = ones(1, size(x,2))* n;
    scatter(x, y, 5, 'filled', 'MarkerFaceColor', [0.1, 0.1, 0.6]);
end

xlabel('Time (s)');

ylim([0.5, (n_neuron + 0.5)])
yticks(0:5:n_neuron+1);
ylabel('Nº Neuron');

% Stimulus start marker
x_line = [stim, stim]; 
y_line = [0.5, n_neuron + 0.5]; 
plot(x_line, y_line, 'r-', 'LineWidth', 2);
text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);


title(sprintf('Raster Plot of %s with dt = 1 * 10^{-%d}', file, i));
hold off;
