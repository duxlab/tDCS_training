%function generate_motion_trajectories_CKN4

% FUNCTION DETAILS --------------------------------------------------------

% This function is used to generate the trajectories of moving objects.
% When an object reaches the edge of a display, it bounces off in a
% Newtonian direction.
%
% You can vary the number of targets/distractors (1-9), probability of a
% direction change (0, 2%, 4%, 6%), and probability of a velocity change
% (0,  25%, 50%, 75%, 100%).
%
% Written by Zheng Ma; Editted by Claire between_object_count. Naughtin (2015)

clc
clear all;
warning('off','all');

% create random state
RandStream.create('mrg32k3a','seed',sum(100*clock));

% initialize important MEX-files.
KbCheck;
GetSecs;

% switch KbName into unified mode; this will use the names of the OS-X platform on all platforms in order to make this script portable
KbName('UnifyKeyNames');

% VARIABLES ---------------------------------------------------------------

computer_used = 1; % 1= lab testing mini, 2= personal laptop, 3= Claire's laptop

n_objects = 2;
file_number = 35;
possible_object_speeds_dps = [.01:.004:.082,.083:.001:.112]; % speed in degrees/sec
maximum_duration = 10; % maximum duration to try on current trajectory before moving to the next

filename_template = 'trajectory_%d_objs_%.3f_dps_res_%dx%d_%d.mat';
size_object_deg = 5;
size_fixation_deg = .4;
starting_position_y = 10;
min_distance_between_objs_deg = 1;
p_velocity_change = 0; % in percentage (0, 25, 50, 75, 100)
p_direction_change = .5; % in percentage (0, 2, 4, 6)
duration_motion = 60; % in seconds
refresh_rate = 60;
motion_area_offsets_pix = [5 5]; % width and height offsets, subtracted from entire screen size
velocity_cut_points_dps = 1:7;
drag_force = [0.7, 0.5, 0.4, 0.5, 0.6, 0.5, 0.3]; % probability that the object_speed_dps will increase for each cut point, do not include the 100% extreme ones
velocity_step = 0.1; % the changing step of the absolute velocity value

% RUN CODE ----------------------------------------------------------------

% implement computer used settings
if computer_used == 1 % duxlab testing computer
    screen_size_cm = [39.9 29.6];
    viewing_distance_cm = 50;
    screen_resolution = [1920 1080];
    disp('Computer set for Duxlab testing computer');
elseif computer_used == 2 % personal laptop
    screen_size_cm = [28.4 18];
    viewing_distance_cm = 50;
    screen_resolution = [1440 900];
    disp('Computer set for personal laptop');
elseif computer_used == 3 % Claire's laptop
    screen_size_cm = [28.8 18];
    viewing_distance_cm = 50;
    screen_resolution = [1280 800];
    disp('Computer set for Claire''s laptop');
end

