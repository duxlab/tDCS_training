 function RSVP

% FUNCTION DETAILS --------------------------------------------------------
%
% Participants are presented with an RSVP stream containing one target and
% numerous distractors. They have to report the identity of the target.
%
% Stimulus presentation durations are staircased to keep accuracy at approximately 70% 
%
% Written by Kristina S. Horne (2017, UQ)
%
% RUN CODE ----------------------------------------------------------------
stand_alone = 0;

previous_speed = 0.1;

if stand_alone == 1
   % clc
   % clear all;
else
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject_number = ActiveData(1,1);
    session_number = ActiveData(1,2);
    if session_number > 1
        previous_speed = ActiveData(1,11);
    end
    cd('RSVP')
end;

warning('off','all');

% create random state
rand('twister',sum(100*clock));

% initialize important MEX-files.
KbCheck;
GetSecs;

% switch KbName into unified mode; this will use the names of the OS-X platform on all platforms in order to make this script portable
KbName('UnifyKeyNames');

% SETTINGS/CHEATS --------------------------------------------------------

% define computer being used
computer_used = 1; % 1= Dux lab iMac,2= Dux lab testing mini,3= Claire's personal laptop,4= Dux lab PC laptop

% define cheats for display speeds
duration_speed = 1; % set to 1 for normal speed,< 1 = fast,> 1 = slow

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

% condition details - number of distractors before target
% 1= lag 2
% 2= lag 3
% 3= lag 4
% 4= lag 5
% 5= lag 6
% 6= lag 7
condition_names = {'lag_2','lag_3','lag_4','lag_5','lag_6','lag_7'};
possible_pre_T1_distractors = [2 3 4 5 6 7];

% allocate number of pre-T1 distractors for each condition
for condition_count = 1:length(condition_names)
n_pre_T1_distractors = possible_pre_T1_distractors(condition_count);
end

% duration details
duration_first_fixation = 2*duration_speed; % present initial pause at the start of each block
duration_fixation = .2:.01:.6;
minimum_trial_duration = 2*duration_speed;

% specify number of correct/incorrect trials needed before changing stimulus duration
no_correct_trials = 5;
no_incorrect_trials = 2; %change back to 2 for real deal!

% trial details
n_trials_per_block = [24 48]; %60; % SHOULD BE 60
n_blocks = [1 5]; % n_blocks(1)= number of practice blocks; n_blocks(2)= number of test blocks %THIS WILL BE 8 BLOCKS 

% colour details
colour_background = [211 211 211];
colour_text = [0 0 0];

% size details
size_stimuli_pix = [100 100];

% text details
standard_font = 'Arial';
stimuli_font = 'Arial';
stimuli_font_size = 40;
task_instructions = {'Your task is to report the letter';...
    'presented among a stream of digits.';...
    '';...
    'Please respond as accurately as possible.';...
    '';...
    'Press the space key to begin the %s block.'}; % these instructions can be editted, but keep same format (ie., all in one cell matrix) and the final line need to stay the same
task_types = {'practice','test'};
line_spacing = 45;
response_prompt = 'Enter target identity.';
goodbye_prompt = {'Please notify the experimenter.','Take a short break! Task will restart...'};
prac_response_feedback = {'Well done! You''ve just completed practice block %d of %d!';...
    '';...
    '%s'};
response_feedback = {'Well done! You''ve just completed block %d of %d!';...
    '';...
    '%s'};

% stimuli details
possible_target_stim = {'A','B','C','D','E','F','G','H','J','K','M','N','P','R','S','T','W','Y','Z'};
possible_distractor_stim = {'2','3','4','5','6','7','8','9'};

% SETUP EXPERIMENT --------------------------------------------------------

Screen('Preference','SkipSyncTests', 1);

% implement computer used settings
if computer_used == 1 % lab iMac
    standard_font_size = 40;
    screen_resolution = [1920 1080]; %overwrite screen resolution 
    disp('Computer set for Dux lab iMac');
elseif computer_used == 2 % Dux lab testing computer
    standard_font_size = 40;
    disp('Computer set for Dux lab mac mini computer');
