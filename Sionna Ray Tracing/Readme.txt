Steps to run ray tracing:
1. Run "SionnaRT_PropagationPathSim.py" to generate propagation path simulation results, which will be later used for OFDM-MIMO_Throughput_Simulation.
2. To generate isotropic path gain maps, Use the Tx information recored during running "SionnaRT_PropagationPathSim.py", and run "Generate_PGIso.py". After running "Generate_PGIso.py", run "Process_data.py" to replace Nan values and resize data. Isotropic path gain maps will serves as the input of U-Net-TP.
