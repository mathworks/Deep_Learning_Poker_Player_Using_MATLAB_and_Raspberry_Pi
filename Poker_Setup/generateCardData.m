% Copyright 2018-2020 The MathWorks, Inc.

%% Clear workspace and create webcam obj
clear;
cam = webcam;
preview(cam);

%% Initialize varialbes
NumImages = 200; % Max = 1000
suits     = ['D' 'C' 'H' 'S'];
suitsfull = ["Diamond", "Club","Heart",'Spade'];
rank      = ['A' '2' '3' '4' '5' '6' '7' '8' '9' 'T' 'J' 'Q' 'K'];
rankfull  = ["Ace", "Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Jack","Queen","King"];

%% Get input from commandline and validate
disp('Show the card to the webcam and enter the card name in short form. ex: "2D" for Diamond-Two, AC for Club-Ace');
cardname = input('Enter card name in short form:','s');
if ~ischar(cardname) || (numel(cardname) ~= 2) || ~contains(rank,cardname(1)) || ~contains(suits,cardname(2))
    error('Invalid cardname');
end

%% Generate Data from Video
waitBarHandle = waitbar(0,['Prepare ' cardname '... ']);
cardsDirectory = fullfile(pwd,'cards',cardname);
unusedImgsDirectory = fullfile(pwd,'unused_imgs',cardname);
mkdir(cardsDirectory);
mkdir(unusedImgsDirectory);
% Capture input from webcam and save to file.
tic
for i = 1:1000
    waitbar(i/1000,waitBarHandle,['Saving image: ' num2str(i)]);
    im = snapshot(cam);
    if mod(i,2)
        im = imrotate(im,180);
    end
    if i <= NumImages
        imwrite(im,fullfile(cardsDirectory,[cardname,num2str(i) '.png']));
    else
        imwrite(im,fullfile(unusedImgsDirectory,[cardname,num2str(i) '.png']));
    end
end
waitbar(1,waitBarHandle,['Capturing images for ',cardname,' completed.']);
toc;
%%END
