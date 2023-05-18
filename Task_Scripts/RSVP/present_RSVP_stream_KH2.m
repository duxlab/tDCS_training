% present RSVP stream
% 
% define the number of distractors that appear after the target (this is dependent on the lag manipulation)

n_pre_T1_distractors = possible_pre_T1_distractors(data.trial_type_order(trial_count,1));
n_post_T1_distractors = 8-n_pre_T1_distractors;

% determine duration of fixation cross (it is jittered across trials)
possible_fixation_durations = Shuffle(duration_fixation);
current_fixation_duration = possible_fixation_durations(1);

if trial_count > 1 && data.post_fixation_trial_duration(trial_count-1,block_count) < minimum_trial_duration  % IF TRIAL IS LESS THAN FOUR SECONDS EXTEND FIXATION LENGTH 
    current_fixation_duration = minimum_trial_duration - (data.post_fixation_trial_duration(trial_count-1,block_count));
end

data.current_fixation_duration(trial_count,1) = current_fixation_duration;

% ...fixation square dimensions
fix_x1 = (current_resolution.width/2)-5;
fix_x2 = (current_resolution.width/2)+5;
fix_y1 = (current_resolution.height/2)-5;
fix_y2 = (current_resolution.height/2)+5;

% present fixation square
     Screen('FillRect',w_screen, [0 0 0], [fix_x1 fix_y1 fix_x2 fix_y2]);
     Screen(w_screen,'Flip');
     trial_onset = GetSecs;
     while ((GetSecs - trial_onset) <= current_fixation_duration); end;
            
% present pre-T1 distractors
post_fixation_trial_onset = GetSecs;
distractor_counter = 0;
for stim_count = 1:n_pre_T1_distractors
    distractor_counter = distractor_counter+1; 
    Screen('CopyWindow',disp_distractor(distractor_stimuli_IDs(distractor_counter)),w_screen,[],present_stimuli,[]);
    Screen(w_screen,'Flip');
    stim_onset = GetSecs;
    while ((GetSecs - stim_onset) <= duration_stimuli); end;
end

% present first target
Screen('CopyWindow',disp_target(target_stimuli_IDs(1)),w_screen,[],present_stimuli,[]);
Screen(w_screen,'Flip');
stim_onset = GetSecs;
while ((GetSecs - stim_onset) <= duration_stimuli); end;

% present post-T1 distractors
for stim_count = 1:n_post_T1_distractors
    distractor_counter = distractor_counter+1; 
    Screen('CopyWindow',disp_distractor(distractor_stimuli_IDs(distractor_counter)),w_screen,[],present_stimuli,[]);
    Screen(w_screen,'Flip');
    stim_onset = GetSecs;
    while ((GetSecs - stim_onset) <= duration_stimuli); end;
end
