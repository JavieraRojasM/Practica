%% Types Of Neurons
clear
close all

addpath('Functions');
load("colors.mat")


% Choose of the main folder
%[file, path] = uigetfile;
%main_folder = fullfile(path, file);

main_folder = "C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'


folder_names = string({folder.name});

% Choose of the file of type neurons
% [file, path] = uigetfile;
% Type_of_Neurons_path = fullfile(path, file)
% Type_of_Neurons = load(Type_of_Neurons_path);

Type_of_Neurons = load("Types_of_Neurons_Reduced_data_dt4");

names = string(fieldnames(Type_of_Neurons.data_set));

barplot.test = Type_of_Neurons.data_set.(names(1))(:, 1);
string({folder.name})
n = 1;

for f = 1 : size(folder_names, 2)
    barplot.test{1, 1+f} = folder_names(f);
    set_name = folder_names(f);
    while n <= length(names) && contains(names(n), set_name)
        barplot.test{2, f + 1} = [barplot.test{2, f + 1}, Type_of_Neurons.data_set.(names(n)){2, 3}];
        barplot.test{3, f + 1} = [barplot.test{3, f + 1}, Type_of_Neurons.data_set.(names(n)){3, 3}];
        barplot.test{4, f + 1} = [barplot.test{4, f + 1}, Type_of_Neurons.data_set.(names(n)){4, 3}];
        barplot.test{5, f + 1} = [barplot.test{5, f + 1}, Type_of_Neurons.data_set.(names(n)){5, 3}];
        n = n + 1;
    end
    
end

for type = 2:(size(barplot.test, 1) - 1)
    tags(1, type-1) = string(barplot.test{type, 1});
    for age = 1:size(folder_names, 2)
        mean_type = mean(barplot.test{type, age + 1});
        all_bar(type-1, age) = mean_type;
    end
end


%% Plot

bar(all_bar);
hold on;

ticks = 1:size(tags, 2);
% Definir etiquetas personalizadas
xticks(ticks); % Posiciones de las etiquetas
xticklabels(tags); % Un nombre por cada par de barras

max(all_bar(:))
yMax = max(all_bar(:)) + 5;
ylim([0, yMax]);

ylabel('Number of neurons');
legend(folder_names);
grid on
title('Mean of typed of neuron by age');

hold off;



