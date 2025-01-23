%load('NSYSU_grid\position_grid.mat');                % Rx Location in Wireless Insite 

%% Antenna Type  (3D)  [x, y, z]
unitAnt_Config = [0; 0; 0];
% Triangular array 
TriAnt_Config = [ [       0        ;        0        ;        0       ], ...
                  [ cos(60/180*pi) ; -sin(60/180*pi) ;        0       ], ...
                  [-cos(60/180*pi) ; -sin(60/180*pi) ;        0       ] ];     % antenna position
              
% Linear array 
ULA2_Config = [ [ 0 ; 0 ; 0 ], ...
                [ 0 ; 1 ; 0 ] ];     % antenna position
ULA2_Config = ULA2_Config - mean(ULA2_Config,2);              
              
% Rectangular array (4 ant.)
RectAnt_Config = [ [ 0 ; 0 ; 0 ], ...
                   [ 1 ; 0 ; 0 ], ...
                   [ 0 ; 0 ; 1 ], ...
                   [ 1 ; 0 ; 1 ] ];     % antenna position
RectAnt_Config = RectAnt_Config - mean(RectAnt_Config,2);

% Planer array 
FourCrossPolarizationAnt_Config = [ [ 0 ; 0 ; 0 ], ...
                                    [ 2 ; 0 ; 0 ], ...
                                    [ 0 ; 0 ;-2 ], ...
                                    [-2 ; 0 ;-2 ], ...
                                    [ 0 ; 0 ; 0 ], ...
                                    [ 2 ; 0 ; 0 ], ...
                                    [ 0 ; 0 ;-2 ], ...
                                    [-2 ; 0 ;-2 ] ];     % antenna position 
FourCrossPolarizationAnt_Config = FourCrossPolarizationAnt_Config - mean(FourCrossPolarizationAnt_Config,2) ;

% Planer array 
EightAnt_Config = [ [ 0 ; 0 ; 0 ], ...
                    [ 1 ; 0 ; 0 ], ...
                    [ 0 ; 0 ;-1 ], ...
                    [ 1 ; 0 ;-1 ], ...
                    [ 0 ; 0 ;-2 ], ...
                    [ 1 ; 0 ;-2 ], ...
                    [ 0 ; 0 ;-3 ], ...
                    [ 1 ; 0 ;-3 ] ];     % antenna position 
EightAnt_Config = EightAnt_Config - mean(EightAnt_Config,2) ;

% Planer array 
PlanAnt_element_num = [4 4] ;             % numbers of antennas in (1) horizontal, (2) vertical 
[grid_x,grid_y,grid_z] = ndgrid(0:PlanAnt_element_num(1)-1, 0, 0:PlanAnt_element_num(2)-1); 
PlanAnt_Config = [grid_x(:)'; grid_y(:)'; grid_z(:)'];
PlanAnt_Config = [ kron([0:PlanAnt_element_num(1)-1], ones(1,PlanAnt_element_num(2))) ;
                   zeros(1,PlanAnt_element_num(1)*PlanAnt_element_num(2)) ;
                   repmat([0:PlanAnt_element_num(2)-1], 1, PlanAnt_element_num(1))];
PlanAnt_Config = PlanAnt_Config - mean(PlanAnt_Config,2) ;        
PlanAnt_antRotAng = [0 0 0]/180*pi;      % elevation (positive points upwards) in deg and azimuth (0 deg is boresight North, 90 deg is boresight West)
PlanAnt_Config_x =  RotMat(PlanAnt_antRotAng) * PlanAnt_Config ;
PlanAnt_antRotAng = [0 0 90]/180*pi;     % elevation (positive points upwards) in deg and azimuth (0 deg is boresight North, 90 deg is boresight West)
PlanAnt_Config_y =  RotMat(PlanAnt_antRotAng) * PlanAnt_Config ;            

%% AP
Tx_power_dB = randi([40, 50]);   % (dB) Tx amplified ratio to 0 dBm (Assume Tx power in WirelessInsite is 0 dBm)
fprintf('Tx power is %d\n', Tx_power_dB)
AP.Element_gain = 10^(Tx_power_dB/20); % Tx power (Amplitude)
AP.antRotAng = [0 0 0]/180*pi;       % elevation (positive points upwards) in deg and azimuth (0 deg is boresight North, 90 deg is boresight West in EC9F) (0 deg is boresight East, 90 deg is boresight South in Campus)
AP.Config = RectAnt_Config;            % RectAnt_Config / EightAnt_Config
AP.ANT_PATTERN_ON = 1 ;                % 1: turn on power pattern of antenna element
AP.Element_size = [1 1];
AP.Name = 'AP';

%% Rx (UE)
Rx_LNA_dB = 0;                        % Rx LNA (dB)
Rx.Element_gain = 10^(Rx_LNA_dB/20);  % Rx (Amplitude)
Rx.antRotAng = [0 0 0]/180*pi;       % elevation (positive points upwards) in deg and azimuth (0 deg is boresight North, 90 deg is boresight West in EC9F) (0 deg is boresight East, 90 deg is boresight South in Campus)
Rx.Config = RectAnt_Config;          % RectAnt_Config / EightAnt_Config
Rx.ANT_PATTERN_ON = 1;                % 1: turn on power pattern of antenna element
Rx.Element_size = [1 1];            
Rx.Name = 'UE';
