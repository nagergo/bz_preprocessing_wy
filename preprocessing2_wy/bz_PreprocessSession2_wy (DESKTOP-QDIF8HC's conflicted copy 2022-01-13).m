function bz_PreprocessSession2_wy(basepath,clusteringPath,varargin)
 %to be run after manual spike sorting
 % Winnie Yang, Jan 2022
 %%
p = inputParser;
addParameter(p,'ripple_channel',0,@isfolder); % 0 indexing
addParameter(p,'detectSpike',1); % if detect spike though amplitude thresholding
addParameter(p,'manualSort',1); %  if get spike though manual sorting

parse(p,varargin{:});
ripple_channel = p.Results.ripple_channel;
detectSpike = p.Results.detectSpike;
manualSort = p.Results.manualSort;
SPIKEbin = 0.1;
%% 0.0 detect spikes
if detectSpike
    spikes = detectSpikes_wy(basepath);

end

%% 0.1 Generating spike mat from spike time
    % during behavior 
    tic 
    disp('Generating spike mat from spike time...')
    cd(basepath);
    load([basename,'.behavior.mat']);
    [spikemat_mu_beh] = bz_SpktToSpkmat_wy(spikes, 'dt',SPIKEbin,'win',[behavior.timestamps(1) behavior.timestamps(end)],'units','counts', 'bintype','gaussian');
    save([basename,'.spikemat_mu_beh.mat'],'spikemat_mu_beh');
    toc
%% 1.generate spikes data structure from manual sorting with phy
if manualSort
    loadSpikes_wy(basepath,'clusteringPath',clusteringPath);
end


%% 2.ripple detection

[ripples] = bz_FindRipples_wy(basepath,ripple_channel);%'noise',badChannels); % circle%, 'show','on','plotType',1);%, 'restrict',ripple_intervals);



%% 3. Detect high synchrnuous events (HSE) that contained SWR 
ripple_HSE = find_rippleHSE_wy(basepath, ripples);


%% 4.CellExplorer cell metric infomation

cell_metrics = ProcessCellMetrics('session', session,'showGUI',true);

%% visualize events 
NeuroScope2('basepath',basepath)
 
end