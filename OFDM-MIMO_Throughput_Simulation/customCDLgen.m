function channel = customCDLgen(raytracing_data,obj)
%UNTITLED Summary of this function goes here
%   使用CDL產生ray tracing隨機通道

%%%%%%%%%CDL channel model + ray tracing%%%%%%%%%%
r_seed = obj.seed;
channel = nrCDLChannel('DelayProfile','Custom','Seed',r_seed);

%%set ray tracing data
channel.PathDelays = raytracing_data.PathDelays.'-min(raytracing_data.PathDelays);       %normalize delay
channel.AveragePathGains = 20*log10(raytracing_data.AveragePathGains+eps).';            %gain2db
channel.AnglesZoD = (raytracing_data.AOD(:,1)./pi.*180).';    % channel uses zenith angle, rays use elevation
channel.AnglesAoD = (raytracing_data.AOD(:,2)./pi.*180).';       % azimuth of departure
channel.AnglesZoA = (raytracing_data.AOA(:,1)./pi.*180).';    % channel uses zenith angle, rays use elevation
channel.AnglesAoA = (raytracing_data.AOA(:,2)./pi.*180).';       % azimuth of arrival


%%set cdl channel model
channel.HasLOSCluster = 0;       %defult nonLOS
channel.CarrierFrequency = obj.f_center;
channel.NormalizeChannelOutputs = false; % do not normalize by the number of receive antennas, this would change the receive power
channel.NormalizePathGains = false;      % set to false to retain the path gains
channel.NumStrongestClusters =0;
channel.XPR = 0;
%%%antenna set for CDL generator(在傳送端和接收端產生不含天線場型效應(Isotropic)的MIMO天線 p.s.天線以方型排列)
tx_size = zeros(1,2);
rx_size = zeros(1,2);
tx_size(2) = floor(sqrt(obj.Nt));
tx_size(1) =  obj.Nt/tx_size(2);
rx_size(2) = floor(sqrt(obj.Nr));
rx_size(1) =  obj.Nr/rx_size(2);

%% Base station array (single panel)
%%phase antenna 程式預設天線指向+X軸(天線擺放在Y-Z平面)，平台天線擺放在(X-Z平面，所以梯線旋轉扣90度)
bsArray = phased.NRRectangularPanelArray('Size',[tx_size(1:2) 1 1],'Spacing', [0.5*obj.lambda*[1 1] 1 1]);
bsArray.ElementSet = {phased.IsotropicAntennaElement};   % isotropic antenna element
channel.TransmitAntennaArray = bsArray;
channel.TransmitArrayOrientation = [+90+obj.tx_antRotAng(3)/pi*180; (-1)*obj.tx_antRotAng(1)/pi*180; 0];  % the (-1) converts elevation to downtilt
% UE array (single panel)
%%
ueArray = phased.NRRectangularPanelArray('Size',[rx_size(1:2) 1 1],'Spacing', [0.5*obj.lambda*[1 1] 1 1]);
ueArray.ElementSet = {phased.IsotropicAntennaElement};   % isotropic antenna element
channel.ReceiveAntennaArray = ueArray;
channel.ReceiveArrayOrientation = [+90+obj.rx_antRotAng(3)/pi*180; (-1)*obj.rx_antRotAng(1)/pi*180; 0];  % the (-1) converts elevation to downtilt
%% set sampling rate
channel.SampleRate = obj.f_sample;
channel.SampleDensity = 64;               %default setting channel gain 的取樣精度
channel.ChannelFiltering = false;

% %doppler
% v = 15.0;                    % UE velocity in km/h
% fc = 4e9;                    % carrier frequency in Hz
% c = physconst('lightspeed'); % speed of light in m/s
% fd = (v*1000/3600)/c*fc;     % UE max Doppler frequency in Hz
% channel.MaximumDopplerShift = fd;
channel.MaximumDopplerShift = 0;
end