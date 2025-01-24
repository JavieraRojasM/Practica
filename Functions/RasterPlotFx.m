function matriz_spks = RasterPlotFx(data_spk, data_maxtime, dt, data_mintime)
    % This function creates the binary spike matrix
        % spike -> 1 ; no spike -> 0

    if nargin < 4 
        data_mintime = 0; 
    end
  
    % Get the total of spikes
    %row = size(data_spk,1);
        
    % Get the total of neurons
    n_neuron = data_spk(end,1);
        
    % Get the maximun time
    if ischar(data_maxtime) || isstring(data_maxtime)
        maxtime = sscanf(data_maxtime, '%d')*60; % Minutes to seconds conversion

    elseif isnumeric(data_maxtime)
        maxtime = data_maxtime;

    end
       
    min_time = floor(data_mintime)
    % Get the total time nodes
    max_time = ceil(maxtime)
    
    matrix_time = (max_time - min_time)/dt

    % Initiate the spikes matrix
    matrix = zeros(n_neuron, matrix_time);
    size(matrix)    

    % Iterate between neuron
    
    row = 1   
%     for row = 1:size(data_spk,1)
%         row
for n = 1:n_neuron
    n
    time = min_time;
    
    while data_spk(row,1) == n
        row
        data_spk(row,1);
        

        while time < max_time
            for t = 1:size(matrix, 2)
               
                % If the time of the spike (data) is the time of the node,
                % the matrix goes from 0 to 1
                if abs(data_spk(row,2) - time) < dt
                    %n_neuron2 = data_spk(n,1);
                    matrix(data_spk(row,1), t) = 1;
                    %break;
                end
                time = time + dt;

            end
            %break
        end
        row = row + 1;
        if row > size(data_spk, 1)
            break
        end
        %break
    end
end


    % Return the binary matrix with the spikes
    matriz_spks = matrix;

end
