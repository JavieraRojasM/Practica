%% Rasterplot de todos
clear
close all

% Se cargan los datos
%[archivo, path] = uigetfile;
% main_folder = fullfile(path, archivo);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos";

% Obtener las subcarpetas dentro de la carpeta principal
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

file_count = 0;
names = [];
total_spks = [];

% El paso temporal tomado es 10^-i
%Elegir i:
i = 1;

% Se calcula el paso temporal
dt = 1*10^-i; %[s]

% Crear una figura
figure;

% Iterar sobre las subcarpetas

for f = 1:length(folder)
    % Ruta de la subcarpeta actual
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Obtener los archivos de la subcarpeta actual
    file = dir(fullfile(folder_path, '*.mat'));

    % Iterar sobre los archivos de la subcarpeta
    for a = 1:length(file)
        % Ruta completa del archivo
        file_path = fullfile(folder_path, file(a).name);

        % Nombre de la carpeta en que estoy trabajando
        [~, name, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + ", " + name;
        
        % Cargar el archivo
        data = load(file_path);
        data_spk = data.spks;
        data_maxtime = data.file_length;
        
        % Marcador de inicio de estimulo
        stimtime = data.stim_time;
        stim = sscanf(stimtime, '%d')*60;
        
        matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt);

        file_count = file_count + 1;
        %% Raster Plot
        subplot(2, 3, file_count);
        hold on;

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
        title(sprintf('Raster Plot of %s with dt = 1 * 10^{-%d}', newname, i));

        hold off;

    end

end
