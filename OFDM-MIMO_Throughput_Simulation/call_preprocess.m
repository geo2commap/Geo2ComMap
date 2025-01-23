close all; clear; clc;

% Set general plot properties
set(0,'defaultfigurecolor', [1 1 1]);
set(0,'DefaultLineLineWidth', 1.5);
set(0,'DefaultAxesFontSize', 12);
set(0,'DefaultaxesFontName', 'Times new Roman');
set(0,'DefaultaxesFontWeight', 'normal');
set(0,'DefaultLineMarkerSize', 8);

% Define the base directory where all folders are located
baseDirectory = 'C:\Users\CTLAB\Desktop\MIMO_Throughput_Sim-V3.2\RT_Data';

% Get list of all folders in baseDirectory
listOfFolders = dir(baseDirectory);
listOfFolders = listOfFolders([listOfFolders.isdir]);  % Only keep directories
listOfFolders = listOfFolders(~ismember({listOfFolders.name}, {'.', '..'}));  % Remove '.' and '..'

% Initialize the total process time
total_tic = tic;

% Loop through all the folders
for folderIdx = 1:length(listOfFolders)

    % Set the current folder name as fileNames_cir_case
    fileNames_cir_case = listOfFolders(folderIdx).name;
    
    % Display the folder being processed
    fprintf('Processing folder: %s\n', fileNames_cir_case);

    % Navigate into the folder
    currentFolderPath = fullfile(baseDirectory, fileNames_cir_case);
    cd([currentFolderPath, '/data_all']);
    
    % Get list of files in the current folder
    list = dir;
    
    % Navigate back up two directories after getting the list
    cd ..; cd ..;

    sim_AP_Rx_ALL = [];

    % Loop through each file in the folder (skip '.' and '..')
    for rx = 1:length(list)-2
        rx_tic = tic;

        %% Generate channels for AP to Rx / RISs to Rx / SM of RIS
        fprintf('RX = %d \n', rx);
        load([currentFolderPath, '/data_all/data', num2str(rx), '.mat']);  % Load sim of AP_Rx / RIS_Rx
        sim_AP_Rx = sim;

        % Process simulation data and append it to sim_AP_Rx_ALL
        sim_AP_Rx_ALL = [sim_AP_Rx_ALL Preprocess_sim(sim_AP_Rx)];

        toc(rx_tic);  % Display processing time for this RX point
    end

    % Save the processed simulation data for the current folder
    save([currentFolderPath, '/sim_AP_Rx_ALL.mat'], 'sim_AP_Rx_ALL');

end

% Display total processing time
toc(total_tic);

disp('All folders have been processed successfully.');
