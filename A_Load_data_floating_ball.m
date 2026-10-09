clear all
path = "Y:\LWX\2p\BEHAVIOR\260923\"; % Enter you raw data file path here.

filelist = dir(strcat(path, '*.txt'));
n_file = size(filelist,1);
 
for k = 1:n_file
 
   % get the file name:
   filename = filelist(k).name;
   disp(filename);

   %在下面插入你对每个文件要执行的脚本:
   filename_full=strcat(path,filename); %links the path and filename together

   fID=fopen(filename_full);
   text_all_lines = textscan(fID,'%s','delimiter','\n'); %text_all_lines is a cell that stores all lines
   n_lines=numel(text_all_lines{1}); % line number
   fclose(fID);

   fID=fopen(filename); %textscan will read the file line by line to its end
%    h=waitbar(0,'Loading...'); %initiate the waitbar
   
   clear speed t_speed t_speedA t_speedZ position t_position t_sync t_sync2 t_sync2_arduino t_sync_arduino t_lick t_lick_arduino t_reward t_reward_arduino 
   k_speed=0; k_speedZ=0; k_speedA=0; k_position=0; k_sync=0; k_sync2=0; k_lick=0; k_reward=0;
%     speed = zeros(n_lines, 1);
%     t_speed = zeros(n_lines, 1);
%     con = zeros(n_lines, 1);
%     t_con = zeros(n_lines, 1);
%     % odor = zeros(n_lines, 1);
%     t_odor = zeros(n_lines, 1);
%     position = zeros(n_lines, 1);
%     t_position = zeros(n_lines, 1);
%     t_sync = zeros(n_lines, 1);
%     t_sync_arduino = zeros(n_lines, 1);
%     t_lick = zeros(n_lines, 1);
%     t_lick_arduino = zeros(n_lines, 1);
%     t_reward = zeros(n_lines, 1);
%     t_reward_arduino = zeros(n_lines, 1);

   for p=1:n_lines
%        waitbar(p/n_lines,h); %update the waitbar

       %s=text_all_lstrcatines{1}{p}; %s is a string for one line
       s=text_all_lines{1}{p};
       words=strsplit(s,','); % separate words with deliminator ','

       if numel(words)>=2 % more than 2 words in this line
           if strcmp(words(2),"Speed")
               k_speed=k_speed+1;
               speed(k_speed)=str2num(cell2mat(words(3))); %speed
               t_speed(k_speed)=str2num(cell2mat(words(1))); %Unity timestamp for each speed record
           elseif strcmp(words(2),"SpeedZ")
               k_speedZ=k_speedZ+1;
               speedZ(k_speedZ)=str2num(cell2mat(words(3))); %speed
               t_speedZ(k_speedZ)=str2num(cell2mat(words(1))); %Unity timestamp for each speed record
           elseif strcmp(words(2),"SpeedA")
               k_speedA=k_speedA+1;
               speedA(k_speedA)=str2num(cell2mat(words(3))); %speed
               t_speedA(k_speedA)=str2num(cell2mat(words(1))); %Unity timestamp for each speed record
           elseif strcmp(words(2),"VR")
               k_position=k_position+1;
               position(k_position)=str2num(cell2mat(words(5))); %(forward-backward) position on a track; Z axis in Unity
               position_lateral(k_position)=str2num(cell2mat(words(3))); %which track? X axis in Unity
               t_position(k_position)=str2num(cell2mat(words(1))); %Unity timestamp for each position record
           elseif strcmp(words(2),"SYNC")
               k_sync=k_sync+1;
               t_sync(k_sync)=str2num(cell2mat(words(1))); %Unity timestamp for each sync pulse
               t_sync_arduino(k_sync)=str2num(cell2mat(words(5))); %Arduino timestamp for each sync pulse
            elseif strcmp(words(2),"SYNC2")
               k_sync2=k_sync2+1;
               t_sync2(k_sync2)=str2num(cell2mat(words(1))); %Unity timestamp for each sync pulse
               t_sync2_arduino(k_sync2)=str2num(cell2mat(words(5))); %Arduino timestamp for each sync pulse
           elseif strcmp(words(2),"LICK")
               if strcmp(words(4),"ON") %Only load the ON time of each lick signal pulse
                   k_lick=k_lick+1;
                   t_lick(k_lick)=str2num(cell2mat(words(1))); %Unity timestamp for each lick
                   t_lick_arduino(k_lick)=str2num(cell2mat(words(5))); %Arduino timestamp for each lick
               end
           elseif strcmp(words(2),"REWARD")
               if strcmp(words(4),"ON") %Only load the ON time of each reward
                   k_reward=k_reward+1;
                   t_reward(k_reward)=str2num(cell2mat(words(1))); %Unity timestamp for each lick
                   t_reward_arduino(k_reward)=str2num(cell2mat(words(5))); %Arduino timestamp for each lick
               end
           end
       end
   end
%    delete(h)

    
   save_folder = fullfile(path, 'Analysis_Files');
   if ~exist(save_folder, 'dir')
       mkdir(save_folder);
   end
%    clear h; %remove the wait bar
   % 删除 .txt 后缀
   [~, filename_no_ext, ~] = fileparts(filename);
   filename_new = strcat(save_folder, '\', filename_no_ext, "_Analysis.mat");
   save(filename_new); %Save everything in the workspace into the file
end 



