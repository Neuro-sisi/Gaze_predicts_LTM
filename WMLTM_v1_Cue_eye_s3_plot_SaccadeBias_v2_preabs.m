%% Eye-tracking data analysis
% 08-05-2023, for Object Search consequence for LTM

% 16 Jan 2024, seperate trials with probe present/absent

%% Part1--WM Retrocue Analysis

%% Step3b--grand average plots of gaze-shift (saccade) results

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

% select subs to average
% pp2do = 3:length(sub_list);
pp2do = [3:27];

oneOrTwoD       = 1;        oneOrTwoD_options = {'_1D','_2D'};
nsmooth         = 25;
plotSinglePps   = 0;
% xlimtoplot      = [-500 1500];
xlimtoplot      = [-200 1000];


% % load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam_OSltmv1(pp);

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.path, 'results/saved_data/Cue_saccadeEffects', oneOrTwoD_options{oneOrTwoD} '_', param.subjName], 'saccade','saccadesize');

    % smooth?
    if nsmooth > 0
        for x1 = 1:size(saccade.toward,1)
            saccade.toward(x1,:)  = gsmooth(squeeze(saccade.toward(x1,:)), nsmooth);
            saccade.away(x1,:)    = gsmooth(squeeze(saccade.away(x1,:)), nsmooth);
            saccade.effect(x1,:)  = gsmooth(squeeze(saccade.effect(x1,:)), nsmooth);
        end
        % also smooth saccadesize data over time.
        for x1 = 1:size(saccadesize.toward,1)
            for x2 = 1:size(saccadesize.toward,2)
                saccadesize.toward(x1,x2,:) = gsmooth(squeeze(saccadesize.toward(x1,x2,:)), nsmooth);
                saccadesize.away(x1,x2,:)   = gsmooth(squeeze(saccadesize.away(x1,x2,:)), nsmooth);
                saccadesize.effect(x1,x2,:) = gsmooth(squeeze(saccadesize.effect(x1,x2,:)), nsmooth);
            end
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = saccade.toward;
    d2(s,:,:) = saccade.away;
    d3(s,:,:) = saccade.effect;

    d4(s,:,:,:) = saccadesize.toward;
    d5(s,:,:,:) = saccadesize.away;
    d6(s,:,:,:) = saccadesize.effect;
end


%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
% calculate difference between SMP-cor - SMP-incor
d7 = squeeze(d6(:,2,:,:)-d6(:,3,:,:));
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));

for c = 1:7
saccadesize.effectdiff(c,:,:) = squeeze(mean(d7));
end



%% plot single sub
if plotSinglePps

    % plot single sub--informative cue
    figure('Name','WMltm_v1_Cue_saccade_effect_singlesub','NumberTitle','off','Color','white'),
    set(gcf,'Position',[0 0 1800 900])
    for sp = 1:s
        subplot(5,5,sp);
        hold on; 
        plot(saccade.time, squeeze(d3(sp,1,:))); % inforcue
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-3 3]);
        title(pp2do(sp));
    end
    legend(saccade.label(1));
    saveas(gcf, 'WMltm_v1_Cue_saccade_effect_singlesub_s25', 'jpg')


    %  plot single sub--gaze shift effect X saccade size
    figure('Name','WMltm_v1_Cue_saccadesize_singlesub','NumberTitle','off','Color','white'),
    set(gcf,'Position',[0 0 1800 900])

    cfg = [];
    cfg.parameter = 'effect_individual';
    cfg.figure = 'gcf';
    cfg.zlim = [-.1 .1];
    cfg.xlim = xlimtoplot;
    for sp = 1:s
        subplot(5,5,sp);
        hold on;
        saccadesize.effect_individual = squeeze(d6(sp,:,:,:)); % put in data from this pp & specific condition
        cfg.channel = 1; % con1--inforcue
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end
    saveas(gcf, 'WMltm_v1_Cue_saccadesize_singlesub_s25', 'jpg')

end



%% plot grand average data patterns of interest, with error bars

