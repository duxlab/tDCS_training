%function data_extraction_GoNoGO

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
logfile_template = 'data_logfile_exp_EFIL_sub_0%s_GNG_session_%s.mat';
%raw_output_file = '%d_subs_raw_%s_GoNoGo_data.xls';
analysed_output_file = sprintf('%d_subs_extracted_GoNoGO_data.xls',length(subject_numbers));

task_name = 'GoNoGo';

% column details for raw data files for each task
column_headings = {'Subj No','Session No','Block No','Trial No','Trial type','Go Reaction time','NoGo Reaction time','Accuracy','MW probe', 'MW Reaction Time'}; 

identifier_for_string_writing = {'%d','%d','%d','%d','%d','%.4f','%.4f','%d','%d','%d'};

parent_dir = cd;

% RUN CODE ----------------------------------------------------------------
  
    cd(parent_dir); % not needed?
    
    % define and open output files
%    full_raw_output_filename = [parent_dir '/' sprintf(raw_output_file,length(subject_numbers))];% define full path directory of raw output file
%    full_raw_output_file_ID = fopen(full_raw_output_filename,'w'); % open excel file for writing
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
%             if sessions_to_analyse(session_count) < 10 % add a zero in front
%                 session_number_string = ['0' num2str(sessions_to_analyse(session_count))];
%             else
                session_number_string = num2str(sessions_to_analyse(session_count));
%             end
            
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
            
            NoGoCounter = 1;
            GoCounter = 1;
            a = 1; b = 1; c=1; d=1;

            for block_count = 1:length(data.block_no)
                
                % TRIAL LOOP ----------------------------------------------
                
                for trial_count = 1:length(data.trial_no)
                    
                    if data.trial_type_order(trial_count,block_count) == 1 %go trial
                        goAccuracy(a) = data.accuracy(trial_count,block_count); 
                        if goAccuracy(a) == 1
                            goRT(b) = data.go_reaction_time(trial_count,block_count); b=b+1;
                        end
                        a=a+1;
                    else %no go
                        nogoAccuracy(c) = data.accuracy(trial_count,block_count); 
                        if nogoAccuracy(c) == 0
                            nogoRT(d) = data.nogo_reaction_time(trial_count,block_count); d=d+1;
                        end
                        c=c+1;
                    end
                    
%                     if data.mindWanderingProbe > 0
%                         
%                     end;
                    
                end % END OF TRIAL LOOP -----------------------------------
                
            end % END OF BLOCK LOOP ---------------------------------------
            
            % INDIVIDUAL SUBJECT DESCRIPTIVE STATISTICS -------------------
            
            Go_RT_Mean(session_count, subject_count) = mean(goRT);
            NoGo_RT_Mean(session_count, subject_count) = mean(nogoRT);
            Go_Ac_Mean(session_count, subject_count) = mean(goAccuracy);
            NoGo_Ac_Mean(session_count, subject_count) = mean(nogoAccuracy);
            
%             MW_Probe(session_count, subject_count) = mean([full_data_matrix{:,mw_probe_column_ID,analysed_subj_counter}]);
%             MW_RT(session_count, subject_count) = mean([full_data_matrix{:,mw_reaction_time_column_ID,analysed_subj_counter}]);
            
%             % write column headings to open excel file
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
        
              fprintf(full_analysed_output_file_ID,'%s\t',num2str(Go_RT_Mean(session_count, subject_count)));
              fprintf(full_analysed_output_file_ID,'%s\t',num2str(NoGo_RT_Mean(session_count, subject_count)));
              fprintf(full_analysed_output_file_ID,'%s\t',num2str(Go_Ac_Mean(session_count, subject_count)));
              fprintf(full_analysed_output_file_ID,'%s\t',num2str(NoGo_Ac_Mean(session_count, subject_count)));
%               fprintf(full_analysed_output_file_ID,'%s\t',num2str(MW_Probe(session_count, subject_count)));
%               fprintf(full_analysed_output_file_ID,'%s\t',num2str(MW_RT(session_count, subject_count)));
        
    end
end
%end