elseif computer_used == 3 % Claire's personal laptop
    standard_font_size = 30;
    screen_resolution = [1280 800]; % over-write screen resolution as my personal laptop cannot display 1024 x 768 resolution
    refresh_rate = 0; % over-write screen resolution as my personal laptop cannot display at 100Hz
    disp('Computer set for personal laptop');
elseif computer_used == 4 % Dux lab PC laptop
    standard_font_size = 30;
    disp('Computer set for Dux lab PC laptop');
end

% enter subject details
if stand_alone ==1 
    subj_number = input('Subject Number (Enter "0" for no logfile): ');
    session_number = input('Session Number: ');
    if session_number > 1
        previous_speed = input('Starting speed: ');
    end
else
    subj_number = subject_number;
end

date_time = fix(clock);


% open a screen
HideCursor;
AssertOpenGL;
my_screens = Screen('Screens');
screen_number = max(my_screens);
current_resolution = Screen('Resolution',screen_number);
[w_screen,w_rect] = Screen('OpenWindow',screen_number);
Screen(w_screen,'Flip'); % do an initial flip so that you draw on background and not on programming screen
Screen(w_screen,'FillRect',colour_background,w_rect);
Screen(w_screen,'Flip');
Screen(w_screen,'FillRect',colour_background,[]);

% determine size and position of stimuli
[~,center_y] = RectCenter(w_rect); %  coordinates start from top left corner [0,0]

% ...for instructions screen
size_instructions = [0 0 current_resolution.width current_resolution.height]; % make run_instructions take up entire screen
present_instructions = CenterRect(size_instructions,w_rect); % present instructions in center of the screen

% ...for stimuli screen
size_stimuli = [0 0 size_stimuli_pix];
present_stimuli = CenterRect(size_stimuli,w_rect); % present stimuli in center of the screen

% create the generic stimulus screens

% ...fixation square dimensions
fix_x1 = (current_resolution.width/2)-5;
fix_x2 = (current_resolution.width/2)+5;
fix_y1 = (current_resolution.height/2)-5;
fix_y2 = (current_resolution.height/2)+5;

% ...for target screens
for stimuli_count = 1:length(possible_target_stim)
    disp_target(stimuli_count) = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
    Screen('TextFont',disp_target(stimuli_count),stimuli_font);
    Screen('TextStyle',disp_target(stimuli_count),1);
    Screen('TextSize',disp_target(stimuli_count),stimuli_font_size);
    DrawFormattedText(disp_target(stimuli_count),possible_target_stim{stimuli_count},'Center','Center',colour_text,115);
end

% ...for distractor screens
for stimuli_count = 1:length(possible_distractor_stim)
    disp_distractor(stimuli_count) = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
    Screen('TextFont',disp_distractor(stimuli_count),stimuli_font);
    Screen('TextStyle',disp_distractor(stimuli_count),1);
    Screen('TextSize',disp_distractor(stimuli_count),stimuli_font_size);
    DrawFormattedText(disp_distractor(stimuli_count),possible_distractor_stim{stimuli_count},'Center','Center',colour_text,115);
end

% ...for first target response screen
disp_T1_response = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_T1_response,standard_font);
Screen('TextStyle',disp_T1_response,1);
Screen('TextSize',disp_T1_response,standard_font_size);
DrawFormattedText(disp_T1_response,sprintf(response_prompt,'first'),'Center','Center',colour_text,115);

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
%     Screen('TextFont',disp_screen_specs,standard_font);
%     Screen('TextStyle',disp_screen_specs,1);
%     Screen('TextSize',disp_screen_specs,standard_font_size);
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

if session_number == 1
    Prac_included = 1;
else
    Prac_included = 2;
end;