%% plot infor_SMPcor vs. infor_SMPincor
%% plot overlay: saccade effect
% lineco = [0 0 0; 0 1 1; 1 0 1;];
lineco = [0 0 0; 0 0.4470 0.7410; 0.8500 0.3250 0.0980;];
figure('Name','WMltm_v1_Cue_saccade_effect_overlay','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 400 300])
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,2,:)), lineco(2,:), 'se');
p3 = frevede_errorbarplot(saccade.time, squeeze(d3(:,3,:)), lineco(3,:), 'se');
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');ylim([-0.5 1]);
legend([p2,p3], saccade.label(2:3),'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

saveas(gcf, 'WMltm_v1_Cue_saccade_effect_overlay_s25_new', 'jpg')


%% plot toward & away -- infor_SMPcor vs. infor_SMPincor
lineco = [0.6350, 0.0780, 0.1840; 0.9290, 0.6940, 0.1250; 0, 0.4470, 0.7410; 0.4660, 0.6740, 0.1880;];
figure('Name','WMltm_v1_Cue_saccade_toward_away_SMP','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 800 300])

subplot(1,2,1), hold on, title('toward'),
p2 = frevede_errorbarplot(saccade.time, squeeze(d1(:,2,:)), lineco(1,:), 'se');
p3 = frevede_errorbarplot(saccade.time, squeeze(d1(:,3,:)), lineco(2,:), 'se');
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');ylim([0 1]);
legend([p2,p3], {'SMP-cor','SMP-incor'},'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

subplot(1,2,2), hold on, title('away'),
p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,2,:)), lineco(3,:), 'se');
p3 = frevede_errorbarplot(saccade.time, squeeze(d2(:,3,:)), lineco(4,:), 'se');
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');ylim([0 1]);
legend([p2,p3], {'SMP-cor','SMP-incor'},'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

saveas(gcf, 'WMltm_v1_Cue_saccade_toward_away_SMP_s25', 'jpg')


%% plot SMP X target_presence
% saccade effect (to-aw)
figure('Name','WMltm_v1_Cue_saccade_effect_tarpreabs','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 800 300])

subplot(1,2,1);hold on; title('Present');
p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,4,:)), lineco(2,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,5,:)), lineco(3,:), 'se');
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');ylim([-0.5 1]);
% legend([p1,p2], saccade.label(4:5),'AutoUpdate','off','Box','off');
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')

subplot(1,2,2);hold on; title('Absent');
p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,6,:)), lineco(2,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,7,:)), lineco(3,:), 'se');
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');ylim([-0.5 1]);
% legend([p1,p2], saccade.label(6:7),'AutoUpdate','off','Box','off');
legend([p1,p2], {'SMP-cor', 'SMP-incor'},'AutoUpdate','off','Box','off');
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')

saveas(gcf, 'WMltm_v1_Cue_saccade_effect_tarpreabs_s25_new', 'jpg')



%% plot toward vs. away  && saccade size for infor_all
% redefine time range
colormap2use        = fliplr(brewermap(100, 'RdBu'));
xlimtoplot      = [-200 1000];
% toward vs away 
figure('Name','WMltm_v1_Cue_saccade_towardvsaway','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 600 800])

subplot(3,1,1);hold on;title('toward vs. away')
p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,1,:)), [1 0 0], 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,1,:)), [0 0 1], 'se');
xlim(xlimtoplot); ylim([0 1]);
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
xlabel('Time (ms)'), ylabel('Saccade rate (Hz)')
legend([p1, p2], {'Toward','Away'},"AutoUpdate","off","Box","off");

subplot(3,1,2);hold on;title('toward minus away')
p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), [0 0 0], 'se');
xlim(xlimtoplot); ylim([-0.5 0.5]);
xline(0,'--','Cue Onset',FontSize=12);
yline(0,'--');
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
xlabel('Time (ms)'), ylabel('Saccade bias')

subplot(3,1,3);hold on;
% % as function of saccade size
% saccadesize.toward = squeeze(mean(d4));
% saccadesize.away   = squeeze(mean(d5));
% saccadesize.effect = squeeze(mean(d6));

cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = ' ';
cfg.channel = 1;
cfg.colorbar = 0;

ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
% colormap('jet');
colormap(colormap2use);
% colorbar

% saveas(gcf, 'WMltm_v1_Cue_saccade_towardvsaway_saccadesize_inforcue_s25_bar', 'jpg')
saveas(gcf, 'WMltm_v1_Cue_saccade_towardvsaway_saccadesize_inforcue_s25_nobar', 'jpg')



%% plot saccade size X SMP
% redefine time range
colormap2use        = fliplr(brewermap(100, 'RdBu'));
xlimtoplot      = [-200 1000];

