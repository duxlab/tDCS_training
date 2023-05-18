function Go_no_Go_MW
try
    % FUNCTION DETAILS --------------------------------------------------------
    %
    % Participants make a button press whenever a "go" stimulus appears. On
    % some trials, a "no-go" stimulus instead appears and participants are to
    % withhold their response.
    %
    % Co-written by Angela Bender & Claire K. Naughtin (2015, UQ)
    %
    % RUN CODE ----------------------------------------------------------------
    
    %%
    
    stand_alone = 0;
    
    if stand_alone ==1
        
    else
        filename=strcat('Current_subject.txt');
        cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
        ActiveData=dlmread(filename);
        subject_number = ActiveData(1,1);
        session_number = ActiveData(1,2);
        cd('Go_no_Go_MW')
    end
    
    Screen('Preference', 'SkipSyncTests', 1);
    
    %clc
%     display('running Go no-go task...');
    display(sprintf('\n %%%%%%%%%%%%%%   running Go-no-go task ... %%%%%%%%%%%%%%%% \n'));

    %clear all;
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
    computer_used = 1; % 1= Dux lab iMac, 2= Dux lab testing mini, 3= Claire's personal laptop, 4= Dux lab PC laptop
    
    % define cheats for display speeds
    duration_speed = 1; % set to 1 for normal speed,< 1 = fast,> 1 = slow
    DummyMode = 0;

    % VARIABLES ---------------------------------------------------------------
    
    % display details
    screen_resolution = [1024 768];
    refresh_rate = 100;
    screen_specs_description = {'The current screen settings are incorrect for testing.';...
        '';...
        'Screen Resolution: %d x %d';...
        'Refresh Rate: %d Hz';...
        '';...
        '(c)ontinue with current settings or (t)erminate?'};
    
    % condition details
    % 1= go trial
    % 2= no-go trial
    condition_names = {'go_trial','nogo_trial'};
    
    % duration details
    duration_first_fixation = 2*duration_speed; % present initial pause at the start of each block
    duration_fixation = .2:.01:.6; % jittered fixation time - do this (500 ms?)
    duration_stimuli = .2*duration_speed; % do this (500 ms?)
    duration_response = 1.8*duration_speed;
    duration_feedback = .5*duration_speed;
    
    % trial details
    n_trials = [24 144]; % n_trials(1) = number of practice trials,n_trials(2)= number of test trials
    n_blocks = [1 4]; % n_blocks(1)= number of practice blocks; n_blocks(2)= number of test blocks
    
    % colour details
    colour_background = [128 128 128];
    colour_text = [0 0 0];
    
    % size details
    size_stimuli_pix = [100 100] ./2;
    
    % text details
    font = 'Arial';
    task_instructions = {'Your task is to press the "G" key whenever';...
        'you see the "GO" shape as quickly and accurately as you can.';...
        '';...
        'On some trials, a "NO-GO" shape will instead appear.';...
        'On these trials, you should try your best to STOP yourself from responding.';...
        'Occasionally, you will be prompted to indicate the extent you have experienced task unrelated thoughts.';...
        'Please use the numbers 1-7 to indicate task the level of task unrelated thoughts.';...
        'Press the space key to begin %s block.'}; % these instructions can be editted, but keep same format (ie., all in one cell matrix) and the final line need to stay the same
    shape_types = {'"GO" shape','"NO-GO" shape'};
    start_trial_prompt = 'Press the space key to begin %s block.';
    error_feedback = {'Correct!','Incorrect...','Too slow to respond...','Try to withhold your response...'};
    task_types = {'practice','test'};
    line_spacing = 45;
    goodbye_prompt = {'Please notify the experimenter.','Press the space key to continue.'};
    prac_goodbye_prompt = {'Please notify the experimenter to move on to the test.'};
    response_feedback = {'Well done! You''ve just completed block %d of %d!';...
        '';...
        'Accuracy: %.f %%';...
        'Response Time: %.f ms';...
        '';...
        '%s'};
    
    % stimuli details
    shape_stimuli = {'smoothie','spiky'};
    image_format = 'jpg';
    proportion_of_nogo_trials = .25; % 25% of trials will contain the nogo signal
    
    %TUT probe text
    TUT_Text_1 = 'To what extent have you experienced task unrelated';
    TUT_Text_2 = 'thoughts prior to the thought probe?';
    TUT_Text_3 = '1 (minimal) - 7 (maximal)';
    
    % response keys
    response_keys_to_use = 'g';
    n_familarisation_loops = 4;
    T1 = KbName('1'); T2 = KbName('2'); T3 = KbName('3'); T4 = KbName('4'); T5 = KbName('5'); T6 = KbName('6'); T7 = KbName('7');
    
    key_press = 0;
    probe_key = 0;
    ProbeRT = 0;
    MW_response_made = 0;
    
    % SETUP EXPERIMENT --------------------------------------------------------
    
    % implement computer used settings
    if computer_used == 1 % lab iMac
        font_size = 35;
        refresh_rate = 0;
        disp('Computer set for Dux lab iMac');
    elseif computer_used == 2 % Dux lab testing computer
        font_size = 25;
