%% Run Full Analysis

% This script runs various analyses related to spike data, including raster plots,
% average spike computations, and similarity matrix calculations for different neuron types.
% It also includes the generation of various plots for visual analysis of the data.

% Javiera Rojas 7/02/2025

clear
close all  

load("colors.mat")      % Load color settings for plots
addpath('Functions');   % Add a folder containing necessary functions to the path


% Choose the main folder that contains the folders for both 'Juvenile' and 'Old' datasets
% [path] = uigetdir;
% main_folder = fullfile(path);

main_folder ="C:\Users\javie\OneDrive\Escritorio\Datos\Original_Data";

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Excluir '.' y '..'

% 
% % Choose the folder to save the figure
% [path_figures] = uigetdir;  
% Figures_folder = fullfile(path_figures);  
% 

% Parameters related to time and analysis
max_time = 90;          %[s] Define maximum time for plotting
max_perm = 100;         % Number of permutations for statistical testing

% Select i (used for time step for certain plots)
i = 3;  
dt = 1*10^-i;           %[s] Time step resolution in seconds

% Set parameters for similarity matrix analysis
max_lag = 20;  %[s]     % Maximum lag for correlation analysis
up_threshold = 3;       % Upper threshold for statistical significance
bot_threshold = -2;     % Lower threshold for statistical significance
% Select b (used to define time step resolution)
b = 0;             
binsize = 1*10^-b;      %[s] Time bin size in seconds

% Call different analysis functions

% Bar plot of all total neurons
TotalNeurons  % Call function to generate a bar plot of total neurons across datasets

% Raster plot of all files in one figure
RasterPlot_Base  % Call function to generate a raster plot for all files

% Classifies neurons into four categories: non-oscillatory, oscillator, burster and pauser. 
TypesOfNeurons  

% Load the previously saved data for the neuron types
Type_of_Neurons = load(Type_of_Neurons_name); 

% Clean the file name to prepare for labeling in plots
file_name = erase(Type_of_Neurons_name, '_');  
file_name = erase(file_name, 'NT'); 
file_name = erase(file_name, 'maxtime');
file_name = erase(file_name, 'binsize'); 
file_name = replace(file_name, 'e', '[s], bin size 1 * 10^');  
file_name = replace(file_name, 'CC', ', maximum analysis time '); 

% Generate a pie plot showing neuron type distributions
Pie_plot 

% Generate cosine similarity matrices
Cosine_SM_Base          % Compute the base cosine similarity matrix for the data
Cosine_SM_Reorganized   % Compute the reorganized by neuron types cosine similarity matrix

% Generate raster plots with neurons grouped by type
RasterPlot_Reorganized  

% Generate position plots showing the location of neurons and their type
Position_plot

% Modify i for a different time step resolution and run the average neuron analysis
i = 1;  
dt = 1*10^-i;   %[s] Time step

% Plots the number of spikes normalized by the number of neurons throughout
% the time of the experiment
Mean_spikes_normalized

% Calculate the average spike train for all neurons across datasets  
Global_average_spike_rate