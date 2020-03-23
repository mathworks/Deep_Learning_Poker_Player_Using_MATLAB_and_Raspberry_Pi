function [bet, finalHand] = build_hands_for_app(hand,nHand)
%#codegen
% Copyright 2020 The MathWorks, Inc.

rank = char(zeros(1,nHand));
for k = 1:nHand
    card = hand{k};
    rank(k) = card(1);
end
fprintf('rank: %s\n',rank);

suit = char(zeros(1,nHand));
for k = 1:nHand
    card = hand{k};
    suit(k) = card(2);
end
fprintf('suit: %s\n',suit);

[sf,hc] = findStraightFlush(rank,suit);
if sf
    bet = 900 * adjustFaceCards(hc);
    finalHand = 'Straight Flush';
else
    [k4,hc] = find4Kind(rank);
    if k4
        bet = 800 * adjustFaceCards(hc);
        finalHand = '4 OAK';
    else
        [fh,hc] = findFullHouse(rank);
        if fh
            bet = 700 * adjustFaceCards(hc);
            finalHand = 'Full House';
        else
            [f,hc] = findFlush(rank,suit);
            if f
                bet = 600 * adjustFaceCards(hc);
                finalHand = 'Flush';
            else
                [s,hc] = findStraight(rank);
                if s
                    bet = 500 * adjustFaceCards(hc);
                    finalHand = 'Straight';
                else
                    [k3,hc] = find3Kind(rank);
                    if k3
                        bet = 400 * adjustFaceCards(hc);
                        finalHand = '3 OAK';
                    else
                        [p2,hc] = find2Pair(rank);
                        if p2
                            bet = 300 * adjustFaceCards(hc);
                            finalHand = '2 Pair';
                        else
                            [p,hc] = findPair(rank);
                            if p
                                bet = 200 * adjustFaceCards(hc);
                                finalHand = 'Pair';
                            else
                                bet = 100 * adjustFaceCards(hc);
                                finalHand = 'High Card';
                            end
                        end
                    end
                end
            end
        end
    end
end
fprintf('Hand: %s \n',finalHand);
fprintf('++++++++++++++++++++++\n')
fprintf('Bet: %f\n',bet)
fprintf('++++++++++++++++++++++\n')
end

function mult = adjustFaceCards(c)
        if c == 'T'
            mult = char(58);
        elseif c == 'J'
            mult = char(59); 
        elseif c == 'Q'
            mult = char(60);
        elseif c == 'K'
            mult = char(61);
        elseif c == 'A'
            mult = char(62);
        else 
            mult = char(c);
        end
        
        mult = char(mult - 49);
end

function [hasPair,highCard] = findPair(rank)
    if isempty(rank)
        hasPair = false;
        highCard = '2';
        return;
    end
    ord = sort(rank);
    hasPair = (any(diff(ord) == 0));
    if hasPair
        highCard = findHC(ord(diff(ord) == 0));
    else 
        highCard = findHC(ord);
    end
end

function [highcard] = findHC(cards)
    if isempty(cards)
        highcard = '2';
        return;
    end
    adj = zeros(1,length(cards));    
    for k = 1:length(adj) 
        if cards(k) == 'T'
            adj(k) = char(58);
        elseif cards(k) == 'J'
            adj(k) = char(59); 
        elseif cards(k) == 'Q'
            adj(k) = char(60);
        elseif cards(k) == 'K'
            adj(k) = char(61);
        elseif cards(k) == 'A'
            adj(k) = char(62);
        else 
            adj(k) = cards(k);
        end
    end
    ix = find(adj == max(adj));
    highcard = char(cards(ix(1)));
end

function [hasPair,highCard] = find2Pair(rank)
    [pair,hc] = findPair(rank);
    highCard = hc;
    if ~pair
        hasPair = pair;
        
    else
        newset = rank(rank ~= hc);
        [pair2,~] = findPair(newset);
        hasPair = pair2;
    end
end

function [hasPair,highCard] = find3Kind(rank)
    ord = sort(rank);
    t = sum(diff(ord) == 0) >= 2;
    if ~t
        hasPair = false;
        highCard = findHC(rank);
    else
        d = diff(ord) == 0;
        d2 = [diff(d) == 0 false];
        hasPair = any(d & d2);
        if hasPair
            ix = find(d & d2);
            highCard = char(ord(ix(end)));
        else 
            highCard = char(findHC(rank));
        
        end
    end
end

function [hasPair,highCard] = findFullHouse(rank)
    [has3k,hc] = find3Kind(rank);
    if ~has3k
        hasPair = false;
        highCard = findHC(rank);
    else
        highCard = hc;
        subhand = rank(rank ~= hc);
        [pair,~] = findPair(subhand);
        hasPair = pair;
    end
end

function [hasPair,highCard] = find4Kind(rank)
    [~,hc] = find3Kind(rank);
    hasPair = sum(rank == hc) >= 4;
    highCard = hc;
end

function [hasPair,highCard] = findStraight(rank)

    [ord,ix] = specialSort(rank);
    adjSet = rank(ix);
    od = diff(ord) == 1;
    count = 0;
    j = length(od);
    while j > 0
        if od(j)
            count = count + 1;
        else 
            count = 0;
        end
        if count >= 4
            break;
        end
        j = j - 1;
    end
    
    hasPair = count >= 4;
    if hasPair
        highCard = char(adjSet(j + 4));
    else
        highCard = char(findHC(rank));
    end
end

function [sorted,order] = specialSort(cards)
    adj = zeros(1,length(cards));    
    for k = 1:length(adj) 
        if cards(k) == 'T'
            adj(k) = 58;
        elseif cards(k) == 'J'
            adj(k) = 59; 
        elseif cards(k) == 'Q'
            adj(k) = 60;
        elseif cards(k) == 'K'
            adj(k) = 61;
        elseif cards(k) == 'A'
            adj(k) = 62;
        else 
            adj(k) = cards(k);
        end
    end
    [sorted,order] = sort(adj);
end

function [hasPair,highCard] = findFlush(rank,suit)
    [ord,ix] = sort(suit);
    rank = rank(ix);
    od = diff(ord) == 0;
    count = 0;
    j = length(od);
    while j > 0
        if od(j)
            count = count + 1;
        else 
            count = 0;
        end
        if count >= 4
            break;
        end
        j = j - 1;
    end
    
    hasPair = count >= 4;
    if hasPair
        highCard = char(rank(j + 4));
    else
        highCard = char(findHC(rank));
    end
    
end

function [hasPair,highCard] = findStraightFlush(rank,suit)
    [s,hc1] = findStraight(rank);
    [f,hc2] = findFlush(rank,suit);
    hasPair = s && f;
    highCard = max(hc1,hc2);
end