%         disp('Computer set for Dux lab mac mini computer with ASUS monitor');
        screen_resolution = [1920 1080]; % for ASUS monitors
        refresh_rate = 60;
    elseif computer_used == 3 % Claire's personal laptop
        font_size = 30;
        screen_resolution = [1280 800]; % over-write screen resolution as my personal laptop cannot display 1024 x 768 resolution
        refresh_rate = 0; % over-write screen resolution as my personal laptop cannot display at 100Hz
        disp('Computer set for personal laptop');
    elseif computer_used == 4 % Dux lab PC laptop
        font_size = 30;
        disp('Computer set for Dux lab PC laptop');
    elseif computer_used == 5
        font_size = 20;
        screen_resolution = [1920 1080]; % for ASUS monitors
        refresh_rate = 60;%100;
        disp('Computer set forAbbey retina laptop');
    end
    
    %% enter subject details
    
    if stand_alone == 1
       subj_number = input('Subject Number (Enter "0" for no logfile): ');
        session_number = input('Session Number?');
    else
        subj_number = subject_number;
       session_number = session_number;
    end
    
    date_time = fix(clock);
    
    %% define which response hand condition this participant is in
    if mod(subj_number,2) == 1 % for odd subjects, assign them to the first go-nogo condition (go= star, nogo= yinyang)
        nogo_symbol_condition = 1;
    elseif mod(subj_number,2) == 0 % for odd subjects, assign them to the second go-nogo condition (go= yinyang, nogo= star)
        nogo_symbol_condition = 2;
    end
    
    % define which symbol is the nogo signal
    if nogo_symbol_condition == 1 % if the first stimulus is the nogo symbol...
        go_symbol_ID = 1;
        nogo_symbol_ID = 2;
    elseif nogo_symbol_condition == 2 % % if the second stimulus is the nogo symbol...
        go_symbol_ID = 2;
        nogo_symbol_ID = 1;
    end
    
    % open a screen
    HideCursor;
    ListenChar(2); % supress 
    AssertOpenGL; Screen('Preference', 'SkipSyncTests', 1);
    
    my_screens = Screen('Screens');
    screen_number = max(my_screens);
    current_resolution = Screen('Resolution',screen_number);
    [w_screen,w_rect] = Screen('OpenWindow',screen_number);
    Screen(w_screen,'Flip'); % do an initial flip so that you draw on background and not on programming screen
    Screen(w_screen,'FillRect',colour_background,w_rect);
    Screen(w_screen,'Flip');
    Screen(w_screen,'FillRect',colour_background,[]);
    
    % Hack
    if computer_used == 5
        current_resolution.width = current_resolution.width/4;
        current_resolution.height = current_resolution.height/4;
    end
    
    % determine size and position of stimuli
    [~,center_y] = RectCenter(w_rect); %  coordinates start from top left corner [0,0]
    
    % ...for instructions screen
    size_instructions = [0 0 current_resolution.width current_resolution.height]; % make run_instructions take up entire screen
    present_instructions = CenterRect(size_instructions,w_rect); % present instructions in center of the screen
    
    % ...for stimuli screen
    size_stimuli = [0 0 size_stimuli_pix];
    present_stimuli = CenterRect(size_stimuli,w_rect); % present stimuli in center of the screen
    
    % create the generic stimulus screens
    
    % ...for fixation cross screen
    disp_fixation = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
    Screen('TextFont',disp_fixation,font);
    Screen('TextStyle',disp_fixation,1);
    Screen('TextSize',disp_fixation,font_size);
    DrawFormattedText(disp_fixation,'+','Center','Center',colour_text,115);
    
    % ...for shape screens
    for shape_count = 1:length(shape_stimuli)
        shape_handle{shape_count} = imread([shape_stimuli{shape_count} '.' image_format],image_format);
        disp_shape(shape_count) = Screen('OpenoffscreenWindow',w_screen,colour_background,size_stimuli);
        Screen(disp_shape(shape_count),'FillRect',colour_background,size_stimuli);
        Screen(disp_shape(shape_count),'PutImage',shape_handle{shape_count},size_stimuli);
    end
    
    % ...for hand response mapping screen
    for key_count = 1:length(shape_stimuli)
        disp_mappings(key_count) = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_mappings(key_count),font);
        Screen('TextStyle',disp_mappings(key_count),1);
        Screen('TextSize',disp_mappings(key_count),font_size);
        if key_count == 1
            DrawFormattedText(disp_mappings(key_count),[shape_types{key_count} ' - Press "' upper(response_keys_to_use) '" key'],'Center',center_y-line_spacing*2,colour_text,115); % only put quotation marks for "go" key
        else
            DrawFormattedText(disp_mappings(key_count),[shape_types{key_count} ' - DO NOT press any key'],'Center',center_y-line_spacing*2,colour_text,115);
        end
    end
    
    % ...for response feedback screens
    for feedback_count = 1:length(error_feedback)
        disp_feedback(feedback_count) = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_feedback(feedback_count),font);
        Screen('TextStyle',disp_feedback(feedback_count),1);
        Screen('TextSize',disp_feedback(feedback_count),font_size);
        DrawFormattedText(disp_feedback(feedback_count),error_feedback{feedback_count},'Center','Center',colour_text,115);
    end
    
    %% PRACTICE/TEST LOOP ------------------------------------------------------
    
    for version_count = 1:length(task_types)
        
        % reset data matrix so that only test data is stored
        clear data
