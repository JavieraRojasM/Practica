%% Rasterplot
clear
close all

% Se cargan los datos
%[archivo, path] = uigetfile;
%structmat = fullfile(path, archivo);

structmat = "C:\Users\javie\OneDrive\Escritorio\Datos\Juvenile\Jul1119_1.mat";
[~, archivo] = fileparts(structmat);


% Cargar el archivo
struct = load(structmat);
spikesstruct = struct.spks;


% Se calcula el numero de spks totales registrados
filas = size(spikesstruct,1);


% Se calcula el numero de neuronas
n_neuronas = spikesstruct(end,1);

% El paso temporal tomado es 10^-i
%Elegir i:
i = 2;

% Se calcula el paso temporal
dt = 1*10^-i; %[s]

% Se calcula el tiempo maximo registrado
max_time = round(max(spikesstruct(:,i)));

% Se calcula el numero de puntos temporales
m_tiempos = ceil(max_time)/dt;

% Se crea la nueva matriz
m = zeros(n_neuronas, m_tiempos);

% Se itera
for j = 1:filas
  for t = 1:m_tiempos
    % Se calcula el tiempo en el nodo t
    time = t*dt;
    % Si el spk corresponde al tiempo, se coloca un 1 en la matriz m
    if abs(spikesstruct(j,2) - time) < dt
      n_neurona2 = spikesstruct(j,1);
      m(n_neurona2, t) = 1;
      break;
    end
  end
end


%% Raster Plot
figure(1)
hold on
for n = 1:n_neuronas
    indice = (find(m(n,:)));
    x = indice*dt;
    y = ones(1, size(x,2))* n;
    scatter(x, y, 8, 'filled', 'MarkerFaceColor', [0.1, 0.1, 0.6]);
end

xlabel('Tiempo (s)');
xlim([-0.5, max_time])


ylim([0.5, (n_neuronas + 0.5)])
yticks(0:5:n_neuronas+1);
ylabel('Nº Neurona');

% Marcador de inicio de estimulo
stimtime = struct.stim_time;
stim = sscanf(stimtime, '%d')*60;
x_line = [stim, stim]; 
y_line = [0.5, n_neuronas + 0.5]; 
plot(x_line, y_line, 'r-', 'LineWidth', 2);
text(stim, 0, 'stimulus', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red', 'FontSize', 8);


title(sprintf('Raster Plot of %s with dt = 1 * 10^{-%d}', archivo, i));
hold off
