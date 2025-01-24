function Perm_matriz_spks = FromISItoSpiketrain(isi, matrix_spks)
    % ...
    empty_matrix_spks = zeros(size(matrix_spks));
    n_spiketrains = size(matrix_spks, 1);
    total_time = size(matrix_spks, 2);

    % Posición inicial del primer spike
    current_time = 0;

    for st = 1:n_spiketrains
        
        spike_train = zeros(1, size(matrix_spks, 2));
        % Recorrer el vector de ISI
        for i = 1:length(isi)
            % Avanzar según el intervalo entre spikes
            current_time = current_time + isi(i) + 1;
            
            % Colocar un spike en la posición actual
            if current_time <= total_time
                spike_train(current_time) = 1;
            else
                warning('Spike fuera de rango de tiempo total. Verifica el isi_vector.');
                break;
            end
            
        end 
        
        empty_matrix_spks(st, :) = spike_train;

    end 

    Perm_matriz_spks = empty_matrix_spks;
end
