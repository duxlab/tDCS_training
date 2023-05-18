function OSpan_prac

% FUNCTION DETAILS --------------------------------------------------------
%
% Practice version of the OSpan task. 
% 
% Includes the letter and math tasks alone, followed by both tasks
% combined, with corrective feedback (auditory tone). If participants have 
% difficulty with one task in particular they can repeat the practice of 
% that task only. 
% 
% This script calculates a mean and SD for time taken for correct math 
% responses. If you wish to use the practice of the combined task only you 
% will need to enter these values when prompted. 
%
% If participants take longer to respond than their mean + 2.5SDs, the task
% skips to the TRUE/FALSE response window. 
% 
% Written by Kristina Horne (2018, UQ)
%
% RUN CODE ----------------------------------------------------------------

stand_alone = 0;

if stand_alone ==1 
   % clc
   % clear all;
else
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject_number = ActiveData(1,1);
    session_number = ActiveData(1,2);
    cd('OSpan')
end;

warning('off','all');

% create random state
rand('twister',sum(100*clock));

% initialize important MEX-files.
KbCheck;
GetSecs;

% switch KbName into unified mode; this will use the names of the OS-X platform on all platforms in order to make this script portable
KbName('UnifyKeyNames');

% SETTINGS/CHEATS ---------------------------------------------------------

% define computer being used
computer_used = 2; % 1= Dux lab iMac, 2= Dux lab testing mini, 3= Claire's personal laptop, 4= Dux lab PC laptop

% define cheats for display speeds
duration_speed = 1; % set to 1 for normal speed, < 1 = fast, > 1 = slow

% VARIABLES ---------------------------------------------------------------

% display details
screen_resolution = [1920 1080];
refresh_rate = 60;
screen_specs_description = {'The current screen settings are incorrect for testing.';...
    '';...
    'Screen Resolution: %d x %d';...
    'Refresh Rate: %d Hz';...
    '';...
    '(c)ontinue with current settings or (t)erminate?'};

% duration details
duration_fixation = .2:.01:.6; % jittered fixation time
letter_duration = .8*duration_speed; % letter presentation duration

% trial & block details
block_types = [1 2 3]; % block type 1 = letter task alone, block type 2 = math task alone, block type 3 = both tasks combined 
n_blocks = [4 1 3]; % number of blocks corresponding to each block type 
possible_n_trials = [2 15 2];  % number of trials (sets of stimuli) per block, corresponding to each block type 

% colour details
colour_background = [255 255 255];
colour_text = [0 0 0];

% % response array details
size_stimuli_pix = [1200 1000]; % size of response array
image_format = 'png';

% text details
font = 'Arial';
font_size = 40;
line_spacing = 45;
task_instructions = {'In this task you will need to memorise letters';...
    'shown on the screen, while you solve simple math problems.';...
    '';...
    'You will now practice each component of the task alone, then together.'
    '';...
    'Press the space key to continue.'};

letter_instructions_1 = {'You will now practice the letter component of the task.';...
    '';...
    '2 - 3 letters will appear on the screen, one at a time.';...
    '';...
    'You will then see a screen with 12 possible letters and must';...
    'click on the letters you saw, in the order they were presented.'};
letter_instructions_2 = {'If you are unsure of a letter, just guess.';...
    '';...
    'If you make a mistake you will hear a beeping sound.';...
    '';...
    'Press the CLEAR button if you wish to start again.';...
    '';...
    'Press the space key to start the practice.'};
                     
math_instructions_1 = {'You will now practice the math component of the task.';...
    '';...
    'A math problem will appear on the screen, such as:';...
    '';...
    '(2 x 3) + 2 = ?';...
    '';...
    'You need to solve this problem in your head,';...
    'and click the mouse button when you are done.';...
    '';...
    'You will then see a number displayed on the screen';... 
    'and the words TRUE and FALSE.'};
    
math_instructions_1_2 = {'If the number is the correct answer to the math problem...';...
                        'Click on the word TRUE.';...
                        '';...
                        'If the number is not the correct answer to the math problem...';...
                        'Click on the word FALSE.';...
                        '';...
                        'If you make a mistake you will hear a beeping sound.';...
                        '';...
                        'Press the space key to start the practice.'};
ospan_instructions_1 = {'You will now practice both tasks together.';...
    '';...
    'You will do the math task first, then be shown a letter.';...
    '';...
    'This will happen twice, before the screen with 12 letters will appear.';...
    '';...
    'It is very important that you do both tasks as accurately as possible.'};

ospan_instructions_2 = {'It is also very important that you solve the math problems within your normal time frame.';...
    '';...
    'We recorded the average time it took you to solve them in the first practice.';...
    '';...
    'If you take much longer than this, the task will skip to the  TRUE/FALSE response screen.';...
    '';...
    'Press the space key to start the practice'};

% onscreen instructions for math task 
math_instructions = {'When you have solved the';...
    'math problem, click the';...
    'mouse to continue.'};

% end of block feedback
feedback_message = {'You recalled %d letters correctly out of %d.';...
    '';...
    'You made %d math error(s) on this set of trials.';...
    '';...
    'Press space to continue.'};

feedback_message_1 = {'You recalled %d letters correctly out of %d.';...
    '';...
    'Press space to continue.'};

feedback_message_2 = {'You made %d math error(s) on this set of trials.';...
    '';...
    'Press space to continue.'};

% goodbye message 
goodbye_message = 'Finished! Please notify the experimenter.';

% letters for response array 
possible_letters = {'F', 'H', 'J', 'K', 'L', 'N', 'P', 'Q', 'R', 'S', 'T', 'Y'};

% math equation details
math_trial_types = [1 2]; % trial type 1 = present correct answer, 2 = present incorrect answer
repeated_math_trial_types = repmat(math_trial_types,15);
math_trial_type = repeated_math_trial_types(1,:); % includes trial type repeated 38 times (76 trials in total)
equation_no = 1:20;
equations = {'(8 / 2) + 5','(9 - 8) x 7','(7 - 2) x 3','(7 - 5) x 9','(3 + 5) / 2',...
             '(6 + 7) - 2','(2 x 6) / 3','(7 x 3) + 8','(1 + 7) x 3','(6 - 3) + 8',...
             '(2 / 2) + 9','(8 x 5) / 4','(7 + 9) - 2','(4 - 1) x 3','(9 / 3) - 2',...
             '(4 + 7) x 4','(4 + 6) x 2','(1 x 2) x 3','(4 x 3) / 2','(7 x 3) - 5'};

