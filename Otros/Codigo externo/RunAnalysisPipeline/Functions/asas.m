max_lag_bins = maxlag / binsize; % 20s / 1s = 20 bins
% Supongamos que tenemos dos trenes de spikes (en segundos)
times1 = [0.1, 2.3, 5.7, 10.2, 15.8]; % Tiempos de spikes para neurona 1
times2 = neuron_data(:, 2)'

% Definir el rango de tiempo total basado en los spikes
T = max([times1, times2]); % Duración total del experimento en segundos

time_window = [min(times2), max(times2)];
% Definir bins de tiempo
bins = min(times2):binsize:max(times2); % Bins de 1 segundo como se especifica

% Crear señales discretizadas (vector binario)
spike_train1 = histcounts(times2, bins);


[c_auto, lags_auto] = xcorr(spike_train1, max_lag_bins);

% Convertir lags a segundos
time_lags_auto = lags_auto * binsize;

[y,bins,f1,f2] = LIF_xcorr(times2,times2,binsize,time_window)

% Graficar el auto-correlograma
figure;
stem(time_lags_auto, c_auto, 'filled');
xlabel('Lag (s)');
ylabel('Auto-Correlación normalizada');
title('Auto-Correlograma');

figure;
stem(y, 'filled');
xlabel('Lag (s)');
ylabel('Auto-Correlación normalizada');
title('Auto-Correlograma');
