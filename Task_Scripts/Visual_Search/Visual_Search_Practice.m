function Visual_Search_Practice

warning off;
disp('START PROGRAM');

KbCheck;
GetSecs;

%% Provide subject details and set rand state according to the subject
%% number

practice_or_test = 1;
stand_alone = 0;

subject.date_time = fix(clock);

if stand_alone ==1
%    clear all;
    subject.Number = input('Subject Number? ');
    SessionNumber = input('Session?');
else
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject.Number = ActiveData(1,1);
    SessionNumber = ActiveData(1,2);
    cd('Visual_Search')
end;

feedback_interval = 2;

results.subject = subject.Number;

if practice_or_test == 1
   
    n_trials = 15;
    n_blocks = 1;
    
elseif practice_or_test == 2

    n_trials = 30;
    n_blocks = 8;
    
end

filename = strcat('Visual_Search_',num2str(subject.Number), '_',num2str(practice_or_test),'_','Session_', num2str(SessionNumber),'.txt'); 

if subject.Number<99 && fopen(filename, 'rt')~=-1
    fclose('all');
    error('Result data file already exists! Choose a different subject number.');
else
    datafilepointer = fopen(filename,'wt'); 
end;

results=zeros(1, 19);

w=1;

% define colours

background_colour = [255 255 255];
text_colour = [0 0 0];

%% set up sound
InitializePsychSound(1);

wavfile = 'FinSound_7_200ms.wav'%'FinSound_4_200ms.wav';
[y freq] = audioread(wavfile);
wavdata = y';
channel = size(wavdata, 1);
pa_handle = PsychPortAudio('Open', [], [], 0, freq, 1);
PsychPortAudio('FillBuffer', pa_handle, wavdata);


%% call screen function and open screens

AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
my_screens = Screen('Screens');
screen_number = max(my_screens);
[w_screen, w_rect] = Screen('OpenWindow',screen_number);
%[w_screen,w_rect] = Screen('OpenWindow',screen_number, [], [0 0 1440 900]);
[mx, my] = RectCenter(w_rect);
Screen(w_screen,'Flip');
Screen(w_screen,'FillRect',background_colour,w_rect);
Screen(w_screen,'Flip');
Screen(w_screen,'FillRect',background_colour,[]);

my1=my-200;
my2=my-100;
my3=my+100;

% create rects for the display area and the size of stimulus presentation
search_rect_size = [0 0 600 600];

search_rect_presentation = CenterRect(search_rect_size, w_rect);

smaller_rect_size = search_rect_size/ 20;

smaller_rect_presentation = CenterRect(smaller_rect_size, w_rect);

fix_size = [0 0 80 80];

present_fix = CenterRect(fix_size, w_rect);


% need to get equally spaced points for x and y co-ordinates for stimulus
% destination rects to be centered upom

getting_screen_coordinates = search_rect_presentation;

min_space_between_stim = smaller_rect_size(3) + 10;
poss_x_coords = getting_screen_coordinates(1):min_space_between_stim:getting_screen_coordinates(3);
poss_y_coords = getting_screen_coordinates(2):min_space_between_stim:getting_screen_coordinates(4);