for version_count = Prac_included:length(task_types)

    
    % reset data matrix so that only test data is stored
    clear data
    
    % add input data to data structure
    data.screen_specifications = current_resolution;
    data.subject_no = subj_number;
    data.date_time = date_time;
    data.session_number = session_number;
    data.previous_speed = previous_speed;
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
    if subj_number && version_count == 2 % only save data for test blocks
        subj_data_filename = ['data_logfile_for_single_target_RSVP_task_sub_' subject_number_string '_session_' session_number_string];
        
        % check if data file already exists
        if subj_number && version_count == 2 % only save data for test blocks ~= 999
            if exist([subj_data_filename '.mat'],'file')
                error('Data for file for this subject number already exists - please chose a different subject number.');
            end
        end 
    end
    
    % determine trial type order
    n_repetitions_per_type = n_trials_per_block(version_count)/length(condition_names); % determine how many repetitions there will be of each trial type per block
    if mod(n_trials_per_block(version_count),length(condition_names)) ~= 0 % if n_trials_per_block is not perfectly divisible by the number of conditions names (i.e.,there is an unequal number of trials per type)
        error('You have an unequal number of trials per block,per condition - check this!'); % throw an error - the number of repetitions should be equal across conditions
    end
    for block_count = 1:n_blocks(version_count) % for each block...
        temp_trial_type_order = []; % create an empty matrix to fill the trial types for each block
        for trial_type_count = 1:length(condition_names) % for each condition...
            for repetition_count = 1:n_repetitions_per_type% for each repetition of this condition...
                temp_trial_type_order = [temp_trial_type_order trial_type_count]; % add this condition number to temporary version of trial order matrix
            end
        end
        data.trial_type_order(1:length(temp_trial_type_order),block_count) = Shuffle(temp_trial_type_order); % shuffle the trial order for this block and save in data structure
    end
    
    % create remaining stimulus screens
    
    % ...for task instruction screen
    temp_task_instructions = task_instructions; % make a copy of task instructions so that they can be editted in each version loop
    temp_task_instructions{end} = sprintf(task_instructions{end},task_types{version_count});
    disp_task_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
    Screen('TextFont',disp_task_instructions,standard_font);
    Screen('TextStyle',disp_task_instructions,1);
    Screen('TextSize',disp_task_instructions,standard_font_size);
    n_lines_above_center = ceil(length(temp_task_instructions)/2);
    n_lines_below_center = length(temp_task_instructions) - n_lines_above_center;
    line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
    for line_count = 1:size(temp_task_instructions,1)
        DrawFormattedText(disp_task_instructions,temp_task_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
    end
    
    % do initial save to create logfile
    if subj_number && version_count == 2 % only save data for test blocks
        % add updated data matrix to logfile
        save(subj_data_filename,'data');
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
    
    % BLOCK LOOP ----------------------------------------------------------
    
    TaskTimer = GetSecs;
    
    for block_count = 1:n_blocks(version_count)
                
        duration_saved = 0; % reset this variable at the start of each block
        
        % present fixation cross
             % present fixation square
             Screen('FillRect',w_screen, [0 0 0], [fix_x1 fix_y1 fix_x2 fix_y2]);
                 Screen(w_screen,'Flip');
                 block_onset = GetSecs;
             if block_count == 1 || block_count == 3 || block_count == 5 || block_count == 7            
                 while ((GetSecs - block_onset) <= duration_first_fixation); end;
             else 
                 while ((GetSecs - block_onset) <= current_fixation_duration); end;
             end
        
        correct_counter = 0; %start accuracy correct counter
        incorrect_counter = 0; %start accuracy incorrect counter
        
        % TRIAL LOOP ------------------------------------------------------
        
        for trial_count = 1:n_trials_per_block(version_count)
            
        % STAIRCASING --------------------------------------------------
        
        if block_count == 1 && trial_count == 1 % if this is the first trial of the first block
            duration_stimuli = previous_speed*duration_speed; % use given duration speed 
        elseif block_count > 1 && trial_count == 1 % if this is the first trial, but not the first block
            duration_stimuli = data.duration_stimuli(n_trials_per_block(version_count),block_count-1); % use last stimulus duration from previous block
        elseif trial_count > 1 % if this is not the first trial
            duration_stimuli = data.duration_stimuli(trial_count-1,block_count); % use stimulus duration from previous trial
            if correct_counter == no_correct_trials % if there have been x correct trials in a row 
                duration_stimuli = duration_stimuli - 0.01; % minus 0.01 seconds from previous duration speed
            end
            if incorrect_counter == no_incorrect_trials % if there have been 2 incorrect trials in a row 
                duration_stimuli = data.duration_stimuli(trial_count-1,block_count) + 0.01; % add 0.01 seconds to previous duration speed
            end
        end
                  
            % Reset correct counter after it reaches 3 and speed has been
            % changed
           
            if correct_counter == no_correct_trials   
                correct_counter = 0;
            end
            
            % Reset incorrect counter after it reaches 2
            if incorrect_counter == no_incorrect_trials   
                incorrect_counter = 0;
            end
           
         % END OF STAIRCASING ------------------------------------------
            
            % shuffle target and distractor stimuli
            target_stimuli_IDs = randperm(length(possible_target_stim));
            distractor_stimuli_IDs = randperm(length(possible_distractor_stim));

            % present RSVP stream using separate script to improve timings
            trial_onset = GetSecs;
            present_RSVP_stream_KH2;
            trial_offset = GetSecs;
            
            % calculate and save duration of first fixation (only do this once)
            if ~duration_saved
                data.first_fix_duration(block_count,1) = trial_onset-block_onset;
                duration_saved = 1; % register that the first fixation duration has been saved
            end
            
            % present first target response screen 
            Screen('CopyWindow',disp_T1_response,w_screen,[],present_instructions,[]);
            Screen(w_screen,'Flip');
            T1_response_onset = GetSecs;
            key_found = 0;
            while ~key_found
                % poll keyboard for first stimulus response
                [key_is_down,time_in_secs,key_code] = KbCheck;
                if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                    keys_pressed = find(key_code);
                    response_key = KbName(keys_pressed(1));
                    
                    % record response key and reaction time
                    if numel(response_key) == 1 % if there is only one element in the response key variable (i.e., a letter key was pressed, and not some other sort of key)
                        data.T1_response_key{trial_count,block_count} = upper(response_key(1)); % change response to uppercase
                    else
                        data.T1_response_key{trial_count,block_count} = response_key; % otherwise simply record entire key string
                    end
                    data.T1_reaction_time(trial_count,block_count) = time_in_secs-T1_response_onset;
                    
                    FlushEvents('keyDown');
                    key_found = 1;
                end
            end
            
            if key_found == 0
                data.T1_response_key{trial_count,block_count} = 0; 
            end
            
            % calculate and store accuracy
            if strcmp(data.T1_response_key{trial_count,block_count},possible_target_stim{target_stimuli_IDs(1)}) || strcmp(data.T1_response_key{trial_count,block_count},possible_target_stim{target_stimuli_IDs(2)}) % if the response key matches the either of the target letters
                data.T1_accuracy(trial_count,block_count) = 1;
            else
                data.T1_accuracy(trial_count,block_count) = 0;
            end
            
            % add to accuracy correct counter
            if data.T1_accuracy(trial_count,block_count) == 1; % if response was correct, add 1 to accuracy correct_counter
                correct_counter = correct_counter + 1;
            elseif data.T1_accuracy(trial_count,block_count) == 0; % if response was incorrect, reset accuracy correct_counter
                correct_counter = 0;
            end
            
            % save correct_counter for debugging
            data.correct_counter{trial_count,block_count} = correct_counter;
            
            % add to accuracy incorrect counter
            if data.T1_accuracy(trial_count,block_count) == 0; % if response was incorrect, add 1 to accuracy incorrect counter
                incorrect_counter = incorrect_counter + 1;
            elseif data.T1_accuracy(trial_count,block_count) == 1; % if response was correct, reset accuracy incorrect counter
                incorrect_counter = 0;
            end
            
            % save incorrect_counter for debugging
            data.incorrect_counter{trial_count,block_count} = incorrect_counter;
            
            % save stimulus speed data
            data.duration_stimuli(trial_count,block_count) = duration_stimuli;
            
            % save remaining data values in structure
            data.trial_no(trial_count,1) = trial_count;
            data.trial_type_name{trial_count,block_count} = condition_names{data.trial_type_order(trial_count,block_count)};
            data.block_no(block_count,1) = block_count;
            data.trial_duration(trial_count,block_count) = trial_offset-trial_onset;
            data.post_fixation_trial_duration(trial_count,block_count) = trial_offset-post_fixation_trial_onset;
            data.first_target{trial_count,block_count} = possible_target_stim{target_stimuli_IDs(1)};
%             data.second_target{trial_count,block_count} = possible_target_stim{target_stimuli_IDs(2)};
            data.distractor_items{trial_count,block_count} = possible_distractor_stim(distractor_stimuli_IDs);
            
            if subj_number && version_count == 2 % only save data for test blocks
                % add updated data matrix to logfile
                save(subj_data_filename,'data','-append');
            end          
            
        end % END OF TRIAL LOOP -----------------------------------------------
         
        % save block duration data
        block_offset = GetSecs;
        data.block_duration(block_count,1) = block_offset-block_onset;
        
        %calculate and store accuracy percentage for each block
        block_accuracy = sum(data.T1_accuracy(1:n_trials_per_block(version_count),block_count))/n_trials_per_block(version_count);
        data.block_accuracy_percentage(block_count) = block_accuracy*100;
        
        if subj_number && version_count == 2 % only save data for test blocks
            % store additional details in data matrix
            save(subj_data_filename,'data','-append');
        end
        
        block_to_show = 0;
        
        if block_count == 2
            block_to_show = 1;
        elseif block_count == 4
            block_to_show = 2;
        end;
        
        totalblocks = 3;
        
        % create response feedback with updated response data
        disp_feedback = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_feedback,standard_font);
        Screen('TextStyle',disp_feedback,1);
        Screen('TextSize',disp_feedback,standard_font_size);
        n_lines_above_center = ceil(length(response_feedback))/2;
        n_lines_below_center = length(response_feedback) - n_lines_above_center;
        line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
        DrawFormattedText(disp_feedback,sprintf(response_feedback{1},(block_to_show),(totalblocks)),'Center',line_positions_y(1),colour_text,115);
        DrawFormattedText(disp_feedback,response_feedback{2},'Center',line_positions_y(2),colour_text,115);
        if block_count ~= n_blocks(version_count) % if it's not the last block...
            DrawFormattedText(disp_feedback,sprintf(response_feedback{3},goodbye_prompt{2}),'Center',line_positions_y(3),colour_text,115); % display "continue" prompt
        else
            DrawFormattedText(disp_feedback,sprintf(response_feedback{3},goodbye_prompt{1}),'Center',line_positions_y(3),colour_text,115); % display "get experimenter" prompt
        end
        
        disp_prac_feedback = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_prac_feedback,standard_font);
        Screen('TextStyle',disp_prac_feedback,1);
        Screen('TextSize',disp_prac_feedback,standard_font_size);
        n_lines_above_center = ceil(length(prac_response_feedback))/2;
        n_lines_below_center = length(prac_response_feedback) - n_lines_above_center;
        line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
        DrawFormattedText(disp_prac_feedback,sprintf(prac_response_feedback{1},block_count,n_blocks(version_count)),'Center',line_positions_y(1),colour_text,115);