% saccade size
figure('Name','WMltm_v1_Cue_saccadesize_SMP','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 1200 300])

subplot(1,3,1);hold on;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'Inforcue-all';
cfg.channel = 1;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar

subplot(1,3,2);hold on;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'SMP-cor';
cfg.channel = 2;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar

subplot(1,3,3);hold on;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'SMP-incor';
cfg.channel = 3;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar

% saveas(gcf, 'WMltm_v1_Cue_saccadesize_SMP_s25_bar', 'jpg')
saveas(gcf, 'WMltm_v1_Cue_saccadesize_SMP_s25_nobar', 'jpg')



%% saccade size difference--SMPcor-incor--4con
% redefine time range
colormap2use        = fliplr(brewermap(100, 'RdBu'));
xlimtoplot      = [-200 1000];

% saccade size
figure('Name','WMltm_v1_Cue_saccadesize_SMP_4con','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 1600 300])

subplot(1,4,1);hold on;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'Inforcue-all';
cfg.channel = 1;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar

subplot(1,4,2);hold on;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'SMP-cor';
cfg.channel = 2;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar

subplot(1,4,3);hold on;
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'SMP-incor';
cfg.channel = 3;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar

subplot(1,4,4);hold on;
cfg = [];
cfg.parameter = 'effectdiff';
cfg.figure = 'gcf';
cfg.zlim = [-.05 .05];
cfg.xlim = xlimtoplot;
cfg.title = 'SMP cor-incor';
cfg.channel = 1;
cfg.colorbar = 0;
ft_singleplotTFR(cfg, saccadesize);
xline(0,'--','Cue Onset',FontSize=12);
yline(1,'--',' ');
xlabel('Time (ms)'), ylabel('Degree')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
colormap(colormap2use);
% colorbar
% saveas(gcf, 'WMltm_v1_Cue_saccadesize_SMP_4con_s25_bar', 'jpg')
saveas(gcf, 'WMltm_v1_Cue_saccadesize_SMP_4con_s25_nobar', 'jpg')


%% plot infor_all & infor_SMPcor & infor_SMPincor
% redefine time range
% xlimtoplot      = [-200 1000];
% toward vs away 
figure('Name','WMltm_v1_Cue_saccade_towardvsaway','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 1200 300])
for con = 1:3
    subplot(1,3,con);hold on; title(saccade.label(con));
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,con,:)), [1,0,0], 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,con,:)), [0,0,1], 'se');
    xlim(xlimtoplot); ylim([0 1]);
    xline(0,'--','Cue Onset');
    yline(0,'--');
    set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
    xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
end
legend([p1, p2], {'Toward','Away'},"AutoUpdate","off","Box","off");

saveas(gcf, 'WMltm_v1_Cue_saccade_towardvsaway_s25_new', 'jpg')


%% plot infor_all & infor_SMPcor & infor_SMPincor
% redefine time range
xlimtoplot      = [-200 1000];
% toward vs away 
figure('Name','WMltm_v1_Cue_saccade_towardvsaway','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 900 300])
for con = 1:3
    subplot(1,3,con);hold on; title(saccade.label(con));
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,con,:)), [1,0,0], 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,con,:)), [0,0,1], 'se');
    xlim(xlimtoplot); ylim([0 2]);
    xline(0,'--','Cue Onset');
    yline(0,'--');
    set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
    xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
end
legend([p1, p2], {'Toward','Away'});
% saveas(gcf, 'WMltm_v1_Cue_saccade_towardvsaway_s25', 'jpg')
saveas(gcf, 'WMltm_v1_Cue_saccade_towardvsaway_s25_2', 'jpg')


% saccade effect (to-aw)
lineco = [0 0 0; 0 1 1; 1 0 1;];
figure('Name','WMltm_v1_Cue_saccade_effect','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 900 300])
for con = 1:3
    subplot(1,3,con);hold on; title(saccade.label(con));
    p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,con,:)), lineco(con,:), 'se');
    xline(0,'--','Cue Onset');
    yline(0,'--');ylim([-0.5 1]);
    legend([p1], saccade.label(con),'AutoUpdate','off','Box','off');
    xlim(xlimtoplot);
    set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
    xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
end
% saveas(gcf, 'WMltm_v1_Cue_saccade_effect_s25', 'jpg')
saveas(gcf, 'WMltm_v1_Cue_saccade_effect_s25_2', 'jpg')


