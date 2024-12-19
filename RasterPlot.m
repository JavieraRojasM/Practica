%% Rasterplot
clear
close all

% Se cargan los datos

%[archivo, path] = uigetfile;
%data_mat = fullfile(path, archivo);

data_mat = "C:\Users\javie\OneDrive\Escritorio\Datos\Juvenile\Jul1119_1.mat";
[~, archivo] = fileparts(data_mat);


% Cargar el archivo
data = load(data_mat);
data_spk = data.spks;
data_maxtime = data.file_length;

% Marcador de inicio de estimulo
stimtime = data.stim_time;
stim = sscanf(stimtime, '%d')*60;

% El paso temporal tomado es 10^-i
%Elegir i:
i = 1;
        
% Se calcula el paso temporal
dt = 1*10^-i; %[s]

% Funcion de raster plot
matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt);

%% Raster Plot
figure(1)
hold on

n_neuronas = data_spk(end,1);
for n = 1:n_neuronas
    indice = (find(matriz_spks(n,:)));
    x = indice*dt;
    y = ones(1, size(x,2))* n;
    scatter(x, y, 5, 'filled', 'MarkerFaceColor', [0.1, 0.1, 0.6]);
end

xlabel('Tiempo (s)');

ylim([0.5, (n_neuronas + 0.5)])
yticks(0:5:n_neuronas+1);
ylabel('Nº Neurona');

% Marcador de inicio de estimulo
x_line = [stim, stim]; 
y_line = [0.5, n_neuronas + 0.5]; 
plot(x_line, y_line, 'r-', 'LineWidth', 2);
text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);


title(sprintf('Raster Plot of %s with dt = 1 * 10^{-%d}', archivo, i));
hold off
