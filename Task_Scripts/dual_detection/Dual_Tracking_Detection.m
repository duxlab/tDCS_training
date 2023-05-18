function Dual_Tracking_Detection

% FUNCTION DETAILS --------------------------------------------------------

% This script runs a dual tracking tracking and visual detection task.
% Participants have to track a visual stimulus with a mouse while
% simultaneously monitoring for a to-be-detected shape.

% Written by Dr. Claire K. Naughtin & Angela Bender (2015, UQ)

% Edited by HF (Sept 2019)

% RUN CODE ----------------------------------------------------------------

stand_alone = 0;
if stand_alone == 1
    %clear all
else
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject_number = ActiveData(1,1);
    session_number = ActiveData(1,2);
    Tracking_Thresholding_Value = ActiveData(1,9);
    Detection_Threshold_Value = ActiveData(1,10);
    cd('Dual_Tracking_Detection')
end

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
computer_used = 3; % 1= work iMac, 2= lab iMac, 3= lab testing mini, 4= scanner LCD, 5= eye-tracker lab LCD, 6 = lap mac laptop, 7= personal laptop, 8= PC laptop, 9= Psychology EEG lab, 10= Claire's laptop

% define cheats for display speeds
duration_speed = 1; % set to 1 for normal speed,< 1 = fast,> 1 = slow

% make all tracking stimuli visible or not
all_tracking_stim_visible = 0; % set to 1 to show all tracking stimuli, set to 0 to only show single tracking stimulus (for experimental purposes)

% define whether to use staircasing procedure
use_staircasing = 1; % set to 1 to implement staircasing, set to 0 to turn off staircasing
check_staircasing = 1; % set to 1 to produce output to check staircasing, set to 0 to turn off output

% check if logfile already exists
file_checking = 1; % set to 1 to check for existing participant logfile, set to 0 to turn off this check

% VARIABLES ---------------------------------------------------------------

% display details
desired_screen_resolution = [1920 1080];
desired_refresh_rate = 60;

% logfile details
logfile_template = 'logfile_single_vs_test_task_sub%d_session_%d.mat';

condition_names = {'single_tracking','single_detection','dual_task'};

% trial details
n_trials_per_block = [9 15]; % n_trials_per_block(1)= number of practice trials; n_trials_per_block(2)= number of test trials
n_blocks = [2 1]; % n_blocks(1)= number of practice block_numbers; n_blocks(2)= number of test block_numbers
final_session = 8;

% duration details (in secs)
duration_first_fixation = 2*duration_speed; % present initial pause at the start of each block
duration_motion = [20 20 30]*duration_speed; %%% TRIAL DURATIONS
duration_detection_shape = .4*duration_speed;
duration_shape_ITI = [1.6 2.1 2.6]*duration_speed; % these ITIs are calculated relative to the current shape duration, e.g., the first ITI equals 1.6 s when the shape appears for 0.4 s (balanced across presentations) (CKN)
duration_feedback = .5*duration_speed;

% colour details
colour_background = [128 128 128];
colour_text = [0 0 0];
colour_error = [255 0 0];

% tracking task details
n_objects = 2;
tracking_stim_line_thickness = 7;
motion_trajectory_dir = '/motion trajectory files';
motion_trajectory_filename = 'trajectory_%d_objs_%.3f_dps_res_%dx%d*.mat';

% detection task details
shape_names = {'square','hexagon','star'};
colour_names = {'red','green','blue','yellow'};
shape_filename = '%s.png';
n_shapes_per_trial = [8 8 12];  %%%%NUMBER OF SHAPES
min_frame_onset = 1; % in seconds
max_time_onset = 0; % in seconds
proportion_detection_targets_per_trial = .5; % 50% of shape presentations will be the target shape; note. if this does not equal a whole number, this value will be rounded up

% size details
size_tracking_stim_deg = 5;
size_shape_stim_deg = 4;
size_cursor_deg = 1;
size_fix_deg = .4;

% response keys
detection_response_key = 'space';
response_types = {'hit','late','miss','FA','CR'};

% text details
standard_font = 'Arial';
line_spacing = 45; % number of pixels between each line position

% instruction details
version_types = {'practice','test'};
task_block_types = {'tracking only','detection only','dual task'};
task_descriptions = {'track the moving disc with your MOUSE CURSOR',...
                     'Please IGNORE the central shape stimuli.'...
                     'press the SPACEBAR when a target shape appears',...
                     'Please IGNORE the moving circle stimulus.'};
general_instructions = {'Welcome! In this experiment you will complete 2 different types of tasks.';...
    '';...
    'In the TRACKING Task, track the moving disc with your MOUSE CURSOR.';...
    'In the DETECTION task, press the SPACEBAR when a target shape appears.';...
    'In the DUAL task, complete the TRACKING and DETECTION task simultaneously.';...
    '';...
    'Please be as quick and accurate as possible when tracking the disc';...
    'and/or monitoring for the target shape.';...
    '';...
    'Press the spacebar to start the practice blocks.'};
testing_phase_instructions = {'Well done! You have completed the practice phase!';...
    '';...
    'In the test phase, you will complete a mixture of tracking only trials, ';...
    'shape detection only trials, or dual-task trials.';...
    '';...
    'You will be instructed on what task to complete at the start of each trial.';...
    '';...
    'Press the spacebar to start the test blocks.'};
trial_instructions = {'This is a %s trial';...
    '';...
    'In this trial, you will %s.';... % string variable corresponds to task_block_types
    '%s';...
    '';...
    'Please respond as quickly and accurately as possible.';...
    '';...
    'Press the spacebar to begin this block.'};
detection_instructions = {'Press the SPACEBAR whenever you see this target shape.', 'Press the space key to continue.'};
dual_instructions = {'Remember to track the target disc as accurately as possible, AND';...
    'Press the SPACEBAR whenever you see this target shape.'};
end_of_block_instructions = {'End of block %d of %d';...
                              '';...
                              '%s'};
final_session_instructions = 'Welcome! This is the final session of this experiment!';
goodbye_prompt = {'Please notify the experimenter.','Press the space key to continue.'};
response_feedback = {'Tracking Accuracy: %.f %%';...
    'Shape Detection Accuracy: %.f %%';...
    'Shape Detection Response Time: %.f ms';...
    '';...
    'Press spacebar to start the next trial.'};

% staircasing details
median_acc_score = 80; % in percentage
min_acc_cut_off = 77.5; % in percentage
max_acc_cut_off = 82.5; % in percentage
acc_step_increment = 1.75; % in percentage
starting_step = 35; % starting step for shape repsonse durations and object tracking speed WAS 29 CHANGED TO 32 DEC 2019
possible_duration_shape_response = [1:-.025:.55,.54:-.01:.25]; % in ms
possible_tracking_stimulus_speed = [.01:.004:.082,.083:.001:.112]; % in dps

% SET UP EXPERIMENT -------------------------------------------------------

% implement computer used settings
if computer_used == 1 % work iMac
    screen_size_cm = [47.6 26.6];
    viewing_distance_cm = 50;
    standard_font_size = 35;
    disp('Computer set for Work iMac');
elseif computer_used == 2 % lab iMac
    screen_size_cm = [47.5 26.5];
    viewing_distance_cm = 50;
    standard_font_size = 35;
    disp('Computer set for Lab iMac');
elseif computer_used == 3 % duxlab testing computer
    screen_size_cm = [39.9 29.6];
    viewing_distance_cm = 50;
    standard_font_size = 25;
    disp('Computer set for Duxlab testing computer');
elseif computer_used == 4 % scanner LCD
    screen_size_cm = phys_3T_screen_size_cm;
    viewing_distance_cm = 106; % new viewing distance (previously 90cm)
    standard_font_size = 15;
    disp('Computer set for 3T Scanner LCD');
elseif computer_used == 5 % eye-tracker lab LCD
    screen_size_cm = [37.5 30];
    viewing_distance_cm = 67;
    standard_font_size = 15;
    disp('Computer set for Eye-tracker lab testing computer');
