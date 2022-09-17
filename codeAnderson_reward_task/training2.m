sca
clear all;

%%%%%Uncomment the following line if the SyncTest fails%%%%%
% Screen('Preference', 'SkipSyncTests', 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Generates prompt to input subject information%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter Subject Number:'};
default = {'0'};
title = 'Setup Info';
LineNo = 1;
answer = inputdlg(prompt,title,LineNo,default);
[subjno_Str] = deal(answer{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Create file names, based on prior input%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName=['S' subjno_Str 'TrainG.xls'];
fileName2=['S' subjno_Str 'LogTrainG.xls'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Set Screen Parameters%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
bcolor = [0 0 0];
WinNum = 0; %0 for one monitor, 1 for two or more monitors
SetResolution(WinNum,1024,768,60); %WinNum, Length, Height, Hz of monitor
w = Screen('OpenWindow',WinNum,bcolor);
HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Set Font Parameters%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
oldfont=Screen('TextFont', w, 'Arial');
oldsize=Screen('TextSize', w, 40);       
oldstyle=Screen('TextStyle', w, 1);   

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Designate Variables%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
TrialDuration = 0.8;
NumTrials = 240;
EventLog = zeros(NumTrials,4); 
WaitTime = [0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6];
WaitTime = [WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime];
WaitTime = Shuffle(WaitTime);
points = 0;
score = '0.00';
change = '0';

cd stimuli

%Read in the stimuli
ReadColorStimG

%Generate Trial Sequence
LogL

cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Determine the position of the stimuli%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[width, height]=Screen('WindowSize', WinNum);
Cx = width/2;
Cy = height/2;
loc1 = [Cx-50 Cy-250 Cx+50 Cy-150];
loc2 = [Cx+150 Cy-143 Cx+250 Cy-43];
loc3 = [Cx+150 Cy+43 Cx+250 Cy+143];
loc4 = [Cx-50 Cy+150 Cx+50 Cy+250];
loc5 = [Cx-250 Cy+43 Cx-150 Cy+143];
loc6 = [Cx-250 Cy-143 Cx-150 Cy-43];

%%%%%%%%%%%%%%%%%%%%%%
%%%Practic sequence%%%
%%%%%%%%%%%%%%%%%%%%%%
feedback = 3;
CenterText2 (w, 'Get Ready For Some Practice', [255 255 255], 0, 0);
Screen('Flip',w);
WaitSecs(2);
StartOfExp = GetSecs;
for v2 = 1:size(PracLog,1);
    responded =0;
    Screen('Flip',w);
    WaitSecs(0.5);
    if v2 > 1
       if feedback == 1;
            CenterText2 (w, 'Correct!', [255 255 255], 0, 0);
            Screen('Flip',w);
            WaitSecs(1);
        elseif feedback == 2;
            CenterText2 (w, 'Incorrect', [255 255 255], 0, 0);
            Screen('Flip',w);
            WaitSecs(1);
        elseif feedback == 3;
            Screen('Flip',w);
            beep2(1000,.25);
            WaitSecs(0.75);
        end
        Screen('Flip',w);
        WaitSecs(1);
        feedback = 3;
    end
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('Flip',w);
    WaitSecs(WaitTime(v2));
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('DrawTexture',w,Item(PracLog(v2,1)),[],loc1);
    Screen('DrawTexture',w,Item(PracLog(v2,2)),[],loc2);
    Screen('DrawTexture',w,Item(PracLog(v2,3)),[],loc3);
    Screen('DrawTexture',w,Item(PracLog(v2,4)),[],loc4);
    Screen('DrawTexture',w,Item(PracLog(v2,5)),[],loc5);
    Screen('DrawTexture',w,Item(PracLog(v2,6)),[],loc6);
    Screen('Flip',w);
    TimeOfStim = GetSecs; %%%Returns the time the flip occurred relative to when the experiment started
    while GetSecs-TimeOfStim < TrialDuration & responded == 0;
        [keyIsDown,respTime,respKey]=KbCheck;
        if keyIsDown == 1
            resp = find(respKey);
            feedback = 2;
            responded =1;
            if PracLog(v2,8)==2
                if resp(1) == KbName('z') || resp(1) == KbName('Z')
                    feedback = 1;
                end
            elseif PracLog(v2,8)==1
                if resp(1) == KbName('m') || resp(1) == KbName('M')
                    feedback = 1;
                end
            end
        end
    end
end
responded =0;
Screen('Flip',w);
WaitSecs(0.5);
if feedback == 1;
    CenterText2 (w, 'Correct!', [255 255 255], 0, 0);
    Screen('Flip',w);
    WaitSecs(1);
elseif feedback == 2;
    CenterText2 (w, 'Incorrect', [255 255 255], 0, 0);
    Screen('Flip',w);
    WaitSecs(1);
elseif feedback == 3;
    Screen('Flip',w);
    beep2(1000,.25);
    WaitSecs(0.75);
end
Screen('Flip',w);
WaitSecs(1);
feedback = 3;

%%%%%%%%%%%%%%%%%%%%
%%%Trial sequence%%%
%%%%%%%%%%%%%%%%%%%%
CenterText2 (w, 'Practice is complete.', [255 255 255], [], [-80])
CenterText2 (w, 'The experimental trials', [255 255 255], [], [+0])
CenterText2 (w, 'will now begin', [255 255 255], [], [+80])
Screen('Flip',w);
WaitSecs(4);
StartOfExp = GetSecs;
for v2 = 1:size(FrameLog,1);
    if v2 > 1
        if responded == 0
            Screen('Flip',w);
            beep2(1000,.25);
        end
    end
    Screen('Flip',w);
    WaitSecs(1);
    responded =0;
    CenterText2 (w, ['+ ' change '¢'], [255 255 255], [], [-40])
    CenterText2 (w, ['$' score ' total'], [255 255 255], [], [+40]);
    Screen('Flip',w);
    WaitSecs(1.5);
    change = '0';
    Screen('Flip',w);
    WaitSecs(1);
     if v2 == 121
      CenterText2 (w, 'Take a short break.', [255 255 255], [], [-80])
      CenterText2 (w, 'The experiment will', [255 255 255], [], [+0])
      CenterText2 (w, 'resume in 30 seconds', [255 255 255], [], [+80])
      Screen('Flip',w);
      WaitSecs(30);
      CenterText2 (w, 'Press Space Bar When Ready', [255 255 255], 0, 0);
      Screen('Flip',w);
      KbWait([], 2);
      WaitSecs(1);
    end
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('Flip',w);
    WaitSecs(WaitTime(v2));
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('DrawTexture',w,Item(FrameLog(v2,1)),[],loc1);
    Screen('DrawTexture',w,Item(FrameLog(v2,2)),[],loc2);
    Screen('DrawTexture',w,Item(FrameLog(v2,3)),[],loc3);
    Screen('DrawTexture',w,Item(FrameLog(v2,4)),[],loc4);
    Screen('DrawTexture',w,Item(FrameLog(v2,5)),[],loc5);
    Screen('DrawTexture',w,Item(FrameLog(v2,6)),[],loc6);
    Screen('Flip',w);
    TimeOfStim = GetSecs; %%%Returns the time the flip occurred relative to when the experiment started
    EventLog(v2,3)= TimeOfStim - StartOfExp; %when stimulus was presented
    EventLog(v2,4)= FrameLog(v2,7); %type of target
    while GetSecs-TimeOfStim < TrialDuration & responded == 0;
        [keyIsDown,respTime,respKey]=KbCheck;
        if keyIsDown == 1
            resp = find(respKey);
            EventLog(v2,2)=(respTime-TimeOfStim); %%%RT relative to when the target was flipped on the screen
            responded =1;
            if FrameLog(v2,8)==2
                if resp(1) == KbName('z') || resp(1) == KbName('Z')
                    EventLog(v2,1)=1; %ACC (correct), otherwise is 0 (incorrect)
                    points = points + FrameLog(v2,9);
                    score = num2str(points);
                    if length(score) == 1
                        score = ['0' '.' '0' score(1)];
                    elseif length(score) == 2
                        score = ['0' '.' score(1) score(2)];
                    elseif length(score) == 3
                        score = [score(1) '.' score(2) score(3)];
                    elseif length(score) == 4
                        score = [score(1) score(2) '.' score(3) score(4)];
                    end
                    change = num2str(FrameLog(v2,9));
                end
            elseif FrameLog(v2,8)==1
                if resp(1) == KbName('m') || resp(1) == KbName('M')
                    EventLog(v2,1)=1; %ACC (correct), otherwise is 0 (incorrect)
                    points = points + FrameLog(v2,9);
                    score = num2str(points);
                    if length(score) == 1
                        score = ['0' '.' '0' score(1)];
                    elseif length(score) == 2
                        score = ['0' '.' score(1) score(2)];
                    elseif length(score) == 3
                        score = [score(1) '.' score(2) score(3)];
                    elseif length(score) == 4
                        score = [score(1) score(2) '.' score(3) score(4)];
                    end
                    change = num2str(FrameLog(v2,9));
                end
            end
        end
    end
end
if responded == 0
    Screen('Flip',w);
    beep2(1000,.25);
end
Screen('Flip',w);
WaitSecs(1);
CenterText2 (w, ['+ ' change '¢'], [255 255 255], [], [-40])
CenterText2 (w, ['$' score ' total'], [255 255 255], [], [+40]);
Screen('Flip',w);
WaitSecs(1.5);
CenterText2 (w, 'Task Complete!', [255 255 255], 0, 0);
Screen('Flip',w);
WaitSecs(4);

%%%%%%%%%%%%%%%
%%%Save Data%%%
%%%%%%%%%%%%%%%
cd TrainingData
xlswrite(fileName, EventLog);
xlswrite(fileName2, FrameLog);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Get Back to Matlab Command Window%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('CloseAll')