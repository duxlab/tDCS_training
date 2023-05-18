%function data_extraction_DigitSpan

% RUN CODE ----------------------------------------------------------------

clc

warning('off','all');

stand_alone = 1; %1 = run alone, 0 = run from mother script
    if stand_alone == 1
        subject_numbers = [1]; % subject numbers to analyse
        sessions_to_analyse = [1]; % session numbers to analyse
    end;
    
% file details
raw_output_file = '%d_subs_raw_%s_DotMotion_data.xls';

if stand_alone == 1
    analysed_output_file = sprintf('%d_subs_extracted_DotMotion_data.xls',length(subject_numbers));
end;

task_name = 'Dot_Motion';

% column details for raw data files for each task
column_headings = {'Subj No','Session No','Block No','Trial No','Target direction','Distractor direction','Target colour','Response','Accuracy', 'Reaction time'}; 

identifier_for_string_writing = {'%d','%d','%d','%d','%d','%d','%d','%d','%.4f'};

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
           
            filename=strcat('Dot_Motion_sub_',num2str(subject_numbers(subject_count)),'_session_',num2str(sessions_to_analyse(session_count)),'.txt');
            
            if exist(filename,'file') % check if this logfile exists
                analysed_subj_counter = analysed_subj_counter+1; % keep a tally of how many subjects are actually analysed
                load(filename); % if it does, load the logfile
            else % otherwise, if this logfile doesn't exist...
                fprintf('The following file is missing: %s\n\n',filename); % output to command window
                continue % if the logfile cannot be found, skip to the next participant
            end
            
             ActiveData=dlmread(filename);
             Y=size(ActiveData); Y=Y(1);
             a = 1; b = 1; c = 1; d = 1; e = 1; f = 1; g = 1; h = 1;
             DifficultDiffRT = NaN;
             DifficultSameRT = NaN;
             EasySameRT = NaN;
             EasyDiffRT = NaN;
             
            for Cycle = 1:Y
     
                TarDir = ActiveData(Cycle,6)+90;
                DistDir = ActiveData(Cycle,7)+90;
                
               if TarDir == 30 || TarDir == -30 %easy condition, 30 or -30 degrees from 0
                    if TarDir > 0 && DistDir > 0
                    
                        EasySameAcc(a) = ActiveData(Cycle,9); 
                        if EasySameAcc(a) == 1
                            EasySameRT(b) = ActiveData(Cycle,10); b=b+1;
                        end;
                        a=a+1;
                    elseif TarDir < 0 && DistDir < 0
                        
                        EasySameAcc(a) = ActiveData(Cycle,9); 
                        if EasySameAcc(a) == 1
                            EasySameRT(b) = ActiveData(Cycle,10); b=b+1;
                        end;
                        a=a+1;
                    elseif TarDir < 0 && DistDir > 0
                        
                        EasyDiffAcc(c) = ActiveData(Cycle,9); 
                        if EasyDiffAcc(c) == 1
                            EasyDiffRT(d) = ActiveData(Cycle,10); d=d+1;
                        end;
                        c=c+1;
                    elseif TarDir > 0 && DistDir < 0
                        
                        EasyDiffAcc(c) = ActiveData(Cycle,9); 
                        if EasyDiffAcc(c) == 1
                            EasyDiffRT(d) = ActiveData(Cycle,10); d=d+1;
                        end;
                        c=c+1;
                    end
                    
               else %difficult (15 or -15)
                   if TarDir > 0 && DistDir > 0
                    
                        DifficultSameAcc(e) = ActiveData(Cycle,9); 
                        if DifficultSameAcc(e) == 1
                            DifficultSameRT(f) = ActiveData(Cycle,10); f=f+1;
                        end;
                        e=e+1;
                    elseif TarDir < 0 && DistDir < 0
                        
                        DifficultSameAcc(e) = ActiveData(Cycle,9); 
                        if DifficultSameAcc(e) == 1
                            DifficultSameRT(f) = ActiveData(Cycle,10); f=f+1;
                        end;
                        e=e+1;
                    elseif TarDir < 0 && DistDir > 0
                        
                        DifficultDiffAcc(g) = ActiveData(Cycle,9); 
                        if DifficultDiffAcc(g) == 1
                            DifficultDiffRT(h) = ActiveData(Cycle,10); h=h+1;
                        end;
                        g=g+1;
                    elseif TarDir > 0 && DistDir < 0
                        
                        DifficultDiffAcc(g) = ActiveData(Cycle,9); 
                        if DifficultDiffAcc(g) == 1
                            DifficultDiffRT(h) = ActiveData(Cycle,10); h=h+1;
                        end;
                        g=g+1;
                    end
                   
               end
               
            end; 

             EasySameAccAVG(subject_count,session_count) = mean(EasySameAcc);
             EasyDiffAccAVG(subject_count,session_count) = mean(EasyDiffAcc);
             EasySameRTAVG(subject_count,session_count) = mean(EasySameRT);
             EasyDiffRTAVG(subject_count,session_count) = mean(EasyDiffRT);
             
             DifficultSameAccAVG(subject_count,session_count) = mean(DifficultSameAcc);
             DifficultDiffAccAVG(subject_count,session_count) = mean(DifficultDiffAcc);
             DifficultSameRTAVG(subject_count,session_count) = mean(DifficultSameRT);
             DifficultDiffRTAVG(subject_count,session_count) = mean(DifficultDiffRT);             
             
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
    
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Easy_Same_Acc']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Easy_Different_Acc']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Difficult_Same_Acc']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Difficult_Different_Acc']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Easy_Same_RT']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Easy_Different_RT']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Difficult_Same_RT']));
            fprintf(full_analysed_output_file_ID,'%s\t',sprintf([task_name,'_01_Difficult_Different_RT']));
    

    for subject_count = 1:length(subject_numbers)
        fprintf(full_analysed_output_file_ID,'%s\n','');
        fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
        for session_count = 1:length(sessions_to_analyse)

            fprintf(full_analysed_output_file_ID,'%s\t',num2str(EasySameAccAVG(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(EasyDiffAccAVG(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(DifficultSameAccAVG(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(DifficultDiffAccAVG(subject_count,session_count)));
            
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(EasySameRTAVG(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(EasyDiffRTAVG(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(DifficultSameRTAVG(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(DifficultDiffRTAVG(subject_count,session_count)));

        end
    end

end

%end



