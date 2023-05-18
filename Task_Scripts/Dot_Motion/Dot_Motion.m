
% Code adapted from Morgan Spence (Spence, Mattingley, & Dux,
% submitted, Experiment 3) by Michelle Hall, April 2018. Then adapted
% by Hannah Filmer (August 2019) for use as an attention task in a
% large-scale training/tDCS/MRI study.

% DaveL additons 29 August 2019 -> search for #######DAVEL in comments

% Two sets of RDKs presented overlapped on each trial (2000ms), one in white and one in black.
% Participants have to focus on one colour of the dots, and respond whether moving to left or right.
% RDKs vary in the degree of difference from verticle of motion, for
% both the target colour and the distractor colour.


%% %%%%%%%%%%%%%%%%%%%%%INITIALISE%%%%%%%%%%%%%%%

function Dot_Motion

commandwindow

stand_alone = 0;

no_practice_mode = 1; % 0 = include practice; 1 = no practice

Screen('Preference', 'SkipSyncTests', 1);

% allocate data structure
data = [];

% initialisation procedure for current PTB version
PsychDefaultSetup(1);
rng('default');
rng('shuffle');

% Initialize important MEX-files.
KbCheck;
GetSecs;

% computer info
computer = 2; % 1 = macBook pro, 2 = SLRC lab - room 427 in 24a, 3 = macBook pro with external monitor

fprintf('\n\n');
switch computer
    case 1
        %                     screenSize = [28.8 18]; % in cm; p is a structure containing all parametes relating to the screen
        %                     viewingDist = 50; % in cm
        font_size = 20;
        %                     lineSpacing = 1.5;
        
        fprintf('computer set for macBook Pro\n\n\n');
    case 2
        %                     screenSize = [53.5 30.1]; % set screen res to (1920x1080, 60 Hz)
        %                     viewingDist = 57;
        font_size = 25;
        %                     lineSpacing = 1.5;
        
        fprintf('computer set for SLRC lab');
    case 3
        %                     screenSize = [59 34];
        %                     viewingDist = 60;
        font_size = 25;
        %                     lineSpacing = 1.5;
        
        fprintf('computer set for macBook Pro external monitor\n\n\n');
end

% pop up input dialogue
if stand_alone == 1
 %   clear all;
    subject = input('Subject Number? ');
    session = input('Session?');
else
    filename=strcat('Current_subject.txt');
    cd('/Users/duxlab/Documents/Experiments/Battery_TASKS');
    ActiveData=dlmread(filename);
    subject = ActiveData(1,1);
    session = ActiveData(1,2);
    cd('Dot_Motion')
end;

startTime = datestr(now);

if ~exist('Data','dir')
    mkdir('Data');
end

if exist(sprintf('Data/Dot_Motion_sub_%d_session_1.mat',subject),'file')
    
    load(sprintf('Data/Dot_Motion_sub_%d_session_1',subject));
    
end

data.subject = subject;
data.session = session;
save_filename = sprintf('Data/Dot_Motion_sub_%d_session_%d',subject,session);
text_filename = strcat('Dot_Motion_sub_',num2str(subject),'_session_',num2str(session),'.txt');
data.startTime = startTime;

datafilepointer = fopen(text_filename,'wt');

% Parameters

dot_colour1 = [0 0 0]; % Black
dot_colour2 = [255 255 255]; % White

num_dots = 160; % Number of dots
coherence = .25;
dist_per_sec = 100; % speed of moving dots
rand_dist_per_sec = 6; % Number of pixels to move per second

mask_diam = 400; % diameter of display region in pixels
dot_diam = 1; % % #######DAVEL changed to 1 to mimic whats in the code -  diameter in pixels of individual dots

stim_duration = 2; % in seconds. This is only changing duration of display, not duration of dots.

trial_range = 0;

% direction parameters

dir_ranges = [15 75; 15 -45; 30 90; 30 -30; -15 45; -15 -75; -30 30; -30 -90]; % variable direction in degrees (away from vertex)
num_conditions = (size(dir_ranges));
num_conditions = (num_conditions(1));
if no_practice_mode == 0
    trials_per_dir_range = 1;
    num_blocks = 2;