% draw stimuli
    % make a T and L (Luck's code) creates an array for each t and l image
    % (just making an L now to experiment
    letsz=100;

    letcol=[0 0 0]; % black
    arrayL=zeros([letsz letsz 4]);
    arrayL(:,:) = 255;
    arrayT=zeros([letsz letsz 4]);
    arrayT(:, :) = 255;
    arrayL(1:100,1:20,1)=letcol(1);
    arrayL(81:100,1:100,1)=letcol(1);
    arrayL(1:100,1:20,2)=letcol(2);
    arrayL(81:100,1:100,2)=letcol(2);
    arrayL(1:100,1:20,3)=letcol(3);
    arrayL(81:100,1:100,3)=letcol(3);
    arrayL(1:100,1:20,4)= 0;
    arrayL(81:100,1:100,4)= 0;
    
    textureL = Screen('MakeTexture', w_screen, arrayL);
    
    arrayT(1:20,1:100,1)=letcol(1);
    arrayT(1:100,40:60,1)=letcol(1);
    arrayT(1:20,1:100,2)=letcol(2);
    arrayT(1:100,40:60,2)=letcol(2);
    arrayT(1:20,1:100,3)=letcol(3);
    arrayT(1:100,40:60,3)=letcol(3);
    arrayT(1:20,1:100,4)=0;
    arrayT(1:100,40:60,4)=0;
    
    textureT = Screen('MakeTexture', w_screen, arrayT);

% font
Screen('TextFont', w_screen, 'Courier New');
Screen('TextStyle', w_screen, 1);
Screen('TextSize', w_screen, 20);    
    
% fixation screens (1 - small; 2 - large)

% % 1
small_fix_screen = Screen(w_screen, 'OpenoffscreenWindow', background_colour, fix_size);
Screen('TextFont', small_fix_screen, 'Courier New');
Screen('TextStyle', small_fix_screen, 1);
Screen('TextSize', small_fix_screen, 50);
DrawFormattedText(small_fix_screen, '.', 'Center', 'Center', text_colour);
% 
% % 2
large_fix_screen = Screen(w_screen, 'OpenoffscreenWindow', background_colour, fix_size);
Screen('TextFont', large_fix_screen, 'Courier New');
Screen('TextStyle', large_fix_screen, 1);
Screen('TextSize', large_fix_screen, 70);
DrawFormattedText(large_fix_screen, '.', 'Center', 'Center', text_colour);

% blank screen
blank_screen = Screen(w_screen, 'OpenoffscreenWindow', background_colour, fix_size);
Screen('TextFont', blank_screen, 'Courier New');
Screen('TextStyle', blank_screen, 1);
Screen('TextSize', blank_screen, 70);
DrawFormattedText(blank_screen, ' ', 'Center', 'Center', background_colour);

% now sort out response keys 
    
    key1 = KbName('m'); 
    key2 = KbName('z'); 
    TSP = KbName('space');

set_size_options = [8 12 16];

% make vectors for feedback
trial_numbers_for_feedback = [];
target_orientation_for_feedback = [];
participant_response_feedback = [];
RTs_for_feedback = [];
set_sizes_for_feedback = [];

% make empty vector to allocate set sizes at the start of the block
set_sizes = [];

for allocate_set_sizes = 1:(n_trials/(length(set_size_options)))
    
    set_sizes = [set_sizes set_size_options];
    
end

%% start experiment

HideCursor;

instructions1 = ('Search for the letter T!');
instructions2 = ('Press the Z key if the T pointed to the left.');
instructions3 = ('Press the M key if the T pointed to the right.');
instructions4 = ('Respond as quickly and accurately as you can! Press any key to begin');
DrawFormattedText(w_screen, instructions1, 'Center', my1, text_colour, 115);
DrawFormattedText(w_screen, instructions2, 'Center', my2, text_colour, 115);
DrawFormattedText(w_screen, instructions3, 'Center', 'Center', text_colour, 115);
DrawFormattedText(w_screen, instructions4, 'Center', my3, text_colour, 115);
Screen(w_screen,'Flip');
while (KbCheck); end; while (~KbCheck); end;

for count_runs = 1:n_blocks;
    
% set durations for this block

duration.alert_fix = .2;
duration.search_display = 2;
duration.T1_onset_options = [0.4 0.8];

% fixation period of ~10.8 s for each run to allow for T1 equilibrium
% initial fixation (including dummy volumes)
time.first_fix_onset = GetSecs;
Screen('CopyWindow', small_fix_screen, w_screen,[], present_fix, []);
Screen(w_screen, 'Flip');


% combines sub and run number to have a new number to randomise from

start_rand_num = num2str(subject.Number);
mid_rand_num = num2str(SessionNumber);
end_rand_num = num2str(count_runs);
total_rand_num = [start_rand_num mid_rand_num end_rand_num];
total_rand_num = str2num(total_rand_num);

rand('state',total_rand_num);
randstate = rand('state');

% allocate set size order for this block of trials
%
set_sizes = Shuffle(set_sizes);




%% now start trial loop for this block

for count_trials = 1: n_trials

    
% set key press detector variable to 0
key_found = 0;
response = 0;
response_time = 0;
Acc_Response_Time = 0;

% select an onset time
duration.T1_onset_options = Shuffle(duration.T1_onset_options);

% get coordinates for this trial
poss_x_coords = Shuffle(poss_x_coords);
poss_y_coords = Shuffle(poss_y_coords);

% make a matrix to indicate where distractors will go
distractors_this_trial = ((set_sizes(count_trials)) - 1);

destination_Rects = zeros(4, distractors_this_trial);

for count_distractors=1:distractors_this_trial 
        
    destination_Rects(:, count_distractors) = CenterRectOnPoint(smaller_rect_presentation,  poss_x_coords(count_distractors), poss_y_coords(count_distractors))';
end

% do the same for the target
target_destination_rect = zeros(4, 1);

target_destination_rect(: , 1) = CenterRectOnPoint(smaller_rect_presentation,  poss_x_coords(set_sizes(count_trials)), poss_y_coords(set_sizes(count_trials)))';


% define degree of rotation for all stimuli
scalar_for_vector_tiling = set_sizes(count_trials)/2;
all_orientations = repmat([90 270], 1, scalar_for_vector_tiling);
all_orientations = Shuffle(all_orientations);

% assign target and distractor orientations
target_orientation = all_orientations(1);

distractor_orientations = all_orientations(2:set_sizes(count_trials));


% present alert fixation for .2 sec
    time.alert_fix_onset = GetSecs;
    
    % present alerting fixation for 2s
    Screen('CopyWindow', small_fix_screen, w_screen, [], present_fix, []);
    Screen(w_screen, 'Flip');
    while ((GetSecs - time.alert_fix_onset) <= duration.T1_onset_options(1)); end
    
    time.alert_fix_offset = GetSecs;
    time.trial_onset = GetSecs;
    

% draw the textures to the screen
Screen('CopyWindow', small_fix_screen, w_screen, [], present_fix, []);
Screen('DrawTextures', w_screen, textureL, [],  destination_Rects, distractor_orientations);
Screen('DrawTexture', w_screen, textureT, [], target_destination_rect, target_orientation);

time.search_array_onset = GetSecs;

Screen(w_screen,'Flip'); 

% wait for response or until 3 sec has passed (if a response then record it
 %while key_found == 0 && ((GetSecs - time.search_array_onset) <= duration.search_display)
while key_found == 0    
    [keyIsDown,secs,keyCode] = KbCheck;
    
    if any(keyCode([key1, key2]))
        time.response_time_stamp = GetSecs;
        response_time = time.response_time_stamp - time.search_array_onset;
        
        if keyCode(key1)
            response = 1;
        elseif keyCode(key2)
            response = 2;
        end
        
        key_found = 1;
    end
    
end

time.search_array_offset = GetSecs;

time.total_display_time = time.search_array_offset - time.search_array_onset;

WaitSecs(0.1);


if target_orientation == 90 && response == 1;
    Ac=1; Acc_Response_Time=response_time;
elseif target_orientation == 270 && response == 2;
    Ac=1; Acc_Response_Time=response_time;
else 
    Ac=0; Acc_Response_Time=NaN;
    if practice_or_test == 1
    PsychPortAudio('Start', pa_handle, 1, 0, 0);
    WaitSecs(0.2);
    end;
end

results(w,:) = [subject.Number, SessionNumber, practice_or_test, n_trials, n_blocks, count_runs, count_trials, duration.T1_onset_options(1), set_sizes(count_trials), target_orientation, time.alert_fix_onset, time.search_array_onset, time.response_time_stamp, response_time, time.search_array_offset, time.total_display_time, response, Ac, Acc_Response_Time];
               dlmwrite(filename,results,'delimiter','\t','precision',8);
w=w+1;

end  
      
   
end

if practice_or_test == 1
    endtext = 'End of practice!';
else
    endtext = 'End of task!';
end;

DrawFormattedText(w_screen, endtext, 'center', 'center');
Screen('Flip', w_screen);
tic; while toc < 3; end;

Screen('CloseAll'); 

end