% plot overlay: saccade effect (right-left)
lineco = [0 0 0; 0 1 1; 1 0 1;];
figure('Name','WMltm_v1_Cue_saccade_effect_overlay','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 400 300])
p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), lineco(1,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,2,:)), lineco(2,:), 'se');
p3 = frevede_errorbarplot(saccade.time, squeeze(d3(:,3,:)), lineco(3,:), 'se');
xline(0,'--','Cue Onset');
yline(0,'--');ylim([-0.5 1]);
legend([p1,p2,p3], saccade.label(1:3),'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

% saveas(gcf, 'WMltm_v1_Cue_saccade_effect_overlay_s25', 'jpg')
saveas(gcf, 'WMltm_v1_Cue_saccade_effect_overlay_s25_2', 'jpg')





%% as function of saccade size
cfg = [];
cfg.parameter = 'effect';
cfg.figure = 'gcf';
cfg.zlim = [-.1 .1];
cfg.xlim = xlimtoplot;

% all conditions collapsed
figure('Name','WMltm_v1_Cue_saccadesize','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 1200 300])
for con = 1:3
    subplot(1,3,con);hold on;
    cfg.title = saccadesize.label(con);
    ft_singleplotTFR(cfg, saccadesize);
    cfg.channel = con;
    xline(0,'--','Cue Onset');
    xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
    set(gca, 'FontSize', 15);set(gca,'LineWidth',3);
    colormap('jet');
end
saveas(gcf, 'WMltm_v1_Cue_saccadesize_s25', 'jpg')






%% Stats

%% cluster-permutation test
%% Permutation on saccade in inforcue
timerange = [0 1000];
timediff1 = abs(saccade.time-timerange(1));
pnt_start = find(timediff1==min(timediff1));
timediff2 = abs(saccade.time-timerange(2));
pnt_end = find(timediff2==min(timediff2));
clear timediff1 timediff2

data_cond0 = squeeze(d3(:,1,pnt_start:pnt_end));
data_zero = zeros(size(data_cond0)); % compare with 0

statcfg.xax = saccade.time(pnt_start:pnt_end);
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.025; % two-sided (0.05 if one-sided)
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo'; % or 'analytic'; 

% cluster test
stat0 = frevede_ftclusterstat1D(statcfg, data_cond0, data_zero);

signegclurange0 = statcfg.xax(find(stat0.negclusterslabelmat==1));
sigposclurange0 = statcfg.xax(find(stat0.posclusterslabelmat==1));

save(fullfile('WMxLTM_v1_s25_saccadebias_permutation_results_inforcue.mat'))


%% cluster-permutation test
timerange = [0 1000];
timediff1 = abs(saccade.time-timerange(1));
pnt_start = find(timediff1==min(timediff1));
timediff2 = abs(saccade.time-timerange(2));
pnt_end = find(timediff2==min(timediff2));
clear timediff1 timediff2

data_cond1 = squeeze(d3(:,2,pnt_start:pnt_end));
data_cond2 = squeeze(d3(:,3,pnt_start:pnt_end));
data_zero = zeros(size(data_cond1)); % compare with 0

statcfg.xax = saccade.time(pnt_start:pnt_end);
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

save(fullfile('WMxLTM_v1_s25_saccadebias_permutation_results.mat'))



%% Latency-analysis--Jackknife

%  % S1: calculate mean Saccade leave-one-out method
sub_num = size(d3,1);

for s = 1:sub_num
    for con = 1:2
        if con == 1, sel = 2; elseif con == 2, sel = 3; end
        if s == 1
            saccade_jk(:,s,con) = mean(squeeze(d3([s+1:sub_num],sel,:)),1);
        elseif s == sub_num
            saccade_jk(:,s,con) = mean(squeeze(d3([1:sub_num-1],sel,:)),1);
        elseif s < sub_num && s > 1
            saccade_jk(:,s,con) = mean(squeeze(d3([1:s-1 s+1:sub_num],sel,:)),1);
        end
    end
end


%% Jackknife--S2: find peak latency during a specific time range--50%
% define onset & offset latency 50% peak

srate = 1; % sampling rate
bl = abs(saccade.time(1)); % baseline length: ms
method = 2; % 1-min; 2-max; min(for negative component)/max(for positive component)
% relativeperc = 0.3; % relative percentage of peak amplitude to detect the component onset 
relativeperc = 0.5; % relative percentage of peak amplitude to detect the component onset 
timerg = [1 1000]; % interested time window of ERP component
% find min(for negative component) / max(for positive component) during the time window for each condition
for s = 1:size(saccade_jk,2) % sub_num
    for c = 1:size(saccade_jk,3) % condition_num
        grandave = saccade_jk(round((bl+timerg(1))/srate):round((bl+timerg(2))/srate),s,c);
        if method == 1
            peak_val = min(grandave);
        elseif method == 2
            peak_val = max(grandave);
        end
        grandave_diff = abs(grandave-relativeperc*peak_val); % calculate absulute difference of ERP & 50% of peak value
        
        peak_val_loc = find(grandave==peak_val); % find location of peak value
        
        % component onset & offset
        peak_val_loc_50onset = find(grandave_diff==min(grandave_diff(1:peak_val_loc))); % find the nearest location of the 50% of peak value before peak latency
        peak_val_loc_50offset = find(grandave_diff==min(grandave_diff(peak_val_loc:end))); % find the nearest location of the 50% of peak value before peak latency
        area_diff = peak_val_loc_50offset-peak_val_loc_50onset;

        saccade_jk_peak_val(s,c) = peak_val;

        saccade_jk_peak_lat(s,c) = (peak_val_loc-1)*srate+timerg(1); % get peak latency
        saccade_jk_peak_onset_lat(s,c) = (peak_val_loc_50onset-1)*srate+timerg(1); % get peak latency
        saccade_jk_peak_offset_lat(s,c) = (peak_val_loc_50offset-1)*srate+timerg(1); % get peak latency
        saccade_jk_area50_lat(s,c) = area_diff; % get 50% area latency
        clear grandave peak_val peak_val_loc peak_val_loc_50onset peak_val_loc_50offset grandave_diff area_diff
    end
end


% S3: Retrieved estamation (Smulders, F. T. Y. (2010))
% calculated retrieved latency for each sub
for c = 1:2
    for s = 1:sub_num
        saccade_jk_peak_lat_re(s,c) = sub_num*mean(saccade_jk_peak_lat(:,c),1)-(sub_num-1)*saccade_jk_peak_lat(s,c); % n*aver(lat)-(n-1)*lat_persub
        saccade_jk_peak_onset_lat_re(s,c) = sub_num*mean(saccade_jk_peak_onset_lat(:,c),1)-(sub_num-1)*saccade_jk_peak_onset_lat(s,c); % n*aver(lat)-(n-1)*lat_persub
        saccade_jk_peak_offset_lat_re(s,c) = sub_num*mean(saccade_jk_peak_offset_lat(:,c),1)-(sub_num-1)*saccade_jk_peak_offset_lat(s,c); % n*aver(lat)-(n-1)*lat_persub
        saccade_jk_area50_lat_re(s,c) = sub_num*mean(saccade_jk_area50_lat(:,c),1)-(sub_num-1)*saccade_jk_area50_lat(s,c); % n*aver(lat)-(n-1)*lat_persub
    end
end
 
% do t-test
[~,p_peak_lat_re_12,~,stats_peak_lat_re_12] = ttest(saccade_jk_peak_lat_re(:,1),saccade_jk_peak_lat_re(:,2));

[~,p_peak_onset_lat_re_12,~,stats_peak_onset_lat_re_12] = ttest(saccade_jk_peak_onset_lat_re(:,1),saccade_jk_peak_onset_lat_re(:,2));

[~,p_peak_offset_lat_re_12,~,stats_peak_offset_lat_re_12] = ttest(saccade_jk_peak_offset_lat_re(:,1),saccade_jk_peak_offset_lat_re(:,2));

[~,p_area50_lat_re_12,~,stats_area50_lat_re_12] = ttest(saccade_jk_area50_lat_re(:,1),saccade_jk_area50_lat_re(:,2));

save(fullfile('WMxLTM_v1_saccadebias_SMP_latency_50%_results_Smulders_s25.mat'))



%% bar plot of onset & offset latency--2*2 onset*SMP

figure('Name','WMxLTM_v1_saccadebias_SMP_latency_50%_barplot_re','NumberTitle','off', 'Color','white'),
% set(gcf,'Position',[0 0 400 300])
set(gcf,'Position',[0 0 350 200])

merged_laten = [saccade_jk_peak_onset_lat_re, saccade_jk_peak_offset_lat_re];
% merged_laten = [saccade_jk_peak_onset_lat, saccade_jk_peak_offset_lat];
mean_merged_laten =mean(merged_laten,1);
% calculate means & SEMs
mean_ss = zeros(2,2);
mean_ss(1:2,1) = mean(merged_laten(:,[1 3]),1);
mean_ss(1:2,2) = mean(merged_laten(:,[2 4]),1);
SEM_ss = zeros(2,2);
SEM_ss(1:2,1) = std(merged_laten(:,[1 3]),1)./sqrt(size(merged_laten(:,[1 3]),1));
SEM_ss(1:2,2) = std(merged_laten(:,[2 4]),1)./sqrt(size(merged_laten(:,[2 4]),1));

bp = bar(mean_ss,'LineWidth', 2);
pause(0.1); hold on;
for ib = 1:numel(bp)
    xData = bp(ib).XData+bp(ib).XOffset;
    errorbar(xData,mean_ss(:,ib),SEM_ss(:,ib),'k.','LineWidth',2)
end
set(gca, 'xtick', 1:size(mean_ss,1), 'xticklabel', {'Onset', 'Offset'})
% xlabel('Latency Type'), 
ylabel('Latency (ms)'),
ylim([0 1200]);
legend({'SMP-cor' 'SMP-incor'},"Box","off","AutoUpdate","off");
set(gca, 'FontSize', 15)
set(gca,'LineWidth',3);

saveas(gcf, 'WMxLTM_v1_saccadebias_SMP_latency_50%_barplot_re_s25', 'jpg')
% saveas(gcf, 'WMxLTM_v1_saccadebias_SMP_latency_50%_barplot_s25', 'jpg')



%% horizontal boxplot of onset latency X SMP
% lineco = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;];
lineco = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;];

