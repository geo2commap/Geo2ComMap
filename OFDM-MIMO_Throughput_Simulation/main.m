% ================================================================================ 
% Code Title: MIMO_Sim 
% -------------------------------------------------------------------------------- 
% Version: Modified by MIMO_Sim Hybrid channel model: Ray tracing + CDL 
% RI CQI and Throughput Calculator 
% -------------------------------------------------------------------------------- 
% Function: Set_AP_Rx / PropagationChannel_6G / gcs2lcs / RotMat / Steering / 
% Preprocess_sim / Th_BER / BER_Constellation / PlotResult_LoS / PlotWall 
% -------------------------------------------------------------------------------- 
% Copyright (c) 2023 De-Ming Chian, Chao-Kai Wen, Feng-Ji Chen, and Tzu-Hao Huang. 
% ================================================================================ 
close all; clear; clc
set(0,'defaultfigurecolor', [1 1 1]);
set(0,'DefaultLineLineWidth', 1.5);
set(0,'DefaultAxesFontSize', 12);
set(0,'DefaultaxesFontName', 'Times new Roman');
set(0,'DefaultaxesFontWeight', 'normal');
set(0,'DefaultLineMarkerSize', 8);

% Set base directory containing all folders
baseDirectory = 'C:\Users\CTLAB\Desktop\MIMO_Throughput_Sim-V3.2\RT_Data';

% Get all folder names in the base directory
folderList = dir(baseDirectory);
folderList = folderList([folderList.isdir]);  % Only keep directories
folderList = folderList(~ismember({folderList.name}, {'.', '..'}));  % Remove '.' and '..'

total_tic = tic;  % Start total processing time timer

