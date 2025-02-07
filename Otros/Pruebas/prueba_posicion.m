close all

file_path = "C:\Users\javie\OneDrive\Escritorio\Datos\Juvenile\Jul1119_1.mat";
[~, file] = fileparts(file_path);


% Load the file
data = load(file_path);
data_x = data.x;
data_y = data.y;

% Folder name


figure;
hold on
for n = 1:size(data_x,2)
    plot(data_x(n), data_y(n), 'o', 'MarkerSize', 14, 'MarkerFaceColor', [0.5, 0.8, 1.0], 'MarkerEdgeColor', 'k'); % Puntos marcados en rojo
    % Colocar el número en el centro del punto
    text(data_x(n), data_y(n), num2str(n), ... % El texto será el índice del punto
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');

end 

xlabel('X Axis');

ylabel('Y Axis');

title(sprintf('Position Plot of %s', file));

grid on; % Activar la cuadrícula para mayor claridad

hold off