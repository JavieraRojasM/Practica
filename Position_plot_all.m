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


% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

[Juv, Old] = folder.name;

file_count = 0;

% Create a figure
figure;
sgtitle(sprintf('Position plot by type of neuron, %s', file_name));


% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));
    fprintf('Inside %s\n', string(folder(f).name));
    
    % Iterate over the files inside the subfolder
    for a = 1:length(file)
        file_count = file_count + 1;
        % File path
        file_path = fullfile(folder_path, file(a).name);

        % Folder name
        [~, filename, ~] = fileparts(file(a).name);
        newname = string(folder(f).name) + "_" + filename;
        oficial_name = string(folder(f).name) + ", " + filename;
        
        
        fprintf('Analyzing %s\n', string(file(a).name));

        % Load the file
        data = load(file_path);
        data_x = data.x;
        data_y = data.y;

        %% SubPlot
        subplot(2, 3, file_count);
        hold on;

        % Definir las referencias para la leyenda
        hNonOscillatory = [];  % Inicializar como vacío
        hOscillator = [];
        hBurster = [];
        hPauser = [];
        hNoInfo = [];



        for n = 1:size(data_x, 2)
            found_in_row = []; % Variable para guardar la fila donde se encuentra

            % Recorremos las filas de la columna 'Neurons ID'
            for row = 2:size(Type_of_Neurons.data_set.(newname), 1) % Desde la fila 2 (evitar encabezados)
                neurons = Type_of_Neurons.data_set.(newname){row, 2}; % Obtener la lista de IDs de neuronas
                if ismember(n, neurons) % Verificar si la neurona está presente
                    found_in_row = row; % Guardar la fila donde se encuentra
                    break; % Salir del bucle si se encuentra
                end
            end
            
            if isempty(found_in_row)
                type = 'No info';
            else

                type = Type_of_Neurons.data_set.(newname){found_in_row, 1};
            end 

            % Select color for type
            if strcmp(type, 'Non-oscillatory')
                color = colors.type(1,:);
                if isempty(hNonOscillatory)  % Comprobar si ya se asignó un handle
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

            % Graficar el punto correspondiente
            plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k'); % Puntos marcados en color según tipo

            % Colocar el número en el centro del punto
            text(data_x(n), data_y(n), num2str(n), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');
        end



        % Añadir etiquetas y título
        xlabel('X Axis');
        ylabel('Y Axis');
        title(sprintf('Position Plot of %s', oficial_name));
        grid on;

    end 
    
end

legend([hPauser, hBurster, hOscillator, hNonOscillatory, hNoInfo], ...
            { 'Pauser', 'Burster', 'Oscillator', 'Non-oscillatory', 'No info'}, ...
            'TextColor', 'black', 'Location', 'best');


% Guardar la figura como imagen
output_folder = 'C:\Users\javie\OneDrive\Escritorio\GitHub\Practica\TestFigures2\Postion Plot';


% Crear la carpeta si no existe
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

output_file = fullfile(output_folder, sprintf('Position_Plot_%s.png', Type_of_Neurons_name));


% Obtener las dimensiones de la pantalla
screenSize = get(0, 'ScreenSize');

% Establecer la ventana de la figura en pantalla completa
set(gcf, 'Position', screenSize*1.5);
exportgraphics(gcf, output_file, 'BackgroundColor', 'white');
hold off;



close all
clear
