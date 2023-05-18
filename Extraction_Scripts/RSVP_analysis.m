function data_extraction_RSVP

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
logfile_template = 'data_logfile_for_single_target_RSVP_task_sub_%s_session_%s.mat';
analysed_output_file = sprintf('%d_subs_extracted_RSVP_data.xls',length(subject_numbers));

task_name = 'RSVP';

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
                
                for trial_count = 1:length(data.trial_no)
                    data_matrix{subj_no_column_ID} = subject_numbers(subject_count);
                    data_matrix{session_no_column_ID} = session_count;
                    data_matrix{block_no_column_ID} = block_count;
                    data_matrix{trial_no_column_ID} = trial_count;
                    strcmp(task_name,'single_target_RSVP_task')
                        data_matrix{accuracy_column_ID} = data.T1_accuracy(trial_count,block_count);
                        data_matrix{presentation_duration_column_ID} = data.duration_stimuli(trial_count,block_count);
                        
                    data_matrix_count = data_matrix_count + 1;
                    full_data_matrix(data_matrix_count,1:size(data_matrix,2),analysed_subj_counter) = data_matrix;
                    
                end % END OF TRIAL LOOP -----------------------------------
                
            end % END OF BLOCK LOOP ---------------------------------------
            
            % INDIVIDUAL SUBJECT DESCRIPTIVE STATISTICS -------------------
            
%            strcmp(task_names{tasks_to_analyse(task_count)},'single_target_RSVP_task') % ...for single target RSVP task
            RSVP_duration(analysed_subj_counter,session_count) = mean([full_data_matrix{:,presentation_duration_column_ID,analysed_subj_counter}]); % mean stimulus duration
            
            % write column headings to open excel file
%             if analysed_subj_counter == 1 && session_count == 1 % for the first subject, put column headers at the top of matrix
%                 fprintf(full_raw_output_file_ID,'%s\t',column_headings{:});
%                 fprintf(full_raw_output_file_ID,'\n');
%             end
%             
%             % write full_data_matrix to open excel file
%             
%             for analysis_matrix_row_count = 1:size(full_data_matrix,1)
%                 for analysis_matrix_col_count = 1:size(full_data_matrix,2)
%                     fprintf(full_raw_output_file_ID,[identifier_for_string_writing{task_name}{analysis_matrix_col_count} '\t'],full_data_matrix{analysis_matrix_row_count,analysis_matrix_col_count,analysed_subj_counter}); % write value to excel file
%                 end
%                 fprintf(full_raw_output_file_ID,'\n');
%             end
%             
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
            
        current_task_name = task_name;
        fprintf(full_analysed_output_file_ID,'%s\t',sprintf([current_task_name,'_',session_number_string]));

end

for subject_count = 1:length(subject_numbers)
    fprintf(full_analysed_output_file_ID,'%s\n','');
    fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
    for session_count = 1:length(sessions_to_analyse)
        
        if exist('RSVP_duration') == 1
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(RSVP_duration(subject_count,session_count)));
        end
        
    end
end
end






