[![View Deep_Learning_Poker_Player_using_MATLAB_and_Raspberry_Pi on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/75018-deep_learning_poker_player_using_matlab_and_raspberry_pi)

# Deep_Learning_Poker_Player_using_MATLAB_and_Raspberry_Pi
This package includes MATLAB scripts that help you design a poker player using MATLAB, Deep Learning, and Raspberry Pi. 
The poker-playing algorithm consists of a deep learning network that predicts the cards, and a custom MATLAB algorithm that
identifies ranked hands from the predictions and then makes bets like an actual player would. The algorithm can finally be 
deployed to a Raspberry Pi hardware.

# Prerequisite
Configure the Raspberry Pi network, using the hardware-setup screen. During the this process, ensure that you download the MathWorks Raspbian image for deep learning.

# Poker_Setup:
This folder contains all the required files to generate a new dataset and train the classifier.

To generate datasets for training, connect a webcam to your PC and run the script "generateCardData.m"
Once card datasets are ready, run "transferLearnedCardset.m" for transferlearning.
This will create "identifyCards.mat" where all DNN info are stored.

# Poker_MATLAB_App:
Source code for the MATLAB App version of the poker player

Copy "identifyCards.mat" generated from Poker_Setup to this directory.
Run the MATLAB App.

# Poker_Codegen:
Codegen capable MATLAB function that can be deployed to Raspberry Pi

Copy "identifyCards.mat" generated from Poker_Setup to this directory.
Deploy the MATLAB function "raspi_poker_player" to Raspberry using the following commands:


>> t = targetHardware('Raspberry Pi')  
>> t.CoderConfig.TargetLang = 'C++'  
>> dlcfg = coder.DeepLearningConfig('arm-compute')  
>> dlcfg.ArmArchitecture = 'armv7'  
>> t.CoderConfig.DeepLearningConfig = dlcfg  
>> deploy(t,'raspi_poker_player')  
