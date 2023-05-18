%function data_extraction_DigitSpan

% RUN CODE ----------------------------------------------------------------

clc

warning('off','all');

stand_alone = 1; %1 = run alone, 0 = run from mother script
    if stand_alone == 1
        subject_numbers = [1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 21 23]; % subject numbers to analyse
      %  subject_numbers = [23];
        sessions_to_analyse = [1 6]; % session numbers to analyse
    end;

% file details
raw_output_file = '%d_subs_raw_%s_DigitSpan_data.xls';

if stand_alone == 1
    analysed_output_file = sprintf('%d_subs_extracted_DigitSpan_data.xls',length(subject_numbers));
end;

task_name = 'Digit_Span';

% column details for raw data files for each task
column_headings = {'Subj No','Session No','Task Direction','Trial No','Trial length','Accuracy'}; 

identifier_for_string_writing = {'%d','%d','%d','%d','%d','%d'};

parent_dir = cd;

% RUN CODE ----------------------------------------------------------------
  
    cd(parent_dir); % not needed?
    
    % define and open output files
    full_raw_output_filename = [parent_dir '/' sprintf(raw_output_file,length(subject_numbers))];% define full path directory of raw output file
    full_raw_output_file_ID = fopen(full_raw_output_filename,'w'); % open excel file for writing
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
        Direction = 0;
        
        for subject_count = 1:length(subject_numbers)
            
            % resets these variables at the start of each subject loop
            data_matrix = [];
            data_matrix_count = 0;
            FORCorrectLength = [];
            FORErrorLength = [];
            BACKCorrectLength = [];
            BACKErrorLength = [];
           
            filename=strcat('Digit_span_',num2str(subject_numbers(subject_count)),'_session_',num2str(sessions_to_analyse(session_count)),'_.txt');
            
            if exist(filename,'file') % check if this logfile exists
                analysed_subj_counter = analysed_subj_counter+1; % keep a tally of how many subjects are actually analysed
                load(filename); % if it does, load the logfile
            else % otherwise, if this logfile doesn't exist...
                fprintf('The following file is missing: %s\n\n',filename); % output to command window
                continue % if the logfile cannot be found, skip to the next participant
            end
            
             ActiveData=dlmread(filename);
             Y=size(ActiveData); Y=Y(1);
             a = 1; b = 1; c = 1; d = 1;
             
            for Cycle = 1:Y
     
               if ActiveData(Cycle,1)==1 % Forward
                   Direction = 1;
               elseif ActiveData(Cycle,1) == 2
                   Direction = 2;
               end; 

               if ActiveData(Cycle,1)==1 %forward direction
                   if ActiveData(Cycle,4) == 1 %if trial was correct
                       FORCorrectLength(a) = ActiveData(Cycle,3);
                       a = a+1;
                   else
                       FORErrorLength(b) = ActiveData(Cycle,3);
                       b = b+1;
                   end;
               elseif ActiveData(Cycle,1) == 2 %backward direction
                   if ActiveData(Cycle,4) == 1 %if trial was correct
                       BACKCorrectLength(c) = ActiveData(Cycle,3);
                       c = c+1;
                   else
                       BACKErrorLength(d) = ActiveData(Cycle,3);
                       d = d+1;
                   end;
               end;
               
               
            end; 

             maxFORValue(subject_count,session_count) = max(FORCorrectLength); maxBACKValue(subject_count,session_count) = max(BACKCorrectLength);
             
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


    end
    
    if length(sessions_to_analyse) == 1
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Forward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Backward']));
    elseif length(sessions_to_analyse) == 2
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Forward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Backward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_02_Forward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_02_Backward']));
    elseif length(sessions_to_analyse) == 3
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Forward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Backward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_02_Forward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_02_Backward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_03_Forward']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_03_Backward']));

    end;

    for subject_count = 1:length(subject_numbers)
        fprintf(full_analysed_output_file_ID,'%s\n','');
        fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
        for session_count = 1:length(sessions_to_analyse)

            fprintf(full_analysed_output_file_ID,'%s\t',num2str(maxFORValue(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(maxBACKValue(subject_count,session_count)));

        end
    end

end

%end