figure('Name','WMxLTM_v1_saccadebias_SMP_latency_50%_boxplot_re','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 400 200])
% SMP = {'SMP-cor','SMP-incor'};
% ax1 = nexttile;
% boxchart(ax1,saccade_jk_peak_onset_lat_re,'GroupByColor',SMP)
% ylabel(ax1,'SMP')
% legend

b = boxchart(saccade_jk_peak_onset_lat_re,'orientation','horizontal');
% b = boxchart(saccade_jk_peak_onset_lat,'orientation','horizontal');
xlim(xlimtoplot);

% boxplot(saccade_jk_peak_onset_lat_re,'orientation','horizontal','Labels',{'SMP-cor','SMP-incor'},ColorGroup={'b','r'},Symbol='')
% xlim(xlimtoplot);
xlabel('Time (ms)'), ylabel('SMP')
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

saveas(gcf, 'WMxLTM_v1_saccadebias_SMP_latency_50%_boxplot_re_s25', 'jpg')
% saveas(gcf, 'WMxLTM_v1_saccadebias_SMP_latency_50%_boxplot_s25', 'jpg')



%% plot infor_SMPcor vs. infor_SMPincor--with latency
%% plot overlay: saccade effect
% lineco = [0 0 0; 0 1 1; 1 0 1;];
lineco = [0 0 0; 0 0.4470 0.7410; 0.8500 0.3250 0.0980;];
figure('Name','WMltm_v1_Cue_saccade_effect_overlay','NumberTitle','off', 'Color','white'),
set(gcf,'Position',[0 0 400 300])
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,2,:)), lineco(2,:), 'se');
p3 = frevede_errorbarplot(saccade.time, squeeze(d3(:,3,:)), lineco(3,:), 'se');
xline(0,'--','Cue Onset',FontSize=12);
xline(mean_merged_laten(1),'b-');
xline(mean_merged_laten(2),'r-');
xline(mean_merged_laten(3),'b--');
xline(mean_merged_laten(4),'r--');
yline(0,'--');ylim([-0.5 1]);
legend([p2,p3], saccade.label(2:3),'AutoUpdate','off','Box','off');
xlabel('Time (ms)'), ylabel('Microsaccade bias (Hz)')
xlim(xlimtoplot);
set(gca, 'FontSize', 15);set(gca,'LineWidth',3);

saveas(gcf, 'WMltm_v1_Cue_saccade_effect_overlay_s25_new_withlatency', 'jpg')






