%set things up
ClockRandSeed;
NumTrials = 240;
NumPracTrials = 50;

%%%designate non-target items, targ ID, reward, targ pos, & resp
%non-target items
baseNum = [1 3 5 7 9 11];
slant = [1 1 1 0 0 0];
%targ ID
z = zeros(1,NumTrials/2);
o = ones(1,NumTrials/2);
color = [z o];
color = Shuffle(color);
%targ resp
z = zeros(1,NumTrials/4);
o = ones(1,NumTrials/4);
z = z+2;
resp = [z o];
cT1 = 0;
cT2 = 0;
respT1 = Shuffle(resp);
respT2 = Shuffle(resp);
%reward
z = ones(1,NumTrials/2*.8);
o = zeros(1,NumTrials/2*.2);
money1 = [z o];
money2 = [z o];
money1 = Shuffle(money1);
money2 = Shuffle(money2);
%targ pos
x = [1 2 3 4 5 6];
x = [x x x x x x x x x x];
t1pos = Shuffle(x);
t2pos = Shuffle(x);
t3pos = Shuffle(x);
t4pos = Shuffle(x);
cp1 = 0;
cp2 = 0;
cp3 = 0;
cp4 = 0;
for x = 1:length(money1)
    if money1(x) == 1
        money1(x) = 2;
    elseif money1(x) == 0
        money1(x) = 10;
    end
    if money2(x) == 1
        money2(x) = 10;
    elseif money2(x) == 0
        money2(x) = 2;
    end
end
%enter into FrameLog
for x = 1:NumTrials
    baseNum = Shuffle(baseNum);
    FrameLog(x,1:6) = baseNum;
    slant = Shuffle(slant);
    FrameLog(x,1:6) = FrameLog(x,1:6) + slant;
    if color(x) == 0
        cT1 = cT1+1;
        FrameLog(x,7) = 0;
        FrameLog(x,8) = respT1(cT1);
        if respT1(cT1) == 1;
            cp1 = cp1+1;
            FrameLog(x,t1pos(cp1)) = 200;
        elseif respT1(cT1) == 2;
            cp2 = cp2+1;
            FrameLog(x,t2pos(cp2)) = 250;
        end
        FrameLog(x,9) = money1(cT1);
    elseif color(x) == 1
        cT2 = cT2+1;
        FrameLog(x,7) = 1;
        FrameLog(x,8) = respT2(cT2);
        if respT2(cT2) == 1;
            cp3 = cp3+1;
            FrameLog(x,t3pos(cp3)) = 100;
        elseif respT2(cT2) == 2;
            cp4 = cp4+1;
            FrameLog(x,t4pos(cp4)) = 150;
        end
        FrameLog(x,9) = money2(cT2);
    end
end

%create PracLog
Pos = randperm(NumTrials);
for x = 1:NumPracTrials
    PracLog(x,:) = FrameLog(Pos(x),:);
end

clear z x o Pos NumTrials NumPracTrials ans baseNum cT1 cT2 resp respT1 respT2 color slant money1 money2 cp1 cp2 cp3 cp4 t1pos t2pos t3pos t4pos