% correct answers - correspond to each equation
correct_answers = {'9','7','15','18','4',...
                   '11','4','29','24','11',...
                   '10','10','14','9','1',...
                   '44','20','6','6','16'};
               
incorrect_answers = {'15','4','17','21','10',...
                      '5','8','10','17','2',...
                      '7','13','20','10','14',...
                      '37','15','5','3','21'};
         

% coordinates of cells in response array
column_coords = [175 530 895 175 530 895 175 530 895 175 530 895];

row_1_height = 195;
row_2_height = 375;
row_3_height = 560;
row_4_height = 743;


% SETUP EXPERIMENT --------------------------------------------------------

Screen('Preference','SkipSyncTests', 1);

% implement computer used settings
if computer_used == 1 % lab iMac
    font_size = 40;
    %screen_resolution = [1024 768];
    disp('Computer set for Dux lab iMac');
elseif computer_used == 2 % Dux lab testing computer
    font_size = 40;
    disp('Computer set for Dux lab mac mini computer');
elseif computer_used == 3 % Claire's personal laptop
    font_size = 30;
    screen_resolution = [1280 800]; % over-write screen resolution as my personal laptop cannot display 1024 x 768 resolution
    refresh_rate = 0; % over-write screen resolution as my personal laptop cannot display at 100Hz
    disp('Computer set for personal laptop');
elseif computer_used == 4 % Dux lab PC laptop
    font_size = 30;
    disp('Computer set for Dux lab PC laptop');
end

% enter subject details
if stand_alone == 1
    subj_number = input('Subject Number (Enter "0" for no logfile): ');
    session_number = input('Session Number: ');
    tasks_to_practice = input('Tasks to practice (1 for all, 2 for letter task only, 3 for math task only, 4 for combined task only): ');
else
    subj_number = subject_number;
    tasks_to_practice = 1;
end;

if tasks_to_practice == 4
    data.mean_correct_RTs = input('Mean RT: ');
    data.std_dev_correct_RTs = input('St Dev RT: ');
end
    
date_time = fix(clock);

% open a screen
HideCursor;
AssertOpenGL;
my_screens = Screen('Screens');
screen_number = max(my_screens);
current_resolution = Screen('Resolution',screen_number);
[w_screen,w_rect] = Screen('OpenWindow',screen_number); % make display (w_screen) take up entire screen
Screen(w_screen,'Flip'); % do an initial flip so that you draw on background and not on programming screen
Screen(w_screen,'FillRect',colour_background,w_rect);
Screen(w_screen,'Flip');
Screen(w_screen,'FillRect',colour_background,[]);

% determine size and position of stimuli
[~,center_y] = RectCenter(w_rect); %  coordinates start from top left corner [0,0]

% ...for instructions screen
size_instructions = [0 0 current_resolution.width current_resolution.height]; % make run_instructions take up entire screen
present_instructions = CenterRect(size_instructions,w_rect); % present instructions in center of the screen

% ...for response array screen
size_stimuli = [0 0 size_stimuli_pix];
present_stimuli = CenterRect(size_stimuli,w_rect); % present stimuli in center of the screen
resp_stimuli_file = sprintf('response_options');
resp_stimulus_handle = imread([sprintf(resp_stimuli_file) '.' image_format],image_format);
disp_resp = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
Screen(disp_resp,'FillRect',colour_background,size_stimuli);
Screen(disp_resp,'PutImage',resp_stimulus_handle,size_stimuli);

%... for goodbye screen
disp_goodbye = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_goodbye,font);
Screen('TextStyle',disp_goodbye,1);
Screen('TextSize',disp_goodbye,font_size);
DrawFormattedText(disp_goodbye,goodbye_message,'Center','Center',colour_text,115);

% open audio file

[y,Fs] = audioread('phaser.wav');
player = audioplayer(y, Fs);

% check screen specifications
WaitSecs(.5);
% if current_resolution.width ~= screen_resolution(1) || current_resolution.height ~= screen_resolution(2) || current_resolution.hz ~= refresh_rate
%     
%     % if the screen specs aren't correct, display current screen settings on display
%     
%     % update screen specs description with current settings
%     screen_specs_description{3} = sprintf(screen_specs_description{3},current_resolution.width,current_resolution.height);
%     screen_specs_description{4} = sprintf(screen_specs_description{4},current_resolution.hz);
%     
%     % create screen
%     disp_screen_specs = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
%     Screen('TextFont',disp_screen_specs,font);
%     Screen('TextStyle',disp_screen_specs,1);
%     Screen('TextSize',disp_screen_specs,font_size);
%     n_lines_above_center = ceil(length(screen_specs_description)/2);
%     n_lines_below_center = length(screen_specs_description)-n_lines_above_center;
%     line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
%     for line_count = 1:size(screen_specs_description,1)
%         DrawFormattedText(disp_screen_specs,screen_specs_description{line_count},'Center',line_positions_y(line_count),colour_text,115);
%     end
%     
%     % display screen
%     Screen('CopyWindow',disp_screen_specs,w_screen,[],present_instructions,[]);
%     Screen(w_screen,'Flip');
%     
%     % poll keyboard to determine whether to continue or terminate script
%     key_found = 0;
%     while ~key_found
%         [key_is_down,~,key_code] = KbCheck;
%         if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
%             keys_pressed = find(key_code);
%             response_key = KbName(keys_pressed(1));
%             if strcmp(response_key,'c')
%                 FlushEvents('keyDown');
%                 key_found = 1;
%                 continue
%             elseif strcmp(response_key,'t')
%                 ShowCursor;
%                 FlushEvents('keyDown');
%                 Screen('CloseAll');
%                 return
%             end
%         end
%     end
% end

% PRACTICE/TEST LOOP ------------------------------------------------------

% add input data to data structure
data.subject_no = subj_number;
data.date_time = date_time;
data.session_number = session_number;
data.screen_specifications = current_resolution;

