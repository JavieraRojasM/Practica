function isi = GetISI(matrix_spks)
    % This function get the inter spike interval of 
    % every spike train in the spike matrix

    n_spiketrains = size(matrix_spks, 1);
    total_time = size(matrix_spks, 2);
    isi = cell(n_spiketrains, 1);


    for st = 1:n_spiketrains
        spike_train = matrix_spks(st, :);

        isi_vector   = [];
        
        time_wo_spike = 0;

        for t = 1:total_time
            if spike_train(1, t) == 1
                isi_vector = [isi_vector time_wo_spike];
                time_wo_spike = 0;
            else
                time_wo_spike = time_wo_spike + 1;
            end 
        end

        isi{st} = isi_vector;
    end
    
end
