Steps to use OFDM-MIMO throughput simulation: 
1. Put ray tracing results in "RT_Data" directory.
2. Run call_preprocess.m to preprocess ray tracing data.
3. Run main.m to simulate throughput.
4. All the simulation results including RI, CQI, throughput... will be saved in "Report" directory.
5. Tx power will be recorded in antenna_power_values.txt
6. Run "Extract_CQI_Index.py", "Extract_RI.py", and "Extract_Tput.py" to extract CQI index, RI, and Tput data from the simulated result saved in "Report" directory.
7. Run "CQIIndex2Efficiency.py" to convert CQI index to efficiency.
