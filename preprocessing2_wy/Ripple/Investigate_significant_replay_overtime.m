%% set basepath
basepath = 'Z:\Buzsakilabspace\LabShare\WinnieYang\Data\Achilles\Achilles_10252013';
cd(basepath);
basename = bz_BasenameFromBasepath(basepath);
saving_folder = '\BayesDecoding\';
%% deal with different state

load(dir('*SleepState.states.mat').name);
% load epochs information if available
load(dir('*sessInfo.mat').name);
% number of significant replay events at different NREM state 

post_ints = sessInfo.Epochs.POSTEpoch;
pre_ints = sessInfo.Epochs.PREEpoch;



beh = SleepState.ints.WAKEstate;

pre_REM = SleepState.ints.REMstate(InIntervals(SleepState.ints.REMstate,pre_ints),:);
pre_NREM = SleepState.ints.NREMstate(InIntervals(SleepState.ints.NREMstate,pre_ints),:);

post_NREM = SleepState.ints.NREMstate(InIntervals(SleepState.ints.NREMstate,post_ints),:);
post_REM = SleepState.ints.REMstate(InIntervals(SleepState.ints.REMstate,post_ints),:);

cd([basepath,saving_folder]);
load(dir([basepath,saving_folder,basename,'.ripple_HSE_dec_forward.mat']).name);
ripple_HSE_dec_forward = ripple_HSE_dec;
load(dir([basepath,saving_folder,basename,'.ripple_HSE_dec_backward.mat']).name);
ripple_HSE_dec_backward = ripple_HSE_dec;

%%
post_REM_duration = sum(post_REM(:,2)-post_REM(:,1));
pre_REM_duration = sum(post_REM(:,2)-post_REM(:,1));

figure; bar(post_REM_duration)

%%
[num_sig_replayes, prop_sig_replays_beh_for, prop_sig_replays_postNREM_for] = significant_replay_over_epoch({ripple_HSE_dec_forward,ripple_HSE_dec_backward},pre_NREM,beh,post_NREM);
[num_sig_replays_preNREM, num_sig_replays_postNREM, num_ripple_preNREM,num_ripple_postNREM]  = significant_replay_over_epoch(ripple_HSE_dec_backward,pre_NREM,beh,post_NREM);

%%
figure; plot(num_replays_postNREM);
figure; plot(num_sig_replays_postNREM);


figure;bar([prop_sig_replays_preNREM_for+prop_sig_replays_preNREM_bck,prop_sig_replays_beh_for+prop_sig_replays_beh_bck,prop_sig_replays_postNREM_for+prop_sig_replays_postNREM_bck]);
figure;bar([prop_sig_replays_preNREM_for,prop_sig_replays_beh_for,prop_sig_replays_postNREM_for]);
figure;bar([prop_sig_replays_preNREM_bck,prop_sig_replays_beh_bck,prop_sig_replays_postNREM_bck]);
