cFileList = dir("Y:\LWX\5pattern\20260321\Analysis_Files");
N = size(FileList,1);

path="Yc
    FileList = dir("Y:\LWX\5pattern\20260321\Analysis_Files\*.mat");
    filename = FileList(k).name;

    disp(filename)
    filename_full = strcat("Y:\LWX\5pattern\20260321\Analysis_Files\",filename);
    load(filename_full)

    h=waitbar(0,'Loading...'); %initiate the waitbar

    %% AssignPosition
    clear pos_lick pos_reward lap

    for i=1:k_lick %go through all licks
        delta_t=t_position-t_lick(i); %difference between all position timestamps and THIS lick time
        index=find(abs(delta_t)==min(abs(delta_t))); %find the smallest difference
        pos_lick(i)=position(index(1)); %assign the position;
        % 'index(1)' to prevent two position timestamps with the same smallest difference
        % In this case, just pick the first one.
    end

    for i=1:k_reward %go through all rewards
        delta_t=t_position-t_reward(i); %difference between all position timestamps and THIS reward time
        index=find(abs(delta_t)==min(abs(delta_t))); %find the smallest difference
        pos_reward(i)=position(index); %assign the position
        % 'index(1)' to prevent two position timestamps with the same smallest difference
        % In this case, just pick the first one.
    end

    %% SortLapTreadmill
    clear lap Correct Correct_avg Miss Miss_avg FalseAlarm FalseAlarm_avg C_Correct B_Correct A_Correct Blank_Correct;
    

    reward_zone1=[36.4,60.4]; %reward zone positions of track 11&12
    reward_zone2=[96.4,120.4]; %reward zone positions of track 9&10
    reward_zone3=[156.4,180.4]; %reward zone positions of track 7&8
    reward_zone4=[216.4,240.4];
    reward_zone5=[276.4,300.4];
    
    pre_zone1 = [66.4,90.5];
    pre_zone2 = [126.4,150.5];
    pre_zone3 = [186.4,210.5];
    pre_zone4 = [246.4,270.5];

    inter_trial_interval=2000; %2000ms inter-trial-interval

    d_pos=diff(position); % position(t+1)-position(t)
    cutoff=-100;
    index_trial=find(d_pos<cutoff); %detect the teleportation back to the start point;
    % index_trial is the end of each trial

    for i=1:(numel(index_trial))
        if i==1
            lap(i).position=position(1:index_trial(i));
            lap(i).t_position=t_position(1:index_trial(i));
        else
            lap(i).position=position((index_trial(i-1)+1):index_trial(i)); %from index_trial(i-1)+1 to index_trial(i)
            lap(i).t_position=t_position((index_trial(i-1)+1):index_trial(i));
        end

        if exist('t_speed', 'var')
            lap(i).speed=speed(find((t_speed>=lap(i).t_position(1))&(t_speed<=lap(i).t_position(end)))); %speed within this trial
        end
        if exist('t_speedz', 'var')
            lap(i).speedz=speedz(find((t_speedz>=lap(i).t_position(1))&(t_speedz<=lap(i).t_position(end))));%speedz within this trial
        end
        index_lick=find((t_lick>=lap(i).t_position(1))&(t_lick<=lap(i).t_position(end))); %licks within this trial
        lap(i).t_lick=t_lick(index_lick);
        lap(i).t_lick_arduino=t_lick_arduino(index_lick);
        lap(i).pos_lick=pos_lick(index_lick);
        index_reward=find((t_reward>=lap(i).t_position(1))&(t_reward<=lap(i).t_position(end))); %rewards within this trial
        lap(i).t_reward=t_reward(index_reward);
        lap(i).t_reward_arduino=t_reward_arduino(index_reward);
        lap(i).pos_reward=pos_reward(index_reward);
        index_sync=find((t_sync>=lap(i).t_position(1))&(t_sync<=lap(i).t_position(end))); %sync pulses within this trial
        lap(i).t_sync=t_sync(index_sync);
        lap(i).t_sync_arduino=t_sync_arduino(index_sync);
%         if exist('t_barcode_on', 'var')
%             lap(i).t_position_neuro=cell(1);
%             lap(i).t_lick_neuro=cell(1);
%             lap(i).t_reward_neuro=cell(1);
%             lap(i).unity_reward_neuro=cell(1);
%             lap(i).unity_lick_neuro=cell(1);
%             lap(i).unit_use = cell(1);
%             lap(i).firing_rate = cell(1);
%             lap(i).firing_rate_del = cell(1);
%         end
        if exist('t_barcode_on', 'var')
            lap(i).t_position_neuro=cell(1);
            lap(i).t_lick_neuro=cell(1);
            lap(i).t_reward_neuro=cell(1);
            lap(i).unity_reward_neuro=cell(1);
            lap(i).unity_lick_neuro=cell(1);
            lap(i).unit_use = cell(1);
            lap(i).firing_rate = cell(1);
            lap(i).firing_rate_run = cell(1);
        end

        t_start=lap(i).t_position(1)+inter_trial_interval; %the time when the display showed up
        lap(i).t_start=t_start; %the time when the display showed up
        lap(i).index_start=min(find(lap(i).t_position>=t_start)); %the index (for position) when the display showed up
        index_lick_inside1=find((lap(i).pos_lick>=reward_zone1(1))&(lap(i).pos_lick<=reward_zone1(2))); %licks within track 4&6 8&10 reward zone
        index_lick_inside2=find((lap(i).pos_lick>=reward_zone2(1))&(lap(i).pos_lick<=reward_zone2(2))); %licks within track 1&5 7&11 reward zone
        index_lick_inside3=find((lap(i).pos_lick>=reward_zone3(1))&(lap(i).pos_lick<=reward_zone3(2)));%licks within track 2&3 9&12 reward zone
        index_lick_inside4=find((lap(i).pos_lick>=reward_zone4(1))&(lap(i).pos_lick<=reward_zone4(2)));
        index_lick_inside5=find((lap(i).pos_lick>=reward_zone5(1))&(lap(i).pos_lick<=reward_zone5(2)));
        if (position_lateral(index_trial(i))<-4800) 
            lap(i).class = "pattern75";
            lap(i).type = 1;
            if (position_lateral(index_trial(i))<-5450) 
                lap(i).trial_style=[10,12,10,11,13];
                lap(i).trial_ty = 3;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-5400) 
                lap(i).trial_style=[10,11,10,12,13];
                lap(i).trial_ty = 3;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-5200) 
                lap(i).trial_style=[13,12,10,11,10];
                lap(i).trial_ty = 1;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-5100)
                lap(i).trial_style=[13,11,10,12,10];
                lap(i).trial_ty = 1;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-4940)
                lap(i).trial_style=[10,12,13,11,10];
                lap(i).trial_ty = 2;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-4900)
                lap(i).trial_style=[10,11,13,12,10];
                lap(i).trial_ty = 2;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end

        elseif (position_lateral(index_trial(i))<-4000)
            lap(i).class = "position75";
            lap(i).type = 2;
            lap(i).trial_ty = 2;
            if (position_lateral(index_trial(i))<-4700)
                lap(i).trial_style=[20,22,20,21,23];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<-4600)
                lap(i).trial_style=[20,21,20,22,23];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif  (position_lateral(index_trial(i))<-4420)
                lap(i).trial_style=[23,22,20,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<-4200)
                lap(i).trial_style=[23,21,20,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<-4120)
                lap(i).trial_style=[20,22,23,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
             elseif (position_lateral(index_trial(i))<-4000)
                lap(i).trial_style=[20,21,23,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);   
            end
        elseif (position_lateral(index_trial(i))<-3700)
            lap(i).class = "origin75";
            lap(i).type = 0;
            lap(i).trial_ty = 2;
            lap(i).blank_lick_number = numel(index_lick_inside4);
            if (position_lateral(index_trial(i))<-3800)
                lap(i).trial_style=[0,2,3,1,0];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))>-3800) 
                lap(i).trial_style=[0,1,3,2,0];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end
        elseif (position_lateral(index_trial(i))<-2000)
            index_pre_pattern1=find((lap(i).pos_lick>=pre_zone1(1))&(lap(i).pos_lick<=pre_zone1(2))); %licks within track 4&6 8&10 reward zone
            index_pre_pattern2=find((lap(i).pos_lick>=pre_zone2(1))&(lap(i).pos_lick<=pre_zone2(2))); %licks within track 1&5 7&11 reward zone
            index_pre_pattern3=find((lap(i).pos_lick>=pre_zone3(1))&(lap(i).pos_lick<=pre_zone3(2)));%licks within track 2&3 9&12 reward zone
            index_pre_pattern4=find((lap(i).pos_lick>=pre_zone4(1))&(lap(i).pos_lick<=pre_zone4(2)));
            lap(i).class = "pre-pattern";
            lap(i).type = 3;
            if (position_lateral(index_trial(i))<-3430)
                lap(i).trial_style = [30,30,31,32];
                lap(i).D_lick_number = numel(index_pre_pattern4);
                lap(i).E_lick_number = numel(index_pre_pattern3);
                lap(i).blank_one_lick_number = numel(index_pre_pattern1);
                lap(i).blank_two_lick_number = numel(index_pre_pattern2);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-3300)
                lap(i).trial_style = [30,30,32,31];
                lap(i).D_lick_number = numel(index_pre_pattern3);
                lap(i).E_lick_number = numel(index_pre_pattern4);
                lap(i).blank_one_lick_number = numel(index_pre_pattern1);
                lap(i).blank_two_lick_number = numel(index_pre_pattern2);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-3200)
                lap(i).trial_style = [30,31,32,30];
                lap(i).D_lick_number = numel(index_pre_pattern3);
                lap(i).E_lick_number = numel(index_pre_pattern2);
                lap(i).blank_one_lick_number = numel(index_pre_pattern1);
                lap(i).blank_two_lick_number = numel(index_pre_pattern4);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-3000)
                lap(i).trial_style = [30,32,31,30];
                lap(i).D_lick_number = numel(index_pre_pattern2);
                lap(i).E_lick_number = numel(index_pre_pattern3);
                lap(i).blank_one_lick_number = numel(index_pre_pattern1);
                lap(i).blank_two_lick_number = numel(index_pre_pattern4);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2900)
                lap(i).trial_style = [30,31,30,32];
                lap(i).D_lick_number = numel(index_pre_pattern4);
                lap(i).E_lick_number = numel(index_pre_pattern2);
                lap(i).blank_one_lick_number = numel(index_pre_pattern1);
                lap(i).blank_two_lick_number = numel(index_pre_pattern3);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2700)
                lap(i).trial_style = [30,32,30,31];
                lap(i).D_lick_number = numel(index_pre_pattern2);
                lap(i).E_lick_number = numel(index_pre_pattern4);
                lap(i).blank_one_lick_number = numel(index_pre_pattern1);
                lap(i).blank_two_lick_number = numel(index_pre_pattern3);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2580)
                lap(i).trial_style = [31,30,30,32];
                lap(i).D_lick_number = numel(index_pre_pattern4);
                lap(i).E_lick_number = numel(index_pre_pattern1);
                lap(i).blank_one_lick_number = numel(index_pre_pattern2);
                lap(i).blank_two_lick_number = numel(index_pre_pattern3);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2500)
                lap(i).trial_style = [32,30,30,31];
                lap(i).D_lick_number = numel(index_pre_pattern1);
                lap(i).E_lick_number = numel(index_pre_pattern4);
                lap(i).blank_one_lick_number = numel(index_pre_pattern2);
                lap(i).blank_two_lick_number = numel(index_pre_pattern3);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2350)
                lap(i).trial_style = [31,30,32,30];
                lap(i).D_lick_number = numel(index_pre_pattern3);
                lap(i).E_lick_number = numel(index_pre_pattern1);
                lap(i).blank_one_lick_number = numel(index_pre_pattern2);
                lap(i).blank_two_lick_number = numel(index_pre_pattern4);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2200)
                lap(i).trial_style = [32,30,31,30];
                lap(i).D_lick_number = numel(index_pre_pattern1);
                lap(i).E_lick_number = numel(index_pre_pattern3);
                lap(i).blank_one_lick_number = numel(index_pre_pattern2);
                lap(i).blank_two_lick_number = numel(index_pre_pattern4);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            elseif (position_lateral(index_trial(i))<-2070)
                lap(i).trial_style = [31,32,30,30];
                lap(i).D_lick_number = numel(index_pre_pattern2);
                lap(i).E_lick_number = numel(index_pre_pattern1);
                lap(i).blank_one_lick_number = numel(index_pre_pattern3);
                lap(i).blank_two_lick_number = numel(index_pre_pattern4);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            else
                lap(i).trial_style = [32,31,30,30];
                lap(i).D_lick_number = numel(index_pre_pattern1);
                lap(i).E_lick_number = numel(index_pre_pattern2);
                lap(i).blank_one_lick_number = numel(index_pre_pattern3);
                lap(i).blank_two_lick_number = numel(index_pre_pattern4);
                [all_judgement,seperately_judgement] = reward1_none3_judge_Correct(lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).D_lick_number,lap(i).E_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
            end
        elseif (position_lateral(index_trial(i))<-1200)
            lap(i).class = "position";
            lap(i).type = 2;
            lap(i).trial_ty = 2;
            if (position_lateral(index_trial(i))<-1700)
                lap(i).trial_style = [20,22,20,21,23];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<-1500)
                lap(i).trial_style=[20,21,20,22,23];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif  (position_lateral(index_trial(i))<-1400)
                lap(i).trial_style=[23,22,20,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<-1200)
                lap(i).trial_style=[23,21,20,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            end
        elseif (position_lateral(index_trial(i))<-700)
            lap(i).class = "pattern";
            lap(i).type = 1;
            if (position_lateral(index_trial(i))<-1150) 
                lap(i).trial_ty = 3;
                lap(i).trial_style=[10,12,10,11,13];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-1100) 
                lap(i).trial_ty = 3;
                lap(i).trial_style=[10,11,10,12,13];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif(position_lateral(index_trial(i))<-880) 
                lap(i).trial_ty = 1;
                lap(i).trial_style=[13,12,10,11,10];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-800)
                lap(i).trial_ty = 1;
                lap(i).trial_style=[13,11,10,12,10];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end
        elseif (position_lateral(index_trial(i))<-550)
            lap(i).class = "origin";
            lap(i).type = 0;
            lap(i).trial_ty = 2;
            lap(i).opto = 0;
            lap(i).blank_lick_number = numel(index_lick_inside4);
            if (position_lateral(index_trial(i))<-630)
                lap(i).trial_style=[0,2,3,1,0];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))>-630) 
                lap(i).opto = 0;
                lap(i).trial_style=[0,1,3,2,0];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end
        elseif (position_lateral(index_trial(i))<200) 
            lap(i).class = "pattern";
            lap(i).type = 1;
            if (position_lateral(index_trial(i))<-330) 
                lap(i).trial_style=[10,12,10,11,13];
                lap(i).trial_ty = 3;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-300) 
                lap(i).trial_style=[10,11,10,12,13];
                lap(i).trial_ty = 3;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-100) 
                lap(i).trial_style=[13,12,10,11,10];
                lap(i).trial_ty = 1;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<0)
                lap(i).trial_style=[13,11,10,12,10];
                lap(i).trial_ty = 1;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<150)
                lap(i).trial_style=[10,12,13,11,10];
                lap(i).trial_ty = 2;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<200)
                lap(i).trial_style=[10,11,13,12,10];
                lap(i).trial_ty = 2;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end
        elseif (position_lateral(index_trial(i))<1200)
            lap(i).class = "position";
            lap(i).type = 2;
            lap(i).trial_ty = 2;
            if (position_lateral(index_trial(i))<400)
                lap(i).trial_style=[20,22,20,21,23];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<500)
                lap(i).trial_style=[20,21,20,22,23];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif  (position_lateral(index_trial(i))<680)
                lap(i).trial_style=[23,22,20,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<800)
                lap(i).trial_style=[23,21,20,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<970)
                lap(i).trial_style=[20,22,23,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
             elseif (position_lateral(index_trial(i))<1200)
                lap(i).trial_style=[20,21,23,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);   
            end
      
        elseif (position_lateral(index_trial(i))<1550)
            lap(i).class = "origin-opto";
            lap(i).type = 0;
            lap(i).trial_ty = 2;
            if (position_lateral(index_trial(i))<1260)
                lap(i).opto = 1;
                lap(i).trial_style=[0,2,3,1,0];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<1330) 
                lap(i).opto = 1;
                lap(i).trial_style=[0,1,3,2,0];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<-1500)
                lap(i).opto = 0;
                lap(i).trial_style=[0,2,3,1,0];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);c
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<1550) 
                lap(i).opto = 0;
                lap(i).trial_style=[0,1,3,2,0];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end
        elseif (position_lateral(index_trial(i))<2700) 
            lap(i).class = "pattern-opto";
            lap(i).type = 1;
            if (position_lateral(index_trial(i))<2060) 
                lap(i).trial_style=[10,12,10,11,13];
                lap(i).trial_ty = 3;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<2100) 
                lap(i).trial_style=[10,11,10,12,13];
                lap(i).trial_ty = 3;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<2330) 
                lap(i).trial_style=[13,12,10,11,10];
                lap(i).trial_ty = 1;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<2400)
                lap(i).trial_style=[13,11,10,12,10];
                lap(i).trial_ty = 1;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<2560)
                lap(i).trial_style=[10,12,13,11,10];
                lap(i).trial_ty = 2;
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            elseif (position_lateral(index_trial(i))<2620)
                lap(i).trial_style=[10,11,13,12,10];
                lap(i).trial_ty = 2;
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
            end
        else
            lap(i).class = "position-opto";
            lap(i).type = 2;
            lap(i).trial_ty = 2;
            if (position_lateral(index_trial(i))<2800)
                lap(i).trial_style=[20,22,20,21,23];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<2900)
                lap(i).trial_style=[20,21,20,22,23];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside5);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside3);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).C_lick_number,lap(i).blank_two_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(5);
                lap(i).C_Correct = seperately_judgement(4);
            elseif  (position_lateral(index_trial(i))<3100)
                lap(i).trial_style=[23,22,20,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<3200)
                lap(i).trial_style=[23,21,20,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside1);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside3);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number,lap(i).blank_one_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(5);
                lap(i).Blank_two_Correct = seperately_judgement(3);
                lap(i).C_Correct = seperately_judgement(4);
            elseif (position_lateral(index_trial(i))<3400)
                lap(i).trial_style=[20,22,23,21,20];
                lap(i).A_lick_number = numel(index_lick_inside4);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside2);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);
             elseif (position_lateral(index_trial(i))>3400)
                lap(i).trial_style=[20,21,23,22,20];
                lap(i).A_lick_number = numel(index_lick_inside2);
                lap(i).C_lick_number = numel(index_lick_inside3);
                lap(i).B_lick_number = numel(index_lick_inside4);
                lap(i).blank_one_lick_number = numel(index_lick_inside1);
                lap(i).blank_two_lick_number = numel(index_lick_inside5);
                [all_judgement,seperately_judgement] = reward1_none4_judge_Correct(lap(i).A_lick_number,lap(i).B_lick_number,lap(i).blank_one_lick_number,lap(i).blank_two_lick_number,lap(i).C_lick_number);
                lap(i).Correct =  all_judgement(1);
                lap(i).Miss = all_judgement(2);
                lap(i).FalseAlarm = all_judgement(3);
                lap(i).A_Correct = seperately_judgement(1);
                lap(i).B_Correct = seperately_judgement(2);
                lap(i).Blank_one_Correct = seperately_judgement(3);
                lap(i).Blank_two_Correct = seperately_judgement(4);
                lap(i).C_Correct = seperately_judgement(5);   
            end
        end
    end

    delete(h)
    
    % Filename_new=strcat(path,filename,"_Analysis_SortLap.mat");
    % save(Filename_new,"lap"); %Save everything in the workspace into the file
    % delete(h); %remove the message box

    % create a new_folder

    new_folder_path = fullfile(path, 'New');

    if ~exist(new_folder_path, 'dir')
        mkdir(new_folder_path);
    end

    % 生成新的文件名
    Filename_new = fullfile(new_folder_path, strcat(filename(1:end-4), '_lap.mat'));

    % 保存数据到新的文件中
    save(Filename_new, 'lap'); % 将工作区中的所有内容保存到文件中

    % 移除消息框
    delete(h);
end