% determine offsets for response square coordinates (difference between
% response array resolution and screen resolution
x_offset = (current_resolution.width - size_stimuli_pix(1))/2;
y_offset = (current_resolution.height - size_stimuli_pix(2))/2;

% create string ID for subject number
if subj_number < 10 % for subject numbers < 10 only
    subject_number_string = ['0' num2str(subj_number)];
else
    subject_number_string = num2str(subj_number);
end

% create string ID for session number
if session_number < 10 % for session numbers < 10 only
    session_number_string = ['0' num2str(session_number)];
else
    session_number_string = num2str(session_number);
end

% define data logfile for saving later
if subj_number
    subj_data_filename = ['Shane_Yohan_data_logfile_for_prac_OSpan_task_sub_' subject_number_string '_session_' session_number_string];
    
    % check if data file already exists
    if subj_number && tasks_to_practice == 1
        if exist([subj_data_filename '.mat'],'file')
            error('Data for file for this subject number already exists - please chose a different subject number.');
        end
    end
end

% determine all stimuli/trial type orders

% determine block type order & number of trials per block type
for block_type_count = 1:length(block_types)
    n_blocks_per_block_type(block_type_count) = n_blocks(block_type_count);  % calculate number of blocks per block type
    temp_block_type_order = repmat(block_types,n_blocks_per_block_type); % determine temporary block type order
    data.block_type_order = temp_block_type_order(1,:); % randomise and save block type order
end

% determine trial type (number of trials) order and letter presentation
% order
for block_type_count = 1:length(block_types)
    for block_count = 1:n_blocks_per_block_type(block_type_count)
        n_trials_per_block(block_count,block_type_count) = possible_n_trials(block_type_count);
        if block_type_count == 1 && (block_count == 3 || block_count == 4)
            data.n_trials_per_block(block_count,block_type_count) = 3;
        else
            data.n_trials_per_block(block_count,block_type_count) = n_trials_per_block(block_count,block_type_count); % save number of trials per block to data structure
        end
        temp_letter_order = Shuffle(1:length(possible_letters)); % create temporary letter order for each block
        if block_type_count == 1 || block_type_count == 3
            data.letter_order(1:data.n_trials_per_block(block_count,block_type_count),block_count,block_type_count) = temp_letter_order(1,1:data.n_trials_per_block(block_count,block_type_count)); % save letter order for each block in data structure
            data.letters(1:data.n_trials_per_block(block_count,block_type_count),block_count,block_type_count) = possible_letters(data.letter_order(1:data.n_trials_per_block(block_count,block_type_count),block_count,block_type_count)); % save letters in presentation order
        else continue
        end
    end
end

% determine equation and answer (true/false) order
for block_type_count = 1:length(block_types)
    %             if block_type_count == 2 || block_type_count == 3
    current_equation_order = Shuffle(equation_no); % randomise all possible equations
    math_trial_type_order = Shuffle(math_trial_type); % randomise math trial type order
    for block_count = 1:n_blocks_per_block_type(block_type_count) % for each block
        for trial_count = 1:data.n_trials_per_block(block_count,block_type_count) % for each trialdata.math_equation(trial_count,block_count,block_type_count) = equations(current_equation_order(trial_count,block_count)); % save
            data.math_trial_type(trial_count,block_count,block_type_count) = math_trial_type_order(trial_count); % save math trial types presentation order to data structure
            data.correct_answer(trial_count,block_count,block_type_count) = correct_answers(current_equation_order(trial_count)); % save correct answers (in order) to data structure
            data.incorrect_answer(trial_count,block_count,block_type_count) = incorrect_answers(current_equation_order(trial_count));
            data.math_equation(trial_count,block_count,block_type_count) = equations(current_equation_order(trial_count));
        end
        current_equation_order = current_equation_order(data.n_trials_per_block(block_count,block_type_count):end);
        math_trial_type_order =  math_trial_type_order(data.n_trials_per_block(block_count,block_type_count):end);
    end
    %             end
end


% create remaining stimulus screens

% ...for  task instruction screen
disp_task_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_task_instructions,font);
Screen('TextStyle',disp_task_instructions,1);
Screen('TextSize',disp_task_instructions,font_size);
n_lines_above_center = ceil(length(task_instructions)/2);
n_lines_below_center = length(task_instructions) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(task_instructions,1)
    DrawFormattedText(disp_task_instructions,task_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for  letter practice instruction screen 1
disp_letter_instructions_1 = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_letter_instructions_1,font);
Screen('TextStyle',disp_letter_instructions_1,1);
Screen('TextSize',disp_letter_instructions_1,font_size);
n_lines_above_center = ceil(length(letter_instructions_1)/2);
n_lines_below_center = length(letter_instructions_1) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(letter_instructions_1,1)
    DrawFormattedText(disp_letter_instructions_1,letter_instructions_1{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for  letter practice instruction screen 2
disp_letter_instructions_2 = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_letter_instructions_2,font);
Screen('TextStyle',disp_letter_instructions_2,1);
Screen('TextSize',disp_letter_instructions_2,font_size);
n_lines_above_center = ceil(length(letter_instructions_2)/2);
n_lines_below_center = length(letter_instructions_2) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(letter_instructions_2,1)
    DrawFormattedText(disp_letter_instructions_2,letter_instructions_2{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for math practice instruction screen 1
disp_math_instructions_1 = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_math_instructions_1,font);
Screen('TextStyle',disp_math_instructions_1,1);
Screen('TextSize',disp_math_instructions_1,font_size);
n_lines_above_center = ceil(length(math_instructions_1)/2);
n_lines_below_center = length(math_instructions_1) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(math_instructions_1,1)
    DrawFormattedText(disp_math_instructions_1,math_instructions_1{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for  math practice instruction screen 2
disp_math_instructions_2 = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_math_instructions_2,font);
Screen('TextStyle',disp_math_instructions_2,1);
Screen('TextSize',disp_math_instructions_2,font_size);
n_lines_above_center = ceil(length(math_instructions_1_2)/2);
n_lines_below_center = length(math_instructions_1_2) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(math_instructions_1_2,1)
    DrawFormattedText(disp_math_instructions_2,math_instructions_1_2{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for ospan practice instruction screen 1
disp_ospan_instructions_1 = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_ospan_instructions_1,font);
Screen('TextStyle',disp_ospan_instructions_1,1);
Screen('TextSize',disp_ospan_instructions_1,font_size);
n_lines_above_center = ceil(length(ospan_instructions_1)/2);
n_lines_below_center = length(ospan_instructions_1) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(ospan_instructions_1,1)
    DrawFormattedText(disp_ospan_instructions_1,ospan_instructions_1{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for ospan practice instruction screen 1
disp_ospan_instructions_2 = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_ospan_instructions_2,font);
Screen('TextStyle',disp_ospan_instructions_2,1);
Screen('TextSize',disp_ospan_instructions_2,font_size);
n_lines_above_center = ceil(length(ospan_instructions_2)/2);
n_lines_below_center = length(ospan_instructions_2) - n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(ospan_instructions_2,1)
    DrawFormattedText(disp_ospan_instructions_2,ospan_instructions_2{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ... for instructions on math screens
n_lines_above_center_2 = ceil(length(math_instructions)/2);
n_lines_below_center_2 = length(math_instructions) - n_lines_above_center_2;
line_positions_y_2 = ((center_y+([-n_lines_above_center_2:n_lines_below_center_2]*line_spacing))+300);

% do initial save to create logfile
if subj_number  % only save data for test blocks
    save(subj_data_filename,'data'); % add updated data matrix to logfile
end

% START EXPERIMENT ----------------------------------------------------

% present experimental instructions
WaitSecs(.5);
Screen('CopyWindow',disp_task_instructions,w_screen,[],present_instructions,[]);
Screen(w_screen,'Flip');
key_found = 0;
while ~key_found
    [key_is_down,~,key_code] = KbCheck;
    if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
        keys_pressed = find(key_code);
        response_key = KbName(keys_pressed(1));
        if strcmp(response_key,'space') % if the spacebar was pressed
            FlushEvents('keyDown');
            key_found = 1; % accept this key response and start trial
        end
    end
end

correct_count = 0;

% BLOCK LOOP ----------------------------------------------------------
if tasks_to_practice == 1
    block_types_to_use = 1:length(block_types);
elseif tasks_to_practice == 2
    block_types_to_use = 1;
elseif tasks_to_practice == 3
    block_types_to_use = 2;
elseif tasks_to_practice == 4
    block_types_to_use = 3;
end

for block_type_count = block_types(block_types_to_use(1)):block_types(block_types_to_use(end))          
    
    key_found = 0;
    
    % present experimental instructions
    WaitSecs(.5);
    if block_type_count == 1
    Screen('CopyWindow',disp_letter_instructions_1,w_screen,[],present_instructions,[]);
    elseif block_type_count == 2
    Screen('CopyWindow',disp_math_instructions_1,w_screen,[],present_instructions,[]);
    elseif block_type_count == 3
    Screen('CopyWindow',disp_ospan_instructions_1,w_screen,[],present_instructions,[]);
    end
    
    Screen(w_screen,'Flip');
    key_found = 0;
    while ~key_found
        [key_is_down,~,key_code] = KbCheck;
        if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
            keys_pressed = find(key_code);
            response_key = KbName(keys_pressed(1));
            if strcmp(response_key,'space') % if the spacebar was pressed
                FlushEvents('keyDown');
                key_found = 1; % accept this key response and start trial
            end
        end
    end
    
    WaitSecs(.5);
    
    if block_type_count == 1
    Screen('CopyWindow',disp_letter_instructions_2,w_screen,[],present_instructions,[]);
    elseif block_type_count == 2
    Screen('CopyWindow',disp_math_instructions_2,w_screen,[],present_instructions,[]);
    elseif block_type_count == 3
    Screen('CopyWindow',disp_ospan_instructions_2,w_screen,[],present_instructions,[]);
    end
    Screen(w_screen,'Flip');
    key_found = 0;
    while ~key_found
        [key_is_down,~,key_code] = KbCheck;
        if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
            keys_pressed = find(key_code);
            response_key = KbName(keys_pressed(1));
            if strcmp(response_key,'space') % if the spacebar was pressed
                FlushEvents('keyDown');
                key_found = 1; % accept this key response and start trial
            end
        end
    end

    for block_count = 1:n_blocks_per_block_type(block_type_count)
        
        key_found = 0;
        duration_saved = 0; % reset this variable at the start of each block
        block_onset = GetSecs;
        
        x = 0; % Decrease volume
        player = audioplayer(x, Fs);
        play(player,[1 (get(player, 'SampleRate')*3)]);
        [y,Fs] = audioread('phaser.wav');
        player = audioplayer(y, Fs);
        
        % TRIAL LOOP ------------------------------------------------------
        
        for trial_count = 1:data.n_trials_per_block(block_count,block_type_count)
            
            % reset these variables at the start of each trial
            key_found = 0;
            
            % determine duration of fixation cross (it is jittered across trials)
            possible_fixation_durations = Shuffle(duration_fixation);
            current_fixation_duration = possible_fixation_durations(1);
            
            % determine fixation square size and position
            fix_x1 = (current_resolution.width/2)-5;
            fix_x2 = (current_resolution.width/2)+5;
            fix_y1 = (current_resolution.height/2)-5;
            fix_y2 = (current_resolution.height/2)+5;
            
            % present fixation square
            Screen('FillRect',w_screen, [0 0 0], [fix_x1 fix_y1 fix_x2 fix_y2]);
            Screen(w_screen,'Flip');
            trial_onset = GetSecs;
            while ((GetSecs - trial_onset) <= current_fixation_duration); end;
            
            % define font for response screens
            Screen('TextFont',w_screen,font);
            Screen('TextStyle',w_screen,1);
            Screen('TextSize',w_screen,font_size);
            
            % calculate and save duration of first fixation (only do this once)
            if ~duration_saved
                data.first_fix_duration(block_count,block_type_count) = trial_onset-block_onset;
                duration_saved = 1; % register that the first fixation duration has been saved
            end
            
            % STIMULI LOOP ------------------------------------------------
            
            if block_type_count == 1
                %present letter
                Screen('TextFont',disp_task_instructions,font);
                Screen('TextStyle',disp_task_instructions,1);
                Screen('TextSize',disp_task_instructions,font_size);
                DrawFormattedText(w_screen,possible_letters{data.letter_order(trial_count,block_count,block_type_count)},'Center','Center',colour_text,115); % present letter
                Screen(w_screen,'Flip');
                letter_onset = GetSecs;
                while ((GetSecs - letter_onset) <= letter_duration);
                end
                
            elseif block_type_count == 2
                
                for stimuli_count = 1:2
                    [x,y,buttons] = GetMouse;
                    
                    if stimuli_count == 1
                        %present math equation
                 
                        ShowCursor;
                        
                        Screen('TextFont',w_screen,font);
                        Screen('TextStyle',w_screen,1);
                        Screen('TextSize',w_screen,font_size);
                        for line_count = 1:size(math_instructions,1)
                            DrawFormattedText(w_screen,math_instructions{line_count},'Center',line_positions_y_2(line_count),colour_text,115); % present on-screen math instructions
                        end
                        DrawFormattedText(w_screen,data.math_equation{trial_count,block_count,block_type_count},'Center','Center',colour_text,115); % present equation
                        Screen(w_screen,'Flip');
                        math_onset = GetSecs;
                        while ~any(buttons) % wait for press
                            [x,y,buttons] = GetMouse; % check for mouse click
                        end
                        response_time = GetSecs - math_onset;
                        data.response_time(trial_count,block_count,block_type_count) = response_time;
                        HideCursor;
                        WaitSecs(0.5); 
                        
                        
                    elseif stimuli_count == 2 
                        
                        while any(buttons) % if already down, wait for release
                            [x,y,buttons] = GetMouse;
                        end
                        %present answer
                        buttons = 0;
                        ShowCursor;
                        Screen('TextFont',disp_task_instructions,font);
                        Screen('TextStyle',disp_task_instructions,1);
                        Screen('TextSize',disp_task_instructions,font_size);
                        if data.math_trial_type(trial_count,block_count,block_type_count) == 1 % if this is a correct answer trial
                            DrawFormattedText(w_screen,data.correct_answer{trial_count,block_count,block_type_count},'Center','Center',colour_text,115); % present correct answer to equation
                        else  % if this is an incorrect answer trial
                            DrawFormattedText(w_screen,data.incorrect_answer{trial_count,block_count,block_type_count},'Center','Center',colour_text,115); % present incorrect answer to equation
                        end
                        DrawFormattedText(w_screen,'TRUE',current_resolution.width*0.25,current_resolution.height*0.75,colour_text,115); % present response options
                        DrawFormattedText(w_screen,'FALSE',current_resolution.width*0.70,current_resolution.height*0.75,colour_text,115);
                        Screen(w_screen,'Flip');
                        
                        
                        response = 0;
                        start = GetSecs;
                        while response == 0 && (GetSecs-start) <= 5 % if no response has been made
                            while ~any(buttons) % wait for key press response
                                [x,y,buttons] = GetMouse;
                                if (x >= current_resolution.width*0.22 && x <= current_resolution.width*0.32) && (y >= current_resolution.height*0.70 && y <= current_resolution.height*0.82)
                                    response = 1; % if the TRUE button has been clicked, response = 1
                                elseif (x >= current_resolution.width*0.67 && x <= current_resolution.width*0.78) && (y >= current_resolution.height*0.70 && y <= current_resolution.height*0.82)
                                    response = 2;
                                    % if the FALSE button has been clicked, response = 2
                                else response = 0;
                                    buttons = 0;
                                    continue % if no button has been clicked, no response is recorded (stops the participant from clicking anywhere on screen)
                                end
                            end
                        end
                    end
                    while any(buttons) % if already down, wait for release
                        [x,y,buttons] = GetMouse;
                    end
                end
                
                data.math_response(trial_count,block_count,block_type_count) = response; % save each response to data structure
                if data.math_trial_type(trial_count,block_count,block_type_count) == 1 && data.math_response(trial_count,block_count,block_type_count) == 1
                    data.math_accuracy(trial_count,block_count,block_type_count) = 1; % if the response is TRUE and this is a TRUE trial, accuracy is 1
                elseif data.math_trial_type(trial_count,block_count,block_type_count) == 2 && data.math_response(trial_count,block_count,block_type_count) == 2
                    data.math_accuracy(trial_count,block_count,block_type_count) = 1; % if the response is FALSE and this is a FALSE trial, accuracy is 1
                else data.math_accuracy(trial_count,block_count,block_type_count) = 0; % otherwise the response is incorrect - accuracy is 0
                end
                
                
                data.std_dev_correct_RTs = std(data.response_time(:,:,2));
                data.mean_correct_RTs = mean(data.response_time(:,:,2));
                
                %play sound
                if data.math_accuracy(trial_count,block_count,block_type_count) == 0
                    play(player)
                end
                
                WaitSecs(0.1);
                
                [y,Fs] = audioread('phaser.wav');
                player = audioplayer(y, Fs);
                
            elseif block_type_count == 3
                
                for stimuli_count = 1:3  
  
                    [x,y,buttons] = GetMouse;  % check for mouse responses
                    
                    if stimuli_count == 1   % if it's the first stimulus
                        
                        %                   %present math equation
                        ShowCursor;
                        Screen('TextFont',w_screen,font);
                        Screen('TextStyle',w_screen,1);
                        Screen('TextSize',w_screen,font_size);
                        for line_count = 1:size(math_instructions,1)
                            DrawFormattedText(w_screen,math_instructions{line_count},'Center',line_positions_y_2(line_count),colour_text,115); % present on-screen math instructions
                        end
                        DrawFormattedText(w_screen,data.math_equation{trial_count,block_count,block_type_count},'Center','Center',colour_text,115); % present equation
                        Screen(w_screen,'Flip');
                        math_onset = GetSecs;
%                         while (GetSecs - math_onset) <= (data.mean_correct_RTs + data.std_dev_correct_RTs*2.5)
                        while ~any(buttons) && (GetSecs - math_onset) <= (data.mean_correct_RTs + data.std_dev_correct_RTs*2.5) % wait for press
                            [x,y,buttons] = GetMouse; % check for mouse click
                        end
%                         end
                        WaitSecs(0.5);
                        
                    elseif stimuli_count == 2 % if it's the second stimulus
                        
                        while any(buttons) % if already down, wait for release
                        [x,y,buttons] = GetMouse;
                        end
                        
                        %present answer
                        ShowCursor;
                        Screen('TextFont',disp_task_instructions,font);
                        Screen('TextStyle',disp_task_instructions,1);
                        Screen('TextSize',disp_task_instructions,font_size);
                        if data.math_trial_type(trial_count,block_count,block_type_count) == 1 % if this is a correct answer trial
                            DrawFormattedText(w_screen,data.correct_answer{trial_count,block_count,block_type_count},'Center','Center',colour_text,115); % present correct answer to equation
                        else  % if this is an incorrect answer trial
                            DrawFormattedText(w_screen,data.incorrect_answer{trial_count,block_count,block_type_count},'Center','Center',colour_text,115); % present incorrect answer to equation
                        end
                        DrawFormattedText(w_screen,'TRUE',current_resolution.width*0.25,current_resolution.height*0.75,colour_text,115); % present response options
                        DrawFormattedText(w_screen,'FALSE',current_resolution.width*0.70,current_resolution.height*0.75,colour_text,115);
                        Screen(w_screen,'Flip');
                        
                        time = GetSecs;
                        response = 0;
                        while response == 0 % if no response has been made
                            while ~any(buttons) % wait for key press response
                                [x,y,buttons] = GetMouse;
                                if (x >= current_resolution.width*0.22 && x <= current_resolution.width*0.32) && (y >= current_resolution.height*0.70 && y <= current_resolution.height*0.82)
                                    response = 1; % if the TRUE button has been clicked, response = 1
                                elseif (x >= current_resolution.width*0.67 && x <= current_resolution.width*0.78) && (y >= current_resolution.height*0.70 && y <= current_resolution.height*0.82)
                                    response = 2;
                                    % if the FALSE button has been clicked, response = 2
                                else response = 0;
                                    buttons = 0;
                                    continue % if no button has been clicked, no response is recorded (stops the participant from clicking anywhere on screen)
                                end
                            end
                        end
                        response_time = GetSecs - time;
                        data.response_time(trial_count,block_count,block_type_count) = response_time;
                        
                        data.math_response(trial_count,block_count,block_type_count) = response; % save each response to data structure
                        if data.math_trial_type(trial_count,block_count,block_type_count) == 1 && data.math_response(trial_count,block_count,block_type_count) == 1
                            data.math_accuracy(trial_count,block_count,block_type_count) = 1; % if the response is TRUE and this is a TRUE trial, accuracy is 1
                        elseif data.math_trial_type(trial_count,block_count,block_type_count) == 2 && data.math_response(trial_count,block_count,block_type_count) == 2
                            data.math_accuracy(trial_count,block_count,block_type_count) = 1; % if the response is FALSE and this is a FALSE trial, accuracy is 1
                        else data.math_accuracy(trial_count,block_count,block_type_count) = 0; % otherwise the response is incorrect - accuracy is 0
                        end
                        %
                        %play sound
                        if data.math_accuracy(trial_count,block_count,block_type_count) == 0
                            play(player)
                        end
                        
                        WaitSecs(0.1);
                        
                        [y,Fs] = audioread('phaser.wav');
                        player = audioplayer(y, Fs);
                        
                        while any(buttons) % if already down, wait for release
                            [x,y,buttons] = GetMouse;
                        end
                        HideCursor;

                    elseif stimuli_count == 3 % if it's the third stimulus
                        
                        %present letter
                        Screen('TextFont',disp_task_instructions,font);
                        Screen('TextStyle',disp_task_instructions,1);
                        Screen('TextSize',disp_task_instructions,font_size);
                        DrawFormattedText(w_screen,possible_letters{data.letter_order(trial_count,block_count,block_type_count)},'Center','Center',colour_text,115); % present letter
                        Screen(w_screen,'Flip');
                        letter_onset = GetSecs;
                        while ((GetSecs - letter_onset) <= letter_duration);
                        end
                        %ShowCursor;       
                    end
                end
                
                buttons = 0;  % reset mouse clicks for next trial
                
                
                
                %                 trial_offset = GetSecs;
                %
                %                 % save remaining data values in structure
                %                 data.trial_no(trial_count,block_count,block_type_count) = trial_count;
                %                 data.block_no(block_count,block_type_count) = block_count;
                %                 data.current_fixation_duration(trial_count,block_count,block_type_count) = current_fixation_duration;
                %                 data.trial_duration(trial_count,block_count,block_type_count) = trial_offset-trial_onset;
                % %                 data.fixation_duration(trial_count,block_count,block_type_count) = math_onset-trial_onset;
                
                                % save data
                                if subj_number  % only save data for test blocks
                                    save(subj_data_filename,'data','-append'); % add updated data matrix to logfile
                                end
                
            end % END OF STIMULI LOOP----------------------------------
            
            
        end % END OF TRIAL LOOP -------------------------------------------
        
        %          % response square coordinates for reference
        %          cell_x1_coords = [155 510 875];
        %          cell_x2_coords = [195 550 915];
        %          cell_y1_coords = [175 355 540 723];
        %          cell_y2_coords = [215 395 580 763];
        
%         WaitSecs(1);
        
        
        if block_type_count == 1 || block_type_count == 3
            % start response and valid response count
        
       valid_response_count = 0; 

        F_count = 0;
        N_count = 0;
        S_count = 0;
        J_count = 0;
        P_count = 0;
        T_count = 0;
        K_count = 0;
        Q_count = 0;
        Y_count = 0;
        L_count = 0;
        R_count = 0;
        H_count = 0;
        
        click_1 = 0;
        click_2 = 0;
        click_3 = 0;
        click_4 = 0;
        click_5 = 0;
        click_6 = 0;
        click_7 = 0;
        click_8 = 0;
        click_9 = 0;
        click_10 = 0;
        click_11 = 0;
        click_12 = 0;
        
        % define font for response screens
        disp_resp = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
        Screen(disp_resp,'FillRect',colour_background,size_stimuli);
        Screen(disp_resp,'PutImage',resp_stimulus_handle,size_stimuli)
        Screen('TextFont',w_screen,font);
        Screen('TextStyle',w_screen,1);
        Screen('TextSize',w_screen,font_size);
        
        while valid_response_count <= (data.n_trials_per_block(block_count,block_type_count)) % while there have been less valid responses than the number of trials for this block
            ShowCursor;
            buttons = 0;
            
            Screen('CopyWindow',disp_resp,w_screen,[],present_stimuli,[]);
            % Present onscreen instructions
            if valid_response_count == (data.n_trials_per_block(block_count,block_type_count)) % if the last response has been made present finished message
                DrawFormattedText(w_screen,'Finished! Click anywhere to continue, or CLEAR to start again.','Center',100,colour_text,115);
            else % Otherwise present standard message
                DrawFormattedText(w_screen,'Select the letters in the order presented.','Center',100,colour_text,115);
            end
            Screen(w_screen,'Flip');
            
            while ~any(buttons)  % wait for press
                % check for mouse clicks and get coordinates
                [x,y,buttons] = GetMouse;
            end
            
            WaitSecs(0.2);
            
            if ((x-x_offset) >= 90) && ((x-x_offset) <= 260) && ((y-y_offset) >= 870) && ((y-y_offset) <= 960)
                valid_response_count = 0; % reset both response counters
                data.click_position_x(:) = []; % clear previous click coordinates
                data.click_position_y(:) = [];
                F_count = 0;
                N_count = 0;
                S_count = 0;
                J_count = 0;
                P_count = 0;
                T_count = 0;
                K_count = 0;
                Q_count = 0;
                Y_count = 0;
                L_count = 0;
                R_count = 0;
                H_count = 0;
                
                click_1 = 0;
                click_2 = 0;
                click_3 = 0;
                click_4 = 0;
                click_5 = 0;
                click_6 = 0;
                click_7 = 0;
                click_8 = 0;
                click_9 = 0;
                click_10 = 0;
                click_11 = 0;
                click_12 = 0;
                
                % reset response array
                disp_resp = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
                Screen(disp_resp,'FillRect',colour_background,size_stimuli);
                Screen(disp_resp,'PutImage',resp_stimulus_handle,size_stimuli)
            end
            
            if valid_response_count < (data.n_trials_per_block(block_count,block_type_count))
                if((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 175) && ((y-y_offset) <= 215)
                    if click_1 == 0
                        valid_response_count = valid_response_count + 1;
                        click_1 = 1;
                    end
                    % if they click in the second box, record their response as "N"
                elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 175) && ((y-y_offset) <= 215)
                    if click_2 == 0
                        valid_response_count = valid_response_count + 1;
                        click_2 = 1;
                    end
                    % if they click in the third box, record their response as "S"
                elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 175) && ((y-y_offset) <= 215)
                    if click_3 == 0
                        valid_response_count = valid_response_count + 1;
                        click_3 = 1;
                    end
                    % if they click in the fourth box, record their response as "J"
                elseif ((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 355) && ((y-y_offset) <= 395)
                    if click_4 == 0
                        valid_response_count = valid_response_count + 1;
                        click_4 = 1;
                    end
                    % if they click in the fifth box, record their response as "P"
                elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 355) && ((y-y_offset) <= 395)
                    if click_5 == 0
                        valid_response_count = valid_response_count + 1;
                        click_5 = 1;
                    end
                    % if they click in the sixth box, record their response as "T"
                elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 355) && ((y-y_offset) <= 395)
                    if click_6 == 0
                        valid_response_count = valid_response_count + 1;
                        click_6 = 1;
                    end
                    % if they click in the seventh box, record their response as "K"
                elseif ((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 540) && ((y-y_offset) <= 580)
                    if click_7 == 0
                        valid_response_count = valid_response_count + 1;
                        click_7 = 1;
                    end
                    % if they click in the eighth box, record their response as "Q"
                elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 540) && ((y-y_offset) <= 580)
                    if click_8 == 0
                        valid_response_count = valid_response_count + 1;
                        click_8 = 1;
                    end
                    %  % if they click in the ninth box, record their response as "Y"
                elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 540) && ((y-y_offset) <= 580)
                    if click_9 == 0
                        valid_response_count = valid_response_count + 1;
                        click_9 = 1;
                    end
                    % if they click in the tenth box, record their response as "L"
                elseif ((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 723) && ((y-y_offset) <= 763)
                    if click_10 == 0
                        valid_response_count = valid_response_count + 1;
                        click_10 = 1;
                    end
                    % if they click in the eleventh box, record their response as "R"
                elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 723) && ((y-y_offset) <= 763)
                    if click_11 == 0
                        valid_response_count = valid_response_count + 1;
                        click_11 = 1;
                    end
                    % if they click in the twelth box, record their response as "H"
                elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 723) && ((y-y_offset) <= 763)
                    if click_12 == 0
                        valid_response_count = valid_response_count + 1;
                        click_12 = 1;
                    end
                end
                
                if valid_response_count > 0
                    if valid_response_count >= 1 && valid_response_count <= (data.n_trials_per_block(block_count,block_type_count))
                        data.click_position_x(valid_response_count,block_count,block_type_count) = x; % save x coordinate of click position for each response
                        data.click_position_y(valid_response_count,block_count,block_type_count) = y; % save y coordinate of click position for each response
                    end
                    Screen('CopyWindow',disp_resp,w_screen,[],present_stimuli,[]);
                    if((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 175) && ((y-y_offset) <= 215)
                        if F_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(1),row_1_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'F'};
                            F_count = 1;
                        end
                        % if they click in the second box, record their response as "N"
                    elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 175) && ((y-y_offset) <= 215)
                        if N_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(2),row_1_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'N'};
                            N_count = 1;
                        end
                        % if they click in the third box, record their response as "S"
                    elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 175) && ((y-y_offset) <= 215)
                        if S_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(3),row_1_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'S'};
                            S_count = 1;
                        end
                        % if they click in the fourth box, record their response as "J"
                    elseif ((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 355) && ((y-y_offset) <= 395)
                        if J_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(1),row_2_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'J'};
                            J_count = 1;
                        end
                        % if they click in the fifth box, record their response as "P"
                    elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 355) && ((y-y_offset) <= 395)
                        if P_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(2),row_2_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'P'};
                            P_count = 1;
                        end
                        % if they click in the sixth box, record their response as "T"
                    elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 355) && ((y-y_offset) <= 395)
                        if T_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(3),row_2_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'T'};
                            T_count = 1;
                        end
                        % if they click in the seventh box, record their response as "K"
                    elseif ((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 540) && ((y-y_offset) <= 580)
                        if K_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(1),row_3_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'K'};
                            K_count = 1;
                        end
                        % if they click in the eighth box, record their response as "Q"
                    elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 540) && ((y-y_offset) <= 580)
                        if Q_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(2),row_3_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'Q'};
                            Q_count = 1;
                        end
                        %  % if they click in the ninth box, record their response as "Y"
                    elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 540) && ((y-y_offset) <= 580)
                        if Y_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(3),row_3_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'Y'};
                            Y_count = 1;
                        end
                        % if they click in the tenth box, record their response as "L"
                    elseif ((x-x_offset) >= 155) && ((x-x_offset) <= 195) && ((y-y_offset) >= 723) && ((y-y_offset) <= 763)
                        if L_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(1),row_4_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'L'};
                            L_count = 1;
                        end
                        % if they click in the eleventh box, record their response as "R"
                    elseif ((x-x_offset) >= 510) && ((x-x_offset) <= 550) && ((y-y_offset) >= 723) && ((y-y_offset) <= 763)
                        if R_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(2),row_4_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'R'};
                            R_count = 1;
                        end
                        % if they click in the twelth box, record their response as "H"
                    elseif ((x-x_offset) >= 875) && ((x-x_offset) <= 915) && ((y-y_offset) >= 723) && ((y-y_offset) <= 763)
                        if H_count == 0
                            DrawFormattedText(disp_resp,num2str(valid_response_count),column_coords(3),row_4_height,colour_text,115);
                            data.response(valid_response_count,block_count,block_type_count) = {'H'};
                            H_count = 1;
                        end
                    end
                    if ~strcmp(data.response{valid_response_count,block_count,block_type_count},possible_letters{data.letter_order(valid_response_count,block_count,block_type_count)})
                        play(player)
                        
                        WaitSecs(0.1);
                        
                        [y,Fs] = audioread('phaser.wav');
                        player = audioplayer(y, Fs);
                    end
                    if valid_response_count == (data.n_trials_per_block(block_count,block_type_count)) % if the last response has been made present finished message
                        DrawFormattedText(w_screen,'Finished! Click anywhere to continue, or CLEAR to start again.','Center',100,colour_text,115);
                    else % Otherwise present standard message
                        DrawFormattedText(w_screen,'Select the letters in the order presented.','Center',100,colour_text,115);
                    end
                    Screen(w_screen,'Flip');
                end
            else valid_response_count = valid_response_count + 1;
            end
        end
            
            % determine letter accuracy for each trial and each block
            for trial_count = 1:data.n_trials_per_block(block_count,block_type_count)
                if strcmp(data.response{trial_count,block_count,block_type_count},possible_letters{data.letter_order(trial_count,block_count,block_type_count)}) % if the key matches the correct response.
                    data.accuracy(trial_count,block_count,block_type_count) = 1; % record as correct response
                else data.accuracy(trial_count,block_count,block_type_count) = 0; % otherwise record as an incorrect response
                end
            end
            data.no_correct_letters(block_count,block_type_count) = sum(data.accuracy(:,block_count,block_type_count)); % save number of errors    
        else continue
        end
        
        % Reset response array for next block
        disp_resp = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
        Screen(disp_resp,'FillRect',colour_background,size_stimuli);
        Screen(disp_resp,'PutImage',resp_stimulus_handle,size_stimuli)
        
        % save block duration data
        block_offset = GetSecs;
        
        %         % save total correct math equations and mean letter accuracy
        if block_type_count == 2 || block_type_count == 3
            data.n_math_errors(block_count,block_type_count) = (data.n_trials_per_block(block_count,block_type_count))-(sum(data.math_accuracy(:,block_count,block_type_count))); % save number of errors to report on screen
        elseif block_type_count == 1 || block_type_count == 3
            data.mean_accuracy(block_count,block_type_count) = mean(data.accuracy(1:data.n_trials_per_block(block_count,block_type_count),block_count,block_type_count)); % save mean number of letters correctly reported
        end
        
        % ... for feedback screen
        
        disp_feedback = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_feedback,font);
        Screen('TextStyle',disp_feedback,1);
        Screen('TextSize',disp_feedback,font_size);
        n_lines_above_center = ceil(length(feedback_message)/2);
        n_lines_below_center = length(feedback_message) - n_lines_above_center;
        line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
        if block_type_count == 1
            DrawFormattedText(disp_feedback,sprintf(feedback_message_1{1},data.no_correct_letters(block_count,block_type_count),data.n_trials_per_block(block_count,block_type_count)),'Center',line_positions_y(2),colour_text,115);
            DrawFormattedText(disp_feedback,feedback_message_1{2},'Center',line_positions_y(3),colour_text,115);
            DrawFormattedText(disp_feedback,feedback_message_1{3},'Center',line_positions_y(4),colour_text,115);
        elseif block_type_count == 3
            DrawFormattedText(disp_feedback,sprintf(feedback_message{1},data.no_correct_letters(block_count,block_type_count),data.n_trials_per_block(block_count,block_type_count)),'Center',line_positions_y(1),colour_text,115);
            DrawFormattedText(disp_feedback,feedback_message{2},'Center',line_positions_y(2),colour_text,115);
            DrawFormattedText(disp_feedback,sprintf(feedback_message{3},data.n_math_errors(block_count,block_type_count)),'Center',line_positions_y(3),colour_text,115);
            DrawFormattedText(disp_feedback,feedback_message{4},'Center',line_positions_y(4),colour_text,115);
            DrawFormattedText(disp_feedback,feedback_message{5},'Center',line_positions_y(5),colour_text,115);
        end
        
        Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]); % display feedback
        Screen(w_screen,'Flip');
        key_found = 0;
        while ~key_found % poll keyboard for space response
            [key_is_down,~,key_code] = KbCheck;
            if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                keys_pressed = find(key_code);
                response_key = KbName(keys_pressed(1));
                if strcmp(response_key,'space') % if the spacebar was pressed
                    FlushEvents('keyDown');
                    key_found = 1; % accept this key response and start next block
                end
            end
        end
        
        %         data.block_duration(block_count,block_type_count) = block_offset-block_onset;
        %
                 if subj_number  % only save data for test blocks
        %             % store additional details in data matrix
                     save(subj_data_filename,'data','-append');
                 end
        
    end % END OF BLOCK LOOP -----------------------------------------------
    
    if block_type_count == 2
        
        data.n_math_errors(block_count,block_type_count) = (data.n_trials_per_block(block_count,block_type_count))-(sum(data.math_accuracy(:,block_count,block_type_count))); % save number of errors to report on screen
        
        disp_feedback = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_feedback,font);
        Screen('TextStyle',disp_feedback,1);
        Screen('TextSize',disp_feedback,font_size);
        n_lines_above_center = ceil(length(feedback_message_2)/2);
        n_lines_below_center = length(feedback_message_2) - n_lines_above_center;
        line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
        DrawFormattedText(disp_feedback,sprintf(feedback_message_2{1},data.n_math_errors(block_count,block_type_count)),'Center',line_positions_y(1),colour_text,115);
        DrawFormattedText(disp_feedback,feedback_message_2{2},'Center',line_positions_y(2),colour_text,115);
        DrawFormattedText(disp_feedback,feedback_message_2{3},'Center',line_positions_y(3),colour_text,115);
        Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]); % display feedback
        Screen(w_screen,'Flip');
        key_found = 0;
        while ~key_found % poll keyboard for space response
            [key_is_down,~,key_code] = KbCheck;
            if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                keys_pressed = find(key_code);
                response_key = KbName(keys_pressed(1));
                if strcmp(response_key,'space') % if the spacebar was pressed
                    FlushEvents('keyDown');
                    key_found = 1; % accept this key response and start next block
                end
            end
        end
    end
    
    WaitSecs(0.2);
    if block_type_count == 3 || block_type_count == 1 && tasks_to_practice == 2 || block_type_count == 2 && tasks_to_practice == 3
    Screen('CopyWindow',disp_goodbye,w_screen,[],present_instructions,[]);
    Screen(w_screen,'Flip');
    key_found = 0;
    while ~key_found
        [key_is_down,~,key_code] = KbCheck;
        if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
            keys_pressed = find(key_code);
            response_key = KbName(keys_pressed(1));
            if strcmp(response_key,'space') % if the spacebar was pressed
                FlushEvents('keyDown');
                key_found = 1; % accept this key response and end task
            end
        end
    end
    end
    
 end % END OF BLOCK TYPE LOOP-----------------------------------------------
    
 data.std_dev_correct_RTs
 data.mean_correct_RTs
 
% END OF PRACTICE/TEST LOOP -----------------------------------------------

% END OF EXPERIMENT -------------------------------------------------------

% close matlab
ShowCursor;
FlushEvents('keyDown');
clc;
Screen('CloseAll');
end