%% Eye-tracking data analysis
% 07-May-2024, for Object Search consequence for LTM

%% Part1--WM Retrocue Analysis

%% Step4--Pupil size calculation

%% start clean
clear; clc; close all;

% % add fieldtrip & path
addpath '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/toolbox/fieldtrip-20201023'
ft_defaults

addpath '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/Analysis_Code/';
cd '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/Analysis_Code/';


%% set loops
% sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';};
sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';'38';'39';'40';'41';'42';'43';};
% sub16&17 lost some eye data, the trial number doesn't match
 
for pp = 3:length(sub_list)

    baselineCorrect = 1;  % 1-baseline correction; 0-no bc
    removeTrials     = 0;    % 1-remove artifact trials; 0-keep trials. 1-remove trials where gaze deviation larger than value specified below. Only sensible after baseline correction!
    max_x_pos        = 100;   % remove trials with x_position bigger than XX pixels (50 pixels~1degree), 50/100 pixels
    plotResults       = 0;

    %% load epoched data of this participant data and concattenate the three parts
    param = getSubjParam_OSltmv1(pp);
    x1 = load([param.path, 'results/epoched_data/OSltm_v1_Cue_', param.subjName], 'eyedata');

    % append
    cfg = [];
    eyedata = ft_appenddata(cfg, x1.eyedata);
    clear x*

    %% add relevant behavioural file data
    behdata = load(param.log);
    eyedata.trialinfo(:,2) = behdata.TrialParamList(:,7); % cuetype: left or right.
    eyedata.trialinfo(:,3) = behdata.pic_SMP(:,3); % SMP: 1-cor, 0-incor
    eyedata.trialinfo(:,4) = behdata.TrialParamList(:,11); % searchtype: 1-present or 2-absent


    %% only keep channels of interest
    cfg = [];
%     cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    cfg.channel = {'eyePupil'}; 
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels


    %% reformat data
    % reformat time-series data from trials cell into double matrix of trial*channel*time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % reformate the data: from trial*time cells into trial*channel*time double matrix

    %% baseline correction
    if baselineCorrect
        tsel = tl.time >= -0.5 & tl.time <= 0; % baseline before sample onset (during fixation)
        bl = squeeze(mean(tl.trial(:,:,tsel),3)); % average bl points
        for t = 1:length(tl.time)
            tl.trial(:,:,t) = ((tl.trial(:,:,t) - bl)); % subtract bl
        end
    end

    %% remove trials with gaze deviation >= 50 pixels
%     chX = ismember(tl.label, 'eyeX');
%     chY = ismember(tl.label, 'eyeY');
% 
%     if plotResults
%         figure; plot(tl.time, squeeze(tl.trial(:,chX,:))); title('all trials - full time range');
%     end
% 
%     if removeTrials
%         % redefine time range of interest to detect extreme values & remove the trial
%         tsel = tl.time>= 0 & tl.time <=1.5; % 0-2s time-locked to retrocue onset: cue-0.5s+delay2-1.5s
%         if plotResults
%             figure; subplot(1,2,1); plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel))); title('before');
%         end
%         for trl = 1:size(tl.trial,1)
%             oktrial(trl) = sum(abs(tl.trial(trl,chX,tsel)) > max_x_pos)==0; % after baselining, no more deviation than 50/100 pixels... which is about 1/2 degree
%         end
% 
%         % extract trials without artifact--oktrial
%         tl.trial = tl.trial(oktrial,:,:);
%         tl.trialinfo = tl.trialinfo(oktrial,:);
%         if plotResults
%             subplot(1,2,2); plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel))); title('after');
%         end
%         proportionOK(pp) = mean(oktrial);
%     end


    chP = ismember(tl.label, 'eyePupil');

    if plotResults
        figure; plot(tl.time, squeeze(tl.trial(:,chP,:))); title('all trials - full time range');
    end

    if removeTrials
        % redefine time range of interest to detect extreme values & remove the trial
        tsel = tl.time>= 0 & tl.time <=1.5; % 0-2s time-locked to retrocue onset: cue-0.5s+delay2-1.5s
        if plotResults
            figure; subplot(1,2,1); plot(tl.time(tsel), squeeze(tl.trial(:,chP,tsel))); title('before');
        end
        for trl = 1:size(tl.trial,1)
            oktrial(trl) = sum(abs(tl.trial(trl,chP,tsel)) > max_x_pos)==0; % after baselining, no more deviation than 50/100 pixels... which is about 1/2 degree
        end

        % extract trials without artifact--oktrial
        tl.trial = tl.trial(oktrial,:,:);
        tl.trialinfo = tl.trialinfo(oktrial,:);
        if plotResults
            subplot(1,2,2); plot(tl.time(tsel), squeeze(tl.trial(:,chP,tsel))); title('after');
        end
        proportionOK(pp) = mean(oktrial);
    end


    %% selection vectors for conditions -- this is where it starts to become interesting!
    % cued item location
    cueL = ismember(tl.trialinfo(:,2), [1]);
    cueR = ismember(tl.trialinfo(:,2), [2]);

    SMPcor = ismember(tl.trialinfo(:,3), [1]);
    SMPincor = ismember(tl.trialinfo(:,3), [0]);

    tarpre = ismember(tl.trialinfo(:,4), [1]);
    tarabs = ismember(tl.trialinfo(:,4), [2]);


    %% get relevant contrasts out
    % calculate pupil size from now on

    pupilsize = [];
    pupilsize.time = tl.time * 1000; % change sec to ms
    pupilsize.label = {'inforcue-SMPcor','inforcue-SMPincor',...
                                'inforcue-cueL','inforcue-cueR',...
                                'inforcue-cueL-SMPcor','inforcue-cueR-SMPcor',...
                                'inforcue-cueL-SMPincor','inforcue-cueR-SMPincor',...
                                };

    for con = 1:length(pupilsize.label)
        if       con == 1 sel = SMPcor;
        elseif con == 2 sel = SMPincor;
        elseif con == 3 sel = cueL;
        elseif con == 4 sel = cueR;
        elseif con == 5 sel = cueL&SMPcor;
        elseif con == 6 sel = cueR&SMPcor;
        elseif con == 7 sel = cueL&SMPincor;
        elseif con == 8 sel = cueR&SMPincor;
        end

        pupilsize.data(con,:) = squeeze(nanmean(tl.trial(sel, chP, :)));

    end



    %% save
    if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end; % depending on this option, append to name of saved file.
    if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end; % depending on this option, append to name of saved file.

    save([param.path, 'results/saved_data/Cue_pupilsize', toadd1, toadd2, '_', param.subjName], 'pupilsize');

    drawnow;

    %% close loops
end % end pp loop


