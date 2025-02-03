function matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt, data_mintime)
    % Esta función crea la matriz binaria de spikes
    % spike -> 1; no spike -> 0
    
    if nargin < 4
        data_mintime = 0; % Tiempo mínimo predeterminado
    end
    
    % Obtener el número total de neuronas
    n_neuron = data_spk(end, 1);
    
    % Convertir `data_maxtime` a segundos si es una cadena o número
    if ischar(data_maxtime) || isstring(data_maxtime)
        maxtime = sscanf(data_maxtime, '%d') * 60; % Convertir minutos a segundos
    elseif isnumeric(data_maxtime)
        maxtime = data_maxtime;
    end
    
    % Ajustar los tiempos mínimo y máximo al intervalo
    min_time = floor(data_mintime);
    max_time = ceil(maxtime);
    matrix_time = ceil((max_time - min_time) / dt);
    
    % Inicializar la matriz binaria de spikes
    matrix = zeros(n_neuron, matrix_time);
    
    % Iterar sobre las filas de `data_spk`
    row = 1;
    while row <= size(data_spk, 1)
        neuron_id = data_spk(row, 1);  % Obtener el ID de la neurona
        spike_time = data_spk(row, 2);  % Tiempo del spike
        
        % Calcular el índice de tiempo correspondiente al spike
        t_index = floor((spike_time - min_time) / dt) + 1;
        
        % Verificar si el índice está dentro de los límites de la matriz
        if t_index > 0 && t_index <= matrix_time
            % Actualizar la matriz si aún no se marcó
            if matrix(neuron_id, t_index) == 0
                matrix(neuron_id, t_index) = 1;
            end
        end
        
        % Avanzar a la siguiente fila de `data_spk`
        row = row + 1;
    end
    
    % Devolver la matriz binaria con los spikes
    matriz_spks = matrix;
end
