%% Similitud del Coseno en MATLAB

% Datos de ejemplo: Neuronas y sus tiempos de activación
data = [1 389.1147; 1 389.2154; 1 389.6771; 1 389.6795; 1 389.6844;
        2 300.6187; 2 301.0337; 2 301.0386; 2 301.2326; 2 301.4708;
        3 280.3451; 3 281.5678; 3 281.9234; 3 282.7854];

% Extraer identificadores de neuronas
neurons = unique(data(:,1)); % Neuronas únicas
num_neurons = length(neurons);

% Crear una matriz de series temporales (rellenando con NaN)
max_time_points = max(histc(data(:,1), neurons));
time_series = nan(num_neurons, max_time_points); % Matriz de datos

% Rellenar la matriz con los tiempos de cada neurona
for i = 1:num_neurons
    times = data(data(:,1) == neurons(i), 2);
    time_series(i, 1:length(times)) = times; % Guardar en la matriz
end

% Reemplazar NaN con ceros antes del cálculo
time_series(isnan(time_series)) = 0;

% Normalizar los vectores fila para calcular la similitud del coseno
norm_data = time_series ./ vecnorm(time_series, 2, 2);

% Calcular la matriz de similitud del coseno
similarity_matrix = norm_data * norm_data';

% Visualizar la matriz de similitud
figure;
imagesc(similarity_matrix);
colorbar;
colormap('parula');
axis square;
title('Cosine Similarity Matrix', 'FontSize', 14, 'FontWeight', 'bold');

% Etiquetas de ejes
xticks(1:num_neurons);
yticks(1:num_neurons);
xlabel('Neuron Index', 'FontSize', 12);
ylabel('Neuron Index', 'FontSize', 12);
