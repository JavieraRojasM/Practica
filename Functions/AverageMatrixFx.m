function AverageMatrix = AverageMatrixFx(min_stim, min_total, matrix_spks, dt, stim)
    % This function get the matrix with the percent of total spikes for
    % each time. 
    
    % Get the total duration of the experiment after the trim
    total_time = -min_stim:dt:(min_total-dt);

    % Initiate the average vector
    average = zeros(1, size(total_time,2));
        
    % Trim of the matrix
    start = stim - min_stim;
    endd = stim + min_total;
           
    matrix_spks(:, [(endd/dt +1):end]) = [];
    size(matrix_spks);
    
    matrix_spks(:, [1:(start/dt)]) = [];
    size(matrix_spks);


    for t = 1:size(matrix_spks,2)
        average(1, t) = sum(matrix_spks(:,t)) / size(matrix_spks,1);
    end
       
    AverageMatrix = average;
end
