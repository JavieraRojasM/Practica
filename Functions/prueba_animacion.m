close all

file_path = "C:\Users\javie\OneDrive\Escritorio\Datos\Old\Dec1622_1.mat";
[~, file] = fileparts(file_path);


% Load the file
data = load(file_path);
data_x = data.x;
data_y = data.y;
data_spk = data.spks;
data_maxtime = data.file_length;

% The time step is 10^-i
% Select i:
i = 1;
% Time step
dt = 1*10^-i; %[s]

% Get the spikes matrix
matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt);

figure;
hold on

xlabel('X Axis');

ylabel('Y Axis');

title(sprintf('Position Plot of %s', file));

grid on; % Activar la cuadrícula para mayor claridad

% Animar el punto
for k = 1:size(matriz_spks, 2)

    for n = 1:size(data_x,2)


        if matriz_spks(n, k) == 0            
            plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', [0.5, 0.8, 1.0], 'MarkerEdgeColor', 'k'); % Puntos marcados en azul
        end
        
        if k > 1
            if matriz_spks(n, k-1) == 1
                plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', [255, 200, 100] / 255 , 'MarkerEdgeColor', 'k'); % Puntos marcados en rojo
            else
                plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', [0.5, 0.8, 1.0], 'MarkerEdgeColor', 'k'); % Puntos marcados en azul
            end
        end

        if matriz_spks(n, k) == 1
            plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor','r' , 'MarkerEdgeColor', 'k'); % Puntos marcados en rojo
                
        end


        % Colocar el número en el centro del punto
        text(data_x(n), data_y(n), num2str(n), ... % El texto será el índice del punto
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');
    
    end 

    % Obtener límites del eje
    xLimits = xlim; % Límites del eje X
    yLimits = ylim; % Límites del eje Y
    
    % Agregar texto en la esquina superior izquierda (coordenadas del gráfico)
    text(xLimits(2), yLimits(2), sprintf('Tiempo: %d (s)', k*dt), ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 10, ...
        'BackgroundColor', 'w', ...
        'EdgeColor', 'k');

    % Pausa para visualizar el movimiento
    pause(0.05);
    
end

hold off