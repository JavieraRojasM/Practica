function time = TotalStimTime(main_folder)
% This function return the minimum duration time after the 
% stimulus between experiments

% Get the subfolders within the main folder
folder = dir(main_folder);
folder = folder(~ismember({folder.name}, {'.', '..'})); % Exclude '.' and '..'

% Minimum initial time to compare with
min_time = 10000;

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
        
        % Get the total experimental time
        data_maxtime = data.file_length;
        maxtime = sscanf(data_maxtime, '%d')*60; % Minutes to seconds conversion

        % Get the time of application of the stimulus
        data_stimtime = data.stim_time;
        stimtime = sscanf(data_stimtime, '%d')*60; % Minutes to seconds conversion
        
        % Get the total time of the experiment after the stimulus
        after_stim_time = maxtime - stimtime;

        % Verify that it corresponds to the minimum time
        if after_stim_time < min_time
            min_time = after_stim_time;
        end    

    end

% Return the minimun time
time = min_time;
end
