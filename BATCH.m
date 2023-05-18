%Scip0rt to batch the running of a behavioural task battery
%Inputs subject details, allocates randomisation conditions and runs 0  tasks
%in predefined order
%Option to skip to a certain task number
%Written by HF, September 201


subject_number = input('Subject number? ');
session_number = input('Session number? ');
if session_number > 1
    Tracking_Thresholding_Value = input('Tracking task threshold for tracking: ');
    Detection_Threshold_Value = input('Tracking task threshold for detection: ');
    RSVP_Speed = input('RSVP speed: ');
else
    Tracking_Thresholding_Value = NaN;
    Detection_Threshold_Value = NaN;
    RSVP_Speed = NaN;
end

starting_point = input('Task Number to start with?'); %change this to start further along the list of tasks (in case of a crash, etc)

if session_number ==1 
    phase_exp_colours = 1; %Set this to include all practice as default for session 1, to start at '3' for session 2+
else
    phase_exp_colours = 3;
end

phase_exp_symbols = 1;

tasks = {'Dot_Motion_practice','Dot_Motion','Digit_Span','Visual_Search_Practice','Visual_Search','Dual_Circles','Dual_Symbols','OSpan_prac','OSpan', 'Go_no_Go_MW','Dual_Tracking_Detection','RSVP'};

%randomisation for task order allocation, determined via 'shuffle' in
%matlab. Only goes up to 250 subjects.
Task_orders_for_subjects = [5,5,2,4,2,1,3,4,5,1,2,3,2,2,5,4,2,2,5,6,4,2,1,5,3,1,4,6,3,3,2,1,2,6,5,3,4,3,2,3,2,6,3,4,1,6,3,3,6,1,3,6,5,4,1,6,1,5,6,4,5,6,4,1,4,5,6,3,5,6,5,4,2,3,4,4,5,4,1,1,3,6,4,5,6,1,3,3,3,4,5,2,1,2,4,6,2,3,3,4,5,5,4,6,3,2,2,5,6,2,5,6,3,5,5,4,2,5,6,1,3,1,3,2,1,1,2,5,2,1,2,2,5,4,4,3,6,1,3,3,6,1,4,4,4,4,4,5,6,6,1,5,6,4,1,1,2,6,5,4,6,3,6,2,1,4,2,2,6,6,3,3,5,3,5,5,5,6,1,1,2,6,5,4,3,1,4,3,6,2,1,4,1,6,2,4,3,6,1,6,5,6,5,1,5,5,1,2,2,1,2,4,2,4,4,2,2,6,6,5,3,1,5,4,3,1,2,1,1,1,4,1,5,6,3,3,5,6,3,5,1,4,2,2,3,4,3,2,1,3];
if Task_orders_for_subjects(subject_number) == 1
    task_order_to_use = [4 3 2 7 8 1 9 6 5]; 
elseif Task_orders_for_subjects(subject_number) == 2
    task_order_to_use = [1 4 3 9 5 2 7 8 6]; 
elseif Task_orders_for_subjects(subject_number) == 3
    task_order_to_use = [5 3 6 7 4 1 2 9 8]; 
elseif Task_orders_for_subjects(subject_number) == 4
    task_order_to_use = [6 5 1 9 8 2 3 7 4]; 
elseif Task_orders_for_subjects(subject_number) == 5
    task_order_to_use = [8 6 7 2 5 1 3 4 9];
elseif Task_orders_for_subjects(subject_number) == 6
    task_order_to_use = [9 5 6 1 4 2 3 7 8];  % if you want to make this task order put RSVP, Visser and RDM first [9 3 1 6 4 2 5 7 8]
end

number_of_tasks = length(task_order_to_use);

