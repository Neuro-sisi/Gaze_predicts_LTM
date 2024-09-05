%% Eye-tracking data analysis
% 08-05-2023, for Object Search consequence for LTM

%% Part1--WM Retrocue Analysis

%% Step3--grand average plots of gaze-position results

%% start clean
clear; clc; close all;

% % add fieldtrip & path
addpath '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/toolbox/fieldtrip-20201023'
ft_defaults

addpath '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/Analysis_Code/';
cd '/Volumes/sisBNU4Tnew/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/Analysis_Code/';


% % set loops
% sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';};
sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';'38';'39';'40';'41';'42';'43';};
% sub16&17 lost some eye data, the trial number doesn't match

% select subs to average
% pp2do = 3:length(sub_list);
pp2do = 3:27;

nsmooth         = 25; % smooth time series data ms
baselineCorrect = 1; % should be consistent with s2
removeTrials    = 0; % should be consistent with s2

xlimtoplot      = [-500 1500];
% xlimtoplot      = [-200 1000];


%% load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam_OSltmv1(pp);

    % load
    disp(['getting data from participant ', param.subjName]);

    if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end; % depending on this option, append to name of saved file.
    if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end; % depending on this option, append to name of saved file.

    load([param.path, 'results/saved_data/Cue_pupilsize', toadd1, toadd2, '_', param.subjName], 'pupilsize');

    % smooth data
    if nsmooth > 0
        for x1 = 1:size(pupilsize.data,1)
            pupilsize.data(x1,:) = gsmooth(squeeze(pupilsize.data(x1,:)), nsmooth);
        end
    end

    % merge all subs data
    d1(s,:,:) = pupilsize.data; % put into matrix, with pp as first dimension
    
end


%% plot grand average 

%% plot infor_SMPcor vs. infor_SMPincor
lineco = [1 0.5 0; 0 0.4470 0.7410;];
figure('Name','WMltm_v1_Cue_pupilsize_SMP','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 500 350])
p1 = frevede_errorbarplot(pupilsize.time, squeeze(d1(:,1,:)), lineco(1,:), 'se');
p2 = frevede_errorbarplot(pupilsize.time, squeeze(d1(:,2,:)), lineco(2,:), 'se');
xline(0,'--','Cue Onset',FontSize=12,LineWidth=2);
yline(0,'--');ylim([-25 30]); 
% yticks(-0.3:0.3:0.6);
legend([p1,p2], {'Later remembered','Later forgotten'}, 'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('pupil size (pixels)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

saveas(gcf, 'WMltm_v1_Cue_pupilsize_SMP_s25', 'jpg')
set(gcf,'renderer','painters')
saveas(gcf, 'WMltm_v1_Cue_pupilsize_SMP_s25', 'epsc')


%% plot infor_cueleft vs. infor_cueright
lineco = [1 0.5 0; 0 0.4470 0.7410;];
figure('Name','WMltm_v1_Cue_pupilsize_cueLvsR','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 500 350])
p1 = frevede_errorbarplot(pupilsize.time, squeeze(d1(:,3,:)), lineco(1,:), 'se');
p2 = frevede_errorbarplot(pupilsize.time, squeeze(d1(:,4,:)), lineco(2,:), 'se');
xline(0,'--','Cue Onset',FontSize=12,LineWidth=2);
yline(0,'--');ylim([-25 30]); 
% yticks(-0.3:0.3:0.6);
legend([p1,p2], {'Cue Left','Cue Right'}, 'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('pupil size (pixels)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

saveas(gcf, 'WMltm_v1_Cue_pupilsize_cueLvsR_s25', 'jpg')
set(gcf,'renderer','painters')
saveas(gcf, 'WMltm_v1_Cue_pupilsize_cueLvsR_s25', 'epsc')


%% cluster-permutation test
timerange = [0 1000];
timediff1 = abs(pupilsize.time-timerange(1));
pnt_start = find(timediff1==min(timediff1));
timediff2 = abs(pupilsize.time-timerange(2));
pnt_end = find(timediff2==min(timediff2));
clear timediff1 timediff2

data_cond1 = squeeze(d1(:,1,pnt_start:pnt_end));
data_cond2 = squeeze(d1(:,2,pnt_start:pnt_end));
data_zero = zeros(size(data_cond1)); % compare with 0

statcfg.xax = pupilsize.time(pnt_start:pnt_end);
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.025; % two-sided (0.05 if one-sided)
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo'; % or 'analytic'; 

% cluster test
stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, data_zero);
stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, data_zero);
stat12 = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2);

signegclurange1 = statcfg.xax(find(stat1.negclusterslabelmat==1));
signegclurange2 = statcfg.xax(find(stat2.negclusterslabelmat==1));
signegclurange12 = statcfg.xax(find(stat12.negclusterslabelmat==1));
sigposclurange1 = statcfg.xax(find(stat1.posclusterslabelmat==1));
sigposclurange2 = statcfg.xax(find(stat2.posclusterslabelmat==1));
sigposclurange12 = statcfg.xax(find(stat12.posclusterslabelmat==1));

save(fullfile('WMltm_v1_Cue_pupilsize_SMP_permutation_results_s25.mat'))



