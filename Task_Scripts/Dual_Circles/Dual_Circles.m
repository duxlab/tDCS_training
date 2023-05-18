

function Dual_Circles

stand_alone = 0;

if stand_alone == 1
    clear all;
    subject_number = input('Subject Number?   ');
    Phase_exp = input('Practice? 1= yes, 4 = no   ');
    Hand = input('Hand? 1 or 2   ');
    Colour_order = input('Colour order? 1, 2, or 3?   ');
    Sound_order = input('Sound order? 1, 2, or 3?   ');
    SessionNumber = input('Session number? 1 = pre, 6 = post and 7 = followup.   ');
else    
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject_number = ActiveData(1,1);
    SessionNumber = ActiveData(1,2);
    Colour_order = ActiveData(1,3);
    Sound_order = ActiveData(1,4);
    Phase_exp = ActiveData(1,7);
    Hand = ActiveData(1,8);
    cd('Dual_Circles')
end;

warning off;
disp('START PROGRAM');

% Debugging settings

speed = 1; % setting variable to run in fast mode = set as .1

rand('state',sum(100*clock));
randstate = rand('state');

KbName('UnifyKeyNames');
KbCheck;
GetSecs;

NumOfTrials = 30;
NumofBlocks = 2;
PracTrials = 24;
BlockRepeat = 1;
BlockRepeatPracSingle=1;
BlockRepeatPrac=1;
PracRepeat=1;
key_press1=0; key_press2=0;
RespTime1 = 0; RespTime2 = 0;
AudRT=0; ColRT=0;
RT1 = 0; RT2 = 0;
Stim1Onset=0; Stim1Offset=0; Stim2Onset=0; Stim2Offset=0;
score=0;
ColourScore=0;
AuditoryScore=0;
Single_Stim=0; Col=0; Aud=0;
SoundOnset=0; SoundOffset=0; ColourOnset=0; ColourOffset=0;

filename = strcat('Dual_Task_Training_COLOURS_PREPOST_SubjectNumber_',num2str(subject_number),'_SessionNumber_',num2str(SessionNumber),'.txt'); 
mat_filename = strcat('Dual_Task_Training_COLOURS_PREPOST_SubjectNumber_',num2str(subject_number),'_SessionNumber_',num2str(SessionNumber),'.txt');

datafilepointer = fopen(filename,'wt'); 

results=zeros(1, 27); w=1;

% timings
StimPresDuration = 0.2*speed;
FixTimeEachTrial = 0.65*speed; 
SoffA = 0.2*speed;

Repeat_Length = NumOfTrials/2;
Repeat_Length2 = NumOfTrials/3;
background_color = [255 255 255];
FixSquare_color = [0 0 0];
Text_color = FixSquare_color;

%%
InitializePsychSound(1);

wavfile1 = 'FinSound_1_200ms.wav';
wavfile2 = 'FinSound_2_200ms.wav';
wavfile3 = 'FinSound_3_200ms.wav';

[y1, freqwf1] = audioread(wavfile1);
wavedata1 = y1';
nrchannels1 = size(wavedata1,1); 
pahandle1 = PsychPortAudio('Open', [], 1, 1, freqwf1, 1, [], 0);

[y2, freqwf2] = audioread(wavfile2);
wavedata2 = y2';
nrchannels2 = size(wavedata2,1);
pahandle2 = PsychPortAudio('Open', [], 1, 1, freqwf2, 1, [], 0);

[y3, freqwf3] = audioread(wavfile3);
wavedata3 = y3';
nrchannels3 = size(wavedata3,1); 
pahandle3 = PsychPortAudio('Open', [], 1, 1, freqwf3, 1, [], 0);


PsychPortAudio('FillBuffer', pahandle1, wavedata1);
PsychPortAudio('FillBuffer', pahandle2, wavedata2);
PsychPortAudio('FillBuffer', pahandle3, wavedata3);

