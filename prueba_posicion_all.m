%% Types Of Neurons
clear
close all

addpath('Functions');

colors = [
    [46, 204, 113] / 255;   % Non-oscillatory
    [52, 152, 219] / 255;   % Oscillator
    [243, 156, 18] / 255;   % Burster
    [142, 68, 173] / 255    % Pausers (Morado)
    ];
        
Type_of_Neurons = load("Types_of_Neurons_Reduced_data_dt4");

% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

[Juv, Old] = folder.name;

% Iterate over the subfolders inside the main folder
for f = 1:length(folder)
    % Subfolder path
    folder_path = fullfile(main_folder, folder(f).name);
    
    % Get the files within the subfolders
    file = dir(fullfile(folder_path, '*.mat'));
    fprintf('Inside %s\n', string(folder(f).name));
    if folder(f).name == Juv
        Juv_non_osc = [];
        Juv_osc = [];
        Juv_burs = [];
        Juv_paus = [];
        Juv_noinfo = [];

    elseif folder(f).name == Old
        Old_non_osc = [];
        Old_osc = [];
        Old_burs = [];
        Old_paus = [];
        Old_noinfo = [];
    end
    
    % Iterate over the files inside the subfolder
    for a = 1:length(file)
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

        total_non_osc = 0;
        total_osc = 0;
        total_burs = 0;
        total_paus = 0;
        total_noinfo = 0;

        figure;
        hold on

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
                color = colors(1,:);
                total_non_osc = total_non_osc + 1;
                if isempty(hNonOscillatory)  % Comprobar si ya se asignó un handle
                    hNonOscillatory = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'Oscillator')
                color = colors(2,:);
                total_osc = total_osc + 1;
                if isempty(hOscillator)
                    hOscillator = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'Burster')
                color = colors(3,:);
                total_burs = total_burs + 1;
                if isempty(hBurster)
                    hBurster = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end
            elseif strcmp(type, 'Pauser')
                color = colors(4,:);
                total_paus = total_paus + 1;
                if isempty(hPauser)
                    hPauser = plot(NaN, NaN, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
                end

            end

            % Graficar el punto correspondiente
            plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k'); % Puntos marcados en color según tipo

            % Colocar el número en el centro del punto
            text(data_x(n), data_y(n), num2str(n), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');
        end

        % Añadir leyenda con los colores correctos
        legend([hNonOscillatory, hOscillator, hBurster, hPauser, hNoInfo], ...
            {'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser'}, ...
            'TextColor', 'black', 'Location', 'bestoutside');

        % Añadir etiquetas y título
        xlabel('X Axis');
        ylabel('Y Axis');
        title(sprintf('Position Plot of %s', oficial_name));
        grid on;

        % Guardar la figura como imagen
        output_folder = 'C:\Users\javie\OneDrive\Escritorio\GitHub\Practica\TestFigures2';

        % Crear la carpeta si no existe
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end

        output_file = fullfile(output_folder, (sprintf('Position_Plot_of_%s.png', newname)));

        % Obtener las dimensiones de la pantalla
        screenSize = get(0, 'ScreenSize');
        
        % Establecer la ventana de la figura en pantalla completa
        set(gcf, 'Position', screenSize/2);
        exportgraphics(gcf, output_file, 'BackgroundColor', 'white');
        hold off;

        total_data = [total_non_osc, total_osc, total_burs, total_paus];  % Porcentajes para cada segmento
        tags = {'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser'};

        figure;
        pie(total_data, tags);
        legend({'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser', 'No info'}, ...
            'TextColor', 'black', 'Location', 'bestoutside');
        colormap(colors);  
        title(sprintf('Pie Plot of %s', oficial_name));

        output_file = fullfile(output_folder, (sprintf('Pie_Plot_of_%s.png', newname)));

        % Obtener las dimensiones de la pantalla
        screenSize = get(0, 'ScreenSize');
        
        % Establecer la ventana de la figura en pantalla completa
        set(gcf, 'Position', screenSize/2);
        exportgraphics(gcf, output_file, 'BackgroundColor', 'white');
        hold off;

    end 
    
end


%close all
clear

