data = load("Analyses_Neurons_and_Groups_RD.mat"); % Cargar como estructura

name = "C:\Users\javie\OneDrive\Escritorio\Datos\Reduced_Data\";

load(name + 'DataList.mat'); % list of spike-train files

for recording = 1:size(DataList,2)
    total_non_osc = 0;
    total_osc = 0;
    total_burs = 0;
    total_paus = 0;
    total_noinfo = 0;
    
    newname =  DataList(recording).spikes
    
    % Create the cell array
    data_set.(newname) = {'Type', 'Neurons ID', 'Total neurons';
        'Non-oscillatory', [], [];
        'Oscillator', [], [];
        'Burster', [], [];
        'Pauser', [], [];
        'No info', [], []};

    for a = 1:452
        n_recording = data.neurondata(a).Recording;
        while n_recording == recording


                newname;
                is_down_bot = neurondata(a).blnOscN;
                is_sup_up = neurondata(a).blnOscP;

                if isempty(is_sup_up) || isempty(is_down_bot)
                    % (5) no info
                    %set.(newname){5, 2}(1, end+1) = neurondata(a).ID;
                    data_set.(newname){6, 2} = [data_set.(newname){6, 2}, neurondata(a).ID'];
                    sort(data_set.(newname){6, 2});
                    total_noinfo = total_noinfo + size(neurondata(a).ID, 1);
                    break
  

                % four possible outcomes:
                elseif is_sup_up == 0 && is_down_bot == 0
                    % (1) no significant peaks or troughs = "non-oscillatory"
                    %set.(newname){2, 2}(1, end+1) = neurondata(a).ID';
                    data_set.(newname){2, 2} = [data_set.(newname){2, 2}, neurondata(a).ID'];
                    sort(data_set.(newname){2, 2});
                    total_non_osc = total_non_osc + size(neurondata(a).ID, 1);
                    break

                elseif is_sup_up == 1 && is_down_bot == 1
                    % (2) significant peaks and troughs = "oscillator"
                    %set.(newname){3, 2}(1, end+1) = neurondata(a).ID;
                    data_set.(newname){3, 2} = [data_set.(newname){3, 2}, neurondata(a).ID'];
                    sort(data_set.(newname){3, 2});
                    total_osc = total_osc + size(neurondata(a).ID, 1);
                    break

                elseif is_sup_up == 1 && is_down_bot == 0
                    % (3) significant peaks but no significant troughs = "burster"
                    %set.(newname){4, 2}(1, end+1) = neurondata(a).ID;
                    data_set.(newname){4, 2} = [data_set.(newname){4, 2}, neurondata(a).ID'];
                    sort(data_set.(newname){4, 2});
                    total_burs = total_burs + size(neurondata(a).ID, 1);
                    break

                elseif is_sup_up == 0 && is_down_bot == 1
                    % (4) no significant peaks but significant troughs = "pauser"
                    %set.(newname){5, 2}(1, end+1) = neurondata(a).ID;
                    data_set.(newname){5, 2} = [data_set.(newname){5, 2}, neurondata(a).ID'];
                    sort(data_set.(newname){5, 2});
                    total_paus = total_paus + size(neurondata(a).ID, 1);
                    break
                end   
        end
    end

    data_set.(newname){2, 3} = total_non_osc;
    data_set.(newname){3, 3} = total_osc;
    data_set.(newname){4, 3} = total_burs;
    data_set.(newname){5, 3} = total_paus;
    data_set.(newname){6, 3} = total_noinfo;
    data_set.(newname){7, 3} = total_non_osc + total_osc + total_burs + total_paus + total_noinfo;
end

save('NT_EC_maxtime_90', 'data_set');

