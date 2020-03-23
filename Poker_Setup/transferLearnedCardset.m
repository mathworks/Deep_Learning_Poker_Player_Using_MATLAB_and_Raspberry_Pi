%% Clear workspace create image data store for classification
clear;
imds                       = imageDatastore('cards','IncludeSubfolders',true,'LabelSource','foldernames');
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');
%% Initialize net and replace layer for transfer learning
net                         = squeezenet;
inputSize                   = net.Layers(1).InputSize;

if isa(net,'SeriesNetwork')
    lgraph = layerGraph(net.Layers);
else
    lgraph = layerGraph(net);
end

[learnableLayer,classLayer] = findLayersToReplace(lgraph);
numClasses                  = numel(categories(imdsTrain.Labels));

if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
                                            'Name','new_fc', ...
                                            'WeightLearnRateFactor',10, ...
                                            'BiasLearnRateFactor',10);
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
                                           'Name','new_conv', ...
                                           'WeightLearnRateFactor',10, ...
                                           'BiasLearnRateFactor',10);
end

lgraph        = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph        = replaceLayer(lgraph,classLayer.Name,newClassLayer);

layers        = lgraph.Layers;
connections   = lgraph.Connections;
layers(1:10)  = freezeWeights(layers(1:10));
lgraph        = createLgraphUsingConnections(layers,connections);

is                = net.Layers(1).InputSize;
audsTrain         = augmentedImageDatastore(is(1:2),imdsTrain);
augimdsValidation = augmentedImageDatastore(is(1:2),imdsValidation);

%% Options for transfer learning
options = trainingOptions('sgdm', ...
                          'MiniBatchSize',50, ...
                          'MaxEpochs',6, ...
                          'InitialLearnRate',1e-3, ...
                          'Shuffle','every-epoch', ...
                          'ValidationData',augimdsValidation, ...
                          'ValidationFrequency',3, ...
                          'Verbose',false, ...
                          'Plots','training-progress', ...
                          'ExecutionEnvironment','parallel',...
                          'ValidationPatience',Inf);
netTransfer = trainNetwork(audsTrain,lgraph,options); %layerGraph(layers)
save('identifyCards.mat','netTransfer');
disp('Transfer learing done. Network saved to identifyCards.mat');

%%
[YPred,scores] = classify(netTransfer,augimdsValidation);
YValidation    = imdsValidation.Labels;
accuracy       = mean(YPred == YValidation);
AccuracyOutput = ['Accuracy = ',num2str(accuracy)];
disp(AccuracyOutput);

%% Real time accuracy:
cam = webcam;
preview(cam)
test = input('To measure realtime accuracy, show a card infront of webcam and press "y". If not press "n". :','s');
if (lower(test) == 'y')
    im = snapshot(cam);
    im2 = imresize(im,inputSize);
    [labelPredicted, scoresPredicted] = classify(netTransfer,im2);
    output = ['Predicted label = ',char(labelPredicted),' Score = ',num2str(max(scoresPredicted))];
    disp(output);
end
