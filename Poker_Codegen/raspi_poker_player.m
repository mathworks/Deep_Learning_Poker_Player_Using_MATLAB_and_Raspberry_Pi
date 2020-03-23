function raspi_poker_player()
%#codegen
% Copyright 2020 The MathWorks, Inc.

%Create raspi & webcam obj. Conigure inpute pins 
raspiObj = raspi();
cam      = webcam(raspiObj,1);
configurePin(raspiObj,18,'DigitalInput');
configurePin(raspiObj,24,'DigitalInput');

%Initialize DAGNetwork and the input size
net        = coder.loadDeepLearningNetwork('identifyCards.mat','cardNet');
inputSize  = [227, 227,3]; %net.Layers(1).InputSize;

%Initialize local variables
bet           = 0;
processImage  = 1;
textToDisplay = '......'; %#ok<NASGU>

fprintf('Entering into while loop.\n');
while true
    %Capture image from webcam
    img = snapshot(cam);
    
    if readDigitalPin(raspiObj,18)
        %Resize the image
        if (processImage == 1)
            imgSizeAdjusted = imresize(img,inputSize(1:2));
            bet = raspi_predict(net,imgSizeAdjusted);
            %No need to run the DL n/w on image with the same switch click.
            processImage = 0;
        end
    else
        %Make sure that the image is captured and passed to the DL with
        %next switch click.
        processImage = 1;
    end
    
    %Display the image with additional details
    textToDisplay = sprintf('bet: %f',bet);
    img_label = insertText(img,[0,0],textToDisplay);
    displayImage(raspiObj,img_label);
end