%random selection (between 1 and 3) for the stimulus orders for each of the
%four different sets of stimuli to be controlled. Orders generated using a
%loop with shuffle in matlab.
orders_controlled = [3,1,3,3;1,1,2,2;1,3,3,1;1,2,1,2;2,3,2,2;1,2,1,2;1,1,2,2;1,2,2,3;3,2,2,1;3,3,3,3;2,1,1,2;2,2,1,2;2,2,2,2;2,3,2,3;2,3,2,3;3,3,3,3;2,3,1,1;1,3,1,1;1,3,1,1;3,1,3,2;1,2,2,3;2,3,1,1;3,2,1,2;3,2,2,2;2,2,1,3;1,1,2,3;1,2,2,1;2,2,3,2;2,2,2,1;3,2,3,2;2,1,2,3;1,3,2,3;2,2,1,1;1,2,2,1;1,2,2,1;1,2,2,2;1,3,3,3;3,2,3,1;1,3,3,1;2,2,2,2;3,1,3,2;1,3,3,3;2,1,1,2;1,2,3,3;3,2,3,3;3,3,3,1;1,1,2,3;2,3,3,1;3,3,1,2;2,3,3,2;2,2,3,2;1,1,3,1;1,2,2,1;3,1,2,3;3,3,2,1;1,3,1,2;2,1,1,1;2,3,1,2;2,2,1,2;1,2,3,3;2,2,3,3;2,3,2,1;1,3,2,3;2,3,1,1;1,1,3,3;2,1,3,1;1,1,2,3;2,2,3,3;2,2,2,1;2,1,1,1;2,3,2,3;2,1,3,1;2,1,1,3;2,3,2,3;3,3,3,3;3,2,2,3;1,3,1,2;3,3,1,3;3,3,2,2;3,1,1,3;2,1,2,3;3,3,3,1;3,3,1,3;3,2,2,1;1,2,1,2;2,2,3,3;2,1,1,2;3,1,2,2;1,3,2,3;2,3,3,1;2,2,1,1;1,1,3,2;1,3,1,2;1,2,1,1;1,1,1,1;2,3,3,1;1,3,1,2;1,1,1,1;1,3,2,2;3,2,1,2;1,1,3,2;2,3,2,2;3,3,1,1;1,2,1,2;1,1,1,2;1,1,1,2;1,1,2,1;3,3,1,2;1,1,1,1;1,1,2,3;1,2,3,3;1,1,3,3;3,2,3,3;2,1,1,2;1,2,2,3;3,3,1,2;1,3,2,3;3,2,1,2;2,3,2,1;2,1,1,3;3,1,2,3;3,1,2,1;1,1,2,2;3,1,2,2;2,3,1,3;1,3,1,1;3,2,3,2;1,2,2,3;2,3,1,3;3,1,3,3;1,2,1,3;2,1,1,1;2,3,1,3;2,2,3,2;3,2,1,3;3,1,3,3;1,1,3,2;2,2,3,1;3,1,3,1;3,3,2,2;2,1,1,1;2,2,2,3;1,3,1,1;1,3,3,1;3,1,3,3;2,2,2,2;3,1,2,1;3,2,1,2;2,3,1,1;1,3,2,2;1,3,2,2;3,1,2,2;3,3,2,2;3,1,2,2;1,2,1,3;1,3,1,3;3,3,2,3;2,3,3,2;1,2,3,1;1,2,1,3;2,3,1,1;2,3,1,2;2,2,2,1;3,3,1,2;3,2,3,1;1,1,3,2;2,3,2,3;1,1,2,2;3,1,1,3;1,3,3,2;2,3,3,1;2,1,3,3;2,1,3,1;2,2,1,2;3,1,3,1;3,3,3,2;1,2,1,2;3,3,2,2;1,1,3,2;1,3,3,1;1,2,3,1;3,1,3,3;2,2,1,1;1,2,1,1;3,2,3,2;2,2,3,3;3,3,1,3;3,3,2,1;2,2,3,2;2,2,1,2;1,2,1,2;1,2,3,2;1,3,1,3;1,2,1,1;3,1,1,3;1,1,1,3;3,3,2,3;1,3,1,3;2,1,1,1;2,1,1,3;2,1,1,3;3,3,1,2;1,2,2,1;1,3,2,3;2,2,3,1;3,1,2,2;3,1,1,3;2,1,1,2;3,3,1,2;1,2,2,2;2,1,2,2;2,3,3,3;3,1,2,2;1,2,3,3;3,3,2,3;1,2,1,2;1,1,3,3;3,3,2,3;2,3,2,2;2,1,1,1;1,1,1,1;2,2,3,3;2,1,2,3;1,2,3,1;2,2,1,3;3,2,2,1;1,2,1,1;2,1,1,1;2,1,2,3;2,1,1,3;3,3,2,1;2,3,1,2;3,2,1,1;1,1,3,2;2,3,2,2;2,3,3,2;3,1,3,3;2,1,1,1;3,2,2,2;1,1,1,3;3,2,1,2;1,2,3,3;3,1,1,2;1,2,1,2;3,3,1,2;3,2,2,2;3,2,1,2;2,1,1,1;1,2,1,3;1,2,2,1];
visual_order_colours = orders_controlled(subject_number,1);
sound_order_colours = orders_controlled(subject_number,2);
visual_order_symbols = orders_controlled(subject_number,3);
sound_order_symbols = orders_controlled(subject_number,4);
   
%Allocate 'hand' to use for the two Dual task scripts
if rem(((subject_number)/2),1) == 0 %if subject number is even
    Hand = 1;
else
    Hand = 2;
end

Main_Directory = ('/Users/duxlab/Documents/Experiments/Battery_TASKS');

%save all of this info to a subject text file for the experiment scripts to
%use
filename = strcat('Current_subject.txt'); 
datafilepointer = fopen(filename,'wt');
results(1,:) = [subject_number, session_number,visual_order_colours,sound_order_colours,visual_order_symbols,sound_order_symbols,phase_exp_colours,Hand,Tracking_Thresholding_Value, Detection_Threshold_Value, RSVP_Speed];
dlmwrite(filename,results,'delimiter','\t','precision',8);

%set up directory and run task for each in turn
for task_tracker = starting_point:number_of_tasks
    
    if task_order_to_use(task_tracker) == 1 %Dot Motion
        directory = tasks{2}; 
        cd(directory)
        run(tasks{1})
        run(tasks{2})
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 2 % Digit Span
        directory = tasks{3}; 
        cd(directory)
        run(tasks{3})
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 3 % Visual Search
        directory = tasks{5}; 
        cd(directory)
        run(tasks{4}) %practice
        run(tasks{5}) %main
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 4 %Dual colours
        directory = tasks{6}; 
        cd(directory)
        run(tasks{6})
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 5 %Dual symbols
        directory = tasks{7}; 
        cd(directory)
        run(tasks{7})
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 6 %OSpan
        directory = tasks{9}; 
        cd(directory)
        run(tasks{8}) %practice
        run(tasks{9}) %main
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 7 %Go no go (and MW)
        directory = tasks{10}; 
        cd(directory)
        run(tasks{10})
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 8 %Dual tracking
        directory = tasks{11}; 
        cd(directory)
        run(tasks{11})
        cd(Main_Directory)
    elseif task_order_to_use(task_tracker) == 9  %RSVP      
        directory = tasks{12}; 
        cd(directory)
        run(tasks{12})
        cd(Main_Directory)
    end
    
end