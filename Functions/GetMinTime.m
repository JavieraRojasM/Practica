function min_time = GetMinTime(folder, main_folder)
% GetMinTime Function

% This function determines:
%   1. The minimum time between the start of the recording and the stimulus (`min_stim`).
%   2. The minimum time between the stimulus and the end of the recording (`min_end`).

% It scans `.mat` files within subfolders of the specified `main_folder`, extracts 
% the total recording time and stimulus time, and computes these two minimal values.

% INPUT:
%   - folder: List of subfolders containing experiment files.
%   - main_folder: Path to the main directory containing all subfolders.

% OUTPUT:
%   - min_time: A two-element vector [min_stim, min_end], where:
%       - `min_stim` is the shortest duration from the start of recording to stimulus.
%       - `min_end` is the shortest duration from stimulus to the end of the recording.

    % Initialize minimum values with large arbitrary numbers
    min_stim = 120000;      % Large initial value for stimulus start time
    min_end = 10000000;     % Large initial value for post-stimulus duration
    
    % Iterate over the subfolders inside the main folder
    for f = 1:length(folder)

        folder_path = fullfile(main_folder, folder(f).name);
        
        file = dir(fullfile(folder_path, '*.mat'));
    
        % Iterate over each file in the subfolder
        for a = 1:length(file)
            % Construct the full file path
            file_path = fullfile(folder_path, file(a).name);
    
            % Load the data 
            data = load(file_path);
            data_maxtime = data.file_length;
            
            % Extract the stimulus application time
            data_stimtime = data.stim_time;
            stim = sscanf(data_stimtime, '%d') * 60; % Minutes to seconds conversion
          
            % Update min_stim if a smaller value is found
            if stim < min_stim
                min_stim = stim;
            end
    
            % Extract the total recording duration
            max_time = sscanf(data_maxtime, '%d') * 60; % Convert minutes to seconds
            
            % Compute time duration after stimulus
            time_befstim = max_time - stim;
            
            % Update min_end if a smaller value is found
            if time_befstim < min_end
                min_end = time_befstim;
            end
        end
    end

    % Return the minimum times as a vector [min_stim, min_end]
    min_time = [min_stim, min_end];

end
