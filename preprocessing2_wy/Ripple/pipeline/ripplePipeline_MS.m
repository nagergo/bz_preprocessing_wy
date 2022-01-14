allSess = dir('*_sess*');
main= pwd;

mkdir('Analysis/Ripple');
for kk =1:size(allSess,1)
fprintf(' ** Summary %3.i of %3.i... \n',kk, size(allSess,1));
cd(strcat(allSess(kk).folder,'\',allSess(kk).name));
mkdir('Analysis/Ripple');
if isempty(dir('*ripples.events.mat'))
spikes = loadSpikes;
session = sessionTemplate(pwd);
rippleChannels.Ripple_Channel = 149;%ripple ch 0 indexing;
ripples = bz_FindRipples_MS(pwd, rippleChannels.Ripple_Channel,'thresholds', [1 1.5], 'passband', [80 250], 'EMGThresh', 1, 'durations', [20 1000],'saveMat',true); % [.2 .4] %[1 1.5]
ripples = removeArtifactsFromEvents(ripples, 'basepath',basepath); %remove threshold if no ieds %2.5 
saveas(gcf,'Analysis\Ripple\Thresholds.png');
ripples = eventSpikingTreshold(ripples,[],'spikingThreshold',1.2); % .8, 7312 1.2
EventExplorer(pwd,ripples); % check events....
targetFile = dir('*ripples.events*'); save(targetFile.name,'ripples');
targetFile = dir('*channelinfo.ripple*'); save(targetFile.name,'rippleChannels');
else
end
clear spikes ripples
end
cd (main)

%% Ripples CSD

disp('Ripples CSD and PSTH...');

allSess = dir('*_sess*');
main= pwd;

for kk =1: size(allSess,1)
fprintf(' ** Summary %3.i of %3.i... \n',kk, size(allSess,1));
cd(strcat(allSess(kk).folder,'\',allSess(kk).name));
[sessionInfo] = bz_getSessionInfo(pwd, 'noPrompts', true);
%spikes = loadSpikes;
fileRip = dir('*.ripples.events.mat'); load(fileRip.name,'ripples');
twin = 0.2;
figure;
for jj = 1:size(sessionInfo.AnatGrps,2)
lfp = bz_GetLFP(sessionInfo.AnatGrps(jj).Channels(1:numel(sessionInfo.AnatGrps(jj).Channels)-mod(numel(sessionInfo.AnatGrps(jj).Channels),8)),'noPrompts', true);              
[csd,lfpAvg] = bz_eventCSD(lfp,ripples.peaks,'twin',[twin twin],'plotLFP',false,'plotCSD',false);
taxis = linspace(-0.2,0.2,size(csd.data,1));
cmax = max(max(csd.data));
%subplot(1,size(sessionInfo.AnatGrps,2),jj);
contourf(taxis,1:size(csd.data,2),csd.data',40,'LineColor','none');hold on;
set(gca,'YDir','reverse'); xlabel('time (s)'); ylabel('channel'); %title(strcat('RIPPLES, Shank #',num2str(jj)),'FontWeight','normal');
colormap jet; if ~isnan(cmax); caxis([-cmax cmax]); end
hold on
for kk = 1:size(lfpAvg.data,2)
plot(taxis,(lfpAvg.data(:,kk)/1000)+kk-1,'k')
end
end  
saveas(gcf,'Analysis/Ripple/RipplesCSD.png');
end
cd (main)

%% winnie temporary
tic 
lfp = bz_GetLFP(session_hack.zero.AnatGrps{1,9},'noPrompts', true);
toc 
%%
[sessionInfo] = bz_getSessionInfo(pwd, 'noPrompts', true);
[csd,lfpAvg] = bz_eventCSD(lfp,ripples.peaks,'twin',[twin twin],'plotLFP',true,'plotCSD',true,'spat_sm',5,'temp_sm',5);
[csd,lfpAvg] = bz_eventCSD(lfp,ripples.peaks(17),'twin',[twin twin],'plotLFP',true,'plotCSD',true,'spat_sm',5,'temp_sm',5);

taxis = linspace(-0.2,0.2,size(csd.data,1));
cmax = max(max(csd.data));
twin = 0.2;

%subplot(1,size(sessionInfo.AnatGrps,2),jj);
figure;
contourf(taxis,1:size(csd.data,2),csd.data',40,'LineColor','none');hold on;
set(gca,'YDir','reverse'); xlabel('time (s)'); ylabel('channel'); %title(strcat('RIPPLES, Shank #',num2str(jj)),'FontWeight','normal');
colormap jet; if ~isnan(cmax); caxis([-cmax cmax]); end
hold on
for kk = 1:size(lfpAvg.data,2)
plot(taxis,(lfpAvg.data(:,kk)/1000)+kk-1,'k')
end