elseif computer_used == 6 % mac laptop
    screen_size_cm = [27.7 20.7];
    viewing_distance_cm = 50;
    standard_font_size = 15;
    disp('Computer set for Mac laptop');
elseif computer_used == 7 % personal laptop
    screen_size_cm = [28.8 18];
    viewing_distance_cm = 50;
    standard_font_size = 30;
    desired_screen_resolution = [1440 900]; % over-write screen resolution as my personal laptop cannot display 1024 x 768 resolution
    desired_refresh_rate = 60;
    disp('Computer set for personal laptop');
elseif computer_used == 8 % PC laptop
    screen_size_cm = [23.3 17.4];
    viewing_distance_cm = 50;
    standard_font_size = 30;
    disp('Computer set for PC laptop');
elseif computer_used == 9 % Psychology EEG lab
    screen_size_cm = [46.5 29];
    viewing_distance_cm = 44;
    standard_font_size = 25;
    disp('Computer set for Psychology EEG lab');
elseif computer_used == 10 % Claire's laptop
    screen_size_cm = [28.8 18];
    viewing_distance_cm = 50;
    standard_font_size = 30;
    desired_screen_resolution = [1280 800]; % over-write screen resolution as my personal laptop cannot display 1024 x 768 resolution
    desired_refresh_rate = 60;
end

% enter subject details
if stand_alone ==1
    subj_number = input('Subject Number (Enter "0" for no logfile): ');
    session_number = input('Session Number: ');
    if session_number > 1
        Tracking_Thresholding_Value = input('Threshold value for tracking: ');
        Detection_Threshold_Value = input('Threshold value for detection: ');
    end
else
    subj_number = subject_number;
end

date_time = fix(clock);
if subj_number
    subj_data_filename = sprintf(logfile_template,subj_number,session_number);
    
    % check if data file already exists
    if subj_number && file_checking % only save data for test block_numbers ~= 999
        if exist([subj_data_filename '.mat'],'file')
            error('Data for file for this subject number already exists - please chose a different subject number.');
        end
    end
end

% add input data to data structure
data.subject_no = subj_number;
data.date_time = date_time;
data.session_number = session_number;
data.detection_response_key = detection_response_key;
data.n_bonus_points = 0;

% create string ID for subject number
if subj_number < 10 % for subject numbers < 10 only
    subject_number_string = ['0' num2str(subj_number)];
else
    subject_number_string = num2str(subj_number);
end

% open a screen
Screen('Preference', 'SkipSyncTests', 1);
HideCursor;
AssertOpenGL;
my_screens = Screen('Screens');
screen_number = max(my_screens);
screen_specifications = Screen('Resolution',screen_number);
[w_screen,w_rect] = Screen('OpenWindow',screen_number);
Screen(w_screen,'Flip'); % do an initial flip so that you draw on background and not on programming screen
Screen(w_screen,'FillRect',colour_background,w_rect);
Screen(w_screen,'Flip');
Screen(w_screen,'FillRect',colour_background,[]);

% calculate the number of frames for each stimulus event
n_frames_per_stimulus = round(duration_detection_shape*desired_refresh_rate); % this is a single value of frame numbers per shape presentations
n_frames_per_ITI = round(duration_shape_ITI*desired_refresh_rate); % this is a matrix of frame numbers per ITI

% determine the range of possible target shapes
shape_counter = 0;
for shape_count = 1:length(shape_names)
    for colour_count = 1:length(colour_names)
        shape_counter = shape_counter+1;
        possible_shapes{shape_counter} = [shape_names{shape_count} '_' colour_names{colour_count}]; % create each possible combination of each shape & colour
    end
end

% determine size of stimulus (deg --> pixels)

% ...for fixation square
[fix_width_pix fix_height_pix] = deg_to_pix(size_fix_deg,size_fix_deg,[screen_specifications.width screen_specifications.height],screen_size_cm,viewing_distance_cm);
size_fix = [0 0 fix_width_pix fix_height_pix];

% ...for tracking stimuli
[tracking_stim_width_pix tracking_stim_height_pix] = deg_to_pix(size_tracking_stim_deg,size_tracking_stim_deg,[screen_specifications.width screen_specifications.height],screen_size_cm,viewing_distance_cm);
size_tracking_stim = [0 0 tracking_stim_width_pix tracking_stim_height_pix];

% ...for shape stimuli
[shape_stim_width_pix shape_stim_height_pix] = deg_to_pix(size_shape_stim_deg,size_shape_stim_deg,[screen_specifications.width screen_specifications.height],screen_size_cm,viewing_distance_cm);
size_shape_stim = [0 0 shape_stim_width_pix shape_stim_height_pix];

% ...for cursor stimuli
[cursor_width_pix cursor_height_pix] = deg_to_pix(size_cursor_deg,size_cursor_deg,[screen_specifications.width screen_specifications.height],screen_size_cm,viewing_distance_cm);
size_cursor = [0 0 cursor_width_pix cursor_height_pix];

% ...for whole screen
size_instructions = [0 0 screen_specifications.width screen_specifications.height]; % make general_instructions take up entire screen

% determine position of stimuli
[center_x,center_y] = RectCenter(w_rect); %  coordinates start from top left corner [0,0]
present_fix = CenterRect(size_fix,w_rect); % present fixation in center of the screen
present_shape = CenterRect(size_shape_stim,w_rect); % present the shape in the center of the screen
present_instructions = CenterRect(size_instructions,w_rect); % present general_instructions in center of the screen

% create stimulus screens

