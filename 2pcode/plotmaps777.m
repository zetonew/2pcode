%% 

clear mean_map peak_spatial

save_folder = fullfile(save_path_str, 'heatmap');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

reward_zone1=[36.4,60.4];
reward_zone2=[96.4,120.4];
reward_zone3=[156.4,180.4];
reward_zone4=[216.4,240.4];
reward_zone5=[276.4,300.4];

pre_zone1 = [66.4,90.5];
pre_zone2 = [126.4,150.5];
pre_zone3 = [186.4,210.5];
pre_zone4 = [246.4,270.5];

bin=2;
reward_bin(1,:)=reward_zone1/bin;
reward_bin(2,:)=reward_zone2/bin;
reward_bin(3,:)=reward_zone3/bin;
reward_bin(4,:)=reward_zone4/bin;
reward_bin(5,:)=reward_zone5/bin;
pre_bin(1,:)=pre_zone1/bin;
pre_bin(2,:)=pre_zone2/bin;
pre_bin(3,:)=pre_zone3/bin;
pre_bin(4,:)=pre_zone4/bin;

pre_bin_all = pre_bin(:);
reward_bin_all = reward_bin(:);

sorting_type=1;
[peak_sort,index_sort]=sort(peak_position(sorting_type,:));

if any(contain75)
    num_title = [num_trialtype, num_trialtype_withoutreward];
    spk_type_all = [spk_type; spk_type_no_reward];   % 保留，但下面会统一用 spk_type_plot
else
    num_title = [num_trialtype, num_trialtype_false];
end

% ========== 新增：计算所有 trial（正确+错误+漏报+无奖励）的平均 ==========
spk_type_all_trials = zeros(n_type, numel(index_responsive), 160);
for k = 1:n_type
    for i = 1:numel(index_responsive)
        all_data = [];
        if num_trialtype(k) > 0
            all_data = [all_data; spk_neuron_type_save(i,k).Correct];
        end
        if num_trialtype_false(k) > 0
            all_data = [all_data; spk_neuron_type_save(i,k).FalseAlarm];
        end
        if num_trialtype_miss(k) > 0
            all_data = [all_data; spk_neuron_type_save(i,k).Miss];
        end
        if any(contain75) && num_trialtype_withoutreward(k) > 0
            all_data = [all_data; spk_neuron_type_save(i,k).NoReward];
        end
        if ~isempty(all_data)
            spk_type_all_trials(k,i,:) = mean(all_data, 1, 'omitnan');
        else
            spk_type_all_trials(k,i,:) = zeros(1,160);
        end
    end
end

spk_type_all_trials_75 = zeros(2*n_type, numel(index_responsive), 160);
if any(contain75)
    for k = 1:n_type
        for i = 1:numel(index_responsive)

            % ---- 有奖励的所有试次 ----
            rwd_data = [];
            if num_trialtype(k) > 0
                rwd_data = [rwd_data; spk_neuron_type_save(i,k).Correct];
            end
            if num_trialtype_false(k) > 0
                rwd_data = [rwd_data; spk_neuron_type_save(i,k).FalseAlarm];
            end
            if num_trialtype_miss(k) > 0
                rwd_data = [rwd_data; spk_neuron_type_save(i,k).Miss];
            end
            if ~isempty(rwd_data)
                spk_type_all_trials_75(k,i,:) = mean(rwd_data, 1, 'omitnan');
            end

            % ---- 无奖励的所有试次 ----
            nr_data = [];
            if num_trialtype_withoutreward(k) > 0
                nr_data = [nr_data; spk_neuron_type_save(i,k).NoReward];
            end
            if ~isempty(nr_data)
                spk_type_all_trials_75(n_type+k,i,:) = mean(nr_data, 1, 'omitnan');
            end

        end
    end
end

% ========================================================================

