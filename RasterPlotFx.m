function matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt)

    % Se calcula el numero de spks totales registrados
    filas = size(data_spk,1);
        
    % Se calcula el numero de neuronas
    n_neuronas = data_spk(end,1);
        
    % Se calcula el tiempo maximo
    max_time = sscanf(data_maxtime, '%d')*60;

    % Se calcula el numero de puntos temporales
    m_tiempos = ceil(max_time/dt);

    % Se crea la nueva matriz
    m = zeros(n_neuronas, m_tiempos);
        
    % Se itera
    for j = 1:filas
        for t = 1:m_tiempos
            % Se calcula el tiempo en el nodo t
            time = t*dt;
            % Si el spk corresponde al tiempo, se coloca un 1 en la matriz m
            if abs(data_spk(j,2) - time) < dt
                n_neurona2 = data_spk(j,1);
                m(n_neurona2, t) = 1;
                break;
            end
        end
    end
    matriz_spks = m;

end
