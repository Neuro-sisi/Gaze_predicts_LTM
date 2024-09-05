%% Eye-tracking data analysis
% 08-05-2023, for Object Search consequence for LTM

% 16 Jan 2024, seperate trials with probe present/absent

%% Part1--WM Retrocue Analysis

%% Step3-- saccade-shift calculation

%% start clean
clear; clc; close all;

%% add fieldtrip & path
addpath '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/toolbox/fieldtrip-20201023'
ft_defaults

addpath '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/Analysis_Code/';
cd '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/Analysis_Code/';

%% set loops
% sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';};
sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';'38';'39';'40';'41';'42';'43';};
% sub16&17 lost some eye data, the trial number doesn't match

for pp = 3:length(sub_list)
% for pp = 23:28

    oneOrTwoD       = 1; oneOrTwoD_options = {'_1D','_2D'};
    plotResults     = 0; % plot-1


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
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

    %% reformat such that all data in single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
    tl.trial(:,1,:) = dva_x;
    tl.trial(:,2,:) = dva_y;

    %% selection vectors for conditions -- this is where it starts to become interesting!
    % cued item location
    cueL = ismember(tl.trialinfo(:,2), [1]);
    cueR = ismember(tl.trialinfo(:,2), [2]);

    SMPcor = ismember(tl.trialinfo(:,3), [1]);
    SMPincor = ismember(tl.trialinfo(:,3), [0]);

    tarpre = ismember(tl.trialinfo(:,4), [1]);
    tarabs = ismember(tl.trialinfo(:,4), [2]);

    %% channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    data_input = squeeze(tl.trial);
    time_input = tl.time*1000;

    if oneOrTwoD == 1         [shiftsX, velocity, times]             = PBlab_gazepos2shift_1D(cfg, data_input(:,chX,:), time_input);
    elseif oneOrTwoD == 2     [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    end

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1     saccadesize = abs(shiftsX);
    elseif oneOrTwoD == 2 saccadesize = abs(shiftsX+shiftsY*1i);
    end
    shiftsL = shiftsX<0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);
    shiftsR = shiftsX>0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);

    %% get relevant contrasts out
    saccade = [];
    saccade.time = times;
    saccade.label = {'informativecue','inforcue-SMPcor','inforcue-SMPincor',...
        'inforcue-SMPcor-tarpre','inforcue-SMPincor-tarpre','inforcue-SMPcor-tarabs','inforcue-SMPincor-tarabs'};

    for con = 1:7
        if       con == 1 sel = ones(length(cueL),1);
        elseif con == 2 sel = SMPcor;
        elseif con == 3 sel = SMPincor;
        elseif con == 4 sel = SMPcor&tarpre;
        elseif con == 5 sel = SMPincor&tarpre;
        elseif con == 6 sel = SMPcor&tarabs;
        elseif con == 7 sel = SMPincor&tarabs;
        end
        saccade.toward(con,:) =  (mean(shiftsL(cueL&sel,:)) + mean(shiftsR(cueR&sel,:))) ./ 2;
        saccade.away(con,:)  =   (mean(shiftsL(cueR&sel,:)) + mean(shiftsR(cueL&sel,:))) ./ 2;

        % count trial number for each condition
        trial_num(pp,con) = length(find(sel));
    end

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);


    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccade.toward = smoothdata(saccade.toward,2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccade.away   = smoothdata(saccade.away,2,  'movmean',integrationwindow)*1000;
    saccade.effect = smoothdata(saccade.effect,2,'movmean',integrationwindow)*1000;


    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:6-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label =  {'informativecue','inforcue-SMPcor','inforcue-SMPincor',...
        'inforcue-SMPcor-tarpre','inforcue-SMPincor-tarpre','inforcue-SMPcor-tarabs','inforcue-SMPincor-tarabs'};

    cnt = 0;
    for sz = saccadesize.freq;
        cnt = cnt+1;
        shiftsL = [];
        shiftsR = [];
        shiftsL = shiftsX<-sz+halfbin & shiftsX > -sz-halfbin; % left shifts within this range
        shiftsR = shiftsX>sz-halfbin  & shiftsX < sz+halfbin; % right shifts within this range

        for con = 1:7
            if       con == 1 sel = ones(length(cueL),1);
            elseif con == 2 sel = SMPcor;
            elseif con == 3 sel = SMPincor;
            elseif con == 4 sel = SMPcor&tarpre;
            elseif con == 5 sel = SMPincor&tarpre;
            elseif con == 6 sel = SMPcor&tarabs;
            elseif con == 7 sel = SMPincor&tarabs;
            end
            saccadesize.toward(con,cnt,:) = (mean(shiftsL(cueL&sel,:)) + mean(shiftsR(cueR&sel,:))) ./ 2;
            saccadesize.away(con,cnt,:) =   (mean(shiftsL(cueR&sel,:)) + mean(shiftsR(cueL&sel,:))) ./ 2;
        end

    end

    % add towardness field
    saccadesize.effect = (saccadesize.toward - saccadesize.away);


    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccadesize.away   = smoothdata(saccadesize.away,3,  'movmean',integrationwindow)*1000;
    saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;

    if plotResults
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        figure;
        for chan = 1
            cfg.channel = chan;
            ft_singleplotTFR(cfg, saccadesize);
        end
        colormap('jet');
        drawnow;
    end

    %% save
    save([param.path, 'results/saved_data/Cue_saccadeEffects', oneOrTwoD_options{one