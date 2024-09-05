%% Eye-tracking data analysis
% 08-05-2023, for Object Search consequence for LTM

%% Part1--WM Retrocue Analysis

%% Step1--Trial epoch extraction

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

% for pp = 1:length(sub_list)
for pp = 23:28


    %% Set trig labels and epoch timings
    values2use  = 30; % retrocue onset
    prestim     = -0.5; % from fixation onset
    poststim    = 2; % until 2 s after retrocue

    %% participant-specific information
    param = getSubjParam_OSltmv1(pp);
    disp(['getting data from ', param.subjName]);

    % get correct datafile, given session loop
    param.eds = param.eds1;

    %% get eyetracker data also locked to desired events
    hdr = ft_read_header([param.eds]);
    hdr.Fs = 1000;

    %% read in full dataset at once
    cfg = [];
    cfg.dataset = param.eds;
    cfg.hdr = hdr;
    eyedata = ft_preprocessing(cfg);

    %% nan blinks using function
    %         plotting = true; % plot single sub's eyemovement or not: true-plot, false-not plot
    plotting = false;
    eyedata = frevede_nanBlinks_1eye(eyedata, hdr, plotting);

    %% epoch using custom code
    clear event;
    idx = 0;
    for t = 1:length((hdr.orig.msg))
        x = findstr(hdr.orig.msg{t}, 'trig'); % find timepoints label start with 'trig', find all trigs
        if x % whenever find the word 'trig' check what trig value it has, and what the data sample is, to epoch around.
            %                 disp(['found trigger no. ' num2str(idx)]); % display found trigger
            idx = idx+1;
            event.label(idx) =  {[hdr.orig.msg{t}(x:end)]};
            event.timestamp(idx) = str2double([hdr.orig.msg{t}(4:x-1)]);

            % find closest possible sample to make sure to always have one...
            [a,b] = min(abs(hdr.orig.dat(1,:) - event.timestamp(idx)));
            event.sample(idx) = b;
        end
    end

    % get labels of triggers we wish to epoch around
    idx = 0;
    for v = values2use;
        idx = idx+1;
        lab2use(idx) = {['trig', num2str(v)]};
    end

    % get trl with begin sample, endsample, and offset
    trloi = match_str(event.label, lab2use); % trl of interest from all events
    soi = event.sample(trloi)'; % samples of interest, given trials of interest.
    trl_eye = [soi+prestim*hdr.Fs, soi+(poststim-0.001)*hdr.Fs, ones(length(soi),1)*prestim*hdr.Fs]; % determine startsample, endsample, and offset

    % re-define trial after trig & timerange selection
    cfg = [];
    cfg.trl = trl_eye;
    eyedata = ft_redefinetrial(cfg, eyedata);

    % get timepoints for each epoch
    trigval = [];
    for trl = 1:length(trloi)
        trigval(trl) = str2double(event.label{trloi(trl)}(5:end));
        eyedata.time{trl} = prestim:1/hdr.Fs:poststim-1/hdr.Fs; % for some reason timing was way off an inconsistent across pp, even though trl_eye looked fine. Hopefully this corrects it...
    end
    eyedata.trialinfo(:,1) = trigval';

    %% get to three channels
    % we only need x-axis, y-axis, & pupil from now on
    eyedata.label(2:4) = {'eyeX','eyeY','eyePupil'};

    % keep only relevant eye-data channels
    cfg = [];
    cfg.channel = {'eyeX','eyeY','eyePupil'};
    eyedata = ft_selectdata(cfg, eyedata);

    %% save data as function of pp name and eyedata session
    save([param.path, 'results/epoched_data/OSltm_v1_Cue_', param.subjName], 'eyedata');

    %% end loops
end % end of pp loop

clear;clc

