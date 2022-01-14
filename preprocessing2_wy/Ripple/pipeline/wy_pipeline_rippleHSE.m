
%% got to the data path and load the relevant epoch for ripple analysis, for an example dataset, you can load:
basepath = 'Z:\Buzsakilabspace\LabShare\WinnieYang\Data\HPC_RSC\wy1\wy1_211109';%'Z:\Buzsakilabspace\LabShare\WinnieYang\Data\Achilles\Achilles_11012013';


basename = bz_BasenameFromBasepath(basepath);
cd(basepath);



%% Basic pipeline for SWR analysis 


%% 1 - determine the nioise channel and best SWR channel for detection

% NOTICE, everthing in the bz_FindRipples function should be 0
% indexing!!!!!
  load([basepath,basename,'.session_hack.mat']);  
  badChannels = session_hack.zero.badChannels;
%% 2 - SWR detection


[ripples] = bz_FindRipples_wy(basepath,20);%'noise',badChannels); % circle%, 'show','on','plotType',1);%, 'restrict',ripple_intervals);



%% 3 - Detect high synchrnuous events (HSE) that contained SWR 
ripple_HSE = find_rippleHSE_wy(basepath, ripples);
 

%% 4 - inspect detection quality
cd(basepath);
% open neuroscope
% then load the *ripple.hse.evt file in neuroscope 
%% plot event PETH
event_thrsh =  eventSpikingTreshold(ripple_HSE,spikes);

%%
% % 6 - Get spikes in ripples
% load(dir('*rippleHSE.mat').name);
% HSErippleSpikes = bz_getRipSpikes('spikes',spikes,'events',ripple_HSE); 

%%


%% place cell analysis
% load('posTrials.mat');load('day20.SWRepochs.mat');
% [Tspikes] = bz_ImportSpikes('UID',PCuid);
% load(dir('*.position.behavior.mat').name);
% spikes = bz_GetSpikes(); 
% % make posiiton into correct format so that it can be taken up by the
% % subsequent code!!!
% positions{1} = [position.timestamps,position.position.x];
% [TfiringMaps] = bz_firingMapAvg(positions,spikes);
% % [TplaceFieldStats] = bz_findPlaceFields1D('firingMaps',TfiringMaps,'minPeak',1,'sepEdge',0.04,'doPlot',false);
% [placeFieldStats] = bz_findPlaceFields1D('firingMaps',TfiringMaps,'minPeak',1,'sepEdge',0.04,);

if ~isfile([basename,'.placeFields.cellinfo.mat'])
    % check if  place cell informaiton exist
    [placeFieldStats,firingMaps,placeFieldTemplate] = wy_PlaceCell(basepath);
else
    load([basename,'.placeFields.cellinfo.mat']);
    load([basename,'.firingMapsAvg.cellinfo.mat']);   
    load([basename,'placeFieldTemplate.mat']);
end
%%
tic
spkEventTimes = bz_getRipSpikes('spikes',spikes,'events',ripple_HSE,'saveMat',false);
toc

tic
rankStats = bz_RankOrder('spkEventTimes',spkEventTimes,'templateType','Peak',...
                      'timeSpike','first','minUnits',5,'numRep',500);  
toc

%% plot raster
% find the events with lowest p value
placeCell = placeFieldStats.placeCell;

evenID = find(rankStats.pvalEvents ==min(rankStats.pvalEvents));
eventID = 3721;

load(dir([basename,'.rippleHSE.mat']).name);
event_ints = ripple_HSE.timestamps(eventID,:);

lfp_event = bz_GetLFP(spikes.maxWaveformCh(cellID),'intervals',event_ints);

spk_time = spikes.times;
cellIDs = placeCell(20:40);
spks_event = cell(1,length(cellIDs));
for ii = 1: length(cellIDs)
    spks_event{ii} = spk_time{cellIDs(ii)}(InIntervals(spk_time{cellIDs(ii)},event_ints));
end

passband = [140 200];
wy_plotRaster(lfp_event,spks_event,event_ints,passband,'ripple',cellIDs);