function AverageMatrix = AverageMatrixFx(matrix_spks)
% AverageMatrixFx Function

% This function calculates the average spike occurrence across all neurons 
% for each time bin in the given binary spike matrix.

% It computes the percentage of neurons that fired a spike at each time step 
% and returns a row vector containing these values.

% INPUT:
%   - matrix_spks: A binary matrix where:
%       - Rows represent neurons.
%       - Columns represent time bins.
%       - Value `1` indicates a spike occurrence, `0` indicates no spike.

% OUTPUT:
%   - AverageMatrix: A row vector containing the percentage of total spikes 
%     for each time bin.
    
    % Initialize the output matrix
    average = zeros(1, size(matrix_spks, 2));
    
    % Iterate over each time bin to calculate the fraction of active neurons
    for t = 1:size(matrix_spks, 2)
        average(1, t) = sum(matrix_spks(:, t)) / size(matrix_spks, 1);
    end
       
    % Return the computed average spike matrix
    AverageMatrix = average;
end
