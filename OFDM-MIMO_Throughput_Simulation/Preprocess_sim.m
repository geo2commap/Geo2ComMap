function [sim] = Preprocess_sim(sim)

        sim.path_gain    = double(sim.path_gain);             % gain (linear)
        sim.path_phase   = double(sim.path_phase);            % phase (rad)
        sim.path_delay   = double(sim.path_delay);            % delay (sec)
        sim.path_AOA_hor = double(sim.path_AOA_hor) + pi/2;   % AOA horizontal (rad)
        sim.path_AOA_ver = double(sim.path_AOA_ver) - pi/2;   % AOA vertical (rad)
        sim.path_AOD_hor = double(sim.path_AOD_hor) + pi/2;   % AOD horizontal (rad)
        sim.path_AOD_ver = double(sim.path_AOD_ver) - pi/2;   % AOD vertical (rad)

        path_gain = sim.path_gain;      % gain (linear)
        
        sim.path_gain(path_gain == 0)    = [];   % gain (linear)
        sim.path_phase(path_gain == 0)   = [];   % phase (rad)
        sim.path_delay(path_gain == 0)   = [];   % delay (sec)
        sim.path_AOA_hor(path_gain == 0) = [];   % AOA horizontal (rad)
        sim.path_AOA_ver(path_gain == 0) = [];   % AOA vertical (rad)
        sim.path_AOD_hor(path_gain == 0) = [];   % AOD horizontal (rad)
        sim.path_AOD_ver(path_gain == 0) = [];   % AOD vertical (rad)
end