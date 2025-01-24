% Crear spike trains modificados
spike_trains = cell(13, 1);  % Total de neuronas: 4 oscilatorias + 2 no oscilatorias + 3 bursters + 4 pausers

% 1. Oscilatorias
spike_trains{1} = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1];
spike_trains{2} = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];
spike_trains{3} = [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1];
spike_trains{4} = [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0];

% 2. No oscilatorias
spike_trains{5} = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1];
spike_trains{6} = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0];

% 3. Bursters
spike_trains{7} = [1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1];
spike_trains{8} = [0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1];
spike_trains{9} = [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1];

% 4. Pausers
spike_trains{10} = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
spike_trains{11} = [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
spike_trains{12} = [0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0];
spike_trains{13} = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0];

% Visualización de spike trains
figure;
hold on;
for n = 1:length(spike_trains)
    scatter(find(spike_trains{n}), n * ones(sum(spike_trains{n}), 1), 10, 'k', 'filled');
end
xlabel('Tiempo (bins)');
ylabel('Neuronas');
title('Spike trains ajustados');
xlim([0 max(cellfun(@length, spike_trains))]);
ylim([0 length(spike_trains) + 1]);
grid on;
hold off;


%% Calcular auto-correlogramas y clasificar patrones
% Parámetros de auto-correlograma
max_lag = 20;                % Máximo lag en segundos
bin_size = 1;                % Tamaño del bin en segundos
edges = -max_lag:bin_size:max_lag;  % Límites de los bins

% Inicializar clases y auto-correlogramas
classes = zeros(num_neurons, 1);  % Clases: 1=Non-oscillatory, 2=Oscillators, 3=Bursters, 4=Pausers
auto_corrs = zeros(num_neurons, length(edges) - 1);  % Guardar auto-correlogramas

% Permutación para calcular límites
num_permutations = 100;
for n = 1:num_neurons
    spike_times = spike_trains{n};
    isi = diff(spike_times);  % Intervalos inter-spike
    autocorr_real = histcounts(isi, edges);  % Auto-correlograma real
    
    % Generar modelo nulo con permutaciones
    shuffled_autocorrs = zeros(num_permutations, length(edges) - 1);
    for p = 1:num_permutations
        shuffled_isi = isi(randperm(length(isi)));  % Mezclar ISIs
        shuffled_autocorrs(p, :) = histcounts(shuffled_isi, edges);
    end
    
    % Calcular límites de significancia
    upper_bound = prctile(shuffled_autocorrs, 97.5, 1);
    lower_bound = prctile(shuffled_autocorrs, 2.5, 1);
    
    % Clasificar picos y valles
    significant_peaks = (autocorr_real > upper_bound);
    significant_troughs = (autocorr_real < lower_bound);
    has_peaks = any(significant_peaks);
    has_troughs = any(significant_troughs);
    
    % Clasificar patrones según picos y valles
    if ~has_peaks && ~has_troughs
        classes(n) = 1;  % Non-oscillatory
    elseif has_peaks && has_troughs
        classes(n) = 2;  % Oscillators
    elseif has_peaks
        classes(n) = 3;  % Bursters
    elseif has_troughs
        classes(n) = 4;  % Pausers
    end
    
    % Guardar auto-correlograma
    auto_corrs(n, :) = autocorr_real;
end

%% Visualización de auto-correlogramas y clases
figure;
for n = 1:num_neurons
    subplot(5, 4, n);  % Ajusta si hay menos neuronas
    bar(edges(1:end-1), auto_corrs(n, :), 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none'); hold on;
    plot(edges(1:end-1), upper_bound, 'r--', 'LineWidth', 1);  % Límite superior
    plot(edges(1:end-1), lower_bound, 'b--', 'LineWidth', 1);  % Límite inferior
    xlabel('Lag (s)');
    ylabel('Frecuencia');
    title(['Neurona ', num2str(n), ' Clase: ', num2str(classes(n))]);
    hold off;
end

%% Mapa dinámico de clases
dynamic_map = zeros(4, 1);
for c = 1:4
    dynamic_map(c) = sum(classes == c) / num_neurons * 100;  % Proporción por clase
end

figure;
pie(dynamic_map, {'Non-oscillatory', 'Oscillators', 'Bursters', 'Pausers'});
title('Distribución de clases');
