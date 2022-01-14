clc;
clear;

%% Basic pipeline for SWR analysis 
% These are the basic fucntions for performing SWR related analysis. 
% Is still work in progress and anyone is welcome to contribute. 

% TODO:
  

  % - nice plotting for single events LFP+raster (for sequences, etc.) 
  % - improve the bz_swrChannels so that you don't have to manually give
  % the prompt input
  % - plot the duration distribution
%%
% 1 - Atomatic best channel detection
    swrCh = bz_swrChannels('basepath', basepath);
    load(dir('*.swrCh.mat').name);
  
%%
% 2 - SWR detection
    
    if isnan(swrCh.sharpwave)==0
        ripples = bz_DetectSWR([swrCh.ripple swrCh.sharpwave],'saveMat',true); %, 'Epochs',ripple_intervals);
    elseif isnan(swrCh.noise)==0
        [ripples] = bz_FindRipples(basepath,swrCh.ripple,'noise',swrCh.noise,'saveMat',true) %, 'show','on','plotType',1);%, 'restrict',ripple_intervals);
    else
        [ripples] = bz_FindRipples(basepath,28,'saveMat',true); %, 'restrict',ripple_intervals);
    end 
%%
% 3 detect high synchrnuous events (HSE) that contained SWR 
load([basename])
ripple_HSE = find_rippleHSE(basepath, ripples,'cell_ID',);
 

%%
% 4 inspect detection quality
    cd(basepath);
    % open neuroscope
    % then load the *ripple.hse.evt file in neuroscope 
    

