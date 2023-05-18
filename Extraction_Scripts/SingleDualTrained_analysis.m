%function data_extraction_SingleDualTrained

% RUN CODE ----------------------------------------------------------------

clc

warning('off','all');

stand_alone = 1; %1 = run alone, 0 = run from mother script
    if stand_alone == 1
        subject_numbers = [1:207]; % subject numbers to analyse
        sessions_to_analyse = [1 6]; % session numbers to analyse
    end;


if stand_alone == 1
    analysed_output_file = sprintf('%d_subs_extracted_SingleDualTrained_data.xls',length(subject_numbers));
end;

% column details for raw data files for each task
column_headings = {'Subj No','Session No','Block No','Trial No','Trial type','T1 Reaction time','T1 Accuracy', 'T2 Reaction time', 'T2 Accuracy'}; 

identifier_for_string_writing = {'%d','%d','%d','%d','%d','%.4f','%d','%.4f','%d'};

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
            P = subject_numbers(subject_count);
            Sess = sessions_to_analyse(session_count);
            
            filename=strcat('Dual_Task_Training_COLOURS_PREPOST_SubjectNumber_',num2str(P),'_SessionNumber_',num2str(Sess),'.txt'); 
    
            if exist(filename,'file') % check if this logfile exists
                analysed_subj_counter = analysed_subj_counter+1; % keep a tally of how many subjects are actually analysed
                load(filename); % if it does, load the logfile
            else % otherwise, if this logfile doesn't exist...
                fprintf('The following file is missing: %s\n\n',filename); % output to command window
                continue % if the logfile cannot be found, skip to the next participant
            end
            
            ActiveData=dlmread(filename);
             
            a=1; aa=1; b=1; bb=1; c=1; cc=1;
            h = size(ActiveData);
            h=h(1); %number of rows eg each trial 
            StAudaccCycle=0;
            StAudrtCycle=0;
            StVisaccCycle=0;
            StVisrtCycle=0;
            DtAudaccCycle=0;
            DtVisaccCycle=0;
            DtAudrtCycle=0;
            DtVisrtCycle=0;
            FinalCountRTsSTaud=0;
            FinalCountRTsSTvis=0;
            FinalCountRTsDTaud=0;
            FinalCountRTsDTvis=0;

    
            for Cycle = 1:h
     
               if ActiveData(Cycle, 5)==4 %not practice trials
                   
                  if ActiveData(Cycle, 8) == 1 %Sounds only
                    StAudaccCycle(a) = ActiveData(Cycle,18);
                    if StAudaccCycle(a)==1
                        StAudrtCycle(aa) = ActiveData(Cycle,16);
                        aa=aa+1;
                    end
                    a=a+1;
                  elseif ActiveData(Cycle, 8) == 2 %Visual only
                    StVisaccCycle(b) = ActiveData(Cycle,19);
                    if StVisaccCycle(b)==1
                        StVisrtCycle(bb) = ActiveData(Cycle,17);
                        bb=bb+1;
                    end
                    b=b+1;
                  elseif ActiveData(Cycle, 8) == 3 %DualTask
                    DtAudaccCycle(c) = ActiveData(Cycle,18);
                    DtVisaccCycle(c) = ActiveData(Cycle,19);
                    if DtAudaccCycle(c)==1 && DtVisaccCycle(c)==1
                        DtAudrtCycle(cc) = ActiveData(Cycle,16);
                        DtVisrtCycle(cc) = ActiveData(Cycle,17);
                        cc=cc+1;
                    end
                    c=c+1;
                  end    
             
               end
               
            end

                MeanAccSingAud(subject_count,session_count) = mean(StAudaccCycle);
                MeanAccSingVis(subject_count,session_count) = mean(StVisaccCycle);
                MeanAccDualAud(subject_count,session_count) = mean(DtAudaccCycle);
                MeanAccDualVis(subject_count,session_count) = mean(DtVisaccCycle);
                
                RTsSTaud = mean(StAudrtCycle,'omitnan'); StDevSTaud = std(StAudrtCycle,'omitnan');
                RTsSTvis = mean(StVisrtCycle,'omitnan'); StDevSTvis = std(StVisrtCycle,'omitnan');
                RTsDTaud = mean(DtAudrtCycle,'omitnan'); StDevDTaud = std(DtAudrtCycle,'omitnan');
                RTsDTvis = mean(DtVisrtCycle,'omitnan'); StDevDTvis = std(DtVisrtCycle,'omitnan');
                
                StAudrtCycle(StAudrtCycle > ((3*StDevSTaud)+RTsSTaud)) = NaN;
                StVisrtCycle(StVisrtCycle > ((3*StDevSTvis)+RTsSTvis)) = NaN;
                DtAudrtCycle(DtAudrtCycle > ((3*StDevDTaud)+RTsDTaud)) = NaN;
                DtVisrtCycle(DtVisrtCycle > ((3*StDevDTvis)+RTsDTvis)) = NaN;
                
                MeanRTsSTaud(subject_count,session_count) = mean(StAudrtCycle,'omitnan'); 
                MeanRTsSTvis(subject_count,session_count) = mean(StVisrtCycle,'omitnan'); 
                MeanRTsDTaud(subject_count,session_count) = mean(DtAudrtCycle,'omitnan'); 
                MeanRTsDTvis(subject_count,session_count) = mean(DtVisrtCycle,'omitnan'); 
                
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

    for subject_count = 1:length(subject_numbers)
        fprintf(full_analysed_output_file_ID,'%s\n','');
        fprintf(full_analysed_output_file_ID,'%s\t',num2str(subject_numbers(subject_count)));
        for session_count = 1:length(sessions_to_analyse)

            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanAccSingAud(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanAccSingVis(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanAccDualAud(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanAccDualVis(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanRTsSTaud(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanRTsSTvis(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanRTsDTaud(subject_count,session_count)));
            fprintf(full_analysed_output_file_ID,'%s\t',num2str(MeanRTsDTvis(subject_count,session_count)));

        end
    end

end

%end