%%
AssertOpenGL;
          
    %olddebuglevel=Screen('Preference', 'VisualDebuglevel', 3);
 
    screens=Screen('Screens');
    screenNumber=max(screens);
    Screen('Preference', 'SkipSyncTests', 2 );
    [expWin,rect]=Screen('OpenWindow',screenNumber,[211 211 211], [0 0 1920 1080]);
    % hack to open mini screen
%         [expWin,rect]=Screen('OpenWindow',screenNumber,[], [0 0 1920/3 1080/3]);

    [mx, my] = RectCenter(rect);
    Screen(expWin,'Flip');
    Screen('TextSize', expWin, 20);
    
    [xCenter, yCenter] = RectCenter(rect);
    
    Presentations = Repeat_Length;
    P = [1 Presentations;
         2 Presentations];
     
    cusu = cumsum([1; P(:,2)]);
    order = zeros(cusu(end)-1,1);
    order(cusu(1:end-1))=diff([0;P(:,1)]);
    order = cumsum(order);
    
    ITI_condition=Shuffle(order);
    
    Presentations2 = Repeat_Length2;
    P2 = [1 Presentations2;
         2 Presentations2;
         3 Presentations2];

    cusu2 = cumsum([1; P2(:,2)]);
    order2 = zeros(cusu2(end)-1,1);
    order2(cusu2(1:end-1))=diff([0;P2(:,1)]);
    order2 = cumsum(order2);

    TrialTypeRandomisation=Shuffle(order2);
    
    
    HideCursor;
  
    Screen('TextSize', expWin, 20);
  
    FlushEvents('keyDown');
  
    R = [237 32 36];
    G = [10 130 65];
    B = [44 71 151];

   
   if Colour_order==1; Colour_1=(R); Colour_2=(G); Colour_3=(B); 
   elseif Colour_order==2; Colour_1=(B); Colour_2=(R); Colour_3=(G); 
   elseif Colour_order==3; Colour_1=(G); Colour_2=(B); Colour_3=(R); 
   end;
   
   if Sound_order==1
       Stim1=pahandle1; Stim2=pahandle2; Stim3=pahandle3;
   elseif Sound_order==2
       Stim1=pahandle3; Stim2=pahandle1; Stim3=pahandle2;
   elseif Sound_order==3
       Stim1=pahandle2; Stim2=pahandle3; Stim3=pahandle1;
   end;

      
   TA = KbName('a');  TS = KbName('s');  TD = KbName('d'); TJ = KbName('j'); TK = KbName('k');  TL = KbName('l'); SP = KbName('space'); KP = KbName('p'); KQ = KbName('q');
         
   RespText1 = '"A"';   RespText2 = '"S"';  RespText3 = '"D"'; RespText4 = '"J"'; RespText5 = '"K"';   RespText6 = '"L"';

   Single_prac_sounds = 0; Single_prac_colours = 0; BothDualCorrectScore = 0;
   RT_tracker_SingleSounds = 0; RT_tracker_SingleColours = 0; RT_tracker_Dual = 0; 
  
%% Main Experiment

