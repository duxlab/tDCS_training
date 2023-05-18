%SCRIPT WRITTEN BY HANNAH FILMER, AUGUST 2019
%Digit span, forwards then backwards. Each runs for 14 trials (plus one
%practice trial).
%Programmed for use in a battery of tasks

function Digit_Span

stand_alone = 0;

warning off; 
disp('START PROGRAM');

if stand_alone == 1
    clearvars; 
    subject_number = input('Subject Number?');
    session_number = input('Session Number?');
else
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject_number = ActiveData(1,1);
    session_number = ActiveData(1,2);
    cd('Digit_Span');
end;

rand('state',sum(100*clock));
randstate = rand('state');

RunSpeed = 1;

KbName('UnifyKeyNames');
KbCheck;
GetSecs;

NumOfBlocks = 2; % Forward and backward

accuracy = 0;
clear data

data.session_number = session_number;
data.subject_number = subject_number;

filename = strcat('Digit_span_',num2str(subject_number), '_session_',num2str(session_number),'_.txt'); 

if subject_number<99 && fopen(filename, 'rt')~=-1
    fclose('all');
    error('Result data file already exists! Choose a different subject number.');
else
    datafilepointer = fopen(filename,'wt'); 
end;

        if subject_number < 10 % for subject numbers < 10 only
            subject_number_string = ['00' num2str(subject_number)];
        elseif subject_number < 100 % for subject numbers < 10 only
            subject_number_string = ['0' num2str(subject_number)];
        else
            subject_number_string = num2str(subject_number);
        end
        
% logfile in .mat format

        subj_data_file_temp = sprintf('data_logfile_DigitSpan_sub_%s_session_%s', subject_number_string, num2str(session_number));

            if ~exist('Data','dir')
                mkdir('Data');
            end
 
        % check if data file already exists
        
        subj_data_filename = ['Data/', subj_data_file_temp];
     
            if exist([subj_data_filename '.mat'],'file')
                error('Data for file for this subject number already exists - please chose a different subject number.');
            else
                % do initial save to create logfile
                save(subj_data_filename,'data');
            end
            
RunSpeed = 1;
StimPresDuration = 1*RunSpeed;
FixDuration = 3*RunSpeed;
 
Text_color = [255 255 255];
background_color = [104 104 104];


%%
AssertOpenGL;
          
    Screen('Preference', 'SkipSyncTests', 1);
 
    screens=Screen('Screens');
    screenNumber=max(screens);
  
  [expWin,rect]=Screen('OpenWindow',screenNumber,background_color, [0 0 1920 1080]);
    [mx, my] = RectCenter(rect);
    Screen(expWin,'Flip');
  Screen('TextSize', expWin, 40);
   
  HideCursor;
  
  TSP = KbName('space');
  TP = KbName('p');
  
    %Response text
    resp_text = 'Answer: ';

    %Block type
    block_text_forward = 'For this block, report the numbers in the order they were presented.';
    block_text_backward = 'For this block, report the numbers in the reverse order they were presented (backwards).';
    block_text = 'Press space to begin!';

    %Instructions
    Instruct1 = 'Welcome to the experiment!';
    Instruct2 = 'You will be shown a series of numbers one at a time.';
    Instruct3 = 'At the end of the series, you need to report the numbers shown in the correct order.';
    Instruct4 = 'In the first set of trials you need to report the numbers in the order they were presented (forwards).';
    Instruct5 = 'In the second set trials you need to report the reverse of the order they were presented (backwards).';
    Instruct6 = 'The task begins with two numbers, and may get progressively longer.';
    Instruct7 = 'Use the keys on the number pad to report the numbers.';

    %Feedback screens
    correct_text = 'correct';
    error_text = 'error';
    error_text_first = 'Error! Wait for experimenter.';
    
    %end of exp screen
    EndOfExp='End of task!';
      
   
  %%
[resptime, keyCode] = KbWait;
cc=KbName(keyCode); 

Y= 1; TUT_trial=1;

Screen('TextSize', expWin, 40);
DrawFormattedText(expWin, Instruct1, 'center', ((1080/2)-200));
DrawFormattedText(expWin, Instruct2, 'center', ((1080/2)-150));
DrawFormattedText(expWin, Instruct3, 'center', ((1080/2)-100));
DrawFormattedText(expWin, Instruct4, 'center', 'center');
DrawFormattedText(expWin, Instruct5, 'center', ((1080/2)+100));
DrawFormattedText(expWin, Instruct6, 'center', ((1080/2)+150));
Screen('Flip', expWin); key_press = 0;

while key_press==0
        [keyIsDown,secs,keyCode] = KbCheck;
        if (keyIsDown) && key_press == 0
               if (find(find(keyCode) == TP))
                   key_press = 1;
               end;
        end;
end;

%%