for speed_count = 1:length(possible_object_speeds_dps)

    % define size of stimuli

    % ...for motion area
    size_motion_area = [motion_area_offsets_pix(1),motion_area_offsets_pix(2),... % position details
        screen_resolution(1)-motion_area_offsets_pix(1),screen_resolution(2)-motion_area_offsets_pix(2)]; % size details

    % ...for fixation square
    [size_fixation_pix,~] = deg_to_pix(size_fixation_deg,size_fixation_deg,screen_resolution,screen_size_cm,viewing_distance_cm);

    % ...for objects
    [object_width_pix,object_height_pix] = deg_to_pix(size_object_deg,size_object_deg,screen_resolution,screen_size_cm,viewing_distance_cm);

    % ...for minimum distance between objects
    [min_distance_between_objs_pix,~] = deg_to_pix(min_distance_between_objs_deg,min_distance_between_objs_deg,screen_resolution,screen_size_cm,viewing_distance_cm);

    % ...for object speed
    object_speed_dps = possible_object_speeds_dps(speed_count);
    [object_speed_pps,a] = deg_to_pix(object_speed_dps,object_speed_dps,screen_resolution,screen_size_cm,viewing_distance_cm);

    % ...for velocity cut points
    for point_count = 1:length(velocity_cut_points_dps)
        [velocity_cut_points_pps(point_count),~] = deg_to_pix(velocity_cut_points_dps(point_count),velocity_cut_points_dps(point_count),screen_resolution,screen_size_cm,viewing_distance_cm);
    end

    % calculate the number of frames per sequence
    n_frames = round(duration_motion*refresh_rate);

    % create matrices for storing relevant information
    distance_between_every_two_objs = zeros(n_objects,n_objects); % the matrix for the distances between every two objects
    obj_position_x = zeros(n_frames,n_objects); % the X position of every item in every trial in every frame
    obj_position_y = zeros(n_frames,n_objects);%the obj_position_y position of every item in every trial in every frame

    % START EXPERIMENT --------------------------------------------------------
    for file_count = 1:file_number

        trajectory_ok = 1; % marker to indicate whether the trajectory is appropriate or not
        while trajectory_ok % while the trajectory is ok...

            frame_counter = 0; % count the number of frames that has been successfully generated
            start_time = GetSecs; % record start time of loop
            if GetSecs-start_time > maximum_duration % if more time than the maximum duration has passed, break out of loop
                continue
            end

            % ##### DEFINE OBJECT LOCATIONS ######
            for object_count = 1:n_objects % for each object...

                % define starting position as top center
                obj_position_x(1,object_count) = screen_resolution(1)/2;
                obj_position_y(1,object_count) = round(object_height_pix+starting_position_y);
                %obj_position_x(1,object_count) = object_width_pix+motion_area_offsets_pix(1)+rand*(screen_resolution(1)-2*(object_width_pix+motion_area_offsets_pix(1)));
                %obj_position_y(1,object_count) = object_height_pix+motion_area_offsets_pix(2)+rand*(size_motion_area(4)-2*object_height_pix-motion_area_offsets_pix(2));

                while ((obj_position_y(1,object_count) > (size_motion_area(4)+size_motion_area(2))/2-size_fixation_pix-object_height_pix) && ... % check if possible position falls within fixation area
                        (obj_position_y(1,object_count) < (size_motion_area(4)+size_motion_area(2))/2+size_fixation_pix+object_height_pix)) && ...
                        ((obj_position_x(1,object_count) > (size_motion_area(3)+size_motion_area(1))/2-size_fixation_pix-object_width_pix) && ...
                        (obj_position_x(1,object_count) < (size_motion_area(3)+size_motion_area(1))/2+size_fixation_pix+object_width_pix))

                    % generate new random position if previous position was not suitable
                    obj_position_x(1,object_count) = object_width_pix+motion_area_offsets_pix(1)+rand*(screen_resolution(1)-2*(object_width_pix+motion_area_offsets_pix(1)));
                    obj_position_y(1,object_count) = object_height_pix+motion_area_offsets_pix(2)+rand*(size_motion_area(4)-2*object_height_pix-motion_area_offsets_pix(2));

                end
            end

            % check that each object falls outside of the minimum distance between objects
            for object_count = 1:n_objects % for each object...

                for between_object_count = 1:n_objects % for every other object...
                    distance_between_every_two_objs(object_count,between_object_count) = sqrt((obj_position_x(1,object_count)-obj_position_x(1,between_object_count))^2+(obj_position_y(1,object_count)-obj_position_y(1,between_object_count))^2); % calculate distance between these two objects
                end
            end
            for object_count = 2:n_objects % for all remaining objects...

                object_overlap = 1; % mark objects as overlapping by default; then check if this is true
                while object_overlap % while the objects are overlapping...
                    for between_object_count = 1:object_count-1 % for every other object...

                        if sqrt((obj_position_x(1,between_object_count)-obj_position_x(1,object_count))^2+(obj_position_y(1,between_object_count)-obj_position_y(1,object_count))^2)<object_width_pix+min_distance_between_objs_pix % if the position of the two current objects is less than the minimum distance between objects

                            % generate new random position if previous position was not suitable
                            obj_position_x(1,object_count)=object_width_pix+motion_area_offsets_pix(1)+rand*(screen_resolution(1)-2*(object_width_pix+motion_area_offsets_pix(1)));
                            obj_position_y(1,object_count)=object_height_pix+motion_area_offsets_pix(2)+rand*(size_motion_area(4)-2*object_height_pix-motion_area_offsets_pix(2));%select a position for the first time

                            while ((obj_position_y(1,object_count) > (size_motion_area(4)+size_motion_area(2))/2-size_fixation_pix-object_height_pix) && ... % check if possible position falls within fixation area
                                    (obj_position_y(1,object_count) < (size_motion_area(4)+size_motion_area(2))/2+size_fixation_pix+object_height_pix)) && ...
                                    ((obj_position_x(1,object_count) > (size_motion_area(3)+size_motion_area(1))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(1,object_count) < (size_motion_area(3)+size_motion_area(1))/2+size_fixation_pix+object_width_pix))

                                % generate new random position if previous position was not suitable
                                obj_position_x(1,object_count) = object_width_pix+motion_area_offsets_pix(1)+rand*(screen_resolution(1)-2*(object_width_pix+motion_area_offsets_pix(1)));
                                obj_position_y(1,object_count) = object_height_pix+motion_area_offsets_pix(2)+rand*(size_motion_area(4)-2*object_height_pix-motion_area_offsets_pix(2));
                            end

                            % keep overlap marker on and start comparison between other objects again
                            object_overlap = 1;
                            break

                        else
                            object_overlap = 0; % between-object distance is okay; turn overlap marker off
                        end
                    end
                end
            end

            % update matrix of between-object distances
            for object_count = 1:n_objects % for each object...
                for between_object_count = 1:n_objects % for every other object...
                    distance_between_every_two_objs(object_count,between_object_count) = sqrt((obj_position_x(1,between_object_count)-obj_position_x(1,object_count))^2+(obj_position_y(1,between_object_count)-obj_position_y(1,object_count))^2);
                end
            end

            % ##### DEFINE OBJECT VELOCITIES #####

            % create matrices for storing relevant information
            velocity_x = zeros(1,n_objects);
            velocity_y = zeros(1,n_objects);
            direction_x = zeros(1,n_objects);
            direction_y = zeros(1,n_objects);

            % define the current velocity current_value for all of the objects
            current_velocity = zeros(1,n_objects)+object_speed_pps;

            for object_count = 1:n_objects % for each object...

                velocity_x(object_count) = object_speed_pps*rand; % define random velocity for initial X velocity
                direction_x(object_count) = rand; % define random direction for initial X direction
                direction_y(object_count) = rand; % define random direction for initial Y direction
                velocity_y(object_count) = sqrt(object_speed_pps^2-(velocity_x(object_count))^2); % define initial Y velocity

                % if direction is less than 0.5, define velocity as negative (check this)
                if direction_x(object_count) < 0.5
                    velocity_x(object_count) = 0-velocity_x(object_count);
                end
                if direction_y(object_count) < 0.5
                    velocity_y(object_count) = 0-velocity_y(object_count);
                end

            end

            % repeat this process for all remaining frames
            for frame_count = 2:n_frames % for all other frames...

                if GetSecs-start_time > maximum_duration % if more time than the maximum duration has passed, break out of loop
                    break
                end

                % check whether the current velocity value is suitable
                current_value = rand(1,n_objects);
                for object_count = 1:n_objects % for each object...

                    if current_value(object_count) < p_velocity_change/100 % if the current velocity value is less than the probability of a velocity change...
                        updated_value = rand; % update velocity value
                        if current_velocity(object_count) == object_speed_pps % if current velocity value is equal to the average velocity speed
                            if updated_value < drag_force((length(drag_force)+1)/2) % if the current velocity value is less than set drag force value
                                current_velocity(object_count) = current_velocity(object_count)+velocity_step; % add velocity step increment
                            else
                                current_velocity(object_count)=current_velocity(object_count)-velocity_step; % otherwise, subtract velocity step increment
                            end
                        elseif current_velocity(object_count) < object_speed_pps % if current current velocity value is smaller than the average velocity speed
                            for point_count = 1:(length(drag_force)+1)/2 % for the smaller cut points...
                                if (current_velocity(object_count) <= velocity_cut_points_pps(point_count)) % if the current velocity is less than the current cut point...
                                    if point_count == 1 % if it's the first cut point...
                                        current_velocity(object_count) = current_velocity(object_count) + velocity_step; % add velocity step increment
                                    elseif current_velocity(object_count) > velocity_cut_points_pps(point_count-1) % if the current velocity is greater than the current cut point...
                                        if updated_value < drag_force(point_count-1) % ...and if the current velocity value is less than the drag for value...
                                            current_velocity(object_count) = current_velocity(object_count) + velocity_step; % add velocity step increment
                                        else
                                            current_velocity(object_count) = current_velocity(object_count) - velocity_step; % otherwise, subtract velocity step increment
                                        end
                                    end
                                end
                            end
                        elseif current_velocity(object_count) > object_speed_pps % otherwise, if the current velocity value is larger than the average velocity speed
                            for point_count = ((length(drag_force)+1)/2):length(drag_force) % for the larger cut points...
                                if (current_velocity(object_count) >= velocity_cut_points_pps(point_count)) % if the current velocity is greater than the current cut point...
                                    if point_count == length(drag_force) % if it's the last cut point...
                                        current_velocity(object_count) = current_velocity(object_count)-velocity_step; % subtract velocity step increment
                                    elseif current_velocity(object_count) < velocity_cut_points_pps(point_count+1) % if the current velocity is less than the current cut point...
                                        if updated_value < drag_force(point_count+1) % ...and if the current velocity value is less than the drag for value...
                                            current_velocity(object_count) = current_velocity(object_count) + velocity_step; % add velocity step increment
                                        else
                                            current_velocity(object_count) = current_velocity(object_count) - velocity_step; % otherwise, subtract velocity step increment
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if velocity_x(object_count) == 0 % if the X velocity is equal to zero...
                        if velocity_y(object_count) > 0 % ...and if the Y velocity is greater than zero...
                            velocity_y(object_count) = current_velocity(object_count); % define Y velocity as current velocity
                        else
                            velocity_y(object_count)=-1*current_velocity(object_count); % otherwise, define Y velocity as a negative of the current velocity
                        end
                    else
                        alpha(object_count) = atan(abs(velocity_y(object_count))/abs(velocity_x(object_count))); % define alpha (rate of change in angular velocity)
                        if velocity_x(object_count) > 0 % if X velocity is greater than zero...
                            velocity_x(object_count) = cos(alpha(object_count))*current_velocity(object_count); % adjust current velocity using alpha value
                        else
                            velocity_x(object_count)=-1*cos(alpha(object_count))*current_velocity(object_count); % adjust current velocity using negative alpha value
                        end
                        if velocity_y(object_count) > 0 % if the Y velocity is greater than zero...
                            velocity_y(object_count) = sin(alpha(object_count))*current_velocity(object_count); % adjust current velocity using alpha value
                        else
                            velocity_y(object_count) = -1*sin(alpha(object_count))*current_velocity(object_count); % adjust current velocity using negative alpha value
                        end
                    end
                end

                % determine whether to change the direction of the object
                direction = rand(1,n_objects); % generate a random direction for each object
                for object_count = 1: n_objects % for each object...
                    if direction(object_count) < p_direction_change/100 % if you need to change the object's direction...

                        velocity_x(object_count) = object_speed_pps*rand; % define random velocity for initial X velocity
                        direction_x(object_count) = rand; % define random direction for initial X direction
                        direction_y(object_count) = rand; % define random direction for initial Y direction
                        velocity_y(object_count) = sqrt(current_velocity(object_count)^2-(velocity_x(object_count))^2); % define initial Y velocity

                        % if direction is less than 0.5, define velocity as negative (check this)
                        if direction_x(object_count) < 0.5
                            velocity_x(object_count) = 0-velocity_x(object_count);
                        end
                        if direction_y(object_count) < 0.5
                            velocity_y(object_count) = 0-velocity_y(object_count);
                        end

                    end
                end

                % check for object overlap
                for object_count = 2:n_objects % for each objects...
                    object_overlap = 1;
                    while object_overlap && (GetSecs-start_time <= maximum_duration) % while the objects overlap and the time has not exceeded the maximum duration

                        for between_object_count = 1:object_count-1 % for all other objects...

                            if sqrt((obj_position_x(frame_count-1,between_object_count)+velocity_x(between_object_count)-obj_position_x(frame_count-1,object_count)-velocity_x(object_count))^2+...
                                    (obj_position_y(frame_count-1,between_object_count)+velocity_y(between_object_count)-obj_position_y(frame_count-1,object_count)-velocity_y(object_count))^2) < object_width_pix+min_distance_between_objs_pix % if the position of the two current objects is less than the minimum distance between objects

                                % bounce object off and then select the corresponding Newtonian direction
                                first_obj_X_velocity = velocity_x(object_count);
                                second_obj_X_velocity = velocity_x(between_object_count);
                                first_obj_Y_velocity = velocity_y(object_count);
                                second_obj_Y_velocity = velocity_y(between_object_count);

                                % switch the first and second objects' velocity dimensions
                                velocity_x(object_count) = second_obj_X_velocity;
                                velocity_x(between_object_count) = first_obj_X_velocity;
                                velocity_y(object_count) = second_obj_Y_velocity;
                                velocity_y(between_object_count) = first_obj_Y_velocity;

                                % keep overlap turned on & break out of loop
                                object_overlap = 1;
                                break

                            else
                                object_overlap = 0; % turn overlap off
                            end

                        end
                    end
                    if (GetSecs-start_time > maximum_duration)
                        break
                    end
                end

                % check if time has passed the maximum duration
                if GetSecs - start_time > maximum_duration
                    break
                end

                % check if time has passed the maximum duration
                if GetSecs - start_time > maximum_duration
                    break
                end

                % check if objects are at the edge of the screen or within fixation area
                for object_count = 1:n_objects % for each object...
                    if (obj_position_y(frame_count-1,object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix) && ...
                            (obj_position_y(frame_count-1,object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix)
                        if velocity_x(object_count) > 0
                            if (((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)) || ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > size_motion_area(3)-object_width_pix))
                                velocity_x(object_count) = 0-velocity_x(object_count);
                            end
                        else
                            if ((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < size_motion_area(1)+object_width_pix) || ...
                                    ((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)))
                                velocity_x(object_count) = 0-velocity_x(object_count);
                            end
                        end

                        if velocity_y(object_count) > 0
                            if (((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)) || ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > size_motion_area(4)-object_height_pix))
                                velocity_y(object_count) = 0-velocity_y(object_count);

                            end
                        else
                            if ((obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < size_motion_area(2)+object_height_pix) || ...
                                    ((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)))
                                velocity_y(object_count) = 0-velocity_y(object_count);
                            end
                        end
                    else
                        if velocity_y(object_count) > 0
                            if (((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)) || ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > size_motion_area(4)-object_height_pix))
                                velocity_y(object_count) = 0-velocity_y(object_count);
                            end
                        else
                            if ((obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < size_motion_area(2)+object_height_pix) || ...
                                    ((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)))
                                velocity_y(object_count) = 0-velocity_y(object_count);
                            end
                        end

                        if velocity_x(object_count) > 0
                            if (((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)) || ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > size_motion_area(3)-object_width_pix))
                                velocity_x(object_count) = 0-velocity_x(object_count);

                            end
                        else
                            if ((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < size_motion_area(1)+object_width_pix) || ...
                                    ((obj_position_x(frame_count-1,object_count)+velocity_x(object_count) > (size_motion_area(1)+size_motion_area(3))/2-size_fixation_pix-object_width_pix) && ...
                                    (obj_position_x(frame_count-1,object_count)+velocity_x(object_count) < (size_motion_area(1)+size_motion_area(3))/2+size_fixation_pix+object_width_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) < (size_motion_area(2)+size_motion_area(4))/2+size_fixation_pix+object_height_pix) && ...
                                    (obj_position_y(frame_count-1,object_count)+velocity_y(object_count) > (size_motion_area(2)+size_motion_area(4))/2-size_fixation_pix-object_height_pix)))
                                velocity_x(object_count) = 0-velocity_x(object_count);

                            end
                        end
                    end
                end

                % save position in new frame
                for object_count = 1:n_objects % for each object...
                    obj_position_x(frame_count,object_count) = obj_position_x(frame_count-1,object_count)+velocity_x(object_count);
                    obj_position_y(frame_count,object_count) = obj_position_y(frame_count-1,object_count)+velocity_y(object_count);
                end

                % save between-object positions in new frame
                for object_count = 1:n_objects % for each object
                    for between_object_count = 1:n_objects % for every other object...
                        distance_between_every_two_objs(object_count,between_object_count) = sqrt((obj_position_x(frame_count,object_count)-obj_position_x(frame_count,object_count))^2+...
                            (obj_position_y(frame_count,object_count)-obj_position_y(frame_count,object_count))^2);
                    end
                end
                frame_counter = frame_counter+1;
            end

            if frame_counter == n_frames-1 % if it's the second last trial...
                trajectory_ok = 0; % success for one trial
            end

            % check if time has passed the maximum duration
            if GetSecs-start_time > maximum_duration
                break
            end
        end

        % output message to command window if the coodinates of all frames weren't computed in the allocated time period
        if frame_count ~= n_frames % if all frames were not computed before the maximum time was up...
           fprintf('***N.B. Only %d frames out of the total %d frames were computed before the maximum time was up. ***\n',frame_count,n_frames); 
        end

        % save details for the experiment
        experiment.obj_position_x = obj_position_x;
        experiment.obj_position_y = obj_position_y;
        experiment.n_objects = n_objects;

        % define and save file
        file_name = [cd '/motion trajectory files/' sprintf(filename_template,n_objects,object_speed_dps,screen_resolution(1),screen_resolution(2),file_count)];
        save(file_name,'experiment');
    end
end