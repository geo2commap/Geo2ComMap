classdef PropagationChannel_6G  % Channel: Create virtual source for each reflecting segment
%%
    properties
        seed = 0;%randi(2^32-1);   %CDL 隨機數種子   0~2^32-1
        N_fft = 2048;           % number of subcarrier
        
        c =  physconst('LightSpeed');                % Light speed (m/s)
        f_center = 3.5e9;       % Center frequency (Hz)
        f_subcar = 60e3;        % Subcarrier frequency (Hz)
        f_sample                % Bandwidth (Hz)
        n_sample                % n/N = [-1024:-1 0:1023] / 2048
        sub_loc_idx             % subcarrier index
        
        tx_antSize = [1 1]      % (1) horizontal, (2) vertical in wavelength
        rx_antSize = [1 1]      % (1) horizontal, (2) vertical in wavelength
        
        lambda                  % Wave length
        tx_loc                  % Tx Location
        rx_loc                  % Rx Location
        tx_antConfig            % Tx antenna configuration
        rx_antConfig            % Rx antenna configuration
        Nt                      % Tx antenna number
        Nr                      % Rx antenna number
        tx_antRotAng            % Tx antenna Orientation
        rx_antRotAng            % Rx antenna Orientation
                
        tx_ant                  % Tx antenna gain and corresponding information
        rx_ant                  % Rx antenna gain and corresponding information
        
        RB_Num                  % RB number        
        
        tx_antGain = 1;         % Tx anetnna gain -10dBm
        rx_antGain = 1;         % Rx anetnna gain
        noise_level = 4e-10;    % 25.22dB @ [10 4]
%         noise_level = 10^(-40/10);
        
        exp_omega_aoa           % AoA in omega
        exp_omega_aod           % AoD in omega
        H                       % channel matrix
        H_Normalized            % Normalized channel matrix
        max_g_exp_omega_aod     % AoD of max gain in omega
        min_d_exp_omega_aod     % AoD of min ToA in omega
        tx_Name
        rx_Name
        LNA
        
    end
    
    %%
    methods
            % *****************************************************************
            %                      CONSTRUCTOR METHOD
            % *****************************************************************
            function obj = PropagationChannel_6G(tx, rx)            
                if nargin == 2                
                    % obj.tx_loc = tx.Location;
                    % obj.rx_loc = rx.Location;                                
                    
                    obj.Nt = size(tx.Config,2);
                    obj.Nr = size(rx.Config,2);
                    
                    obj.tx_antRotAng = tx.antRotAng ;
                    obj.rx_antRotAng = rx.antRotAng ;
                    
                    obj.f_sample = obj.f_subcar*obj.N_fft;
                    obj.lambda = obj.c/obj.f_center;
                    
                    obj.n_sample = (-obj.N_fft/2:obj.N_fft/2-1).'/obj.N_fft;                % n/N = [-1024:-1 0:1023] / 2048
                    
                    obj.RB_Num = 135;                                                       % number of resource block (RB) (Original: 32)
                    sub_num = 12*obj.RB_Num;                                                % number of subcarrier