for X = 1:NumOfBlocks
  
    Screen('TextSize', expWin, 40);
    
 if X == 1 %if this is a forward block
     DrawFormattedText(expWin, block_text_forward, 'center', 'center');
 else %if this is a backward block
     DrawFormattedText(expWin, block_text_backward, 'center', 'center');
 end;
 
 DrawFormattedText(expWin, block_text, 'center', ((1080/2)+100));
 Screen('Flip', expWin); key_press = 0;
 
      while key_press==0
            [keyIsDown,secs,keyCode] = KbCheck;
            if (keyIsDown) && key_press == 0
                   if (find(find(keyCode) == TSP))
                       key_press = 1;
                   end;
            end;
      end;
      
      Length_of_trial = 2;
      tracker = 0;
      num_of_trials = 15;
      
 for trial = 1:num_of_trials
    Screen('TextSize', expWin, 60); 
    start_trial_text = strcat('This trial will have -    ',num2str(Length_of_trial),' numbers.');
    DrawFormattedText(expWin, start_trial_text, 'center', 'center');
    Screen('Flip', expWin); tic; while toc<1; end;
    
    check_array = 0; RepeatDetected = 0; IncrementDetected = 0;
    
    data.Length_of_trial(Y) = Length_of_trial;
    
    while check_array == 0 %check for issues with the shuffled numbers, redo if needed.
        
        Numbers = [1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9];
        Shuffle_numbers = Shuffle(Numbers);
        trial_numbers_used = Shuffle_numbers(1:Length_of_trial);
        
        for l = 1:(Length_of_trial)
            if Shuffle_numbers(l) == Shuffle_numbers(l+1)
                RepeatDetected(l) = 1;
            else
                RepeatDetected(l) = 0;
            end;
            if Shuffle_numbers(l) == ((Shuffle_numbers(l+1))+1)
                IncrementDetected(l) = 1;
            elseif Shuffle_numbers(l) == ((Shuffle_numbers(l+1))-1)
                IncrementDetected(l) = 1;
            else
                IncrementDetected(l) = 0;
            end;
        end;
        
        RepeatDetected = mean(RepeatDetected);
        IncrementDetected = mean(IncrementDetected);
        
        if RepeatDetected > 0 || IncrementDetected > 0
            Shuffle_numbers = Shuffle(Numbers);
            trial_numbers_used = Shuffle_numbers(1:Length_of_trial);
        elseif RepeatDetected == 0 && IncrementDetected == 0
            check_array = 1;
        end;
        
    end;
   
    data.trial_numbers_used{Y,:} = trial_numbers_used(:);
    
    Screen('FillRect',expWin, [0 0 0], [(mx-5) (my-5) (mx+5) (my+5)]);
    Screen('Flip', expWin); TimeNow=GetSecs;
    while GetSecs-TimeNow<FixDuration; end;
    
   for m = 1:Length_of_trial
       number_to_use = num2str(trial_numbers_used(m));
       Screen('TextSize', expWin, 80);
       DrawFormattedText(expWin, number_to_use, 'center', 'center');
       Screen('Flip', expWin); PresentTimeNow=GetSecs;
       while GetSecs-PresentTimeNow<StimPresDuration; end;       
   end;
         
         key_counter = 1;
         key_press = 0;
         
         clc
         
         numbers_response = GetEchoNumber(expWin,'= ',(mx-30), (my-30),[0 0 0],background_color);
         numbers_response2 = str2double(regexp(num2str(numbers_response),'\d','match'));
         Screen('Flip', expWin);
   
         accuracy = NaN;
         TargetRT = NaN;
         num_accuracy = 0;
         
         data.numbers_response{Y,:} = numbers_response2(:);
         
    if X == 1
        numbers_response2score = numbers_response2;
    elseif X == 2
        numbers_response2score = fliplr(numbers_response2);
    end;
    
    how_many_numbers_typed = size(numbers_response2score);
    how_many_numbers_typed = how_many_numbers_typed(2);
    
    if how_many_numbers_typed == Length_of_trial
    for n = 1:Length_of_trial
            if numbers_response2score(n) == Shuffle_numbers(n)
                num_accuracy(n) = 1;
            else
                num_accuracy(n) = 0;
            end;
    end;
    else
        num_accuracy = 0;
    end;
     
    acc = mean(num_accuracy);
    
    trial_length = Length_of_trial;
    
    if acc <1 %one or more errors
        accuracy(Y) = 0; tracker = tracker +1;
        if Length_of_trial == 2 
           DrawFormattedText(expWin, error_text_first, 'center', 'center');  
           Screen('Flip', expWin);
            key_press = 0;
            while key_press==0
                [keyIsDown,secs,keyCode] = KbCheck;
                if (keyIsDown) && key_press == 0
                       if (find(find(keyCode) == TP))
                           key_press = 1;
                       end;
                end;
            end;
            num_of_trials=num_of_trials+1;
        else
           DrawFormattedText(expWin, error_text, 'center', 'center');
           Screen('Flip', expWin);
           tic; while toc < 1; end;
        end;
        if tracker == 2 && Length_of_trial > 3
            Length_of_trial=Length_of_trial-1;
            tracker = 0;
        end;
    else
        accuracy(Y) = 1;
        tracker = 0;
        DrawFormattedText(expWin, correct_text, 'center', 'center');
        Screen('Flip', expWin);
        tic; while toc < 1; end;
        Length_of_trial=Length_of_trial+1;
    end;
    
     FlushEvents('keyDown');

               results(Y,1:4) = [X, trial, trial_length, acc];
               dlmwrite(filename,results,'delimiter','\t','precision',8);               
               Y = Y + 1;
end;

end;

endoftask = 'End of task!';
DrawFormattedText(expWin, endoftask, 'center', 'center');
Screen('Flip', expWin);
tic; while toc < 1; end;

key_press = 0;
            while key_press==0
                [keyIsDown,secs,keyCode] = KbCheck;
                if (keyIsDown) && key_press == 0
                       if (find(find(keyCode) == TSP))
                           key_press = 1;
                       end;
                end;
            end;

save(subj_data_filename,'data','-append');

%%
ShowCursor;
FlushEvents('keyDown');
Screen('CloseAll');

end