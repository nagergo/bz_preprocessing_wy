function bz_PreprocessSession2_wy(basepath,clusteringPath,varargin)
 % to be run after manual spike sorting
 % Winnie Yang, Jan 2022
 %%
p = inputParser;
addParameter(p,'ripple_channel',0,@isfolder); % 0 indexing

parse(p,varargin{:});
ripple_channel = p.Results.ripple_channel;

%% 1.generate spikes data structure 
 spikes = loadSpikes_wy(basepath,'clusteringPath',clusteringPath);
 



%% 2.ripple detection

[ripples] = bz_FindRipples_wy(basepath,ripple_channel);%'noise',badChannels); % circle%, 'show','on','plotType',1);%, 'restrict',ripple_intervals);



%% 3. Detect high synchrnuous events (HSE) that contained SWR 
ripple_HSE = find_rippleHSE_wy(basepath, ripples);

%% 4. get theta state
InstantaneousTheta = getTheta_wy(basepath);

%% 5.CellExplorer cell metric infomation

cell_metrics = ProcessCellMetrics('session', session,'showGUI',true);


 
end