else
    trials_per_dir_range = 5;
    num_blocks = 4;
end;

num_trials = trials_per_dir_range*num_conditions;

target_colour = Shuffle([repmat(1,1,num_trials) repmat(2,1,num_trials)]);

target_colour_directions=repelem(dir_ranges,trials_per_dir_range,1); %create array with all of the angles to use when target is one colour

Order = [1 2];
Order=Shuffle(Order);

if Order(1) == 1
    Block_order = [1 2 1 2];
else
    Block_order = [2 1 2 1];
end;

% for saving...
data.parameters.moving_dot_colour = [dot_colour1, dot_colour2];
data.parameters.num_dots = num_dots;
data.parameters.coherence = coherence;
data.parameters.dist_per_sec = dist_per_sec;
data.parameters.rand_dist_per_sec = rand_dist_per_sec;
data.parameters.mask_diam = mask_diam;
data.parameters.dot_diam = dot_diam;
data.parameters.dir_ranges = dir_ranges;
data.parameters.trials_per_dir_range = trials_per_dir_range;
data.parameters.num_trials = num_trials;
data.parameters.target_colour_directions = target_colour_directions;
data.parameters.block_colour = Block_order;

% instruction messages
% For practice...
prac_inst{1} = 'In this experiment, you will judge the direction of movement of ';
prac_inst{2} = 'dots as moving towards the left or right of center.';
prac_inst{3} = 'First, it is important to keep fixated on the centre red dot during the experiment.';
prac_inst{4} = 'On each trial, white and black dots will appear.';
prac_inst{5} = 'Some of the dots will move in one direction. ';
prac_inst{6} = 'On each trial you will have a target colour to focus on.';
prac_inst{7} = 'Please report whether the direction of movement for the target colour is';
prac_inst{8} = 'left or right of center.';
prac_inst{9} = 'Use the "<" key for left and ">" key for right.';
prac_inst{10} = 'Please ignore the other colour, and just focus on your target.';
prac_inst{11} = '';
prac_inst{12} = '';

prac_inst{13} = 'You have up to 2 seconds on each trial to make your decision.';
prac_inst{14} = '';
prac_inst{15} = ' ';
prac_inst{16} = ' ';
prac_inst{17} = 'Press any key to start practice...';

% for main task...
inst{1} = ' ';
inst{2} = 'Remember to keep fixated on the centre red dot during the experiment.';
inst{3} = 'The next task is just like the practice, but you won''t receive feedback.';
inst{4} = 'The judgments will also get more difficult.';
inst{5} = 'Try your best to be as QUICK and ACCURATE as you can!';


inst{6} = ' ';
inst{7} = ' ';
inst{8} = ' ';
inst{9} = ' If you have any questions or do not understand the task, please let';
inst{10} = 'the experimenter know.';
inst{11} = ' ';
inst{12} = ' ';

inst{13} = 'The task should take less than 10 minutes to complete.';
inst{14} = '';
inst{15} = ' ';
inst{16} = 'Press any key to continue...';

% for start of each block

block_inst{1} = 'For this block, the target colour is: BLACK';
block_inst{2} = ' ';
block_inst{3} = 'Remember to keep fixated on the centre red dot during the experiment.';
block_inst{4} = '';
block_inst{5} = 'Try your best!';

block2_inst{1} = 'For this block, the target colour is: WHITE';
block2_inst{2} = ' ';
block2_inst{3} = 'Remember to keep fixated on the centre red dot during the experiment.';
block2_inst{4} = '';
block2_inst{5} = 'Try your best!';

%% %%%%% Screen settings %%%%%%

bgd_colour = [128 128 128]; % screen background

screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = Screen('OpenWindow', screenNumber, bgd_colour);
Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
hz = FrameRate(window); data.frame_rate = hz;

Screen(window,'FillRect',bgd_colour);
Screen(window,'TextSize',font_size);