while Phase_exp <= 4
        
   if Phase_exp<=2; NumofBlocks = 1; NumOfTrials=15;
   elseif Phase_exp==3; NumofBlocks = 1; NumOfTrials=30;
   elseif Phase_exp>3; NumofBlocks = 8; NumOfTrials=30;
   end;

   Screen('TextSize', expWin, 30); 
   
   %% Instructons
   
   if Phase_exp==1
       Instruct1 = 'Dual Circles - Wait for Experiment Instructions. Sounds practice.'; DrawFormattedText(expWin, Instruct1, 'center', 'center'); Screen('Flip', expWin); WaitSecs(2); KbWait(); 
   elseif Phase_exp==2
       Instruct1 = 'Colours practice, press any key to begin.'; DrawFormattedText(expWin, Instruct1, 'center', 'center'); Screen('Flip', expWin); WaitSecs(2); KbWait(); 
   elseif Phase_exp==3
       Instruct1 = 'Sounds and colours practice, press any key to begin.'; DrawFormattedText(expWin, Instruct1, 'center', 'center'); Screen('Flip', expWin); WaitSecs(2); KbWait(); 
   elseif Phase_exp==4
       Instruct1 = 'Wait for Experimenter.'; DrawFormattedText(expWin, Instruct1, 'center', 'center'); Screen('Flip', expWin);
       K=0; 
       while K<1; [keyIsDown,secs,keyCode] = KbCheck;  
           if (find(find(keyCode) == KP)); K=1; end; 
       end;
   end;
   
   %%
   
    
 if Phase_exp==1 || Phase_exp>2
   
    if Hand==1
        DrawFormattedText(expWin, RespText1, (xCenter-220), 'center'); DrawFormattedText(expWin, RespText2, 'center', 'center'); DrawFormattedText(expWin, RespText3, (xCenter+180), 'center');
    elseif Hand==2
        DrawFormattedText(expWin, RespText4, (xCenter-220), 'center'); DrawFormattedText(expWin, RespText5, 'center', 'center');  DrawFormattedText(expWin, RespText6, (xCenter+180), 'center'); 
    end;
      Screen('Flip', expWin); tic; while toc<0.5; end;

 
     
    TimeStart=GetSecs;
    while GetSecs-TimeStart<=10
     [keyIsDown,secs,keyCode] = KbCheck;  
          if Hand==1
           if (find(find(keyCode) == TA))
                PsychPortAudio('Start', Stim1, 1, 0, 1); tic; while toc<0.2; end;
           elseif (find(find(keyCode) == TS))
                PsychPortAudio('Start', Stim2, 1, 0, 1); tic; while toc<0.2; end;
           elseif (find(find(keyCode) == TD))
                PsychPortAudio('Start', Stim3, 1, 0, 1); tic; while toc<0.2; end;
           end; 
          elseif Hand==2
            if (find(find(keyCode) == TJ))
              PsychPortAudio('Start', Stim1, 1, 0, 1); tic; while toc<0.2; end;
            elseif (find(find(keyCode) == TK))
              PsychPortAudio('Start', Stim2, 1, 0, 1); tic; while toc<0.2; end;
            elseif (find(find(keyCode) == TL))
              PsychPortAudio('Start', Stim3, 1, 0, 1); tic; while toc<0.2; end;
            end; 
       
          end;
     end;
  
    FlushEvents('keyDown');
    PsychPortAudio('DeleteBuffer');
 
 end;
 
     FlushEvents('keyDown'); 
     
 if Phase_exp>1
    
        Screen('TextSize', expWin, 30);
        Screen('FillOval', expWin, Colour_1, [(xCenter-250) (yCenter-50) (xCenter-150) (yCenter+50)]);
        Screen('FillOval', expWin, Colour_2, [(xCenter-50) (yCenter-50) (xCenter+50) (yCenter+50)]);
        Screen('FillOval', expWin, Colour_3, [(xCenter+150) (yCenter-50) (xCenter+250) (yCenter+50)]);
        
        if Hand==1 
            DrawFormattedText(expWin, RespText4, (xCenter-220), (yCenter-100)); DrawFormattedText(expWin, RespText5, 'center', (yCenter-100)); DrawFormattedText(expWin, RespText6, (xCenter+180), (yCenter-100));
        elseif Hand==2
            DrawFormattedText(expWin, RespText1, (xCenter-220), (yCenter-100)); DrawFormattedText(expWin, RespText2, 'center', (yCenter-100)); DrawFormattedText(expWin, RespText3, (xCenter+180), (yCenter-100));
        end;
        
        Screen('Flip', expWin);
        
        tic;
        while toc<=10
        end;
        
 end;
     
    three='3...'; two='2...'; one='1...';      
    Screen('TextSize', expWin, 40);
    DrawFormattedText(expWin, three, 'center', 'center'); Screen('Flip', expWin); timestamp3=GetSecs; while GetSecs-timestamp3<1; end;
    DrawFormattedText(expWin, two, 'center', 'center'); Screen('Flip', expWin); timestamp3=GetSecs; while GetSecs-timestamp3<1; end;
    DrawFormattedText(expWin, one, 'center', 'center'); Screen('Flip', expWin); timestamp3=GetSecs; while GetSecs-timestamp3<1; end;
    Rep=1;
    ISI=0;
      
    FlushEvents('keyDown');
    blockhalf=1;
    
    b = 1;
    
 while b <= NumofBlocks
    
     TrialTypeRandomisation=Shuffle(TrialTypeRandomisation); ITI_condition=Shuffle(ITI_condition);
    m = 1;
     
    %% Trial Loop
    
 while m <= NumOfTrials
        
     % Randomly assign 1 of 2 ITI jitter amounts 
        if ITI_condition(m)==1
            ITI=0.6*speed;
        elseif ITI_condition(m)==2
            ITI=1.0*speed;
        end;
        
        % Choose a radom colour
        
        ColourRandom = [1 2 3]; TrialColour = (Shuffle(ColourRandom)); 
        if TrialColour(1)==1; Trial_Colour=Colour_1; 
        elseif TrialColour(1)==2; Trial_Colour=Colour_2; 
        elseif TrialColour(1)==3; Trial_Colour=Colour_3;
        end;   
        SoundRandom = [1 2 3]; TrialSound = (Shuffle(SoundRandom)); 
        if TrialSound(1)==1; AudioStim=Stim1;
        elseif TrialSound(1)==2; AudioStim=Stim2;
        elseif TrialSound(1)==3; AudioStim=Stim3;
        end;
        
        % define the phase
        
    if Phase_exp==1
        Trial_Type=1; %single task trial, aud
    elseif Phase_exp==2
        Trial_Type=2; %single task trial, vis
    elseif Phase_exp>2 %practice single and dual, and main trials
        Trial_Type=TrialTypeRandomisation(m); %randomised single aud, single vis, or dual 
    end;
        
    % Fixation
    
    FixOnset = GetSecs; 
    Screen('FillRect',expWin, [0 0 0], [(xCenter-5) (yCenter-5) (xCenter+5) (yCenter+5)]);
    Screen('Flip', expWin);
    while ((GetSecs - FixOnset) <= ITI); end;
    FixOffset = GetSecs;
        
    Screen('Flip', expWin);    
     
    % Show Stimulus
    
    if Trial_Type==1 % sound only
        PsychPortAudio('Start', AudioStim, 1, 0, 1); SoundOnset = GetSecs; SoundOffset=SoundOnset+0.2;
        ColourOnset = NaN; ColourOffset=NaN;
    elseif Trial_Type==2 % colour only
        Screen('FillOval', expWin, Trial_Colour, [(xCenter-50) (yCenter-50) (xCenter+50) (yCenter+50)]); ColourOnset=GetSecs; ColourOffset=ColourOnset+0.2; Screen('Flip', expWin);
        SoundOnset = NaN; SoundOffset=NaN;
    elseif Trial_Type==3 % dual
        PsychPortAudio('Start', AudioStim, 1, 0, 1); SoundOnset = GetSecs; SoundOffset=SoundOnset+0.2;
        Screen('FillOval', expWin, Trial_Colour, [(xCenter-50) (yCenter-50) (xCenter+50) (yCenter+50)]); ColourOnset=GetSecs; ColourOffset=ColourOnset+0.2; Screen('Flip', expWin);
    end;
     
    Stim2Onset = GetSecs;

    keyCode=0;
    key_found1 = 0; key_found2 = 0;
    key_press1 = 0; key_press2 = 0;
    
      
    % check for keypress
    
    while ((GetSecs-Stim2Onset)<= StimPresDuration*speed)
    
        [keyIsDown,secs,keyCode] = KbCheck;
        if (keyIsDown) && key_found1 == 0
                if (find(find(keyCode) == TA))
                    key_press1 = 1; key_found1 = 1;
                    RespTime1 = GetSecs;
                elseif (find(find(keyCode) == TS))
                    key_press1 = 2; key_found1 = 1;
                    RespTime1 = GetSecs;
                elseif (find(find(keyCode) == TD))
                    key_press1 = 3; key_found1 = 1;
                    RespTime1 = GetSecs;
                end;
        end;
        if (keyIsDown) && key_found2 == 0
                if (find(find(keyCode) == TJ))
                    key_press2 = 4; key_found2 = 1;
                    RespTime2 = GetSecs;
                elseif (find(find(keyCode) == TK))
                    key_press2 = 5; key_found2 = 1;
                    RespTime2 = GetSecs;
                elseif (find(find(keyCode) == TL))
                    key_press2 = 6; key_found2 = 1;
                    RespTime2 = GetSecs;
                end
        end;
        
        FlushEvents('keyDown');
        
    end;
    
    % turn off Stimulus
    
    StimOffset=GetSecs;
    
    Screen('FillRect',expWin, [211 211 211], [(xCenter-5) (yCenter-5) (xCenter+5) (yCenter+5)]);
    Screen('Flip', expWin);
    
    % Wait an extra 2 sec max for key press, then move on
    
    while ((GetSecs - StimOffset)<= 2*speed) % I would redefine '2' as max_wait_keypress = 2; up the top of script
        [keyIsDown,secs,keyCode] = KbCheck;
        if (keyIsDown) && key_found1 == 0
            if (find(find(keyCode) == TA))
                key_press1 = 1; key_found1 = 1;
                RespTime1 = GetSecs;
            elseif (find(find(keyCode) == TS))
                key_press1 = 2; key_found1 = 1;
                RespTime1 = GetSecs;
            elseif (find(find(keyCode) == TD))
                key_press1 = 3; key_found1 = 1;
                RespTime1 = GetSecs;
            end;
        end;
        if (keyIsDown) && key_found2 == 0
            if (find(find(keyCode) == TJ))
                key_press2 = 4; key_found2 = 1;
                RespTime2 = GetSecs;
            elseif (find(find(keyCode) == TK))
                key_press2 = 5; key_found2 = 1;
                RespTime2 = GetSecs;
            elseif (find(find(keyCode) == TL))
                key_press2 = 6; key_found2 = 1;
                RespTime2 = GetSecs;
            end
        end;
        FlushEvents('keyDown');
    end;
    
   acC=0; acS=0; % reset accuracy to zero each trial
    
   % coding accuracy of response
   
