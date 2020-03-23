function aiBet = raspi_predict(net,imgSizeAdjusted)
%#codegen
% Copyright 2020 The MathWorks, Inc.

persistent fullset nIters hand table oppHand bank oppfullset;

%Initialize variables
if isempty(fullset)
    fullset = {'00', '00' '00' '00' '00' '00', '00'};
    oppfullset = {'00', '00' '00' '00' '00' '00', '00'};
    nIters = 0;
    hand = {'00' '00'};
    table = {'00' '00' '00' '00' '00'};
    oppHand = {'00' '00'};
    bank = 20000;
    fprintf('Bank: %f\n',bank);
end

[label,score]   = net.classify(imgSizeAdjusted);

labelStr  = cellstr(label);
maxScore  = max(score);
outputStr = sprintf('Label : %s \nScore : %f',labelStr{:},maxScore);

%Print label and score to stdout
fprintf('%s\n',outputStr);

nIters = nIters + 1;
fprintf('nIters: %f\n',nIters);

if nIters < 3
    fprintf("Adding to AI Hand...\n")
    hand{nIters} = labelStr{:};
elseif nIters < 8
    fprintf("Adding to table...\n")
    table{nIters - 2} = labelStr{:};
elseif nIters < 10
    fprintf("Adding to opp Hand...\n")
    oppHand{nIters - 7} = labelStr{:};
end

if nIters == 2
    fprintf("Adding to table...\n")
elseif nIters == 7
    fprintf("Adding to opp Hand...\n")
end

if nIters < 8
    for i = 1:nIters
        if i < 3
            fullset{i} = hand{i};
        else
            fullset{i} = table{i - 2};
            oppfullset{i} = table{i - 2};
        end
    end
elseif nIters == 8
    oppfullset{1} = oppHand{nIters - 7};
elseif nIters == 9
    oppfullset{2} = oppHand{nIters - 7};
end

aiBet = build_hands(fullset,nIters);

if nIters == 10
    oppBet = build_hands(oppfullset,7);
    if aiBet > oppBet
        fprintf('You Lose\n')
        bank = bank + aiBet;
    elseif aiBet == oppBet
        fprintf('Its a tie!')
    else
        fprintf('You Win!!\n')
        bank = bank - aiBet;
    end
    nIters = 0;
end

fprintf('Bank: %f\n',bank)
fprintf('=============================================\n')

end