% Loop over each folder
for folderIdx = 1:length(folderList)

    % Set the current folder name as fileNames_cir_case
    fileNames_cir_case = folderList(folderIdx).name;
    fprintf('Processing folder: %s\n', fileNames_cir_case);

    % Set full path for the folder
    currentFolderPath = fullfile(baseDirectory, fileNames_cir_case);

    % Load the AP_Rx simulation data
    load(fullfile(currentFolderPath, 'sim_AP_Rx_ALL.mat'));  % Load the data for AP_Rx / RIS_Rx

    Set_AP_Rx;  % Antenna setting
    mod_size = 8;  % Modulation size: 4 for 16-QAM, 6 for 64-QAM, 8 for 256-QAM, 10 for 1024-QAM
    RI_Alg = 'MaxSE';
    cqiTableName = 'Table1';

    % Get modulation orders and target code rates from CQI table
    cqiTable = nr5g.internal.nrCQITables(cqiTableName);
    cqiTable = cqiTable(:, 2:3);
    tableQms = unique(cqiTable(:, 1));
    tableQms = tableQms(~isnan(tableQms));

    mods = unique([nr5g.internal.nrPDSCHConfigBase.Modulation_Values nr5g.internal.pusch.ConfigBase.Modulation_Values]);
    allCQI.Qms = cellfun(@nr5g.internal.getQm, mods);
    tableModulations = arrayfun(@(x) mods(allCQI.Qms == x), tableQms);

    % Initialize channel
    ch_AP_Rx = PropagationChannel_6G(AP, Rx);
    static_noise_level = ch_AP_Rx.noise_level;  % Noise level
    sub_loc = ch_AP_Rx.sub_loc_idx(1:1:end);  % Subcarrier location indices

    % Performance evaluation for all Rx points
    sub_loc_Perf = sub_loc;  % Performance: All sub_loc
    Nsub_Perf = length(sub_loc_Perf);
    rx_all_len = length(sim_AP_Rx_ALL);

    SNR_Base_stack = zeros(rx_all_len, Nsub_Perf);
    Cap_Base_stack = zeros(rx_all_len, Nsub_Perf);
    BER_Base_stack = zeros(rx_all_len, Nsub_Perf);
    RCN_Base_stack = zeros(rx_all_len, Nsub_Perf);

    RI_ALL = zeros(rx_all_len, 1);
    CQI_ALL = zeros(rx_all_len, 1);
    Throughput_ALL = zeros(rx_all_len, 1);

    parfor rx = 1:rx_all_len

        %% Initialize Channel
        ch_AP_Rx = PropagationChannel_6G(AP, Rx);

        %% Generate channels for AP to Rx / RISs to Rx / SM of RIS
        sim_AP_Rx = sim_AP_Rx_ALL(rx);
        ch_AP_Rx = ch_AP_Rx.CFR_SimBase(sim_AP_Rx);

        %% Performance evaluation
        H_d = squeeze(ch_AP_Rx.H(:, 1, :, :));
        H_d_temp = permute(H_d, [2, 3, 1]);  % Format for easier computation Nr*Nt*1620

        % SVD of H
        HH = pagemtimes(H_d_temp, 'ctranspose', H_d_temp, 'none');
        Sp = squeeze(pagesvd(HH));

        % OTA for Baseline (SNR/Capacity/BER)
        SNR_Hd = sum(Sp, 1) / static_noise_level / size(H_d_temp, 1);
        Cap_Hd = real(log2(prod(Sp / static_noise_level + ones(size(Sp)))));
        BER_fun = @(i) Th_BER(H_d_temp(:, :, i) / sqrt(static_noise_level), 1, mod_size, 10);
        BER_Hd = cell2mat(arrayfun(BER_fun, 1:Nsub_Perf, 'UniformOutput', false));
        RCN_fun = @(i) rcond(H_d_temp(:, :, i)' * H_d_temp(:, :, i));
        RCN_Hd = cell2mat(arrayfun(RCN_fun, 1:Nsub_Perf, 'UniformOutput', false));

        % Stack SNR/Capacity/BER results
        SNR_Base_stack(rx, :) = SNR_Hd;
        Cap_Base_stack(rx, :) = Cap_Hd;
        BER_Base_stack(rx, :) = BER_Hd;
        RCN_Base_stack(rx, :) = RCN_Hd;

        % Get perfect noise value and calculate RI
        nVarPerfect = static_noise_level;
        [numLayersPerfect, cqiPerfect] = hRISelect(ch_AP_Rx.H, nVarPerfect, RI_Alg, cqiTableName, ch_AP_Rx.RB_Num);

        if cqiPerfect ~= 0
            mcs = hCQITables(cqiTableName, cqiPerfect);
            modulations = arrayfun(@(x) tableModulations(tableQms == x), mcs(2));
            targetCodeRates = mcs(3) / 1024;

            % Calculate transport block sizes
            trBlkSizes = nrTBS(modulations, numLayersPerfect, ch_AP_Rx.RB_Num, 12 * 14, targetCodeRates);
        else
            trBlkSizes = 0;
        end

        RI_ALL(rx, 1) = numLayersPerfect;
        CQI_ALL(rx, 1) = cqiPerfect;
        Throughput_ALL(rx, 1) = trBlkSizes * 40 * 1e-6 / 10e-3;  % Frame size: 40 slots, 10 ms total duration

    end  % End of parfor loop

    % Compute mean values for all subcarriers (SNR/Capacity/BER)
    meanSNR = [10 * log10(mean(SNR_Base_stack, 2))];  % dB
    meanCap = [mean(Cap_Base_stack, 2)];
    meanBER = [mean(BER_Base_stack, 2)];
    meanRCN = [mean(RCN_Base_stack, 2)];

    % Create directory for saving results
    %resultDir = fullfile("Report", fileNames_cir_case);
    %if ~exist(resultDir, 'dir')
    %    mkdir(resultDir);  % Create directory if it doesn't exist
    %end

    % Save results for the current folder
    save("Report\"+fileNames_cir_case, "RI_ALL", "CQI_ALL", "Throughput_ALL", "meanSNR", "meanCap", "meanBER", "meanRCN");

    % Inside the folder loop
    antennaPowerFilePath = fullfile("antenna_power_values.txt");

    % Open the file for appending
    fileID = fopen(antennaPowerFilePath, 'a');
    if fileID == -1
        error('Failed to open antenna power values file.');
    end

    % Append new antenna power data
    fprintf(fileID, '%s: Antenna Power Values (in dBm): %d\n', fileNames_cir_case, Tx_power_dB);

    % Close the file
    fclose(fileID);



    % Load position data and plot results
    load(fullfile(currentFolderPath, 'position.mat'));
    PlotResult;

end  % End folder loop

toc(total_tic);  % Display total processing time