if Hand==1
    
    AudRT=RespTime1-SoundOnset;
    ColRT=RespTime2-ColourOnset;
    
    if Trial_Type==1 || Trial_Type==3
        if (key_press1==1)
            if AudioStim==Stim1; acS=1;
            else; acS=0;
            end
        elseif (key_press1==2)
            if AudioStim==Stim2; acS=1;
            else; acS=0;
            end
        elseif (key_press1==3)
            if AudioStim==Stim3; acS=1;
            else; acS=0;
            end
        end;
        AuditoryScore=AuditoryScore+acS;
    else; acS=NaN;
    end;
        
    if Trial_Type==2 || Trial_Type==3
        if (key_press2==4)
            if Trial_Colour==Colour_1; acC=1;
            else; acC=0;
            end
        elseif (key_press2==5)
            if Trial_Colour==Colour_2; acC=1;
            else; acC=0;
            end
        elseif (key_press2==6)
            if Trial_Colour==Colour_3; acC=1;
            else; acC=0;
            end
        end;
        ColourScore=ColourScore+acC;
    else; acC=NaN;
    end;
    
else 
    
    AudRT=RespTime2-SoundOnset;
    ColRT=RespTime1-ColourOnset;
    
     if Trial_Type==2 || Trial_Type==3
        if (key_press1==1)
            if Trial_Colour==Colour_1; acC=1;
            else; acC=0;
            end
        elseif (key_press1==2)
            if Trial_Colour==Colour_2; acC=1;
            else; acC=0;
            end
        elseif (key_press1==3)
           if Trial_Colour==Colour_3; acC=1;
           else; acC=0;
            end
        end;
        ColourScore=ColourScore+acC;
     else; acC=99;
      end;
      
      if Trial_Type==1 || Trial_Type==3
        if (key_press2==4)
          if AudioStim==Stim1; acS=1;
          else; acS=0;
          end
        elseif (key_press2==5)
           if AudioStim==Stim2; acS=1;
           else; acS=0;
           end
        elseif (key_press2==6)
           if AudioStim==Stim3; acS=1;
           else; acS=0;
           end
        end;
      
        AuditoryScore=AuditoryScore+acS;
      
      else; acS=99;
      end;
 end;
 
 % Give some feedback for Practice
 
 if Phase_exp<=3
     if acS==1; TextToShow='Sound CORRECT'; DrawFormattedText(expWin, TextToShow, 'center', (yCenter-50)); 
        elseif acS==0; TextToShow='Sound WRONG'; DrawFormattedText(expWin, TextToShow, 'center', (yCenter-50));
        elseif acS==99
     end
     if acC==1; TextToShow='Colour CORRECT'; DrawFormattedText(expWin, TextToShow, 'center', (yCenter-110));
        elseif acC==0; TextToShow='Colour WRONG'; DrawFormattedText(expWin, TextToShow, 'center', (yCenter-110));
        elseif acC==99
     end
     
     Screen('Flip', expWin); WaitSecs(0.6*speed); % recode as 'feedback_display_duration = .6
     
 end;
     
 if Phase_exp == 3
     if Trial_Type ==1
        Single_prac_sounds = Single_prac_sounds+acS;
     elseif Trial_Type == 2
        Single_prac_colours = Single_prac_colours+acC;
     elseif Trial_Type == 3
         if acS == 1 && acC == 1
            BothDualCorrectScore = BothDualCorrectScore+1;
         end;
     end;
 elseif Phase_exp == 4
     if Trial_Type ==1
        Single_prac_sounds = Single_prac_sounds+acS;
        if acS == 1; RT_tracker_SingleSounds = RT_tracker_SingleSounds+AudRT; end;
     elseif Trial_Type == 2
        Single_prac_colours = Single_prac_colours+acC;
        if acC == 1; RT_tracker_SingleColours = RT_tracker_SingleColours+ColRT; end;
     elseif Trial_Type == 3
         if acS == 1 && acC == 1
            BothDualCorrectScore = BothDualCorrectScore+1;
            RT_tracker_Dual = RT_tracker_Dual + AudRT + ColRT;
         end;
     end;
 end;
   
 % Save results
 
       results(w,:) = [subject_number, SessionNumber, Sound_order, Colour_order, Phase_exp, b, m, Trial_Type, ITI_condition(m), TrialSound(1), TrialColour(1), key_press1, key_press2, RespTime1, RespTime2, AudRT, ColRT, acS, acC, AuditoryScore, ColourScore, FixOnset, FixOffset, SoundOnset, SoundOffset, ColourOnset, ColourOffset];
       dlmwrite(filename,results,'delimiter','\t','precision',8);
                         
    w=w+1;
    key_press=0;
    RespTime=0;
    RespTime1=0;
    RespTime2=0;
    SoundOnset=0;
    ColourOnset=0;
    
   FlushEvents('keyDown'); K=0;
   m=m+1;
 end;
 
 % Text for block breaks
 
