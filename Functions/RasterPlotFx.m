function matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt, data_mintime)
% RasterPlotFx Function

% This function creates a binary spike matrix (raster plot representation) 
% where each spike is marked as '1' and non-spike events are '0'.

% The function processes spike timing data from multiple neurons and 
% organizes it into a time-binned binary matrix for visualization and analysis.

% INPUT:
%   - data_spk: A matrix where each row contains two columns:
%       - Column 1: Neuron ID
%       - Column 2: Spike time (in seconds)
%   - data_maxtime: Maximum recording time (in minutes or seconds).
%   - dt: Time bin size (in seconds).
%   - data_mintime (optional): Minimum time to consider (default = 0).

% OUTPUT:
%   - matriz_spks: A binary matrix where:
%       - Rows represent neurons.
%       - Columns represent time bins.
%       - Value '1' indicates a spike, '0' indicates no spike.

    if nargin < 4
        data_mintime = 0; % Default minimum time
    end

    % Get the total number of neurons from the last entry in data_spk
    n_neuron = data_spk(end, 1);
    
    % Convert `data_maxtime` to seconds if it is a string or character array
    if ischar(data_maxtime) || isstring(data_maxtime)
        maxtime = sscanf(data_maxtime, '%d') * 60; % Convert minutes to seconds
    elseif isnumeric(data_maxtime)
        maxtime = data_maxtime;
    end
    
    % Adjust minimum and maximum times to define the interval
    min_time = floor(data_mintime);
    max_time = ceil(maxtime);
    matrix_time = ceil((max_time - min_time) / dt); % Compute number of time bins
    
    % Initialize the binary spike matrix
    matrix = zeros(n_neuron, matrix_time);
    
    % Iterate through the spike data
    row = 1;
    while row <= size(data_spk, 1)
        neuron_id = data_spk(row, 1);  % Retrieve neuron ID
        spike_time = data_spk(row, 2); % Retrieve spike time
        
        % Compute the corresponding time bin index
        t_index = floor((spike_time - min_time) / dt) + 1;
        
        % Ensure the time index is within valid bounds
        if t_index > 0 && t_index <= matrix_time
            % Update the matrix only if the spike is not already marked
            if matrix(neuron_id, t_index) == 0
                matrix(neuron_id, t_index) = 1;
            end
        end
        
        % Move to the next row in data_spk
        row = row + 1;
    end
    
    % Return the binary spike matrix
    matriz_spks = matrix;
end
