function sim_AP_Rx_ALL = preprocess_v2(fileNames_cir_case)
    % Function to process simulation data from Wireless Insite

    % General settings
    set(0,'defaultfigurecolor', [1 1 1]);
    set(0,'DefaultLineLineWidth', 1.5);
    set(0,'DefaultAxesFontSize', 12);
    set(0,'DefaultaxesFontName', 'Times new Roman');
    set(0,'DefaultaxesFontWeight', 'normal');
    set(0,'DefaultLineMarkerSize', 8);

    % Set directory and get list of files
    cd([fileNames_cir_case,'/data_all']);
    list = dir;
    cd .. % Navigate up one folder
    cd .. % Navigate up another folder

    sim_AP_Rx_ALL = [];

    % Timing the entire process
    total_tic = tic;
    
    % Loop over each receiver data file
    for rx = 1:length(list)-2  % Exclude '.' and '..'
        rx_tic = tic;

        % Display progress
        fprintf('RX = %d \n', rx);
        
        % Load data
        load([fileNames_cir_case,'/data_all','/data',num2str(rx),'.mat']);  % Load sim data

        % Process the simulation data and accumulate results
        sim_AP_Rx = sim;
        sim_AP_Rx_ALL = [sim_AP_Rx_ALL Preprocess_sim(sim_AP_Rx)];

        % Time per receiver processing
        toc(rx_tic);
    end
    
    % Total process time
    toc(total_tic);

    % Save the processed simulation data
    save([fileNames_cir_case,'/sim_AP_Rx_ALL.mat'],'sim_AP_Rx_ALL');
end