if b == NumofBlocks/2
    
    BreakText1 = 'You are half way through!';
    BreakText2 = '30 second break...';
    
    DrawFormattedText(expWin, BreakText1, 'center', (yCenter-100)); 
    DrawFormattedText(expWin, BreakText2, 'center', 'center');
    Screen('Flip', expWin); WaitSecs(25*speed);
    
    % SHow count down for 5 sec
    counter = [5:-1:0];
    for count_down = 1:5
        DrawFormattedText(expWin, num2str(counter(count_down)), 'center', (yCenter-100));
        Screen('Flip', expWin); 
        WaitSecs(1*speed);
    end
   
end;
 
b=b+1;

end;

    if Phase_exp < 3
        Phase_exp=Phase_exp+1;
    elseif Phase_exp == 3 %end of last prac
        FlushEvents('keyDown');
        PercentSingleSounds = Single_prac_sounds/(NumofBlocks*NumOfTrials/3)*100; %3 = number of task bins i.e. sound, visual and dual
        PercentSingleColours = Single_prac_colours/(NumofBlocks*NumOfTrials/3)*100;
        PercentDual = BothDualCorrectScore/(NumofBlocks*NumOfTrials/3)*100;
        Wording1 = 'End of practice! Wait for the experimenter';
        Wording2 = strcat('Accuracy for the single task colours:',num2str(PercentSingleColours));
        Wording3 = strcat('Accuracy for the single task sounds:',num2str(PercentSingleSounds));
        Wording4 = strcat('Combined accuracy for the dual task trials:',num2str(PercentDual));
        DrawFormattedText(expWin, Wording1, 'Center', (my-100), Text_color, 115);
        DrawFormattedText(expWin, Wording2, 'Center', (my), Text_color, 115);
        DrawFormattedText(expWin, Wording3, 'Center', (my+100), Text_color, 115);
        DrawFormattedText(expWin, Wording4, 'Center', (my+200), Text_color, 115);
        Screen('Flip', expWin); WaitSecs(5*speed);
        KK = 0;
            while KK <1
               [keyIsDown,secs,keyCode] = KbCheck;  
               if (find(find(keyCode) == KP))
                   KK = 10;
               elseif (find(find(keyCode) == KQ))
                   Phase_exp=Phase_exp-1;
                   KK = 10;
               end
            end
        Phase_exp=Phase_exp+1;    
        Single_prac_sounds = 0; Single_prac_colours = 0; BothDualCorrectScore = 0;
    elseif Phase_exp == 4
        PercentSingleSounds = Single_prac_sounds/(NumofBlocks*NumOfTrials/3)*100; MeanRTSingleSounds = RT_tracker_SingleSounds/Single_prac_sounds;
        PercentSingleColours = Single_prac_colours/(NumofBlocks*NumOfTrials/3)*100; MeanRTSingleColours = RT_tracker_SingleColours/Single_prac_colours;
        PercentDual = BothDualCorrectScore/(NumofBlocks*NumOfTrials/3)*100; MeanRTDual = RT_tracker_Dual/(BothDualCorrectScore*2);
        Wording1 = 'End of session! Wait for the experimenter';
        Wording2 = strcat('Single task colours acuracy: ',num2str(PercentSingleColours),' and reaction time: ',num2str(MeanRTSingleColours));
        Wording3 = strcat('Single task sounds acuracy: ',num2str(PercentSingleSounds),' and reaction time: ',num2str(MeanRTSingleSounds));
        Wording4 = strcat('Dual task acuracy: ',num2str(PercentDual),' and reaction time: ',num2str(MeanRTDual));
        DrawFormattedText(expWin, Wording1, 'Center', (my-100), Text_color, 115);
        DrawFormattedText(expWin, Wording2, 'Center', (my), Text_color, 115);
        DrawFormattedText(expWin, Wording3, 'Center', (my+100), Text_color, 115);
        DrawFormattedText(expWin, Wording4, 'Center', (my+200), Text_color, 115);
        Screen('Flip', expWin); WaitSecs(30*speed);
        KK = 0;
        while KK <1
           [keyIsDown,secs,keyCode] = KbCheck;
           if (find(find(keyCode) == KP))
               KK = 10;
           end
        end
        Phase_exp=Phase_exp+1;
    end;

end;
%%

Screen(expWin,'Flip');
ShowCursor;
FlushEvents('keyDown');
Screen('CloseAll');

end