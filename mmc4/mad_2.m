function mad = mad_2(x, flag)
    % x: Vector de datos
    % flag: 0 (por defecto de la funcion nativa de Matlab, calcula MAD normal)
    
    % Calcula la mediana
    med_x = median(x);
    
    % Calcula la desviación absoluta respecto a la mediana
    abs_deviation = abs(x - med_x);
    
    % Calcula la mediana de las desviaciones absolutas
    mad = median(abs_deviation);

    % Escalado robusto (opcional)
    if flag == 1
        mad = mad * 1.4826; % Escala para estimar desviación estándar
    end
end