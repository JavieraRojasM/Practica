# README for Run_Full_Analysis.m

## Overview
`Run_Full_Analysis.m` is a MATLAB script designed to execute a comprehensive data analysis pipeline. This script automates the entire workflow, including data preprocessing, model execution, result evaluation, and visualization.

## Features
- Loads input data from specified sources.
- Performs necessary preprocessing steps.
- Stores intermediate and final results.
- Generates relevant visualizations and summary statistics.

## Requirements
To run this script, ensure you have:
- MATLAB installed (R2022a or later recommended).
- Necessary input data files in the correct format.

## Input
- The script prompts the user to select a folder that contains **two subfolders: `Juvenile` and `Old`**. These subfolders must contain the corresponding data for each dataset.
- The following parameters are **customizable**:
  - **Maximum recording time**  
  - **Time step**  
  - **Bin size**
  - **Maximum lag for correlation analysis**
  - **Number of permutations for statistical testing**
  - **Upper and Lower threshold for statistical significance**

## Output
- Processed data and results are saved in an output directory called `Figures_folder`.
- Inside, you will find **nine images** corresponding to different aspects of the analysis for each dataset:
  1. **Total neurons**
  2. **Raster plot**
  3. **Pie plot of neuron types**
  4. **Cosine similarity matrix (before reorganization)**
  5. **Cosine similarity matrix (after reorganization)**
  6. **Raster plot with reorganized neurons**
  7. **Position plot of neurons by dataset**
  8. **Mean spikes normalized by the number of neurons**
  9. **Global average spike rate**
 

## Usage
1. Open MATLAB.
2. Navigate to the directory containing `Run_Full_Analysis.m`.
3. Execute the script.
