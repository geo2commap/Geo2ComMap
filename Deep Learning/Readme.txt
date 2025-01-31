1. File "UNet_Training.py" is the code used for training U-Net.
2. File "UNet_Testing.py" is the code used for testing the performance of trained U-Net.
3. "UNet.py" is the model of U-Net-TP.
4. "AttentionUNet.py" is the model of integrating attention gates into the skip connection of U-Net-TP.
4. "SpecialSampling_Algorithm.py" provide the algorithm of the special sampling method.
5. "Data_proprocess.py" merge P_iso, Building Map, Sparse Tput, Sparse RI, and Sparse CQI into a (128, 128, 3) image, which will serve as the input of U-Net-TP.