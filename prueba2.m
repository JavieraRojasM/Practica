%% Rasterplot de todos
clear
close all

% Se cargan los datos
%[archivo, path] = uigetfile;
%rutaPrincipal = fullfile(path, archivo);

rutaPrincipal = "C:\Users\javie\OneDrive\Escritorio\Datos";

% Obtener las subcarpetas dentro de la carpeta principal
subcarpetas = dir(rutaPrincipal);
subcarpetas = subcarpetas(~ismember({subcarpetas.name}, {'.', '..'})); % Excluir '.' y '..'

total_archivos = 0;
nombres = [];
total_spks = [];

% El paso temporal tomado es 10^-i
%Elegir i:
i = 1;

% Se calcula el paso temporal
dt = 1*10^-i; %[s]

contador_archivo = 0;
% Iterar sobre las subcarpetas
for s = 1:length(subcarpetas)
    % Ruta de la subcarpeta actual
    rutaSubcarpeta = fullfile(rutaPrincipal, subcarpetas(s).name);
    
    % Obtener los archivos de la subcarpeta actual
    archivos = dir(fullfile(rutaSubcarpeta, '*.mat'));

    total_archivos = total_archivos + length(archivos);


    % Iterar sobre los archivos de la subcarpeta
    for a = 1:length(archivos)
        % Ruta completa del archivo
        rutaArchivo = fullfile(rutaSubcarpeta, archivos(a).name);

        % Nombre de la carpeta en que estoy trabajando
        name = string(subcarpetas(s).name) + ", " + string(archivos(a).name);
        newname = erase(name, ".mat");
        
        % Cargar o procesar el archivo
        datos = load(rutaArchivo); % Ejemplo: cargar archivo .mat

        spikesstruct = datos.spks;
        
        % Se calcula el numero de spks totales registrados
        filas = size(spikesstruct,1);
        
        % Se calcula el numero de neuronas
        n_neuronas = spikesstruct(end,1);
        
        % El paso temporal tomado es 10^-i
        %Elegir i:
        i = 2;
        
        % Se calcula el paso temporal
        dt = 1*10^-i; %[s]
        
        % Se calcula el tiempo maximo
        time = datos.file_length;
        max_time = sscanf(time, '%d')*60;

        % Se calcula el numero de puntos temporales
        m_tiempos = ceil(max_time)/dt;

        % Se crea la nueva matriz
        m = zeros(n_neuronas, m_tiempos);
        
        % Se itera
        for j = 1:filas
          for t = 1:m_tiempos
            % Se calcula el tiempo en el nodo t
            time = t*dt;
            % Si el spk corresponde al tiempo, se coloca un 1 en la matriz m
            if abs(spikesstruct(j,2) - time) < dt
              n_neurona2 = spikesstruct(j,1);
              m(n_neurona2, t) = 1;
              break;
            end
          end
        end
        
        contador_archivo = contador_archivo + 1;
        
        %% Raster Plot
        figure(contador_archivo)
        hold on
        for n = 1:n_neuronas
            indice = (find(m(n,:)));
            x = indice*dt;
            y = ones(1, size(x,2))* n;
            scatter(x, y, 8, 'filled', 'MarkerFaceColor', [0.1, 0.1, 0.6]);
        end
        
        xlabel('Tiempo (s)');
        xlim([-0.5, max_time])
        
        
        ylim([0.5, (n_neuronas + 0.5)])
        yticks(0:5:n_neuronas+1);
        ylabel('Nº Neurona');
        
        % Marcador de inicio de estimulo
        stimtime = datos.stim_time;
        stim = sscanf(stimtime, '%d')*60;
        x_line = [stim, stim]; 
        y_line = [0.5, n_neuronas + 0.5]; 
        plot(x_line, y_line, 'r-', 'LineWidth', 2);
        text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);
        
        
        title(sprintf('Raster Plot of %s with dt = 1 * 10^{-%d}', newname, i));
        hold off

    end

end
