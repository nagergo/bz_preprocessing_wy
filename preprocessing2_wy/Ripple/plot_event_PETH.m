
function plot_event_PETH(events,spikes,varargin)
% Descriptive and mean/median difference analysis, with serveral plot
% options.
% 
% INPUTS
%    'events'           Buzcode format events (i.e. ripples) structure.
%
% <optional>
%    'basepath'         Default 'pwd'
%    'spikes'           Buzcode format spikes structure. If not provided runs loadSpikes.      
%    'events'           Structure containing the statistical test results.
%    'winSize'          .5
%    'eventSize'        .01
%    'figOpt'           Default true
% 
% OUTPUS
%    'events'           Buzcode format events (i.e. ripples) structure
%                           after event/spiking thresholing 
%
% Manu Valero - BuzsakiLab 2019
% Winnie Yang - BuzsakiLab 2021 modified from Manu's eventSpikingTreshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse options
p = inputParser;
addParameter(p,'basepath',pwd,@isfolder);
addParameter(p,'spikingThreshold',.5);
addParameter(p,'winSize',.5);
addParameter(p,'eventSize',.01);
addParameter(p,'figOpt',true,@islogical);
addParameter(p,'savefig',true,@islogical);

parse(p,varargin{:});
basepath = p.Results.basepath;
winSize = p.Results.winSize;
eventSize = p.Results.eventSize;
figOpt = p.Results.figOpt;
savefig = p.Results.savefig;

prevPath = pwd;
cd(basepath);

% 
if isempty(spikes)
    spikes = loadSpikes;
end

[spikemat] = bz_SpktToSpkmat(spikes, 'dt',0.01,'overlap',6);
% here, calculate the z score of each time point across all channels(total number of spikes of each event
% devide by number of neurons)
sSpkMat = zscore(sum(spikemat.data,2)/size(spikemat.data,2));
% sSpkMat = mean(zscore(spikemat.data,[],1),2);
clear eventPopResponse

for ii = 1: length(events.peaks)
    %find the spiking data stamps surrounding the peaks of the ripple
    
    % z score of each time point within each event
    temp = sSpkMat(spikemat.timestamps>=events.peaks(ii)-winSize ...
        & spikemat.timestamps<=events.peaks(ii)+winSize);
    
    % also time point of each spike within each event, this line of code
    % maybe redundent .... can take out later   
    eventPopResponse(ii,:) = temp(int32(1:winSize*2/(mean(diff(spikemat.timestamps)))-1));
end
t_event = linspace(-winSize,winSize,size(eventPopResponse,2));

% compute mean 
eventResponse = mean(eventPopResponse(:,t_event>-eventSize & t_event<eventSize),2);
[~,idx] = sort(eventResponse);

% 
%validEvents = find(eventResponse>spikingThreshold);

% if isfield(events,'timestamps')
% events.timestamps = events.timestamps(:,:);
% % elseif isfield(events,'times')
% %     events.timestamps = events.times(validEvents,:);   
% % end
% % try 
% %     events.peaks = events.peaks(validEvents,:);
% %     events.peakNormedPower = events.peakNormedPower(validEvents,:);
% % end
% events.eventSpikingParameters.spikingThreshold = spikingThreshold;
% events.eventSpikingParameters.winSize = winSize;
% events.eventSpikingParameters.eventSize = eventSize;

% fprintf('Keeping %4.0f of %4.0f events \n',length(validEvents),length(eventResponse));

%%
if ~exist('Ripple_analysis','dir')
    mkdir('Ripple_analysis')
end

if figOpt
    figure
    subplot(1,3,[1 2])
    hold on
    imagesc(t_event,1:length(eventPopResponse),eventPopResponse(idx,:),[-3 3]); colormap(jet);
    %plot([t_event([1 end])], length(find(eventResponse<spikingThreshold))* ones(2,1) ,'r','LineWidth',1); axis tight;
    ylabel('Events'); xlabel('Time (s)'); set(gca,'YDir','normal','TickDir','out');ylim([1 length(eventPopResponse)]);xlim([-winSize winSize])
    colorbar('Limits',[min(min(eventPopResponse)),max(max(eventPopResponse))])
    
    subplot(1,3,3)
    hold on
    plot(eventResponse(idx),1:length(eventPopResponse)); 
    %plot([spikingThreshold spikingThreshold], [1 length(eventPopResponse)],'r');
    xlabel('Response (SD)'); ylim([1 length(eventPopResponse)]); set(gca,'YDir','normal','TickDir','out');
    if savefig
        saveas(gcf,'Ripple_analysis\ripple_PETH.pdf')
    end
end

cd(prevPath);
end