% draw and save the default fixation screen...
Screen('DrawDots',window,[xCenter,yCenter+mask_diam*0.75],5,[255 0 0],[],1);
Screen('DrawDots',window,[xCenter,yCenter-mask_diam*0.75],5,[255 0 0],[],1);
Screen('DrawDots',window,[xCenter,yCenter],5,[255 0 0],[],1); %Make this one the colour of the target dots for given trial

img=Screen('GetImage', window, [], 'backBuffer');
fixScreen = Screen('MakeTexture', window, img);
Screen(window,'FillRect',bgd_colour); % Clear the buffer

% draw and save the first fixation screen...
Screen('DrawDots',window,[xCenter,yCenter+mask_diam*0.75],5,[255 0 0],[],1);
Screen('DrawDots',window,[xCenter,yCenter-mask_diam*0.75],5,[255 0 0],[],1);
Screen('DrawDots',window,[xCenter,yCenter],5,[0 0 0],[],1); %Make this one the colour of the target dots for given trial

img=Screen('GetImage', window, [], 'backBuffer');
black_fixScreen = Screen('MakeTexture', window, img);
Screen(window,'FillRect',bgd_colour); % Clear the buffer

% draw and save the second fixation screen...
Screen('DrawDots',window,[xCenter,yCenter+mask_diam*0.75],5,[255 0 0],[],1);
Screen('DrawDots',window,[xCenter,yCenter-mask_diam*0.75],5,[255 0 0],[],1);
Screen('DrawDots',window,[xCenter,yCenter],5,[255 255 255],[],1); %Make this one the colour of the target dots for given trial

img=Screen('GetImage', window, [], 'backBuffer');
white_fixScreen = Screen('MakeTexture', window, img);
Screen(window,'FillRect',bgd_colour); % Clear the buffer

HideCursor;

%% %%%%%%%%%%%%%%%%%%%%% Experiment%%%%%%%%%%%%%%%

%%% Display instructions

msg_y = 60;
if no_practice_mode == 0 %then give practice
    for n = 1:length(prac_inst)
        msg_y = msg_y+40;
        DrawFormattedText(window, prac_inst{(n)}, 'center', msg_y,[0 0 0]);
    end
else
    for n = 1:length(inst)
        msg_y = msg_y+40;
        DrawFormattedText(window, inst{(n)}, 'center', msg_y,[0 0 0]);
    end
end;

Screen('Flip',window);
WaitSecs(3);

if ismember(computer,[1,3])
    while KbCheck(-1)
    end
elseif computer == 2
    while KbCheck
    end
end

keyIsDown = 0;
ok = false;
while ~ok
    while ~keyIsDown
        if ismember(computer,[1,3])
            [keyIsDown] = KbCheck(-1);
        elseif computer == 2
            [keyIsDown] = KbCheck;
        end
        
        if keyIsDown
            ok = true;
            Screen(window,'FillRect',bgd_colour);
            break;
        end
    end
end

clear msg;

Screen('Flip',window);

%%% Experiment parameters

breaktime = 0;

colour1_counter = 1;
colour2_counter = 1;

w=1;