% 外层循环：分别绘制正确 trial 和所有 trial 的平均
for data_type = 1:2
    if data_type == 1
        if sum(num_trialtype) == 0
            continue;   % 没有任何正确 trial，跳过正确 trial 的图
        end
        spk_type_plot = spk_type;
        suffix = 'correct';
        spk_odd_plot = spk_odd;
        spk_even_plot = spk_even;
    else
        spk_type_plot = spk_type_all_trials;
        suffix = 'all';
        % 所有 trial 平均时，奇偶图用平均值代替，保持布局
        spk_odd_plot = spk_type_all_trials;
        spk_even_plot = spk_type_all_trials;
    end

    % 以下为原画图逻辑，将 spk_type / spk_type_all 替换为 spk_type_plot
    % 将 spk_odd / spk_even 替换为 spk_odd_plot / spk_even_plot
    % 保存文件名加入 suffix

    if length(typenum) == 1
        if typenum == 'pre-pattern'
            figure;
            for i=1:12
                subplot(3,6,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:8
                    plot([pre_bin_all(j),pre_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j=1:8
                plot([pre_bin_all(j),pre_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

        elseif typenum == 'origin'
            figure;
            for i=1:2
                subplot(2,4,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            subplot(2,4,3);
            imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('odd trials');
            subplot(2,4,4);
            imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('even trials');
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

        elseif typenum == 'origin75'
            % 4 个标题：类型1-有奖 / 类型2-有奖 / 类型1-无奖 / 类型2-无奖
            trail_new = [trial_name, trial_name];
        
            % 根据 data_type 选用对应的 4 行数据（都是 2*n_type 行）
            if data_type == 1
                % 正确 trial：spk_type_all = [spk_type; spk_type_no_reward]
                if any(contain75)
                    spk_type_new = spk_type_all;
                else
                    % 没有无奖励数据时退化为原 spk_type，保持不报错
                    spk_type_new = spk_type_plot;
                end
            else
                % 所有 trial：spk_type_all_trials_75
                if any(contain75)
                    spk_type_new = spk_type_all_trials_75;
                else
                    spk_type_new = spk_type_all_trials;
                end
            end
        
            n_plot = min(4, size(spk_type_new,1));   % 防越界
        
            figure;
            for i = 1:n_plot
                subplot(2,4,i);
                imagesc(squeeze(spk_type_new(i,index_sort,:)));
                caxis([0,1]);
                if i <= numel(trail_new)
                    title(trail_new(i));
                end
                hold on;
                for j = 1:10
                    plot([reward_bin_all(j),reward_bin_all(j)], ...
                         [1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
        
            [~,index_sort2] = sort(peak_position_odd(sorting_type,:));
            subplot(2,4,5);
            imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('odd trials');
            subplot(2,4,6);
            imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('even trials');
        
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);
        
            % ---- mean map：同样使用 spk_type_new（4 行）----
            mean_map = mean(spk_type_new, 1, 'omitnan');
            peak_spatial = zeros(1, numel(index_responsive));
            for i = 1:numel(index_responsive)
                x = squeeze(mean_map(1,i,:));
                peak_spatial(i) = find(x == max(x), 1);
            end
            [~,index_spatial] = sort(peak_spatial);
        
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j = 1:10
                plot([reward_bin_all(j),reward_bin_all(j)], ...
                     [1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);
        elseif typenum == 'pattern'
            figure;
            for i=1:6
                subplot(2,6,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            subplot(2,6,7);
            imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('odd trials');
            subplot(2,6,8);
            imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('even trials');
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            colorbar;
            caxis([0 1]);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

        elseif typenum == 'position75'
            trail_new = [trial_name,trial_name];
            figure;
            for i=1:12
                subplot(3,6,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trail_new(i));
                title_use_now = "n="+num_title(i);
                subtitle(title_use_now);
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            subplot(3,6,13);
            imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('odd trials');
            subplot(3,6,14);
            imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('even trials');
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

        elseif typenum == 'pattern75'
            trail_new = [trial_name,trial_name];
            figure;
            for i=1:12
                subplot(3,6,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trail_new(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            subplot(3,6,13);
            imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('odd trials');
            subplot(3,6,14);
            imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('even trials');
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

        else
            figure;
            for i=1:6
                subplot(2,6,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);
        end

    elseif length(typenum) == 2
        if typenum(1)=='origin'
            if typenum(2)=='pre-pattern'
                figure;
                for i=1:12
                    subplot(3,6,i);
                    imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                    caxis([0,1]);
                    title(trial_name(i));
                    hold on;
                    for j=1:8
                        plot([pre_bin_all(j),pre_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                    end
                end
                for i=13:14
                    subplot(3,6,i);
                    imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                    caxis([0,1]);
                    title(trial_name(i));
                    hold on;
                    for j=1:10
                        plot([pre_bin_all(j),pre_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                    end
                end
                img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
                img_file_path = fullfile(save_folder, img_file_name);
                saveas(gcf, img_file_path);
                close(gcf);

                mean_map=mean(spk_type_plot(:,:,:),1);
                for i=1:numel(index_responsive)
                    x=squeeze(mean_map(1,i,:));
                    peak_spatial(i)=find(x==max(x),1);
                end
                [~,index_spatial]=sort(peak_spatial);
                figure;
                imagesc(squeeze(mean_map(:,index_spatial,:)));
                caxis([0 1]);
                hold on;
                img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
                img_file_path = fullfile(save_folder, img_file_name);
                saveas(gcf, img_file_path);
                close(gcf);
            else
                figure;
                for i=1:2
                    subplot(2,6,i);
                    imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                    caxis([0,1]);
                    title(trial_name(i));
                    hold on;
                    for j=1:10
                        plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                    end
                end
                for i=3:8
                    plot_index = i+4;
                    subplot(2,6,plot_index);
                    imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                    caxis([0,1]);
                    title(trial_name(i));
                    hold on;
                    for j=1:10
                        plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                    end
                end
                [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
                subplot(2,6,3);
                imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
                caxis([0,1]);
                title('odd trials');
                subplot(2,6,4);
                imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
                caxis([0,1]);
                title('even trials');
                img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
                img_file_path = fullfile(save_folder, img_file_name);
                saveas(gcf, img_file_path);
                close(gcf);

                mean_map=mean(spk_type_plot(:,:,:),1);
                for i=1:numel(index_responsive)
                    x=squeeze(mean_map(1,i,:));
                    peak_spatial(i)=find(x==max(x),1);
                end
                [~,index_spatial]=sort(peak_spatial);
                figure;
                imagesc(squeeze(mean_map(:,index_spatial,:)));
                caxis([0 1]);
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
                end
                img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
                img_file_path = fullfile(save_folder, img_file_name);
                saveas(gcf, img_file_path);
                close(gcf);
            end
        else
            figure;
            for i=1:6
                subplot(3,6,i);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            for i=3:8
                plot_index = i+4;
                subplot(3,6,plot_index);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            for i=6:12
                plot_index = i;
                subplot(3,6,plot_index);
                imagesc(squeeze(spk_type_plot(i,index_sort,:)));
                caxis([0,1]);
                title(trial_name(i));
                hold on;
                for j=1:10
                    plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
                end
            end
            [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
            subplot(3,6,13);
            imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('odd trials');
            subplot(3,6,14);
            imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
            caxis([0,1]);
            title('even trials');
            img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);

            mean_map=mean(spk_type_plot(:,:,:),1);
            for i=1:numel(index_responsive)
                x=squeeze(mean_map(1,i,:));
                peak_spatial(i)=find(x==max(x),1);
            end
            [~,index_spatial]=sort(peak_spatial);
            figure;
            imagesc(squeeze(mean_map(:,index_spatial,:)));
            caxis([0 1]);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
            end
            img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
            img_file_path = fullfile(save_folder, img_file_name);
            saveas(gcf, img_file_path);
            close(gcf);
        end

    elseif length(typenum) == 3
        trail_new = [trial_name,trial_name];
        figure;
        for i=1:2
            subplot(3,6,i);
            imagesc(squeeze(spk_type_plot(i,index_sort,:)));
            caxis([0,1]);
            title(trail_new(i));
            title_use_now = "n="+num_title(i);
            subtitle(title_use_now);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
            end
        end
        for i=7:12
            plot_index = i;
            subplot(3,6,plot_index);
            sort_index = i-4;
            imagesc(squeeze(spk_type_plot(sort_index,index_sort,:)));
            caxis([0,1]);
            title(trail_new(sort_index));
            title_use_now = "n="+num_title(sort_index);
            subtitle(title_use_now);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
            end
        end
        for i=13:18
            plot_index = i;
            subplot(3,6,plot_index);
            sort_index = i-2;
            imagesc(squeeze(spk_type_plot(sort_index,index_sort,:)));
            caxis([0,1]);
            title(trail_new(sort_index));
            title_use_now = "n="+num_title(sort_index);
            subtitle(title_use_now);
            hold on;
            for j=1:10
                plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',0.5);
            end
        end
        [~,index_sort2]=sort(peak_position_odd(sorting_type,:));
        subplot(3,6,5);
        imagesc(squeeze(spk_odd_plot(sorting_type,index_sort,:)));
        caxis([0,1]);
        title('odd trials');
        subplot(3,6,6);
        imagesc(squeeze(spk_even_plot(sorting_type,index_sort,:)));
        caxis([0,1]);
        title('even trials');
        img_file_name = sprintf('heatmap2_%s_%s_%s_%s.png', number, trial_number, date, suffix);
        img_file_path = fullfile(save_folder, img_file_name);
        saveas(gcf, img_file_path);
        close(gcf);

        mean_map=mean(spk_type_plot(:,:,:),1);
        for i=1:numel(index_responsive)
            x=squeeze(mean_map(1,i,:));
            peak_spatial(i)=find(x==max(x),1);
        end
        [~,index_spatial]=sort(peak_spatial);
        figure;
        imagesc(squeeze(mean_map(:,index_spatial,:)));
        caxis([0 1]);
        hold on;
        for j=1:10
            plot([reward_bin_all(j),reward_bin_all(j)],[1,numel(index_responsive)],'-r','LineWidth',1.5);
        end
        img_file_name = sprintf('meanmap_%s_%s_%s_%s.png', number, trial_number, date, suffix);
        img_file_path = fullfile(save_folder, img_file_name);
        saveas(gcf, img_file_path);
        close(gcf);
    end
end
%% 
