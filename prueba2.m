% Ejemplo de datos (ajusta según los tuyos)
total_spks = [116285, 144674, 71028, 25116, 24669, 39683]; % Valores en el eje Y
nombres2 = ["Juvenile1", "Juvenile2", "Juvenile3", "Old1", "Old2", "Old3"]; % Etiquetas del eje X

% Grupos (eje x)
grupos = 1:length(total_spks);

% Gráfico de barras
figure;
bar(grupos, total_spks, 'FaceColor', [0.2, 0.6, 0.8]); % Barra con colores personalizados

% Configuración del gráfico
xlabel('Age group');
ylabel('Total number of spikes');
title('Total number of spikes by age');

% Configuración de los ticks y etiquetas del eje X
xticks(grupos); % Posiciones de los ticks
xticklabels(nombres2); % Etiquetas de los ticks

grid on;
hold off;
