Unpack this entire .ZIP folder in a location of your choice

The top-level script RunAnalysisPipeline.m executes all steps of the analysis pipeline on the supplied test data. 

Each step of the pipeline is detailed in a separate script, emphasising that each step is independently useful for analysing neural recording data.

Each script contains a list of key variables, identifying their format, and the information they contain

Folders:
/TestData/ Spike-train time-series and corresponding neuron position data-files for a set of recordings
/ConsensusComunityDetectionToolbox/ All necessary functions for executing the consensus community detection algorithm
/Functions/ All other supporting functions, including the Voronoi-map building functions

Every function has extensive help available from the MATLAB command line

All code has been tested from MATLAB 7.5 (R2007b); it requires the Statistics Toolbox

Disclaimer: 
Code is supplied as a toolbox of functions implementing the algorithms in
Bruno, Frost & Humphries (2014), and a fully worked analysis pipeline as an exemplar
of how to use those algorithms to do unsupervised functional mapping of a neural circuit. 
Usage on your data may not require all steps; and may require some thought.