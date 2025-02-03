% Crear la figura
figure;

% Definir una distribución de subgráficos 2x2
t = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact'); 

% Definir etiquetas y colores para la leyenda
legend_labels = {'Non-oscillatory', 'Oscillator', 'Burster', 'Pauser'};
colors = [
    [46, 204, 113] / 255;   % Non-oscillatory
    [52, 152, 219] / 255;   % Oscillator
    [243, 156, 18] / 255;   % Burster
    [142, 68, 173] / 255    % Pausers (Morado)
    %[189, 195, 199] / 255   % No info (Gris)
    ];
%colors = lines(length(legend_labels));

% Crear 4 subgráficos con diferentes datos
for i = 1:4
    nexttile; % Moverse al siguiente subplot
    hold on;
    
    % Graficar múltiples líneas con diferentes colores en cada subplot
    for j = 1:length(legend_labels)
        plot(rand(1, 10) * (i + 1), 'Color', colors(j, :), 'LineWidth', 1.5);
    end

    title(['Subgráfico ', num2str(i)]);
    hold off;
end

% Crear la leyenda global debajo de todos los subgráficos
lgd = legend(legend_labels, 'Location', 'southoutside', 'Orientation', 'horizontal');
lgd.Layout.Tile = 'south'; % Posicionar la leyenda en la parte inferior de la figura

% Agregar un título general a la figura
sgtitle('Título General de la Figura');
