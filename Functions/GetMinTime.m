function min_time = GetMinTime(folder, main_folder)
    % This function get the minimun time between the start of the recording and the
    % stimulus (min_stim) and the minimun time between the stimulus and the end 
    % of the recording (min_max_time)
    
    % Minimum time to compare with
    min_stim = 120000;
    min_end = 10000000;
    
    % Iterate over the subfolders inside the main folder
    for f = 1:length(folder)
        % Subfolder path
        folder_path = fullfile(main_folder, folder(f).name);
        
        % Get the files within the subfolders
        file = dir(fullfile(folder_path, '*.mat'));
    
        % Iterate over the files inside the subfolder
        for a = 1:length(file)
            % File path
            file_path = fullfile(folder_path, file(a).name);
    
            % Load the file
            data = load(file_path);
            data_maxtime = data.file_length;
            
            % Get the time of application of the stimulus
            data_stimtime = data.stim_time;
            stim = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion 
          
            if stim < min_stim
                min_stim = stim;
            end
    
            % Get the maximun time before the stimulus
            max_time = sscanf(data_maxtime, '%d')*60; % Minutes to seconds conversion
            time_befstim = max_time - stim;
            if time_befstim < min_end
                min_end = time_befstim;
            end

        end
    end

    % Return the minumun time
    min_time = [min_stim, min_end];
end
