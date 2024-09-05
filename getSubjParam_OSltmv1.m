function param = getSubjParam_OSltmv1(pp)

% 4-12-2023 Freek van Ede
% 4-13-2023 Sisi Wang

%% participant-specific notes

%% set path and pp-specific file locations

param.path = '/Volumes/SisiVUA2024/VUAm_2023/Research_VUAm/Eyedata_Analysis/EyeData_ana_WM_LTM_v1/';

% sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';};
sub_list = {'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';'38';'39';'40';'41';'42';'43';};
% sub_list = {'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37';};
% sub16&17 lost some eye data, the trial number doesn't match

% pp = 1:length(sub_list);

if pp < 10 % sub_No < 10, add 0 to sub_No
    param.subjName = ['pp0' num2str(pp)];
    param.log =  [param.path, ['rawdata/behdata_raw/ObjSearch_LTM_v2_SMPlabel_sub' sub_list{pp} '.mat']];
    param.eds1 = [param.path, ['rawdata/eyedata_raw/OSC_EN_part1_sub' sub_list{pp} '_1.asc']];
    
else % sub_No >= 10
    param.subjName = ['pp' num2str(pp)];
    param.log =  [param.path, ['rawdata/behdata_raw/ObjSearch_LTM_v2_SMPlabel_sub' sub_list{pp} '.mat']];
    param.eds1 = [param.path, ['rawdata/eyedata_raw/OSC_EN_part1_sub' sub_list{pp} '_1.asc']];
    
end

end


