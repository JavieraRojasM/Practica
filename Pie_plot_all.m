%% Types Of Neurons
clear
close all

addpath('Functions');
load("colors.mat")

%Type_of_Neurons_name = "NT_EC_maxtime_90";
Type_of_Neurons_name = "NT_CC_maxtime_90_binsize_e0";
%Type_of_Neurons_name = "NT_CC_maxtime_90_binsize_e1";

Type_of_Neurons = load(Type_of_Neurons_name);

if contains(Type_of_Neurons_name, 'EC')
    file_name = erase(Type_of_Neurons_name, '_');
    file_name = erase(file_name, 'NT');
    file_name = erase(file_name, 'maxtime');
    file_name = replace(file_name, 'EC', 'External Code, maximum analysis time ');
elseif contains(Type_of_Neurons_name, 'CC')
    file_name = erase(Type_of_Neurons_name, '_');
    file_name = erase(file_name, 'NT');
    file_name = erase(file_name, 'maxtime');
    file_name = erase(file_name, 'binsize');
    file_name = replace(file_name, 'e', '[s], bin size 1 * 10^');
    file_name = replace(file_name, 'CC', 'Custom Code, maximum analysis time ');
end

% Definir la carpeta principal
main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Obtener subcarpetas dentro de la carpeta principal
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

file_count = 0;

% Crear la figura con distribución adecuada
figure;
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
sgtitle(sprintf('Pie plot of type of neuron, %s', file_name), 'FontSize', 14, 'FontWeight', 'bold');

% Etiquetas de la leyenda
legend_labels = { 'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser', 'No info'};

% Iterar sobre las subcarpetas dentro de la carpeta principal
for f = 1:length(folder)
    folder_path = fullfile(main_folder, folder(f).name);
    file = dir(fullfile(folder_path, '*.mat'));
    
    fprintf('Inside %s\n', string(folder(f).name));

    % Iterar sobre los archivos dentro de la subcarpeta
    for a = 1:length(file)
        file_count = file_count + 1;
        file_path = fullfile(folder_path, file(a).name);
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + "_" + filename;
        oficial_name = string(folder(f).name) + ", " + filename;
        
        fprintf('Analyzing %s\n', string(file(a).name));

        % Obtener los valores de cada categoría
        total_non_osc = 0;
        total_osc = 0;
        total_burs = 0;
        total_paus = 0;
        total_noinfo = 0;

        for row = 2:size(Type_of_Neurons.data_set.(newname), 1)
            type = Type_of_Neurons.data_set.(newname){row, 1};
            
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
        
        % Crear el subplot
        nexttile;
        hold on;

        legend_labels = { 'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser', 'No info'};


        % Vector de valores
        total_data = [total_non_osc, total_osc, total_burs, total_paus, total_noinfo];

        % Filtrar valores que son cero
        valid_idx = total_data > 0;
        filtered_values = total_data(valid_idx);
        filtered_colors = colors.type(valid_idx, :);
        filtered_labels = legend_labels(valid_idx);

        % Graficar el pie chart
        h = pie(filtered_values);
        
        % Aplicar colores y formatear etiquetas
        for k = 1:length(filtered_values)
            set(h(2*k-1), 'FaceColor', filtered_colors(k, :)); % Color de cada sector
            textHandle = h(2*k); % Obtener la etiqueta de porcentaje
            textHandle.FontSize = 10;
            textHandle.FontWeight = 'bold';
            textHandle.Color = 'k '; % Blanco para mejor visibilidad
            
            % Mover la etiqueta dentro del sector
            pos = textHandle.Position; % Obtener la posición original
            textHandle.Position = pos * 0.6; % Acercarlo al centro
        end

        % Eliminar grid y ejes
        axis off;
        % Título del subplot
        title(sprintf('%s', oficial_name), 'FontWeight', 'bold');
        
        hold off;
    end
end

%Agregar la leyenda general
lgd = legend(legend_labels, 'Orientation', 'vertical', 'Location', 'east', 'FontSize', 12);
lgd.Layout.Tile = 'east';

%Guardar la figura como imagen
output_folder = 'C:\Users\javie\OneDrive\Escritorio\GitHub\Practica\TestFigures2\Pie Plot';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

output_file = fullfile(output_folder, sprintf('Pie_Plot_%s.png', Type_of_Neurons_name));

% Ajustar la ventana a pantalla completa y guardar la imagen

figPos = get(gcf, 'Position'); % Obtener la posición actual de la figura
figWidth = figPos(3); % Ancho de la pantalla
figHeight = figPos(4); % Mantener la altura predeterminada de MATLAB

% Ajustar la posición y tamaño de la figura
set(gcf, 'Position', [0, 1, figWidth*2.2, figHeight*1.8]);

exportgraphics(gcf, output_file, 'BackgroundColor', 'white');

hold off;

clear
close all