%         DrawFormattedText(disp_prac_feedback,prac_response_feedback{2},'Center',line_positions_y(2),colour_text,115);
        DrawFormattedText(disp_prac_feedback,sprintf(prac_response_feedback{3},goodbye_prompt{1}),'Center',line_positions_y(3),colour_text,115); % display "get experimenter" prompt
        
        
        % present response feedback screen
        
        if version_count == 2 && (block_count == 2 || block_count == 4)
            WaitSecs(.5);
            Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]);
            Screen(w_screen,'Flip'); WaitSecs(3);
            if block_count == 2
                targetTime = 330;
            elseif block_count == 4
                targetTime = 660;
            end
            while GetSecs - TaskTimer <= targetTime; end
        elseif version_count == 1
            WaitSecs(.5);
            Screen('CopyWindow',disp_prac_feedback,w_screen,[],present_instructions,[]);
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
        end
        
    end % END OF BLOCK LOOP -----------------------------------------------
    
end % END OF PRACTICE/TEST LOOP -------------------------------------------

% END OF EXPERIMENT -------------------------------------------------------

duration_stimuli;

filename = strcat('Subject_',num2str(subject_number),'Session_',num2str(session_number),'_RSVP_stimuli_duration.txt'); 
datafilepointer = fopen(filename,'wt');
results(1,:) = [subject_number, duration_stimuli];
dlmwrite(filename,results,'delimiter','\t','precision',8);

%end of task screen

endtext = 'End of task!';
DrawFormattedText(w_screen, endtext, 'center', 'center');
Screen('Flip', w_screen);
tic; while toc < 3; end;

% close matlab
ShowCursor;
FlushEvents('keyDown');
clc;
Screen('CloseAll');