% ... for general task instruction
disp_general_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_general_instructions,standard_font);
Screen('TextStyle',disp_general_instructions,1);
Screen('TextSize',disp_general_instructions,standard_font_size);
n_lines_above_center = ceil(length(general_instructions)/2);
n_lines_below_center = length(general_instructions)-n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(general_instructions,1)
    DrawFormattedText(disp_general_instructions,general_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ... for testing phase task instructions

disp_testing_phase_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_testing_phase_instructions,standard_font);
Screen('TextStyle',disp_testing_phase_instructions,1);
Screen('TextSize',disp_testing_phase_instructions,standard_font_size);
n_lines_above_center = ceil(length(testing_phase_instructions)/2);
n_lines_below_center = length(testing_phase_instructions)-n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(testing_phase_instructions,1)
    DrawFormattedText(disp_testing_phase_instructions,testing_phase_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ... for detection shape instructions
disp_detection_shape_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_detection_shape_instructions,standard_font);
Screen('TextStyle',disp_detection_shape_instructions,1);
Screen('TextSize',disp_detection_shape_instructions,standard_font_size);
n_lines_above_center = ceil(length(detection_instructions)+2);
n_lines_below_center = length(detection_instructions)-n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(detection_instructions,1)
    DrawFormattedText(disp_detection_shape_instructions,detection_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ... for dual task instructions
disp_dual_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
Screen('TextFont',disp_dual_instructions,standard_font);
Screen('TextStyle',disp_dual_instructions,1);
Screen('TextSize',disp_dual_instructions,standard_font_size);
n_lines_above_center = ceil(length(dual_instructions)+2);
n_lines_below_center = length(dual_instructions)-n_lines_above_center;
line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
for line_count = 1:size(dual_instructions,1)
    DrawFormattedText(disp_dual_instructions,dual_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
end

% ...for fixation square
disp_fix = Screen('OpenOffscreenWindow',w_screen,colour_background,size_fix);
Screen('FillRect',disp_fix,colour_text,size_fix,[]);

% ...for erroneous fixation square
disp_error_fix = Screen('OpenOffscreenWindow',w_screen,colour_background,size_fix);
Screen('FillRect',disp_error_fix,colour_error,size_fix,[]);

% ...for visible tracking stimulus
disp_visible_tracking_stim = Screen('OpenoffscreenWindow',w_screen,colour_background,size_tracking_stim);
Screen('FillRect',disp_visible_tracking_stim,colour_background,size_tracking_stim,[]);
Screen('FrameOval',disp_visible_tracking_stim,colour_text,size_tracking_stim,tracking_stim_line_thickness,[]);

% ...for invisible tracking stimulus
disp_invisible_tracking_stim = Screen('OpenoffscreenWindow',w_screen,colour_background,size_tracking_stim);
Screen('FillRect',disp_invisible_tracking_stim,colour_background,size_tracking_stim,[]);

% ...for cursor stimulus
disp_cursor = Screen('OpenoffscreenWindow',w_screen,colour_background,size_cursor);
Screen('FillRect',disp_cursor,colour_text,size_cursor,[]);

% ...for erroneous cursor stimulus
disp_error_cursor = Screen('OpenoffscreenWindow',w_screen,colour_background,size_cursor);
Screen('FillRect',disp_error_cursor,colour_error,size_cursor,[]);

% ...for detection shapes
for shape_count = 1:length(possible_shapes)
    shape_array = imread(sprintf(shape_filename,possible_shapes{shape_count}));
    disp_shape(shape_count) = Screen(w_screen,'MakeTexture',shape_array);
end

% if the screen specs aren't correct, display current screen settings on display
WaitSecs(.3);

% do initial save to create logfile
if subj_number % only save data for test data
    % add updated data matrix to logfile
    save(subj_data_filename,'data');
end

% ----------------------- START EXPERIMENT --------------------------------

% PRACTICE/TEST LOOP ------------------------------------------------------
for version_count = 1:length(version_types) % for version count...(practice or test phase)
  if session_number > 1
      version_count = 2;
  end
    % present instructions
    WaitSecs(.3);
    if version_count == 1 % if this is a practice block...
        Screen('CopyWindow',disp_general_instructions,w_screen,[],present_instructions,[]); % display general task instructions
    elseif version_count == 2 % if this is a test block...
        Screen('CopyWindow',disp_testing_phase_instructions,w_screen,[],present_instructions,[]);  % display testing phase instructions
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
    
    % BLOCK LOOP ----------------------------------------------------------
    for block_count = 1:n_blocks(version_count)
        
        % reset these variables at the start of each block
        overall_detection_accuracy = zeros(1,n_trials_per_block(version_count));
        trial_tracking_accuracy = zeros(1,n_trials_per_block(version_count));
        if version_count == 1
            if block_count == 1 % for tracking only thresholding block...
                tracking_thresholding_step = zeros(1,n_trials_per_block(version_count));
            elseif block_count == 2 % for detection only thresholding block...
                detection_thresholding_step = zeros(1,n_trials_per_block(version_count));
            end
        end
        
        % determine trial type order
        trial_type_order = []; % create an empty matrix to fill the trial types for each block
        if version_count == 1 % for practice blocks, do separate blocks of single and dual tasks
            if n_blocks(version_count) ~= 2 % if you want to present more than one of each trial type during the practice...
                error('The script is currently set to present one practice block of each trial type for thresholding. If you want to present more practice blocks, update the script and this error message.');
            end
            trial_type_order = ones(1,n_trials_per_block(version_count))*block_count; % first trial= tracking task only; second trial= detection task only; third trial= dual task
        elseif version_count == 2 % for test blocks, intermix the single and dual task trials
            n_repetitions_per_type = n_trials_per_block(version_count)/length(condition_names); % determine how many repetitions there will be of each trial type per block
            if mod(n_trials_per_block(version_count),length(condition_names)) ~= 0 % if n_trials_per_block(version_count) is not perfectly divisible by the number of conditions names (i.e.,there is an unequal number of trials per type)
                error('You have an unequal number of trials per block,per condition - check this!'); % throw an error - the number of repetitions should be equal across conditions
            end
            for trial_type_count = 1:length(condition_names) % for each condition...
                for repetition_count = 1:n_repetitions_per_type% for each repetition of this condition...
                    trial_type_order = [trial_type_order trial_type_count]; % add this condition number to temporary version of trial order matrix
                end
            end
            trial_type_order = Shuffle(trial_type_order); % shuffle trial type order
        end
        
        % if this is a thresholding block, set tracking speed to default (for detection only block) or shape response duration to default (for tracking only block)
        if version_count == 1 % for thresholding block....
            duration_shape_response = possible_duration_shape_response(starting_step);
            object_speed_dps = possible_tracking_stimulus_speed(starting_step); % target speed (deg/sec)
        elseif version_count == 2 % for test blocks...
            if session_number == 1
                duration_shape_response = data.test_detection_response_duration; % use thresholded response duration
                object_speed_dps = data.test_object_speed_dps; % use thresholded object speed
            else
                duration_shape_response = Detection_Threshold_Value;
                object_speed_dps = Tracking_Thresholding_Value;
            end
        end
        
        block_onset = GetSecs;
        
        % TRIAL LOOP ------------------------------------------------------
        for trial_count = 1:n_trials_per_block(version_count) 
            
            % determine how many shapes will appear in this trial
            if version_count == 1 && trial_type_order(trial_count) == 1 % for tracking only trial...
                current_n_shapes = n_shapes_per_trial(1);
            elseif version_count == 1 && trial_type_order(trial_count) == 2 % for tracking only trial...
                current_n_shapes = n_shapes_per_trial(2);
            elseif version_count == 2 % for all test trials...
                current_n_shapes = n_shapes_per_trial(3);
            end
            
            % determine number of frames for entire trial and shape response
            if version_count == 1 && trial_type_order(trial_count) == 1 % for tracking only trial...
                length_of_trial = duration_motion(1);
            elseif version_count == 1 && trial_type_order(trial_count) == 2 % for tracking only trial...
                length_of_trial = duration_motion(2);
            elseif version_count == 2 % for all test trials...
                length_of_trial = duration_motion(3);
            end
            n_frames = round(length_of_trial*desired_refresh_rate);
            
            % reset these variables at the start of each trial
            key_found = 0;
            stimulus_counter = 1;
            frame_score = 1;
            shape_selected = 0;
            current_cursor_position(1:n_frames,1:4) = 0;
            frame_score(1:n_frames,1) = 0;
            current_shape_name = cell(1,current_n_shapes);
            trial_detection_RT = zeros(1,current_n_shapes);
            trial_detection_responses = cell(1,current_n_shapes);
            trial_detection_accuracy = zeros(1,current_n_shapes);
            trial_signal_detection = zeros(1,current_n_shapes);
            trial_signal_detection_name = cell(1,current_n_shapes);
            
            % determine the ITIs between each shape presentation
            n_shapes_per_ITI_duration = round(current_n_shapes/length(duration_shape_ITI)); % determine how many shapes to present at each ITI
            shape_ITI_order = [];
            for ITI_count = 1:length(duration_shape_ITI) % for each ITI...
                for repetition_count = 1:n_shapes_per_ITI_duration % for each instance of each ITI...
                    shape_ITI_order = [shape_ITI_order ITI_count]; % add the current ITI value (in seconds) to the temporary matrix
                end
            end
            shape_ITI_order = Shuffle(shape_ITI_order); % shuffle ITI order
            
            % determine which frames the shapes will onset
            final_frame_offset = round(max_time_onset*desired_refresh_rate); % determine the maximum frame from which detection stimuli can appear
            current_frame = min_frame_onset; % the first shape appears at the first possible frame possible
            shape_onset_frames = current_frame; % store first shape's frame onset
            for shape_count = 2:current_n_shapes % for each shape...
                current_frame = current_frame+(n_frames_per_stimulus+n_frames_per_ITI(shape_ITI_order(shape_count-1))); % add to the current frame the number of frames that will appear during the previous stimulus and ITI
                shape_onset_frames = [shape_onset_frames current_frame]; % add current frame as the onset of the current shape
            end
            
            % assign detection shape to each trial (randomly selected shape for each trial)
            shuffled_possible_shapes = Shuffle(1:length(possible_shapes)); % shuffle possible shapes IDs
            detection_target_shape = shuffled_possible_shapes(1); % select the first randomised shape as the detection shape for the current trial
            
            % determine trial type order for shape detection task where the proportion of times the to-be-detected shape appears can be manipulated
            n_detection_targets_per_trial = round(current_n_shapes*proportion_detection_targets_per_trial); % determine proportion detection targets within each trial; round upwards if this does not equal a whole number
            detection_type_order = []; % create an empty matrix to fill the trial types for each block
            % first add in detection target shape presentations
            for target_count = 1:n_detection_targets_per_trial % for each target presentation
                detection_type_order = [detection_type_order 1]; % 1= target shape; add this condition number to temporary version of trial order matrix
            end
            % now add in detection non-target shape presentations, where these will be equal to a randomly selected non-target shape
            for lure_count = 1:(current_n_shapes-n_detection_targets_per_trial) % for each lure presentation...
                detection_type_order = [detection_type_order 2]; % 2= non-target shape; add this condition number to temporary version of trial order matrix
            end
            detection_type_order = Shuffle(detection_type_order); % shuffle the trial order for this block and save in data structure
            
            % update trial instruction screen
            temp_trial_instructions = trial_instructions;
            temp_trial_instructions{1} = sprintf(trial_instructions{1},upper(task_block_types{trial_type_order(trial_count)})); % add name of block type
            if trial_type_order(trial_count) == 1 % for tracking only trials...
                temp_trial_instructions{3} = sprintf(trial_instructions{3},task_descriptions{1});
                temp_trial_instructions{4} = sprintf(trial_instructions{4},task_descriptions{2});
            elseif trial_type_order(trial_count) == 2 % for detection only trials...
                temp_trial_instructions{3} = sprintf(trial_instructions{3},task_descriptions{3});
                temp_trial_instructions{4} = sprintf(trial_instructions{4},task_descriptions{4});
            elseif trial_type_order(trial_count) == 3 % for dual-task trials...
                temp_trial_instructions{3} = sprintf(trial_instructions{3},task_descriptions{1});
                temp_trial_instructions{4} = ['AND ' sprintf(trial_instructions{4},task_descriptions{3})];
            end
            
            % present trial instructions
            WaitSecs(.3);
            disp_trial_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
            Screen('TextFont',disp_trial_instructions,standard_font);
            Screen('TextStyle',disp_trial_instructions,1);
            Screen('TextSize',disp_trial_instructions,standard_font_size);
            n_lines_above_center = ceil(length(temp_trial_instructions)/2);
            n_lines_below_center = length(temp_trial_instructions) - n_lines_above_center;
            line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
            for line_count = 1:size(temp_trial_instructions,1)
                DrawFormattedText(disp_trial_instructions,temp_trial_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
            end
            Screen('CopyWindow',disp_trial_instructions,w_screen,[],present_instructions,[]);
            Screen(w_screen,'Flip');
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
            
            % if it is a detection trial, present the detection target shape
            if trial_type_order(trial_count) ~= 1 % if the trial contains a detection component...
                WaitSecs(.3);
                if trial_type_order(trial_count) == 2 % for detection only trials...
                    Screen('CopyWindow',disp_detection_shape_instructions,w_screen,[],present_instructions,[]);
                elseif trial_type_order(trial_count) == 3 % for dual task trials...
                    Screen('CopyWindow',disp_dual_instructions,w_screen,[],present_instructions,[]); % present the dual task instructions
                end
                Screen('CopyWindow',disp_shape(detection_target_shape),w_screen,[],present_shape,[]); % add detection target shape
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
                key_found = 0; % reset key_found so that shape responses can be polled
            end
            
            % define current motion file
            temp_motion_trajectory_filename = motion_trajectory_filename;
            motion_file_list = dir([cd motion_trajectory_dir '/' sprintf(temp_motion_trajectory_filename,n_objects,object_speed_dps,desired_screen_resolution(1),desired_screen_resolution(2))]); % source all files that correspond to the current speed
            trial_file_order = Shuffle(1:length(motion_file_list)); % shuffle all files
            
            % load in motion trajectory file
            current_motion_file = [cd motion_trajectory_dir '/' motion_file_list(trial_file_order(1)).name]; % define current motion file
            load(current_motion_file); % load MATLAB file into workplace
            
            % define X and Y coordinates for object across entire trial
            current_motion_x = experiment.obj_position_x; % this variable is contained in the "current_motion_file"
            current_motion_y = experiment.obj_position_y; % this variable is contained in the "current_motion_file"
            
            % define starting point of cursor as the center of the screen
            cursor_x = center_x;
            cursor_y = current_motion_y(1,1); % cursor starts in the top centre, at the same location as the target
            SetMouse(cursor_x,cursor_y); % set mouse to start in the centre of the screen at the start of each trial
            
            % present static target in the center of the screen initially
            for object_count = 1:n_objects
                if all_tracking_stim_visible
                    Screen('CopyWindow',disp_visible_tracking_stim,w_screen,[],CenterRectOnPoint(size_tracking_stim,current_motion_x(1,object_count),current_motion_y(1,object_count)),[]);
                else
                    if object_count == 1
                        Screen('CopyWindow',disp_visible_tracking_stim,w_screen,[],CenterRectOnPoint(size_tracking_stim,current_motion_x(1,object_count),current_motion_y(1,object_count)),[]);
                    else
                        Screen('CopyWindow',disp_invisible_tracking_stim,w_screen,[],CenterRectOnPoint(size_tracking_stim,current_motion_x(1,object_count),current_motion_y(1,object_count)),[]);
                    end
                end
            end
            
            % determine current cursor location
            [cursor_x,cursor_y,~] = GetMouse; % define updated cursor position
            Screen('DrawTexture',w_screen,disp_cursor,size_cursor,CenterRectOnPoint(size_cursor,cursor_x,cursor_y));% present cursor symbol at starting position
            Screen('CopyWindow',disp_fix,w_screen,[],present_fix,[]); % add fixation
            Screen(w_screen,'Flip');
            trial_onset = GetSecs;
            while (GetSecs - trial_onset) <= duration_first_fixation; end
            
            % by default, mark first shape presentation as a miss/CR (this will be updated if a response is made)
            if detection_type_order(stimulus_counter) == 1 % if the first shape is a target...
                trial_signal_detection(stimulus_counter) = 3; % mark as a miss
                trial_signal_detection_name{stimulus_counter} = response_types{3};
            elseif detection_type_order(stimulus_counter) == 2 % if the first shape is a non-target...
                trial_detection_accuracy(stimulus_counter) = 1; % mark as correct
                trial_signal_detection(stimulus_counter) = 5; % mark as a correct rejection
                trial_signal_detection_name{stimulus_counter} = response_types{5};
            end
            
            % FRAME LOOP --------------------------------------------------
            for frame_count = 1:n_frames % for each frame/screen flip
                
                % determine current cursor location
                [cursor_x,cursor_y,~] = GetMouse; % define updated cursor position
                
                % present tracking_stim stimulus at new position
                current_tracking_stim_position = CenterRectOnPoint(size_tracking_stim,current_motion_x(frame_count,1),current_motion_y(frame_count,1));
                for object_count = 1:n_objects
                    if all_tracking_stim_visible
                        Screen('CopyWindow',disp_visible_tracking_stim,w_screen,[],CenterRectOnPoint(size_tracking_stim,current_motion_x(frame_count,object_count),current_motion_y(frame_count,object_count)),[]);
                    else
                        if object_count == 1
                            Screen('CopyWindow',disp_visible_tracking_stim,w_screen,[],CenterRectOnPoint(size_tracking_stim,current_motion_x(frame_count,object_count),current_motion_y(frame_count,object_count)),[]);
                        else
                            Screen('CopyWindow',disp_invisible_tracking_stim,w_screen,[],CenterRectOnPoint(size_tracking_stim,current_motion_x(frame_count,object_count),current_motion_y(frame_count,object_count)),[]);
                        end
                    end
                end
                
                % determine whether to present the to-be-detected shape on this frame (randomise when each shape will appear)
                if frame_count >= shape_onset_frames(stimulus_counter) && ... % if the current frame equal to when the shape stimulus should onset...
                        frame_count <= shape_onset_frames(stimulus_counter)+n_frames_per_stimulus-1 % ...or it corresponds to one of the frames during the stimulus presentation...
                    if frame_count == shape_onset_frames(stimulus_counter) % if it's the onset frame...
                        shape_onset = GetSecs;
                    end
                    
                    % determine what shape to present - detection target or non-target
                    if ~shape_selected
                        if detection_type_order(stimulus_counter) == 1 % if a detection target shape should appear
                            current_shape = detection_target_shape;
                            shape_selected = 1;
                        elseif detection_type_order(stimulus_counter) == 2 % if a detection non-target shape should appear
                            shuffled_possible_shapes = Shuffle(1:length(possible_shapes)); % shuffle possible shapes IDs
                            shuffled_possible_non_targets = shuffled_possible_shapes(shuffled_possible_shapes ~= detection_target_shape); % remove detection target ID from possible shapes
                            current_shape = shuffled_possible_non_targets(1); % select the first non-target to present
                            shape_selected = 1;
                        end
                        current_shape_name{stimulus_counter} = possible_shapes{current_shape};
                    end
                    Screen('CopyWindow',disp_shape(current_shape),w_screen,[],present_shape,[]); % draw shape
                end
                
                % present cursor symbol at new mouse position
                if trial_type_order(trial_count) ~= 2 % if the current trial contains a tracking component...
                    current_cursor_position(frame_count,1:4) = CenterRectOnPoint(size_cursor,cursor_x,cursor_y);
                    
                    % determine whether cursor falls within boundary of tracking_stim
                    if trial_type_order(trial_count) ~= 2 % if the current trial contains a tracking component...
                        if current_cursor_position(frame_count,1) >= current_tracking_stim_position(1) && ...
                                current_cursor_position(frame_count,3) <= current_tracking_stim_position(3) && ...
                                current_cursor_position(frame_count,2) >= current_tracking_stim_position(2) && ...
                                current_cursor_position(frame_count,4) <= current_tracking_stim_position(4) % if the tracking_stim falls within the bounds of the tracking_stim
                            frame_score(frame_count) = 1; % mark frame as a successful
                        else
                            frame_score(frame_count) = 0; % mark frame as unsuccesful
                        end
                    end
                    
                    % draw cursor, or erroneous cursor if it falls outside of the tracking stimulus
                    if version_count == 1 % if this is a thresholding trial...
                        if frame_score(frame_count) == 1 % if the cursor falls within the tracking stimulus...
                            Screen('DrawTexture',w_screen,disp_cursor,size_cursor,current_cursor_position(frame_count,1:4)); % draw cursor stimulus at cursor location
                        else % otherwise, if the cursor falls outside the tracking stimulus
                            Screen('DrawTexture',w_screen,disp_error_cursor,size_cursor,current_cursor_position(frame_count,1:4)); % draw an erroneous cursor stimulus at cursor location
                        end
                    else
                        Screen('DrawTexture',w_screen,disp_cursor,size_cursor,current_cursor_position(frame_count,1:4)); % draw cursor stimulus at cursor location
                    end
                else % if this is a detection only trial...
                    Screen('DrawTexture',w_screen,disp_cursor,size_cursor,CenterRectOnPoint(size_cursor,current_motion_x(frame_count,1),current_motion_y(frame_count,1))); % draw cursor stimulus in centre of tracking stimulus
                end
                
                % when the shape offsets, reset counters
                if frame_count == shape_onset_frames(stimulus_counter)+n_frames_per_stimulus+n_frames_per_ITI(shape_ITI_order(stimulus_counter))-1 &&... % when the stimulus offsets
                        stimulus_counter ~= current_n_shapes % and this isn't the last shape stimulus presented in this trial...
                    stimulus_counter = stimulus_counter+1; % proceed to next stimulus
                    key_found = 0; % reset key marker after each stimulus
                    shape_selected = 0; % reset non-target shape marker after each stimulus
                    
                    % by default, mark the next shape presentation as a miss/CR (this will be updated if a response is made)
                    if detection_type_order(stimulus_counter) == 1 % if the first shape is a target...
                        trial_signal_detection(stimulus_counter) = 3; % mark as a miss
                        trial_signal_detection_name{stimulus_counter} = response_types{3};
                    elseif detection_type_order(stimulus_counter) == 2 % if the first shape is a non-target...
                        trial_detection_accuracy(stimulus_counter) = 1; % mark as correct
                        trial_signal_detection(stimulus_counter) = 5; % mark as a correct rejection
                        trial_signal_detection_name{stimulus_counter} = response_types{5};
                    end
                end
                
                % add fixation or erroneous fixation if an error response was made
                if version_count == 1 && exist('shape_onset','var') && trial_type_order(trial_count) ~= 1 &&... % if a shape has onset and this trial had a detection component in the thresholding phase...
                        (GetSecs - shape_onset) > (duration_detection_shape+duration_shape_response) &&... % if the response window has passed...
                        (GetSecs - shape_onset) <= (duration_detection_shape+duration_shape_response+duration_feedback) &&... % and time is still less than the error feedback window...
                        trial_detection_accuracy(stimulus_counter) == 0 % and an erroroneous was made...
                    Screen('CopyWindow',disp_error_fix,w_screen,[],present_fix,[]); % present error fixation cross
                else
                    Screen('CopyWindow',disp_fix,w_screen,[],present_fix,[]); % present standard fixation cross
                end
               
                % tell PTB that no further drawing commands will follow before Screen('Flip')
                Screen('DrawingFinished',w_screen);
                Screen(w_screen,'Flip');
                
                % poll button responses for detection task
                if exist('shape_onset','var') && trial_type_order(trial_count) ~= 1 % if a shape has onset and if the current trial contains a detection component...
                    if (GetSecs - shape_onset) <= (duration_detection_shape+duration_shape_ITI(shape_ITI_order(stimulus_counter))) % if the current time falls within the stimulus presentation and ITI time window
                        [key_is_down,time_in_secs,key_code] = KbCheck;
                        if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                            keys_pressed = find(key_code);
                            if ~isempty(keys_pressed)
                                trial_detection_responses{stimulus_counter} = KbName(keys_pressed(1));
                                trial_detection_RT(stimulus_counter) = time_in_secs-shape_onset;
                                
                                if detection_type_order(stimulus_counter) == 1 % if the shape that appeared was the detection target...
                                    if ~isempty(trial_detection_responses{stimulus_counter}) % and if any key was pressed
                                        if trial_detection_RT(stimulus_counter) <= duration_shape_response %...and it fell within the response time window...
                                            trial_detection_accuracy(stimulus_counter) = 1; % mark as correct
                                            trial_signal_detection(stimulus_counter) = 1; % mark as a hit response
                                            trial_signal_detection_name{stimulus_counter} = response_types{1}; % mark as a hit response
                                        else
                                            trial_detection_accuracy(stimulus_counter) = 0; % mark as incorrect
                                            trial_signal_detection(stimulus_counter) = 2; % mark as a late response
                                            trial_signal_detection_name{stimulus_counter} = response_types{2}; % mark as a late response
                                        end
                                    %elseif isempty(trial_detection_responses{stimulus_counter}) % or if no key was pressed...
                                    %    trial_detection_accuracy(stimulus_counter) = 0; % mark as incorrect
                                    %    trial_signal_detection(stimulus_counter) = 3; % mark as a miss response
                                    %    trial_signal_detection_name{stimulus_counter} = response_types{3}; % mark as a miss response
                                    end
                                elseif detection_type_order(stimulus_counter) == 2 % if the shape that appeared was NOT the detection target...
                                    if ~isempty(trial_detection_responses{stimulus_counter}) % and if any key was pressed...
                                        if trial_detection_RT(stimulus_counter) <= duration_shape_response %...and it fell within the response time window...
                                            trial_detection_accuracy(stimulus_counter) = 0; % mark as incorrect
                                            trial_signal_detection(stimulus_counter) = 4; % mark as a false alarm response
                                            trial_signal_detection_name{stimulus_counter} = response_types{4}; % mark as a false alarm response
                                        end
                                    end
                                end
                                
                                FlushEvents('keyDown');
                                key_found = 1;
                            end
                        end
                    else
                        clear shape_onset
                    end
                end
                
                % add accuracy for correct rejections
                %if detection_type_order(stimulus_counter) == 2 % if the shape that appeared was NOT the detection target...
                %    if isempty(trial_detection_responses{stimulus_counter})  &&... % or if no key was pressed...
                %            frame_count > shape_onset_frames(stimulus_counter)+n_frames_per_stimulus+round(duration_shape_response*desired_refresh_rate) % ...or it corresponds to one of the frames during the stimulus presentation... % and the response time window has passed
                %        trial_detection_accuracy(stimulus_counter) = 1; % mark as correct
                %        trial_signal_detection(stimulus_counter) = 5; % mark as a correct rejection response
                %        trial_signal_detection_name{stimulus_counter} = response_types{5}; % mark as a correct rejection response
                %   end
                %end
                
            end % END OF FRAME LOOP ---------------------------------------
            trial_offset = GetSecs;
            
            % calculate tracking accuracy score
            if trial_type_order(trial_count) ~= 2 % for trials with a tracking component...
                trial_tracking_accuracy(trial_count) = sum(frame_score)/n_frames*100;
                if isinf(trial_tracking_accuracy(trial_count)) % the tracking stimulus wasn't successfully tracked at all...
                    trial_tracking_accuracy(trial_count) = 0; % give score of zero
                end
            end
            
            % calculate detection accuracy and RT scores
            if trial_type_order(trial_count) ~= 1 % for trials with a detection component...
                
                % calculate overall RT and accuracy for entire trial
                target_present_trial_IDs = find(detection_type_order == 1); % find target present trials
                correct_taraget_present_trial_IDs = target_present_trial_IDs(trial_detection_accuracy(target_present_trial_IDs) == 1); % find correct target present trials
                if isempty(correct_taraget_present_trial_IDs) % if there are no correct target present trials...
                    overall_detection_RT = 0; % mark RT as zero
                else
                    overall_detection_RT = mean(trial_detection_RT(correct_taraget_present_trial_IDs))*1000; % only calculate RT from correct target-present trials
                end
                overall_detection_accuracy(trial_count) = mean(trial_detection_accuracy)*100;
                
                % calculate overall hits, late responses, misses, false alarms and correct rejections
                target_presentations = find(detection_type_order == 1); % find trials where target was presented
                non_target_presentations = find(detection_type_order == 2); % find trials where a non-target was presented
                for response_count = 1:length(response_types)
                    response_type_row_IDs = find(trial_signal_detection == response_count); % find stimuli that were responded to according to the current type
                    if strcmp(response_types{response_count},'hit') % for hit trials...
                        percentage_hit_trials = length(trial_detection_accuracy(response_type_row_IDs))/length(target_presentations)*100;
                    elseif strcmp(response_types{response_count},'late') % for late trials...
                        percentage_late_trials = length(trial_detection_accuracy(response_type_row_IDs))/length(target_presentations)*100;
                    elseif strcmp(response_types{response_count},'miss') % for miss trials...
                        percentage_miss_trials = length(trial_detection_accuracy(response_type_row_IDs))/length(target_presentations)*100;
                    elseif strcmp(response_types{response_count},'FA') % for false alarm trials...
                        percentage_FA_trials = length(trial_detection_accuracy(response_type_row_IDs))/length(non_target_presentations)*100;
                    elseif strcmp(response_types{response_count},'CR') % for correct rejection trials...
                        percentage_CR_trials = length(trial_detection_accuracy(response_type_row_IDs))/length(non_target_presentations)*100;
                    end
                end
            end
            
            % save remaining data values in structure
            if version_count == 2 % only save data for test blocks
                
                data.trial_no(trial_count,1) = trial_count;
                data.block_no(block_count,1) = block_count;
                data.trial_type_ID(trial_count,block_count) = trial_type_order(trial_count);
                data.trial_type_name{trial_count,block_count} = condition_names{trial_type_order(trial_count)};
                if trial_type_order(trial_count) ~= 1 % for trials with a detection component...
                    
                    % store stimulus information
                    data.shape_ITI_order{trial_count,block_count} = shape_ITI_order;
                    data.shape_onset_frames{trial_count,block_count} = shape_onset_frames;
                    data.detection_target_shape(trial_count,block_count) = detection_target_shape;
                    data.detection_type_order{trial_count,block_count} = detection_type_order;
                    data.current_shape_name{trial_count,block_count} = current_shape_name;
                    data.duration_shape_response(trial_count,block_count) = duration_shape_response;
                    
                    % store response information
                    data.trial_detection_responses{trial_count,block_count} = trial_detection_responses;
                    data.trial_detection_RT{trial_count,block_count} = trial_detection_RT;
                    data.trial_detection_accuracy{trial_count,block_count} = trial_detection_accuracy;
                    data.trial_signal_detection{trial_count,block_count} = trial_signal_detection;
                    data.trial_signal_detection_name{trial_count,block_count} = trial_signal_detection_name;
                    data.overall_detection_RT(trial_count,block_count) = overall_detection_RT;
                    data.overall_detection_accuracy(trial_count,block_count) = overall_detection_accuracy(trial_count);       
                    data.percentage_hit_trials(trial_count,block_count) = percentage_hit_trials;
                    data.percentage_late_trials(trial_count,block_count) = percentage_late_trials;
                    data.percentage_miss_trials(trial_count,block_count) = percentage_miss_trials;
                    data.percentage_FA_trials(trial_count,block_count) = percentage_FA_trials;
                    data.percentage_CR_trials(trial_count,block_count) = percentage_CR_trials;
                    
                else % otherwise, if there is no detection component...
                    
                    % store dummy stimulus information
                    data.shape_ITI_order{trial_count,block_count} = [];
                    data.shape_onset_frames{trial_count,block_count} = [];
                    data.detection_target_shape(trial_count,block_count) = NaN;
                    data.detection_type_order{trial_count,block_count} = [];
                    data.current_shape_name{trial_count,block_count} = [];
                    data.duration_shape_response(trial_count,block_count) = NaN;
                    
                    % store dummy response information
                    data.trial_detection_responses{trial_count,block_count} = [];
                    data.trial_detection_RT{trial_count,block_count} = [];
                    data.trial_detection_accuracy{trial_count,block_count} = [];
                    data.trial_signal_detection{trial_count,block_count} = [];
                    data.trial_signal_detection_name{trial_count,block_count} = [];
                    data.overall_detection_RT(trial_count,block_count) = NaN;
                    data.overall_detection_accuracy(trial_count,block_count) = NaN;
                    data.percentage_hit_trials(trial_count,block_count) = NaN;
                    data.percentage_late_trials(trial_count,block_count) = NaN;
                    data.percentage_miss_trials(trial_count,block_count) = NaN;
                    data.percentage_FA_trials(trial_count,block_count) = NaN;
                    data.percentage_CR_trials(trial_count,block_count) = NaN;
                    
                end
                if trial_type_order(trial_count) ~= 2 % for trials with a tracking component...
                    
                    % store tracking response information
                    data.trial_tracking_accuracy(trial_count,block_count) = trial_tracking_accuracy(trial_count);
                    data.current_motion_file{trial_count,block_count} = motion_file_list(trial_file_order(trial_count)).name;
                    data.object_speed_dps(trial_count,block_count) = object_speed_dps;
                    data.tracking_trajectory{trial_count,block_count} = current_cursor_position;
                    
                else % otherwise, if there is no tracking component...
                    
                    % store dummy tracking response information
                    data.trial_tracking_accuracy(trial_count,block_count) = NaN;
                    data.current_motion_file{trial_count,block_count} = [];
                    data.object_speed_dps(trial_count,block_count) = NaN;
                    data.tracking_trajectory{trial_count,block_count} = [];
                    
                end
                data.trial_duration(trial_count,block_count) = trial_offset-trial_onset;
                
                % store additional details in data matrix
                if subj_number
                    save(subj_data_filename,'data','-append');
                end
            end
            
            % create response feedback with updated response data (present feedback after every trial)
            temp_response_feedback = response_feedback;
            disp_feedback = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
            Screen('TextFont',disp_feedback,standard_font);
            Screen('TextStyle',disp_feedback,1);
            Screen('TextSize',disp_feedback,standard_font_size);
            n_lines_above_center = ceil(length(temp_response_feedback))/2;
            n_lines_below_center = length(temp_response_feedback) - n_lines_above_center;
            line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
            
            % add response information, depending on the task type
            if trial_type_order(trial_count) ~= 1 % if this trial had a detection component...
                
                if trial_type_order(trial_count) == 3 % if this is a dual task trial...
                    DrawFormattedText(disp_feedback,sprintf(temp_response_feedback{1},trial_tracking_accuracy(trial_count)),'Center',line_positions_y(1),colour_text,115); % add tracking accuracy score
                end
                DrawFormattedText(disp_feedback,sprintf(temp_response_feedback{2},overall_detection_accuracy(trial_count)),'Center',line_positions_y(2),colour_text,115); % add detection accuracy score
                DrawFormattedText(disp_feedback,sprintf(temp_response_feedback{3},overall_detection_RT),'Center',line_positions_y(3),colour_text,115); % add detection RT score
                DrawFormattedText(disp_feedback,temp_response_feedback{4},'Center',line_positions_y(4),colour_text,115);
                DrawFormattedText(disp_feedback,temp_response_feedback{5},'Center',line_positions_y(5),colour_text,115);
                
            elseif trial_type_order(trial_count) == 1 % if this was a tracking only trial...

                DrawFormattedText(disp_feedback,sprintf(temp_response_feedback{1},trial_tracking_accuracy(trial_count)),'Center',line_positions_y(1),colour_text,115); % add tracking accuracy scores
                DrawFormattedText(disp_feedback,temp_response_feedback{4},'Center',line_positions_y(4),colour_text,115);
                DrawFormattedText(disp_feedback,temp_response_feedback{5},'Center',line_positions_y(5),colour_text,115);
                
            end
            
            % present response feedback screen
            WaitSecs(.3);
            Screen('CopyWindow',disp_feedback,w_screen,[],present_instructions,[]);
            Screen(w_screen,'Flip');
            key_found = 0;
            while ~key_found
                [key_is_down,~,key_code] = KbCheck;
                if key_is_down == 1 && key_found == 0 % if a key is pressed and if this is the first key that has been pressed...
                    keys_pressed = find(key_code);
                    response_key = KbName(keys_pressed(1));
                    if strcmp(response_key,'space') % if the space key was pressed
                        FlushEvents('keyDown');
                        key_found = 1; % accept this key response and start trial
                    end
                end
            end
            
            % optional: implement stair-casing adjustments to shape response time window for detection task
            if use_staircasing && version_count == 1 % if you've opted to use staircasing, and if it's a thresholding trial
                if trial_type_order(trial_count) ~= 1 % if this trial had a detection component...
                    
                    if trial_count ~= n_trials_per_block(version_count) % if it's the last trial of this thresholding block...
                        
                        % determine thresholding step for the next trial
                        if overall_detection_accuracy(trial_count) < min_acc_cut_off % if the trial accuracy was less than the minimum cut...
                            n_steps = round((median_acc_score-overall_detection_accuracy(trial_count))/acc_step_increment); % determine how many steps to decrease by (the response time window will get longer)
                            detection_thresholding_step(trial_count) = find(possible_duration_shape_response == duration_shape_response); % determine what step you are currently at
                            if detection_thresholding_step(trial_count)-n_steps < 1
                                step_to_change_to = 1;
                            else
                                step_to_change_to = detection_thresholding_step(trial_count)-n_steps;
                            end
                            duration_shape_response = possible_duration_shape_response(step_to_change_to); % increase shape response duration (decrease in steps)
                        elseif overall_detection_accuracy(trial_count) > max_acc_cut_off % if the trial accuracy was greater than the maximum cut off...
                            n_steps = round((overall_detection_accuracy(trial_count)-median_acc_score)/acc_step_increment); % determine how many steps to increase by (the response time window will get shorter)
                            detection_thresholding_step(trial_count) = find(possible_duration_shape_response == duration_shape_response); % determine what step you are currently at
                            if detection_thresholding_step(trial_count)+n_steps > length(possible_duration_shape_response)
                                step_to_change_to = length(possible_duration_shape_response);
                            else
                                step_to_change_to = detection_thresholding_step(trial_count)+n_steps;
                            end
                            duration_shape_response = possible_duration_shape_response(step_to_change_to); % decrease shape response duration (increase in steps)
                        else % otherwise, if the trial accuracy fell between the minimum and maximum accuracy boundaries...
                            detection_thresholding_step(trial_count) = find(possible_duration_shape_response == duration_shape_response); % determine what step you are currently at
                            % do nothing
                        end
                        
                    else
                        
                        detection_thresholding_step(trial_count) = find(possible_duration_shape_response == duration_shape_response); % determine what step you are currently at
                        
                        % determine thresholding value for test blocks
                        [~,slope,x_intercept] = regression(overall_detection_accuracy,detection_thresholding_step); % determine the linear function between thresholding step and accuracy
                        test_threshold_step = round(slope*median_acc_score+x_intercept); % calculate the thresholding step that corresponds to the desired accuracy
                        
                        % update the duration of the shape response
                        if test_threshold_step < 1 || isinf(test_threshold_step)
                            test_threshold_step = 1;
                        elseif test_threshold_step > length(possible_duration_shape_response)
                            test_threshold_step = length(possible_duration_shape_response);
                        end
                        duration_shape_response = possible_duration_shape_response(test_threshold_step);
                        data.test_detection_response_duration = duration_shape_response;
                        data.detection_thresholding_step = test_threshold_step;
                        data.detection_steps_during_thresholding(1:n_trials_per_block(version_count)) = detection_thresholding_step;
                        
                    end
                end
                
                % implement stair-casing adjustments to tracking stimulus for tracking task
                if trial_type_order(trial_count) ~= 2 % if this trial had a tracking component...
                   
                    if trial_count ~= n_trials_per_block(version_count) % if it's not the last trial of this thresholding block...
                        
                        % determine thresholding step for the next trial
                        if trial_tracking_accuracy(trial_count) < min_acc_cut_off % if the trial accuracy was less than the minimum cut...
                            n_steps = round((median_acc_score-trial_tracking_accuracy(trial_count))/acc_step_increment); % determine how many steps to decrease by (the response time window will get longer)
                            tracking_thresholding_step(trial_count) = find(possible_tracking_stimulus_speed == object_speed_dps); % determine what step you are currently at
                            if tracking_thresholding_step(trial_count)-n_steps < 1
                                step_to_change_to = 1;
                            else
                                step_to_change_to = tracking_thresholding_step(trial_count)-n_steps;
                            end
                            object_speed_dps = possible_tracking_stimulus_speed(step_to_change_to); % decrease tracking stimulus speed (decrease in steps)
                        elseif trial_tracking_accuracy(trial_count) > max_acc_cut_off % if the trial accuracy was greater than the maximum cut off...
                            n_steps = round((trial_tracking_accuracy(trial_count)-median_acc_score)/acc_step_increment); % determine how many steps to increase by (the response time window will get shorter)
                            tracking_thresholding_step(trial_count) = find(possible_tracking_stimulus_speed == object_speed_dps); % determine what step you are currently at
                            if tracking_thresholding_step(trial_count)+n_steps > length(possible_tracking_stimulus_speed)
                                step_to_change_to = length(possible_tracking_stimulus_speed);
                            else
                                step_to_change_to = tracking_thresholding_step(trial_count)+n_steps;
                            end
                            object_speed_dps = possible_tracking_stimulus_speed(step_to_change_to); % increase the tracking stimulus speed (increase in steps)
                        else % otherwise, if the trial accuracy fell between the minimum and maximum accuracy boundaries...
                            tracking_thresholding_step(trial_count) = find(possible_tracking_stimulus_speed == object_speed_dps); % determine what step you are currently at
                            % do nothing
                        end
                        
                    else
                        
                        tracking_thresholding_step(trial_count) = find(possible_tracking_stimulus_speed == object_speed_dps); % determine what step you are currently at
                        
                        % determine thresholding value for test blocks
                        [~,slope,x_intercept] = regression(trial_tracking_accuracy,tracking_thresholding_step); % determine the linear function between thresholding step and accuracy
                        test_threshold_step = round(slope*median_acc_score+x_intercept); % calculate the thresholding step that corresponds to the desired accuracy
                        
                        % update the tracking stimulus speed
                        if test_threshold_step < 1 || isinf(test_threshold_step)
                            test_threshold_step = 1;
                        elseif test_threshold_step > length(possible_tracking_stimulus_speed)
                            test_threshold_step = length(possible_tracking_stimulus_speed);
                        end
                        object_speed_dps = possible_tracking_stimulus_speed(test_threshold_step);
                        data.test_object_speed_dps = object_speed_dps;
                        data.tracking_thresholding_step = test_threshold_step;
                        data.tracking_steps_during_thresholding(1:n_trials_per_block(version_count)) = tracking_thresholding_step;
                        
                    end
                end
                
                % produce output in command window for checking staircasing procedure
                if check_staircasing
                    fprintf('Trial no. %d, Thresholding Block no. %d\n',trial_count,block_count);
                    if trial_type_order(trial_count) ~= 2 % if this trial had a tracking component...
                        fprintf('Tracking stimulus speed for CURRENT trial: %.3f dps\n',possible_tracking_stimulus_speed(tracking_thresholding_step(trial_count)));
                        fprintf('Tracking accuracy: %.1f%%\n',trial_tracking_accuracy(trial_count));
                        fprintf('Tracking stimulus speed for NEXT trial: %.3f dps\n',object_speed_dps);
                    elseif trial_type_order(trial_count) ~= 1 % if this trial had a detection component...
                        fprintf('Shape response duration for CURRENT trial: %.3f secs\n',possible_duration_shape_response(detection_thresholding_step(trial_count)));
                        fprintf('Detection accuracy: %.1f%%\n',overall_detection_accuracy(trial_count));
                        fprintf('Shape response duration for NEXT trial: %.3f secs\n',duration_shape_response);
                    end
                    fprintf('\n');
                end
                
            elseif use_staircasing && version_count == 2
                
                % produce output in command window for checking staircasing procedure
%                 if check_staircasing
%                     fprintf('Trial no. %d, Test Block no. %d\n',trial_count,block_count);
%                     if trial_type_order(trial_count) ~= 2 % if this trial had a tracking component...
%                         fprintf('Tracking stimulus threshold speed: %.3f dps\n',possible_tracking_stimulus_speed(data.tracking_thresholding_step));
%                         fprintf('Tracking accuracy: %.1f%%\n',trial_tracking_accuracy(trial_count));
%                     end
%                     if trial_type_order(trial_count) ~= 1 % if this trial had a detection component...
%                         fprintf('Shape response threshold duration: %.3f secs\n',possible_duration_shape_response(data.detection_thresholding_step));
%                         fprintf('Detection accuracy: %.1f%%\n',overall_detection_accuracy(trial_count));
%                     end
%                     fprintf('\n');
%                 end
                
            end
            
        end % END TRIAL LOOP ----------------------------------------------

        % save block duration data
        block_offset = GetSecs;
        if version_count == 2 % only save data for test blocks
            data.block_duration(block_count,1) = block_offset-block_onset;
            
            % store additional details in data matrix
            if subj_number
                save(subj_data_filename,'data','-append');
            end
        end
        
        % update end of block instructions
        if block_count > 1 && version_count == 2 % for test blocks only...
            temp_end_of_block_instructions = end_of_block_instructions;
            temp_end_of_block_instructions{1} = sprintf(end_of_block_instructions{1},block_count,n_blocks(version_count)); % add block count
            if block_count == n_blocks(version_count) % if it's the last block...
                temp_end_of_block_instructions{3} = sprintf(end_of_block_instructions{3},goodbye_prompt{1}); % say goodbye
            else
                temp_end_of_block_instructions{3} = sprintf(end_of_block_instructions{3},goodbye_prompt{2}); % press space to continue
            end
            disp_end_of_block_instructions = Screen('OpenoffscreenWindow',w_screen,colour_background,size_instructions);
            Screen('TextFont',disp_end_of_block_instructions,standard_font);
            Screen('TextStyle',disp_end_of_block_instructions,1);
            Screen('TextSize',disp_end_of_block_instructions,standard_font_size);
            n_lines_above_center = ceil(length(temp_end_of_block_instructions)/2);
            n_lines_below_center = length(temp_end_of_block_instructions)-n_lines_above_center;
            line_positions_y = center_y+([-n_lines_above_center:n_lines_below_center]*line_spacing);
            for line_count = 1:size(temp_end_of_block_instructions,1)
                DrawFormattedText(disp_end_of_block_instructions,temp_end_of_block_instructions{line_count},'Center',line_positions_y(line_count),colour_text,115);
            end
            Screen('CopyWindow',disp_end_of_block_instructions,w_screen,[],present_instructions,[]);
            Screen(w_screen,'Flip');
            while (KbCheck); end; while (~KbCheck); end;
        end
        
    end % END OF BLOCK LOOP -----------------------------------------------
end% END OF VERSION LOOP --------------------------------------------------

% calculate single and dual task performance
for condition_count = 1:length(condition_names) % for each condition
    condition_trial_IDs = find(data.trial_type_ID == condition_count); % find trials that correspond to this condition
    if condition_count == 1 % for tracking only trials...
        single_tracking_acc = mean(data.trial_tracking_accuracy(condition_trial_IDs)); % calculate mean accuracy for current condition
    elseif condition_count == 2 % for detection only trials...
        single_detection_acc = mean(data.overall_detection_accuracy(condition_trial_IDs)); % calculate mean accuracy for current condition
    elseif condition_count == 3 % for dual trials..
        dual_tracking_acc = mean(data.trial_tracking_accuracy(condition_trial_IDs)); % calculate mean accuracy for current condition
        dual_detection_acc = mean(data.overall_detection_accuracy(condition_trial_IDs)); % calculate mean accuracy for current condition
    end
end

% calculate multi-tasking cost
dual_task_cost = (single_tracking_acc-dual_tracking_acc)+(single_detection_acc-dual_detection_acc);
data.dual_task_cost = dual_task_cost;
fprintf('\n#####---------- Dual-task cost = %.2f%% ----------#####\n\n',dual_task_cost);

% store additional details in data matrix
if subj_number
    save(subj_data_filename,'data','-append');
end

filename = strcat('Subject_',num2str(subject_number),'Session_',num2str(session_number),'Tracking_Task_Thresholds.txt'); 
datafilepointer = fopen(filename,'wt');
results(1,:) = [subject_number, object_speed_dps, duration_shape_response];
dlmwrite(filename,results,'delimiter','\t','precision',8);
                
% close matlab
ShowCursor;
FlushEvents('keyDown');
Screen('CloseAll');