function matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt)
    % This function creates the binary spike matrix
        % spike -> 1 ; no spike -> 0

    % Get the total of spikes
    row = size(data_spk,1);
        
    % Get the total of neurons
    n_neuron = data_spk(end,1);
        
    % Get the maximun time
    max_time = sscanf(data_maxtime, '%d')*60; % Minutes to seconds conversion

    % Get the total time nodes
    matrix_time = ceil(max_time/dt);

    % Initiate the spikes matrix
    matrix = zeros(n_neuron, matrix_time);
        
    % Iterate between neuron
    for n = 1:row

        % Iterate between time
        for t = 1:matrix_time

            % Get the time in the t node
            time = t*dt;

            % If the time of the spike (data) is the time of the node,
                % the matrix goes from 0 to 1
            if abs(data_spk(n,2) - time) < dt
                n_neuron2 = data_spk(n,1);
                matrix(n_neuron2, t) = 1;
                break;
            end
        end
    end

    % Return the binary matrix with the spikes
    matriz_spks = matrix;

end
