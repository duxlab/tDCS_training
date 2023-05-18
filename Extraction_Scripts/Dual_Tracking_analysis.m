%function data_extraction_Dual_Tracking

% RUN CODE ----------------------------------------------------------------

clc
clear all;
warning('off','all');

subject_numbers = [1]; % subject numbers to analyse
sessions_to_analyse = [1]; % session numbers to analyse

trim_outliers = 1; % 1= trim outliers (using threshold defined by "outlier_threshold_SD"), 0= do not trim outliers

% folder directory details
output_folder_name = 'extracted data output';

% exclusion criteria
outlier_threshold_SD = 3; % drop trials more than 3 SD away from mean (for accuracy and RT)

% file details
logfile_template = 'logfile_single_vs_test_task_sub%s_session_%s.mat';
analysed_output_file = sprintf('%d_subs_extracted_Dual_Tracking_data.xls',length(subject_numbers));

% column details for raw data files for each task
column_headings = {'Subj No','Session No','Block No','Trial No','Presentation Duration','Accuracy'}; 

identifier_for_string_writing = {'%d','%d','%d','%d','%.4f','%d'};

parent_dir = cd;

% RUN CODE ----------------------------------------------------------------
  
    cd(parent_dir); % not needed?
    
    % define and open output files
    full_analysed_output_filename = [parent_dir '/' sprintf(analysed_output_file)];% define full path directory of analysed output file
    full_analysed_output_file_ID = fopen(full_analysed_output_filename,'w'); % open excel file for writing
    
    % define column ID of all headings
    for column_count = 1:length(column_headings)
        heading_name = lower(strrep(column_headings{column_count},' ','_')); % change to lower case and replace and spaces iwth underscores
        eval([heading_name '_column_ID=column_count;']);
    end
    
    % reset these variables at the start of each task loop
    full_data_matrix = {};
    
    for session_count = 1:length(sessions_to_analyse)
        
        analysed_subj_counter = 0;
        trials_to_analyse = [];
        
        for subject_count = 1:length(subject_numbers)
            
            % resets these variables at the start of each subject loop
            data_matrix = [];
            data_matrix_count = 0;
            
            % create subject number string
%             if subject_numbers(subject_count) < 10 % add a zero in front
%                 subject_number_string = ['0' num2str(subject_numbers(subject_count))];
%             else
                 subject_number_string = num2str(subject_numbers(subject_count));
%             end
            
%             % create session number string
%             if sessions_to_analyse(session_count) < 10 % add a zero in front
%                 session_number_string = ['0' num2str(sessions_to_analyse(session_count))];
%             else
                 session_number_string = num2str(sessions_to_analyse(session_count));
%             end
            
            % define and open logfile
            filename = sprintf(logfile_template,subject_number_string,session_number_string);
            if exist(filename,'file') % check if this logfile exists
                analysed_subj_counter = analysed_subj_counter+1; % keep a tally of how many subjects are actually analysed
                load(filename); % if it does, load the logfile
            else % otherwise, if this logfile doesn't exist...
                fprintf('The following logfile is missing: %s\n\n',filename); % output to command window
                continue % if the logfile cannot be found, skip to the next participant
            end
                  
%            ActiveData=dlmread(filename);
            a = 1; b = 1; c = 1; bb=1; cc=1;
                
                % TRIAL LOOP ----------------------------------------------
                
                for trial_count = 1:length(data.trial_no)
                    if data.trial_type_ID(trial_count) == 1 %single task - tracking only
                        Single_tracking_acc(a) = data.trial_tracking_accuracy(trial_count); 
                        a=a+1;
                    elseif data.trial_type_ID(trial_count) == 2 %single task - detection only
                        Single_detection_acc(b) = data.overall_detection_accuracy(trial_count);
                        Single_detection_RT(b) = data.overall_detection_RT(trial_count);
                        b=b+1;
                    elseif data.trial_type_ID(trial_count) == 3 %dual task
                        Dual_tracking_acc(c) = data.trial_tracking_accuracy(trial_count); 
                        Dual_detection_acc(c) = data.overall_detection_accuracy(trial_count);
                        Dual_detection_RT(c) = data.overall_detection_RT(trial_count);
                        c=c+1;
                    end
                    
                end % END OF TRIAL LOOP -----------------------------------
            
            Single_Tracking_Accuracy(analysed_subj_counter,session_count) = mean(Single_tracking_acc); 
            Single_Detection_Accuracy(analysed_subj_counter,session_count) = mean(Single_detection_acc);
            Single_Detection_ReactionTime(analysed_subj_counter,session_count) = mean(Single_detection_RT);
            Dual_Tracking_Accuracy(analysed_subj_counter,session_count) = mean(Dual_tracking_acc); 
            Dual_Detection_Accuracy(analysed_subj_counter,session_count) = mean(Dual_detection_acc);
            Dual_Detection_ReactionTime(analysed_subj_counter,session_count) = mean(Dual_detection_RT);
            
         end % END OF SUBJECT LOOP -----------------------------------------
        
    end % END OF SESSION LOOP

% WRITE RESULTS TO EXCEL FILE -------------------------------------

fprintf(full_analysed_output_file_ID,'%s\t','Sub');
for session_count = 1:length(sessions_to_analyse)
    
    % create session number string
    if sessions_to_analyse(session_count) < 10 % add a zero in front
        session_number_string = ['0' num2str(sessions_to_analyse(session_count))];
    else
        session_number_string = num2str(sessions_to_analyse(session_count));
    end
            
        current_task_name = 'DualTracking';
        fprintf(full_analysed_output_file_ID,'%s\t',sprintf([current_task_name,'_',session_number_string]));

end

for subject_count = 1:length(subject_numbers)
    fprintf(full_analysed_output_file_ID,'%s\n','');
    fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
    for session_count = 1:length(sessions_to_analyse)
        
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(Single_Tracking_Accuracy(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(Single_Detection_Accuracy(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(Single_Detection_ReactionTime(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(Dual_Tracking_Accuracy(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(Dual_Detection_Accuracy(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(Dual_Detection_ReactionTime(subject_count,session_count)));
        
    end
end
%end