%%% block loop
for block_count = 1:num_blocks % for 1 to number of blocks
    
    target_colour_directions = target_colour_directions(randperm(size(target_colour_directions,1)),:); %randomise the angles for the block
    
    msg_y = 60;
    
    if Block_order(block_count) == 1
        target_colour_for_trial = dot_colour1;
        codedTargetColour = 1;
        distractor_colour_for_trial = dot_colour2;
        
        for n = 1:length(block_inst)
            msg_y = msg_y+40;
            DrawFormattedText(window, block_inst{(n)}, 'center', msg_y,[255 255 255]);
        end
        
    else
        target_colour_for_trial = dot_colour2;
        codedTargetColour = 2;
        distractor_colour_for_trial = dot_colour1;
        
        for n = 1:length(block2_inst)
            msg_y = msg_y+40;
            DrawFormattedText(window, block2_inst{(n)}, 'center', msg_y,[255 255 255]);
        end
        
    end;
    
    Screen('Flip',window);
    WaitSecs(3);
    
    if ismember(computer,[1,3])
        while KbCheck(-1)
        end
    elseif computer == 2
        while KbCheck
        end
    end
    
    %%% trial loop
    for trial_count = 1:num_trials % for 1 to number of trials
        
        %target/distractor angles
        
        target_angle = (target_colour_directions(trial_count,1));
        distractor_angle = (target_colour_directions(trial_count,2));
        
        % three red dots indicating vertical meridian
        if Block_order(block_count) == 1 % black
            Screen('DrawTexture', window, black_fixScreen);
        else % white
            Screen('DrawTexture', window, white_fixScreen);
        end
        Screen('Flip', window)
        
        pause(0.5);
        
        dir1 = target_angle-90; % Target dot motion direction
        dir2 = distractor_angle-90; % Distractor dot motion direction
        
        data.main_task.data(trial_count,block_count).target_colour = target_colour_for_trial; % #######DAVEL change to incorporate trial_total_counter
        data.main_task.data(trial_count,block_count).dir1 = dir1; % #######DAVEL change to incorporate trial_total_counter
        data.main_task.data(trial_count,block_count).dir2 = dir2; % #######DAVEL change to incorporate trial_total_counter
        
        % create the RDKs
        [Xpositions1,Ypositions1,Xpositions2,Ypositions2,Xpositions_rand1,Ypositions_rand1,Xpositions_rand2,Ypositions_rand2] = make_rdk(num_dots,mask_diam,dist_per_sec,rand_dist_per_sec,xCenter,yCenter,hz,dir1,dir2,trial_range,stim_duration);
        
        response = 0;
        RT = 999999; % #######DAVEL added this here to initialise RT in case they don't respond
        ready_for_response = 1;
        start = GetSecs;
        
        % #######DAVEL - extra code
        d1_idx = randperm(size(Xpositions_rand1,1)); % make a random index for dot/colour 1 info
        d2_idx = randperm(size(Xpositions_rand2,1)); % make a random index for dot/colour 2 info
        d1X = Xpositions_rand1(d1_idx ,:);
        d1Y = Ypositions_rand1(d1_idx ,:);
        d2X = Xpositions_rand2(d2_idx ,:);
        d2Y = Ypositions_rand2(d2_idx ,:);
        % select which of the coherent dots for colour 1 and colour 2 will be used
        cd1_idx = datasample(1:num_dots, num_dots * coherence, 'REPLACE', false); % coherent dot selection for colour 1
        cd2_idx = datasample(1:num_dots, num_dots * coherence, 'REPLACE', false); % coherent dot selection for colour 2
        % determine which random dots the coherent dots are going to take over 
        pcd1_idx = datasample(1:num_dots, num_dots * coherence, 'REPLACE', false); % position index colour 1
        pcd2_idx = datasample(1:num_dots, num_dots * coherence, 'REPLACE', false); % position index colour 2
        % overlay coherent dots onto the top of the random dot info into the pcd1/2 positons
        d1X(pcd1_idx,:) = Xpositions1(cd1_idx,:);
        d1Y(pcd1_idx,:) = Ypositions1(cd1_idx,:);
        d2X(pcd2_idx,:) = Xpositions2(cd2_idx,:);
        d2Y(pcd2_idx,:) = Ypositions2(cd2_idx,:);
        % merge all arrays into X and Y arrays that have both dot1 and dot2 info in it and create a matching colour array for this
        d12X = [d1X; d2X]; % put all X data for dot1 and dot2 into this array
        d12Y = [d1Y; d2Y]; % put all Y data for dot1 and dot2 into this array
        c12 = [repmat(target_colour_for_trial,size(d1X,1),1) ; repmat(distractor_colour_for_trial,size(d2X,1),1)]; % create colour array - firstly dot1/col1 then dot2/col2
        % randomize giant array(s) keeping colour and info in sync with each other
        d12_idx = randperm(size(d12X,1));
        d12X = d12X(d12_idx,:);
        d12Y = d12Y(d12_idx,:);
        c12 = c12(d12_idx,:);
        % #######DAVEL - end of extra code
        
        % draw stimuli to screen...
        for n = 1:ceil(hz*stim_duration)
            Screen('DrawTexture', window, fixScreen);
           
            % #######DAVEL - draw all dots at once with this one command - 
            Screen('DrawDots',window,[d12X(:,n)' ; d12Y(:,n)'], dot_diam, c12',[],1); % draws all the dots at once

            Screen('Flip',window);
            
            if ismember(computer,[1,3])
                [~,~,keycode] = KbCheck(-1);
            elseif computer == 2
                [~,~,keycode] = KbCheck;
            end
            
            if strcmp(KbName(find(keycode == 1,1,'first')), ',<')
                RT = GetSecs-start;
                response = 1;
                ready_for_response = 0;
                ready_for_conf = 1;
                clc
            elseif strcmp(KbName(find(keycode == 1,1,'first')), '.>')
                RT = GetSecs-start;
                response = 2;
                ready_for_response = 0;
                ready_for_conf = 1;
                clc
            end;
        end;
        
        
        Screen('DrawTexture', window, fixScreen);
        Screen('Flip',window);
        
        if dir1 < -90 % correct answer is left
            
            if response == 1 % left
                accuracy = 1;
            else
                accuracy = 0;
            end;
            
        elseif dir1 > -90 % correct answer is right
            
            if response == 2 % right
                accuracy = 1;
            else
                accuracy = 0;
            end;
        end;
        
        if no_practice_mode == 0 % if feedback is required...
            
            if accuracy == 1
                centreText(window,'Correct!',xCenter,yCenter,[0 255 0]);
            elseif accuracy == 0
                centreText(window,'Wrong!',xCenter,yCenter,[255 0 0]);
            end
            
            Screen('Flip', window)
            pause(0.5);
            Screen('Flip', window)
        end
        
        % At the end of each trial, update the data frame
        
        data.main_task.data(trial_count,block_count).response = response; % 
        data.main_task.data(trial_count,block_count).acc = accuracy; % r
        data.main_task.data(trial_count,block_count).rt = RT; % 
        data.main_task.data(block_count,1).block_no = block_count;
        data.main_task.data(trial_count,1).block_no = trial_count;
        
        results(w,:) = [subject, session, block_count, trial_count, codedTargetColour, dir1, dir2, response, accuracy, RT];
        dlmwrite(text_filename,results,'delimiter','\t','precision',8);
        
        w=w+1;
        
    end % end trial loop
    
end % end block loop

%%% save and clean up
runEndTime = datestr(now); data.runEndTime = runEndTime(strfind(runEndTime,' ')+1:end);
if subject ~= 999
    disp('saving...');
    save(save_filename,'data');
end

%end of task screen
% endtext = 'End of task!';
% DrawFormattedText(w_screen, endtext, 'center', 'center');
% Screen('Flip', w_screen);
% tic; while toc < 3; end;

ListenChar(); % Allow keyboard inputs to command line
ShowCursor;
Screen('CloseAll');

end

%% function to create RDK
function [Xpositions,Ypositions,Xpositions2,Ypositions2,Xpositions_rand1,Ypositions_rand1,Xpositions_rand2,Ypositions_rand2] = make_rdk(num_dots,mask_diam,dist_per_sec,rand_dist_per_sec,xCenter,yCenter,hz,dir1,dir2,trial_range,stim_duration);

num_frames = ceil(hz * stim_duration);

% code pre-allocating position of each dot on each frame...

Xpositions = zeros(num_dots,num_frames);
Ypositions = zeros(num_dots,num_frames);
DotAge = zeros(num_dots,1);
Path = zeros(num_dots,1);
Xpositions2 = zeros(num_dots,num_frames);
Ypositions2 = zeros(num_dots,num_frames);
DotAge2 = zeros(num_dots,1);
Path2 = zeros(num_dots,1);
Xpositions_rand1 = zeros(num_dots,num_frames);
Ypositions_rand1 = zeros(num_dots,num_frames);
DotAge_rand1 = zeros(num_dots,1);
Path_rand1 = zeros(num_dots,1);
Xpositions_rand2 = zeros(num_dots,num_frames);
Ypositions_rand2 = zeros(num_dots,num_frames);
DotAge_rand2 = zeros(num_dots,1);
Path_rand2 = zeros(num_dots,1);

angle = 2*pi*rand(1,num_dots);
angle_rand = 2*pi*rand(1,num_dots);
distance = mask_diam/2*sqrt(rand(1,num_dots));

for Dots = 1 : num_dots %for loop determining initial dot positions and ages
    Xpositions(Dots,1) = mask_diam/2 + distance(Dots)*sin(angle(Dots));
    Ypositions(Dots,1) = mask_diam/2 + distance(Dots)*cos(angle(Dots));
    DotAge(Dots) = randsample(0:6,1,true); %age of the dot
    Path(Dots) = dir1-trial_range+((mod(Dots-1,10)/9)*(2*trial_range));
    
    Xpositions2(Dots,1) = mask_diam/2 + distance(Dots)*sin(angle(Dots));
    Ypositions2(Dots,1) = mask_diam/2 + distance(Dots)*cos(angle(Dots));
    DotAge2(Dots) = randsample(0:6,1,true); %age of the dot
    Path2(Dots) = dir2-trial_range+((mod(Dots-1,10)/9)*(2*trial_range));
    
    %         angle = 2*pi*rand(1,num_dots);
    Xpositions_rand1(Dots,1) = mask_diam/2 + distance(Dots)*sin(angle_rand(Dots)); %NOISE
    Ypositions_rand1(Dots,1) = mask_diam/2 + distance(Dots)*cos(angle_rand(Dots));
    DotAge_rand1(Dots) = randsample(0:6,1,true); %age of the dot
    Path_rand1(Dots) = randsample(0:359,1,1);
    
    %         angle = 2*pi*rand(1,num_dots);
    Xpositions_rand2(Dots,1) = mask_diam/2 + distance(Dots)*sin(angle_rand(Dots)); %NOISE
    Ypositions_rand2(Dots,1) = mask_diam/2 + distance(Dots)*cos(angle_rand(Dots));
    DotAge_rand2(Dots) = randsample(0:6,1,true); %age of the dot
    Path_rand2(Dots) = randsample(0:359,1,1);
end;

for a = 2 : (hz*stim_duration)  %for loop determining motion for frames 2 -> end of animation
    
    for d = 1 : num_dots % #######DAVEL change from 1:100 so that all num_dots now have data
        
        Xpositions(d,a) = Xpositions(d,a-1)+(cosd(Path(d)) * (dist_per_sec*(1/hz)) ); % update x co-ordinates of dots
        Ypositions(d,a) = Ypositions(d,a-1)+(sind(Path(d)) * (dist_per_sec*(1/hz)) ); % update y co-ordinates of dots
        Xpositions2(d,a) = Xpositions2(d,a-1)+(cosd(Path2(d)) * (dist_per_sec*(1/hz)) ); % update x co-ordinates of dots
        Ypositions2(d,a) = Ypositions2(d,a-1)+(sind(Path2(d)) * (dist_per_sec*(1/hz)) ); % update y co-ordinates of dots
        Xpositions_rand1(d,a) = Xpositions_rand1(d,a-1)+(cosd(Path_rand1(d)) * (rand_dist_per_sec*(1/hz)) ); % update x co-ordinates of dots
        Ypositions_rand1(d,a) = Ypositions_rand1(d,a-1)+(sind(Path_rand1(d)) * (rand_dist_per_sec*(1/hz)) ); % update y co-ordinates of dots
        Xpositions_rand2(d,a) = Xpositions_rand2(d,a-1)+(cosd(Path_rand2(d)) * (rand_dist_per_sec*(1/hz)) ); % update x co-ordinates of dots
        Ypositions_rand2(d,a) = Ypositions_rand2(d,a-1)+(sind(Path_rand2(d)) * (rand_dist_per_sec*(1/hz)) ); % update y co-ordinates of dots
        
        DotAge(d) = DotAge(d)+1;
        DotAge2(d) = DotAge2(d)+1;
        
        DotAge_rand1(d) = DotAge_rand1(d)+1;
        DotAge_rand2(d) = DotAge_rand2(d)+1;
        
        if (mask_diam/2-Xpositions(d,a))^2 + (mask_diam/2-Ypositions(d,a))^2 > (mask_diam/2)^2
            angle = 2*pi*rand;
            distance = (mask_diam/2)*sqrt(rand);
            
            Xpositions(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge(d) = randsample(0:6,1,true);%xpos is the x co-ordinate
        end;
        
        if (mask_diam/2-Xpositions2(d,a))^2 + (mask_diam/2-Ypositions2(d,a))^2 > (mask_diam/2)^2
            angle = 2*pi*rand;
            distance = (mask_diam/2)*sqrt(rand);
            
            Xpositions2(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions2(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge2(d) = randsample(0:6,1,true);%xpos is the x co-ordinate
        end;
        
        if (mask_diam/2-Xpositions_rand1(d,a))^2 + (mask_diam/2-Ypositions_rand1(d,a))^2 > (mask_diam/2)^2
            angle = 2*pi*rand;
            distance = (mask_diam/2)*sqrt(rand);
            
            Xpositions_rand1(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions_rand1(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge_rand1(d) = randsample(0:6,1,true);%xpos is the x co-ordinate
        end;
        
        if (mask_diam/2-Xpositions_rand2(d,a))^2 + (mask_diam/2-Ypositions_rand2(d,a))^2 > (mask_diam/2)^2
            angle = 2*pi*rand;
            distance = (mask_diam/2)*sqrt(rand);
            
            Xpositions_rand2(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions_rand2(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge_rand2(d) = randsample(0:6,1,true);%xpos is the x co-ordinate
        end;
        
        if DotAge(d) > hz/10
            angle = 2*pi*rand;
            distance = mask_diam/2*sqrt(rand);
            Xpositions(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge(d)=0;
        end;
        
        if DotAge2(d) > hz/10
            angle = 2*pi*rand;
            distance = mask_diam/2*sqrt(rand);
            Xpositions2(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions2(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge2(d)=0;
        end;
        
        if DotAge_rand1(d) > hz/10
            angle = 2*pi*rand;
            distance = mask_diam/2*sqrt(rand);
            Xpositions_rand1(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions_rand1(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge_rand1(d)=0;
        end;
        
        if DotAge_rand2(d) > hz/10
            angle = 2*pi*rand;
            distance = mask_diam/2*sqrt(rand);
            Xpositions_rand2(d,a) = mask_diam/2 + distance*sin(angle);
            Ypositions_rand2(d,a) = mask_diam/2 + distance*cos(angle);
            DotAge_rand2(d)=0;
        end;
    end;
    
end;

Xpositions = Xpositions+xCenter-mask_diam/2;
Ypositions = Ypositions+yCenter-mask_diam/2;
Xpositions2 = Xpositions2+xCenter-mask_diam/2;
Ypositions2 = Ypositions2+yCenter-mask_diam/2;
Xpositions_rand1 = Xpositions_rand1+xCenter-mask_diam/2;
Ypositions_rand1 = Ypositions_rand1+yCenter-mask_diam/2;
Xpositions_rand2 = Xpositions_rand2+xCenter-mask_diam/2;
Ypositions_rand2 = Ypositions_rand2+yCenter-mask_diam/2;

end

function centreText(window,text,x,y,colour)
% center text on (x,y)

[dims]= Screen('TextBounds',window,text,x,y,[]);

Screen('DrawText',window,text,x-dims(3)/2,y,colour);

end