%                     sub_num = 1;
                    obj.sub_loc_idx = [obj.N_fft/2-ceil(sub_num/2)+1 : obj.N_fft/2 ...      % subcarrier location index
                                       obj.N_fft/2+2 : obj.N_fft/2+floor(sub_num/2)+1] ;    % ex: [925:1024 1026:1125] for 200 subcarriers
                    
                    obj.tx_Name =tx.Name;
                    obj.rx_Name =rx.Name;
                    
                    if ~isempty(tx.Element_gain), obj.tx_antGain = tx.Element_gain; end
                    if ~isempty(rx.Element_gain), obj.rx_antGain = rx.Element_gain; end
                    if ~isempty(tx.Element_size), obj.tx_antSize = tx.Element_size; end
                    if ~isempty(rx.Element_size), obj.rx_antSize = rx.Element_size; end
                    
                    obj.tx_antConfig = tx.Config .* [tx.Element_size(1); tx.Element_size(1); tx.Element_size(2)];
                    obj.rx_antConfig = rx.Config .* [rx.Element_size(1); rx.Element_size(1); rx.Element_size(2)];                                               
                    
                else % Unallowed nargin ~= 2 syntax
                    error('The numebr of argument to construct a wall is three');
                end
            end
        
            % *****************************************************************
            %                           FUNCTIONS
            % *****************************************************************
            function obj = CFR_SimBase(obj, sim)            
                    %% Channel parameter
                    path_gain    = sim.path_gain;      % gain (linear)
                    path_phase   = sim.path_phase;     % phase (rad)
                    path_delay   = sim.path_delay;     % delay (sec)
                    path_AOA_hor = sim.path_AOA_hor;   % AOA horizontal (rad)
                    path_AOA_ver = sim.path_AOA_ver;   % AOA vertical (rad)
                    path_AOA     = [pi/2-path_AOA_ver path_AOA_hor]; % channel uses zenith angle, rays use elevation
                    path_AOD_hor = sim.path_AOD_hor;   % AOD horizontal (rad)
                    path_AOD_ver = sim.path_AOD_ver;   % AOD vertical (rad)
                    path_AOD     = [pi/2-path_AOD_ver path_AOD_hor]; % channel uses zenith angle, rays use elevation

                    exp_gain = obj.tx_antGain .*obj.rx_antGain .* path_gain .* exp(1j*path_phase);
               
                    % exp_delay = exp(-1j*2*pi*obj.f_sample*obj.n_sample*path_delay.');                    
                    [path_AOD_lcs] = gcs2lcs(path_AOD,obj.tx_antRotAng);
                    [path_AOA_lcs] = gcs2lcs(path_AOA,obj.rx_antRotAng);
                    obj.exp_omega_aod = Steering(path_AOD_lcs, obj.tx_antConfig, 0);
                    obj.exp_omega_aoa = Steering(path_AOA_lcs, obj.rx_antConfig, 1);

                    % CDL CIR generator
                    raytracing_data = struct('AveragePathGains',abs(exp_gain),'PathDelays',path_delay,'AOA',path_AOA,'AOD',path_AOD);
                    channel=customCDLgen(raytracing_data,obj);
                    [pathGains,sampleTimes] = channel();         % 產生 CDL 通道響應

                    %% NR channel_est (利用 CDL 通道響應得到一個 NR 1 slot 的通道)
                    pathFilters = getPathFilters(channel);
                    nSlot = 0;
                    offset = nrPerfectTimingEstimate(pathGains, pathFilters);
                    hest = nrPerfectChannelEstimate_oneSymbol(pathGains, pathFilters, obj.RB_Num, obj.f_subcar/1000, nSlot, offset, sampleTimes, "Nfft", obj.N_fft, "SampleRate", obj.f_sample);
                    obj.H = hest;
                    
                    %%%%%%%%%%%%%%%%%%   Original code   %%%%%%%%%%%%%%%%%%
                    % %% Channel coefficient for ch_AP_RIS case (2048x1024)
                    % %%%%% by subcarrier delay(2048x250), channel path(250x1),
                    % %%%%% and Rx/Tx array manifold(250x256 / 250x4 -> 250x1024).
                    % %%%%% Original code:
                    % %%%%% obj.H = exp_delay * bsxfun( @times, (exp_gain.*Amp), kron(obj.exp_omega_aod,ones(1,obj.Nr)) .* repmat(obj.exp_omega_aoa,1,obj.Nt) );
                    % H_stack = zeros(length(obj.rx_ant.name), length(obj.tx_ant.name), sample_num);
                    % aod = obj.exp_omega_aod;
                    % aoa = obj.exp_omega_aoa;
                    % for j = 1:length(obj.rx_ant.name)                            
                    % for i = 1:length(obj.tx_ant.name)
                    %         aod_need = aod(:,i);
                    %         aoa_need = aoa(:,j);
                    %         Amp = Amp_stack(:,i,j);
                    %         Channel = exp_delay * ((exp_gain.*Amp).*(aod_need.*aoa_need));
                    %         H_stack(j,i,:) = Channel;
                    % end
                    % end
                    % obj.H = H_stack;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    [~, max_g_idx] = max(abs(exp_gain)) ;
                    [~, min_d_idx] = min(path_delay) ;
                    obj.max_g_exp_omega_aod = obj.exp_omega_aod(max_g_idx, :) ;
                    obj.min_d_exp_omega_aod = obj.exp_omega_aod(min_d_idx, :) ;                
            end
    end    
end


