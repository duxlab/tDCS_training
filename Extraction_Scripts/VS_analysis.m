%function data_extraction_VS

% RUN CODE ----------------------------------------------------------------

clc

warning('off','all');

stand_alone = 1; %1 = run alone, 0 = run from mother script
  
subject_numbers = [1]; % subject numbers to analyse
sessions_to_analyse = [1]; % session numbers to analyse

% file details

if stand_alone == 1
    analysed_output_file = sprintf('%d_subs_extracted_VS_data.xls',length(subject_numbers));
end;

% column details for raw data files for each task
column_headings = {'Subj No','Session No','Block No','Trial No','Set Size','Reaction time','Accuracy'}; 

identifier_for_string_writing = {'%d','%d','%d','%d','%d','%.4f','%d'};

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
           
            filename=strcat('Visual_Search_',num2str(subject_numbers(subject_count)),'_2_Session_',num2str(sessions_to_analyse(session_count)),'.txt');
            
            if exist(filename,'file') % check if this logfile exists
                analysed_subj_counter = analysed_subj_counter+1; % keep a tally of how many subjects are actually analysed
                load(filename); % if it does, load the logfile
            else % otherwise, if this logfile doesn't exist...
                fprintf('The following file is missing: %s\n\n',filename); % output to command window
                continue % if the logfile cannot be found, skip to the next participant
            end
            
             ActiveData=dlmread(filename);
             Y=size(ActiveData); Y=Y(1);
             A=1; B=1; C=1;  AA=1; BB=1; CC=1;
             
            for Cycle = 1:Y
     
               if ActiveData(Cycle,9)==8 % Set Size 8
                    AccuracySS8((subject_count),AA) = ActiveData(Cycle,18);
                     if ActiveData(Cycle,18)>0 
                        BASICDataRTss8(subject_count,A) = (ActiveData(Cycle,19));
                        A=A+1;
                     end;
                     AA=AA+1;
               elseif ActiveData(Cycle,9)==12 %set size 12
                   AccuracySS12((subject_count),BB) = ActiveData(Cycle,18);
                     if ActiveData(Cycle,18)>0 
                        BASICDataRTss12(subject_count,B) = (ActiveData(Cycle,19));
                        B=B+1;
                     end;
                     BB=BB+1;
               elseif ActiveData(Cycle,9)==16 %set size 16
                   AccuracySS16((subject_count),CC) = ActiveData(Cycle,18);
                     if ActiveData(Cycle,18)>0 
                        BASICDataRTss16(subject_count,C) = (ActiveData(Cycle,19));
                        C=C+1;
                     end;
                     CC=CC+1;
               end;   

%                 data_matrix{subj_no_column_ID} = subject_numbers(subject_count);
%                 data_matrix{session_no_column_ID} = session_count;
%                 data_matrix{block_no_column_ID} = ActiveData(Cycle,6);
%                 data_matrix{trial_no_column_ID} = ActiveData(Cycle,7);
%                 data_matrix{set_size_no_column_ID} = ActiveData(Cycle,9);
%                 data_matrix{reaction_time_no_column_ID} = ActiveData(Cycle,19);
%                 data_matrix{accuracy_no_column_ID} = ActiveData(Cycle,18);
%                 
%                 data_matrix_count = data_matrix_count + 1;
%                 full_data_matrix(data_matrix_count,1:size(data_matrix,2),analysed_subj_counter) = data_matrix;
               
            end; 

             

             %calculate mean accuracy
             VS_SS8_AC(subject_count,1) = mean(AccuracySS8((subject_count),:));
             VS_SS12_AC(subject_count,1) = mean(AccuracySS12((subject_count),:));
             VS_SS16_AC(subject_count,1) = mean(AccuracySS16((subject_count),:));

             % for the RTs, replace any 0's with NaN;
             BASICDataRTss8(BASICDataRTss8 == 0) = NaN;
             BASICDataRTss12(BASICDataRTss12 == 0) = NaN;
             BASICDataRTss16(BASICDataRTss16 == 0) = NaN;
                

            for condition = 1:3 
                if condition == 1
                   UpperLimit=((nanmean(BASICDataRTss8((subject_count),:)))+(3*(nanstd(BASICDataRTss8((subject_count),:)))));
                   Y=size(BASICDataRTss8); NumDataPoints=Y(2);
                elseif condition == 2
                   UpperLimit=((nanmean(BASICDataRTss12((subject_count),:)))+(3*(nanstd(BASICDataRTss12((subject_count),:)))));
                   Y=size(BASICDataRTss12); NumDataPoints=Y(2);
                elseif condition == 3
                   UpperLimit=((nanmean(BASICDataRTss16((subject_count),:)))+(3*(nanstd(BASICDataRTss16((subject_count),:)))));
                   Y=size(BASICDataRTss16); NumDataPoints=Y(2);
                end;

                    for Cycle = 1:NumDataPoints
                        if condition == 1
                            if BASICDataRTss8(subject_count,Cycle)>0.2 && BASICDataRTss8(subject_count,Cycle)<UpperLimit
                                RTCroppedss8(subject_count,Cycle) = BASICDataRTss8(subject_count,Cycle);
                            end
                        elseif condition == 2
                            if BASICDataRTss12(subject_count,Cycle)>0.2 && BASICDataRTss12(subject_count,Cycle)<UpperLimit
                                RTCroppedss12(subject_count,Cycle) = BASICDataRTss12(subject_count,Cycle);
                            end
                        elseif condition == 3
                            if BASICDataRTss16(subject_count,Cycle)>0.2 && BASICDataRTss16(subject_count,Cycle)<UpperLimit
                                RTCroppedss16(subject_count,Cycle) = BASICDataRTss16(subject_count,Cycle);
                            end
                        end;

                    end

                     if condition == 1
                         VS_SS8_RT(subject_count,1) = nanmean(RTCroppedss8(subject_count,:));
                     elseif condition == 2
                         VS_SS12_RT(subject_count,1) = nanmean(RTCroppedss12(subject_count,:));
                     elseif condition == 3
                         VS_SS16_RT(subject_count,1) = nanmean(RTCroppedss16(subject_count,:));
                     end;

            end
            
          % INDIVIDUAL SUBJECT DESCRIPTIVE STATISTICS -------------------
            
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
            
        end
        
    end

     
% WRITE RESULTS TO EXCEL FILE -------------------------------------

if stand_alone == 1
    
    fprintf(full_analysed_output_file_ID,'%s\t','Sub');

    for session_count = 1:length(sessions_to_analyse)

        % create session number string
        if sessions_to_analyse(session_count) < 10 % add a zero in front
            session_number_string = ['0' num2str(sessions_to_analyse(session_count))];
        else
            session_number_string = num2str(sessions_to_analyse(session_count));
        end

%             fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_',session_number_string]));

    end

    for subject_count = 1:length(subject_numbers)
        fprintf(full_analysed_output_file_ID,'%s\n','');
        fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
        for session_count = 1:length(sessions_to_analyse)

            fprintf(full_analysed_output_file_ID,'%s\t',num2str(VS_SS8_RT(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(VS_SS12_RT(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(VS_SS16_RT(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(VS_SS8_AC(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(VS_SS12_AC(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(VS_SS16_AC(subject_count,session_count)));

        end
    end

end

%end



