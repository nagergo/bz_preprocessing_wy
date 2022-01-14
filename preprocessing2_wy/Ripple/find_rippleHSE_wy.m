function ripple_HSE = find_rippleHSE_wy(basepath, ripples, varargin)
% TODO: save result as a event file 
% Winnie Yang, Jan 2021, Buzsaki Lab

%% deal with input
p = inputParser;
addParameter(p,'interval','all'); % the channels used for decoding, eg [ 1 2 3 4 5]
addParameter(p,'save_evt',true); % the channels used for decoding, eg [ 1 2 3 4 5]
addParameter(p,'cell_ID',[]); % the channels used for decoding, eg [ 1 2 3 4 5]

parse(p,varargin{:});
interval = p.Results.interval;
save_evt = p.Results.save_evt;
cell_ID = p.Results.cell_ID;
%%
basename = bz_BasenameFromBasepath(basepath);
save_folder = [basepath,'\ripple_wy'];
%% (1) find highly sychronized events (HSE)
% check if the HSE file exist,if not call find_HSE
cd(save_folder)
if isfile([basename,'.HSE.mat'])
    load([basename,'.HSE.mat'],'-mat');
else
    cd(basepath)
    spikes = bz_GetSpikes();
    HSE = find_HSE_wy(basepath,spikes,'cell_ID',cell_ID);
end



%% (2) find HSE that contained at least one detected ripple event
% load the ripple events
[~,rippleHSE,~] = InIntervals(ripples.timestamps,HSE.timestamps);
rippleHSE_idx = unique(rippleHSE);
if rippleHSE_idx(1) ==0
    rippleHSE_idx = rippleHSE_idx(2:end);
end

%% save into neuroscope2 compatible structure
num_rippleHSE = length(rippleHSE_idx);
ripple_HSE = struct();
ripple_HSE.eventID = rippleHSE_idx;
[ripple_HSE.eventIDlabels{1:num_rippleHSE,1}] = deal('rippleHSE');
ripple_HSE.timestamps = HSE.timestamps(rippleHSE_idx,:);
ripple_HSE.peaks =  HSE.peaks(rippleHSE_idx,:);
ripple_HSE.duration = HSE.duration(rippleHSE_idx)';
ripple_HSE.center =  HSE.center(rippleHSE_idx)';
ripple_HSE.detectorinfo = HSE.detectorinfo;
cd(basepath)
save([basename '.rippleHSE.events.mat'],'ripple_HSE');


%% (3) save as .evt file so that it can be load in Neuroscope for inspection
n = length(ripple_HSE.timestamps);
d1 = cat(1,ripple_HSE.timestamps(:,1)',ripple_HSE.peaks',ripple_HSE.timestamps(:,2)');%DS1triad(:,1:3)';
events1.time = d1(:);
for i = 1:3:3*n
    events1.description{i,1} = ['RSE' ' start'];
    events1.description{i+1,1} = ['RSE' ' peak'];
    events1.description{i+2,1} = ['RSE' ' stop'];
end

if save_evt
    cd(save_folder)
    SaveEvents([basename '_RSE.RSE.evt'],events1);
end


% %% plot event PETH
% winSize  = HSE.detectorinfo.winSize;
% [~,idx] = sort(ripple_HSE.eventMeanResponse);
% t_event = linspace(-winSize,winSize,size(ripple_HSE.eventZresponse,2));
% figure('color','white')
% 
% imagesc(t_event,1:length(ripple_HSE.eventZresponse),ripple_HSE.eventZresponse(idx,:)); colormap(jet);
% %plot([t_event([1 end])], length(find(eventResponse<spikingThreshold))* ones(2,1) ,'r','LineWidth',1); axis tight;
% ylabel('Events'); xlabel('Time (s)'); set(gca,'YDir','normal','TickDir','out');ylim([1 length(ripple_HSE.eventZresponse)]);xlim([-winSize winSize])
% colorbar('Limits',[min(min(ripple_HSE.eventZresponse)),max(max(ripple_HSE.eventZresponse))])
%     
% %     subplot(1,3,3)
% %     hold on
% %     plot(event_meanResponse(idx),1:length(event_Zresponse)); 
% %     %plot([spikingThreshold spikingThreshold], [1 length(eventPopResponse)],'r');
% %     xlabel('Response (SD)'); ylim([1 length(event_Zresponse)]); set(gca,'YDir','normal','TickDir','out');
% if savefig
%     saveas(gcf,'Ripple_analysis\ripple_PETH.pdf')
% end
end
