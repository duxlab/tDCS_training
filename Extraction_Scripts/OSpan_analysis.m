function data_extraction_OSpan

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
logfile_template = 'Shane_Yohan_data_logfile_for_OSpan_task_sub_%s_session_%s.mat';
analysed_output_file = sprintf('%d_subs_extracted_OSPAN_data.xls',length(subject_numbers));

task_name = 'OSpan';
% column details for raw data files for each task
column_headings = {'Subj No','Session No','Block No','Trial No','Math Equation','Math Trial Type','Math Accuracy','Letter','Letter Accuracy'};

identifier_for_string_writing = {'%d','%d','%d','%d','%s','%d','%d','%s','%d'}; 

parent_dir = cd;

% RUN CODE ----------------------------------------------------------------
    
    cd(parent_dir); % make sure the script always goes back to the data directory after analysing each task
    
    % define and open output file
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
            if subject_numbers(subject_count) < 10 % add a zero in front
                subject_number_string = ['0' num2str(subject_numbers(subject_count))];
            else
                subject_number_string = num2str(subject_numbers(subject_count));
            end
            
            % create session number string
            if sessions_to_analyse(session_count) < 10 % add a zero in front
                session_number_string = ['0' num2str(sessions_to_analyse(session_count))];
            else
                session_number_string = num2str(sessions_to_analyse(session_count));
            end
            
            % define and open logfile
            logfile_name = sprintf(logfile_template,subject_number_string,session_number_string);
            if exist(logfile_name,'file') % check if this logfile exists
                analysed_subj_counter = analysed_subj_counter+1; % keep a tally of how many subjects are actually analysed
                load(logfile_name); % if it does, load the logfile
            else % otherwise, if this logfile doesn't exist...
                fprintf('The following logfile is missing: %s\n\n',logfile_name); % output to command window
                continue % if the logfile cannot be found, skip to the next participant
            end
            
            temp_trial_no = data.trial_no;

            for block_count = 1:length(data.block_no)
                
                % TRIAL LOOP ----------------------------------------------
 %               if strcmp(task_names{tasks_to_analyse(task_count)},'OSpan_task')
                    data.trial_no = temp_trial_no(:,block_count);
  %              end
                
                for trial_count = 1:length(data.trial_no)
                    data_matrix{subj_no_column_ID} = subject_numbers(subject_count);
                    data_matrix{session_no_column_ID} = session_count;
                    data_matrix{block_no_column_ID} = block_count;
                    data_matrix{trial_no_column_ID} = trial_count;
%                    strcmp(task_names{tasks_to_analyse(task_count)},'OSpan_task')
                        if data.trial_no(trial_count,1) == 0 
                            data_matrix{math_equation_column_ID} = NaN;
                            data_matrix{math_trial_type_column_ID} = NaN;
                            data_matrix{math_accuracy_column_ID} = NaN;
                            data_matrix{letter_column_ID} = NaN;
                            data_matrix{letter_accuracy_column_ID} = NaN;
                        else
                            data_matrix{math_equation_column_ID} = data.math_equation{trial_count,block_count};
                            data_matrix{math_trial_type_column_ID} = data.math_trial_type(trial_count,block_count);
                            data_matrix{math_accuracy_column_ID} = data.math_accuracy(trial_count,block_count);
                            data_matrix{letter_column_ID} = data.letters{trial_count,block_count};
                            data_matrix{letter_accuracy_column_ID} = data.accuracy(trial_count,block_count);
                        end   
                        
                    data_matrix_count = data_matrix_count + 1;
                    full_data_matrix(data_matrix_count,1:size(data_matrix,2),analysed_subj_counter) = data_matrix;
                    
                end % END OF TRIAL LOOP -----------------------------------
                
            end % END OF BLOCK LOOP ---------------------------------------
            
               
             OSpan(analysed_subj_counter,session_count) = data.OSpan_score; 
            
        end % END OF SUBJECT LOOP -----------------------------------------      
end

% WRITE RESULTS TO EXCEL FILE -------------------------------------

fprintf(full_analysed_output_file_ID,'%s\t','Sub');
for session_count = 1:length(sessions_to_analyse)
    
    % create session number string
    if sessions_to_analyse(session_count) < 10 % add a zero in front
        session_number_string = ['0' num2str(sessions_to_analyse(session_count))];
    else
        session_number_string = num2str(sessions_to_analyse(session_count));
    end
            
end

for subject_count = 1:length(subject_numbers)
    fprintf(full_analysed_output_file_ID,'%s\n','');
    fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
    for session_count = 1:length(sessions_to_analyse)
        if exist('OSpan') == 1
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(OSpan(subject_count,session_count)));
        end
    end
end
