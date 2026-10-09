function[all_judgement,seperate_judgement]= reward1_none4_judge_Correct(none1_lick_number,none2_lick_number,none3_lick_number,none4_lick_number,reward_lick_number)
     if none1_lick_number > 0
        FalseAlarm = 1;
        Correct = 0;
        Miss = 0;
        none1_Correct = 0;
        if none2_lick_number > 0
            none2_Correct = 0;
        else
            none2_Correct = 1;
        end
        if none3_lick_number>0
            none3_Correct = 0;
        else
            none3_Correct = 1;
        end
        if none4_lick_number>0
            none4_Correct = 0;
        else
            none4_Correct = 1;
        end
        if reward_lick_number >0
            reward_Correct = 1;
        else
            reward_Correct = 0;
        end
    else
        none1_Correct = 1;
        if none2_lick_number >0
            Miss = 0;
            FalseAlarm = 1;
            Correct = 0;
            none2_Correct = 0;
            if none3_lick_number>0
                none3_Correct = 0;
            else
                none3_Correct = 1;
            end
            if none4_lick_number>0
                none4_Correct = 0;
            else
                none4_Correct = 1;
            end
            if reward_lick_number > 0
                reward_Correct = 1;
            else
                reward_Correct = 0;
            end
        else
            none2_Correct = 1;
            if none3_lick_number >0
                none3_Correct = 0;
                Miss = 0;
                FalseAlarm = 1;
                Correct = 0;
                if none4_lick_number>0
                    none4_Correct = 0;
                else
                    none4_Correct = 1;
                end
                if reward_lick_number > 0
                    reward_Correct = 1;
                else
                    reward_Correct = 0;
                end
            else
                none3_Correct = 1;
                if none4_lick_number >0
                    FalseAlarm = 1;
                    Correct = 0;
                    Miss = 0;
                    none4_Correct = 0;
                    if reward_lick_number>0
                        reward_Correct = 1;
                    else
                        reward_Correct = 0;
                    end
                else
                    none4_Correct = 1;
                    if reward_lick_number>0
                        reward_Correct = 1;
                        FalseAlarm = 0;
                        Miss = 0;
                        Correct = 1;
                    else
                        reward_Correct = 0;
                        Miss = 1;
                        FalseAlarm = 0;
                        Correct = 0;
                    end
                end
            end
        end
    end
   all_judgement=[Correct,Miss,FalseAlarm];
   seperate_judgement = [none1_Correct, none2_Correct,none3_Correct,none4_Correct,reward_Correct];
end