%         if version_count == 2 && session_number == 1 % if you started at the practice, and it's the next version, update this so it saves below
%             session_number = 2;
%         end
        % add input data to data structure
        data.screen_specifications = current_resolution;
        data.subject_no = subj_number;
        data.date_time = date_time;
        data.session_number = session_number;
        data.go_symbol = shape_stimuli{go_symbol_ID};
        data.nogo_symbol = shape_stimuli{nogo_symbol_ID};
        data.response_keys_to_use = response_keys_to_use;
        
        
        % create string ID for subject number
        if subj_number < 10 % for subject numbers < 10 only
            subject_number_string = ['00' num2str(subj_number)];
        elseif subj_number < 100 % for subject numbers < 10 only
            subject_number_string = ['0' num2str(subj_number)];
        else
            subject_number_string = num2str(subj_number);
        end
        
        % logfile
        if version_count == 2
        subj_data_file_temp = sprintf('data_logfile_exp_EFIL_sub_%s_GNG_session_%s', subject_number_string, num2str(session_number));

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
        end
        
        % determine trial type order
        n_trials_per_block = n_trials(version_count)/n_blocks(version_count);
        n_nogo_trials = n_trials_per_block*proportion_of_nogo_trials; % determine proportion of trials that will be nogo trials
        n_go_trials = n_trials_per_block-n_nogo_trials; % the remaining trials will all be go trials
        n_MW_trials = 3;
        for block_count = 1:n_blocks(version_count) % for each block...
            temp_trial_type_order = []; % create an empty matrix to fill the trial types for each block
            for go_count = 1:n_go_trials % for each go trials...
                temp_trial_type_order = [temp_trial_type_order 1]; % add this condition number to temporary version of trial order matrix
            end
            for nogo_count = 1:n_nogo_trials % for each nogo trial...
                temp_trial_type_order = [temp_trial_type_order 2]; % add this condition number to temporary version of trial order matrix
            end
            data.trial_type_order(1:length(temp_trial_type_order),block_count) = Shuffle(temp_trial_type_order); % shuffle the trial order for this block and save in data structure
        end
        
        % create remaining stimulus screens
        
        % ...for task instruction screen
        temp_task_instructions = task_instructions; % make a copy of task instructions so that they can be editted in each version loop
        temp_task_instructions{end} = sprintf(task_instructions{end},task_types{version_count});
        disp_task_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_task_instructions,font);
        Screen('TextStyle',disp_task_instructions,1);
        Screen('TextSize',disp_task_instructions,font_size);
        n_lines_above_center = ceil(length(temp_task_instructions)/2);
        n_lines_below_center = length(temp_task_instructions) - n_lines_above_center;
        line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
        for line_count = 1:size(temp_task_instructions,1)
            DrawFormattedText(disp_task_instructions,temp_task_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
        end
        
        % ...for prompt at the start of each trial
        disp_start_prompt = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
        Screen('TextFont',disp_start_prompt,font);
        Screen('TextStyle',disp_start_prompt,1);
        Screen('TextSize',disp_start_prompt,font_size);
        DrawFormattedText(disp_start_prompt,sprintf(start_trial_prompt,task_types{version_count}),'Center','Center',colour_text,115);
        
        % do initial save to create logfile
        if subj_number && version_count == 2 % only save data for test blocks
            % add updated data matrix to logfile
            save(subj_data_filename,'data');
        end
        
        %% START EXPERIMENT ----------------------------------------------------
        
        % present experimental instructions
        WaitSecs(.5*duration_speed);
        Screen('CopyWindow',disp_task_instructions,w_screen,[],present_instructions,[]);
        Screen(w_screen,'Flip');
        key_found = 0;
        if ~DummyMode
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
        else
            FlushEvents('keyDown');
            key_found = 1;
        end
        
        %% BLOCK LOOP ----------------------------------------------------------
        
        for block_count = 1:n_blocks(version_count)
            
            duration_saved = 0; % reset this variable at the start of each block
            
            if version_count == 1
                Position1 = 20;
            elseif version_count == 2 %decide on MW prompt locations
                p=randperm(5); p2 = [1 -1]; p2 = Shuffle(p2);
                Position1 = ((n_trials(2)/n_blocks(2))/3)+(p(1)*p2(1));
                p=randperm(5); p2 = [1 -1]; p2 = Shuffle(p2);
                Position2 = (((n_trials(2)/n_blocks(2))/3)*2)+(p(1)*p2(1));
            end;
            
            %% TRIAL LOOP ------------------------------------------------------
            
            for trial_count = 1:n_trials_per_block
                
                % reset these variables at the start of each trial
                key_found = 0;
                ProbeRT = 0;
                probe_key = 0;
                MW_response_made = NaN;
                
                % determine duration of fixation cross (it is jittered across trials)
                possible_fixation_durations = Shuffle(duration_fixation);
                current_fixation_duration = possible_fixation_durations(1);
                
                % before first trial, present response mappings
                if trial_count == 1 && block_count == 1
                    
                    for loop_count = 1:n_familarisation_loops
                        
                        shape_stimuli_IDs = [go_symbol_ID nogo_symbol_ID]; % always show go stimulus then no-go stimulus in familiarisation
                        
                        for key_count = 1:length(shape_stimuli_IDs)
                            
                            mapping_key_found = 0;
                            
                            % present symbol
                            correct_key_response = response_keys_to_use;
                            Screen('CopyWindow',disp_mappings(key_count),w_screen,[],present_instructions,[]);
                            Screen('CopyWindow',disp_shape(shape_stimuli_IDs(key_count)),w_screen,[],present_stimuli,[]);
                            Screen(w_screen,'Flip');
                            
                            % poll keyboard for first stimulus response
                            if ~DummyMode
                                if key_count == 1
                                    while ~mapping_key_found
                                        [key_is_down,~,key_code] = KbCheck;
                                        if key_is_down == 1 && mapping_key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                                            keys_pressed = find(key_code);
                                            mapping_key = KbName(keys_pressed(1));
                                            if strcmp(mapping_key,correct_key_response) % if one of the possible response keys was pressed
                                                FlushEvents('keyDown');
                                                mapping_key_found = 1; % accept this key response and start trial
                                            end
                                        end
                                    end
                                    WaitSecs(.5*duration_speed);
                                else
                                    WaitSecs(2*duration_speed);
                                end
                            else
                                mapping_key_found = 1; % accept this key response and start trial
                                mapping_key = 'g';
                                FlushEvents('keyDown');
                            end
                            
                        end
                    end
                    
                    % wait for participant to press spacebar to initiate first trial
                    WaitSecs(.1*duration_speed);
                    Screen('CopyWindow',disp_start_prompt,w_screen,[],present_instructions,[]);
                    Screen(w_screen,'Flip');
                    if ~DummyMode
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
                    else
                        key_found = 1; % accept this key response and start trial
                    end
                            
                    % present initial fixation cross on the first trial
                    Screen('CopyWindow',disp_fixation,w_screen,[],present_stimuli,[]);
                    Screen(w_screen,'Flip');
                    block_onset = GetSecs;
                    while ((GetSecs - block_onset) <= duration_first_fixation); end;
                end
                
                % present fixation cross
                Screen('CopyWindow',disp_fixation,w_screen,[],present_stimuli,[]);
                Screen(w_screen,'Flip');
                trial_onset = GetSecs;
                while ((GetSecs - trial_onset) <= current_fixation_duration); end;
                
                % calculate and save duration of first fixation (only do this once)
                if ~duration_saved
                    data.first_fix_duration(block_count,1) = trial_onset-block_onset;
                    duration_saved = 1; % register that the first fixation duration has been saved
                end
                
                % present symbol
                key_found = 0;
                if data.trial_type_order(trial_count,block_count) == 1 % for go trials...
                    Screen('CopyWindow',disp_shape(go_symbol_ID),w_screen,[],present_stimuli,[]); % present go shape
                elseif data.trial_type_order(trial_count,block_count) == 2 % for no-go trials...
                    Screen('CopyWindow',disp_shape(nogo_symbol_ID),w_screen,[],present_stimuli,[]); % present np-go shape
                end
                Screen(w_screen,'Flip');
                stim_onset = GetSecs;
                while (GetSecs - stim_onset) <= duration_stimuli
                    
                    % poll keyboard for first stimulus response
                    if ~DummyMode
                        if ~key_found
                            [key_is_down,time_in_secs,key_code] = KbCheck;
                            if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                                keys_pressed = find(key_code);
                                response_key = KbName(keys_pressed(1));
                                FlushEvents('keyDown');
                                key_found = 1; % accept this key response and start trial
                            end
                        end
                    else
                        key_found = 1; % accept this key response and start trial
                        response_key = 'g';
                        time_in_secs = GetSecs;
                    end
                    
                end
                
                % present fixation for the remaining time
                Screen('CopyWindow',disp_fixation,w_screen,[],present_stimuli,[]);
                Screen(w_screen,'Flip');
                delay_onset = GetSecs;
                while (GetSecs - delay_onset) <= duration_response
                    
                    % poll keyboard for first stimulus response
                    if ~DummyMode
                        if ~key_found
                            [key_is_down,time_in_secs,key_code] = KbCheck;
                            if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                                keys_pressed = find(key_code);
                                response_key = KbName(keys_pressed(1));
                                FlushEvents('keyDown');
                                key_found = 1; % accept this key response and start trial
                            end
                        end
                    else
                        key_found = 1; % accept this key response and start trial
                        response_key = 'g';
                        time_in_secs = GetSecs;
                    end
                end
                
                % calculate accuracy, reaction time and the appropriate feedback to give the participant based on their response (or lack of response)
                if key_found
                    data.response_key{trial_count,block_count} = response_key;
                    if data.trial_type_order(trial_count,block_count) == 1 % for go trials...
                        if strcmp(data.response_key{trial_count,block_count},response_keys_to_use) % if the key matches the corresponding shape...
                            data.accuracy(trial_count,block_count) = 1; % record as correct response
                            data.response_type{trial_count,block_count} = error_feedback{1}; % correct response
                            data.response_type_ID(trial_count,block_count) = 1; % correct response
                        else
                            data.accuracy(trial_count,block_count) = 0;
                            data.response_type{trial_count,block_count} = error_feedback{2}; % incorrect response
                            data.response_type_ID(trial_count,block_count) = 2; % incorrect response
                        end
                        data.nogo_reaction_time(trial_count,block_count) = 0;
                        data.go_reaction_time(trial_count,block_count) = time_in_secs-stim_onset;
                    elseif data.trial_type_order(trial_count,block_count) == 2 % for no go trials...
                        data.accuracy(trial_count,block_count) = 0; % any response is an incorrect response, as no response should have been made
                        data.response_type{trial_count,block_count} = error_feedback{4}; % erroneous response
                        data.response_type_ID(trial_count,block_count) = 4; % erroneous response
                        data.nogo_reaction_time(trial_count,block_count) = time_in_secs-stim_onset;
                        data.go_reaction_time(trial_count,block_count) = 0;
                    end
                else % otherwise, if no key was found
                    data.response_key{trial_count,block_count} = 0;
                    if data.trial_type_order(trial_count,block_count) == 1 % for go trials...
                        data.accuracy(trial_count,block_count) = 0;
                        data.response_type{trial_count,block_count} = error_feedback{3}; % no response detected
                        data.response_type_ID(trial_count,block_count) = 3; % no response detected
                    elseif data.trial_type_order(trial_count,block_count) == 2 % for no go trials...
                        data.accuracy(trial_count,block_count) = 1; % record as correct response
                        data.response_type{trial_count,block_count} = error_feedback{1}; % correct response
                        data.response_type_ID(trial_count,block_count) = 1; % correct response
                    end
                    data.nogo_reaction_time(trial_count,block_count) = 0;
                    data.go_reaction_time(trial_count,block_count) = 0;
                end
                
                % display feedback
                if version_count == 1
                    Screen('CopyWindow',disp_feedback(data.response_type_ID(trial_count,block_count)),w_screen,[],present_instructions,[]);
                    Screen(w_screen,'Flip');
                    feedback_onset = GetSecs;
                    while ((GetSecs - feedback_onset) <= duration_feedback); end
                end
                
                
            %add in MW prompts
             if version_count == 1
                 if trial_count == Position1
                     key_press = 0;
                    ProbeRT = 0;
                    probe_key = 0;
                    probe_key_response1 = '1'; probe_key_response2 = '2'; probe_key_response3 = '3'; probe_key_response4 = '4'; probe_key_response5 = '5'; probe_key_response6 = '6'; probe_key_response7 = '7';

                    DrawFormattedText(w_screen, TUT_Text_1, 'center', ((768/2)-50));
                    DrawFormattedText(w_screen, TUT_Text_2, 'center', 'center');
                    DrawFormattedText(w_screen, TUT_Text_3, 'center', ((768/2)+50));
                    Screen('Flip', w_screen); ProbeTimeNow=GetSecs;
                    while key_press==0
                        [key_is_down,~,key_code] = KbCheck;
                        if key_is_down == 1 && key_press == 0 % if a key is pressed and if this is the first key that has been pressed...
                            keys_pressed = find(key_code);
                            probe_key = KbName(keys_pressed(1));
                            if strcmp(probe_key,probe_key_response1) || strcmp(probe_key,probe_key_response2) || strcmp(probe_key,probe_key_response3) || strcmp(probe_key,probe_key_response4) || strcmp(probe_key,probe_key_response5) || strcmp(probe_key,probe_key_response6) || strcmp(probe_key,probe_key_response7)% if one of the possible response keys was pressed
                                FlushEvents('keyDown');
                                ProbeRT = GetSecs - ProbeTimeNow;
                                key_press = 1; % accept this key response and start trial
                            end
                        end
                    end;   
                    tic; while toc<0.5; end
                 end;
             elseif version_count == 2
                 if trial_count == Position1 || trial_count == Position2 
                    key_press = 0;
                    ProbeRT = 0;
                    probe_key = 0;
                    probe_key_response1 = '1'; probe_key_response2 = '2'; probe_key_response3 = '3'; probe_key_response4 = '4'; probe_key_response5 = '5'; probe_key_response6 = '6'; probe_key_response7 = '7';

                    DrawFormattedText(w_screen, TUT_Text_1, 'center', ((768/2)-50));
                    DrawFormattedText(w_screen, TUT_Text_2, 'center', 'center');
                    DrawFormattedText(w_screen, TUT_Text_3, 'center', ((768/2)+50));
                    Screen('Flip', w_screen); ProbeTimeNow=GetSecs; resp_detected = 0;
                    while key_press==0
                        [key_is_down,~,key_code] = KbCheck;
                        if key_is_down == 1 && key_press == 0 % if a key is pressed and if this is the first key that has been pressed...
                            keys_pressed = find(key_code);
                            probe_key = KbName(keys_pressed(1));
                            MW_response_made = 0;
                            if strcmp(probe_key,probe_key_response1) 
                                MW_response_made = 1; 
                            elseif strcmp(probe_key,probe_key_response2) 
                                MW_response_made = 2;
                            elseif strcmp(probe_key,probe_key_response3) 
                                MW_response_made = 3;
                            elseif strcmp(probe_key,probe_key_response4) 
                                MW_response_made = 4;
                            elseif strcmp(probe_key,probe_key_response5) 
                                MW_response_made = 5;
                            elseif strcmp(probe_key,probe_key_response6) 
                                MW_response_made = 6;
                            elseif strcmp(probe_key,probe_key_response7)
                                MW_response_made = 7;
                            end
                            if MW_response_made > 0;
                                FlushEvents('keyDown');
                                ProbeRT = GetSecs - ProbeTimeNow;
                                key_press = 1; % accept this key response and start trial
                            end
                        end
                    end;
                    tic; while toc<0.5; end
                end;
            end;
                 
   
                trial_offset = GetSecs;
                
                % add remaining data values in structure
                data.trial_no(trial_count,1) = trial_count;
                data.block_no(block_count,1) = block_count;
                data.trial_type_name{trial_count,block_count} = condition_names{data.trial_type_order(trial_count,block_count)};
                data.current_fixation_duration(trial_count,block_count) = current_fixation_duration;
                data.trial_duration(trial_count,block_count) = trial_offset-trial_onset;
                data.fixation_duration(trial_count,block_count) = stim_onset-trial_onset;
                data.stim_duration(trial_count,block_count) = delay_onset-stim_onset;
                data.delay_duration(trial_count,block_count) = feedback_onset-delay_onset;
                data.feedback_duration(trial_count,block_count) = trial_offset-feedback_onset;
                data.mindWanderingProbe(trial_count,block_count) = MW_response_made;
                data.mindWanderingRT(trial_count,block_count) = ProbeRT;
                
                % save data
                if subj_number && version_count == 2 % only save data for test blocks
                    % add updated data matrix to logfile
                    save(subj_data_filename,'data','-append');
                end
                
            end % END OF TRIAL LOOP -------------------------------------------
            %%
            % save block duration data
            block_offset = GetSecs;
            data.block_duration(block_count,1) = block_offset-block_onset;
            if subj_number && version_count == 2 % only save data for test blocks
                % store additional details in data matrix
                save(subj_data_filename,'data','-append');
            end
            
            % calculate mean accuracy and reaction time across entire block
            overall_block_accuracy = mean(data.accuracy(:,block_count))*100; % calculate mean accuracy
            go_trial_IDs = find(data.trial_type_order(:,block_count) == 1);
            correct_go_trial_IDs = find(data.accuracy(go_trial_IDs,block_count) == 1);
            if isempty(correct_go_trial_IDs)
                overall_block_RT = 0;
            else
                overall_block_RT = mean(data.go_reaction_time(go_trial_IDs(correct_go_trial_IDs),block_count))*1000; % calculate mean reaction time (in ms) for correct 'go'trials only
            end
            
            % create response feedback with updated response data
            disp_feedback = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
            Screen('TextFont',disp_feedback,font);
            Screen('TextStyle',disp_feedback,1);
            Screen('TextSize',disp_feedback,font_size);
            n_lines_above_center = ceil(length(response_feedback))/2;
            n_lines_below_center = length(response_feedback) - n_lines_above_center;
            line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
            DrawFormattedText(disp_feedback,sprintf(response_feedback{1},block_count,n_blocks(version_count)),'Center',line_positions_y(1),colour_text,115);
            DrawFormattedText(disp_feedback,response_feedback{2},'Center',line_positions_y(2),colour_text,115);
            DrawFormattedText(disp_feedback,sprintf(response_feedback{3},overall_block_accuracy),'Center',line_positions_y(3),colour_text,115);
            DrawFormattedText(disp_feedback,sprintf(response_feedback{4},overall_block_RT),'Center',line_positions_y(4),colour_text,115);
            DrawFormattedText(disp_feedback,response_feedback{5},'Center',line_positions_y(5),colour_text,115);
             
            
            if version_count == 1
                          
                DrawFormattedText(disp_feedback,sprintf(response_feedback{6},prac_goodbye_prompt{1}),'Center',line_positions_y(6),colour_text,115); % display "continue" prompt
% present response feedback screen
                WaitSecs(.5*duration_speed);
                Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]);
                Screen(w_screen,'Flip');
                
                 % return - add secret key
                    if DummyMode == 0
                        KbQueueRelease; %forgets previous Queue that was created - so you can define new keys???
                        %RestrictKeysForKbCheck([]);
                        secret_key = 'p';
                        %RestrictKeysForKbCheck(KbName(secret_key));
                        key_found = 0;
                        while ~key_found
                            [key_is_down,~,key_code] = KbCheck;
                            if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                                keys_pressed = find(key_code);
                                response_key = KbName(keys_pressed(1));
                                if strcmp(response_key,secret_key) % if the spacebar was pressed
                                    FlushEvents('keyDown');
                                    key_found = 1; % accept this key response and start trial
                                end
                            end
                        end
                    elseif DummyMode == 1
                        % don't wait, just keep going
                    end
                  %  RestrictKeysForKbCheck([]);
                   % RestrictKeysForKbCheck([KbName('space'), KbName(response_keys_to_use)]);
                                            
            elseif version_count == 2 && block_count ~= n_blocks(version_count) % if it's not the last block...
                DrawFormattedText(disp_feedback,sprintf(response_feedback{6},goodbye_prompt{2}),'Center',line_positions_y(6),colour_text,115); % display "continue" prompt
                % present response feedback screen
                WaitSecs(.5*duration_speed);
                Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]);
                Screen(w_screen,'Flip');
                if DummyMode == 0
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
                elseif DummyMode == 1
                    % don't wait, just keep going
                end
            else %if version_count == 2 % for the last block:
                DrawFormattedText(disp_feedback,sprintf(response_feedback{6},goodbye_prompt{1}),'Center',line_positions_y(6),colour_text,115); % display "get experimenter" prompt
                % present response feedback screen
                WaitSecs(.5*duration_speed);
                Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]);
                Screen(w_screen,'Flip');
                if DummyMode == 0
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
                elseif DummyMode == 1
                    % don't wait, just keep going
                end
            end
                        
        end % END OF BLOCK LOOP -----------------------------------------------
        
    end % END OF PRACTICE/TEST LOOP -------------------------------------------
    
    % END OF EXPERIMENT -------------------------------------------------------
    
    % close matlab
    %cd(parent_folder);
    ShowCursor;
    ListenChar(); % Allow keyboard inputs to command line
    FlushEvents('keyDown');
    Screen('CloseAll');
    close all
    
catch ME
    ListenChar(); % Allow keyboard inputs to command line
    ShowCursor;
    Screen('CloseAll');
    commandwindow;
    rethrow(ME); % pri
end
end

