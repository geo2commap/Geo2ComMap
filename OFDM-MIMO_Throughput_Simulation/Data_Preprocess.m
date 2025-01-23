close all; clear; clc
set(0,'defaultfigurecolor', [1 1 1]);
set(0,'DefaultLineLineWidth', 1.5);
set(0,'DefaultAxesFontSize', 12);
set(0,'DefaultaxesFontName', 'Times new Roman');
set(0,'DefaultaxesFontWeight', 'normal');
set(0,'DefaultLineMarkerSize', 8);

fileNames_cir_case = ['RT_Data/building12_47'];   % Files direction about propagations of Wireless Insite
cd([fileNames_cir_case,'/data_all']);
list = dir;
cd ..
cd ..

sim_AP_Rx_ALL = [];

total_tic = tic;
for rx = 1:length(list)-2

    rx_tic = tic;

    %% Generate channels for AP to Rx / RISs to Rx / SM of RIS
    fprintf('RX = %d \n', rx);
    load([fileNames_cir_case,'/data_all','/data',num2str(rx),'.mat']); % load sim of AP_Rx / RIS_Rx
    sim_AP_Rx = sim;
    sim_AP_Rx_ALL = [sim_AP_Rx_ALL Preprocess_sim(sim_AP_Rx)];

    toc(rx_tic);
end
toc(total_tic);

save([fileNames_cir_case,'/sim_AP_Rx_ALL.mat'],'sim_AP_Rx_ALL')
