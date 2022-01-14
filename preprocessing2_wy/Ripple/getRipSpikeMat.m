function [spkmat_all_event,spkmat_all_eventID] = getRipSpikeMat(spikes,ripple_event_struct, rippleID,SPIKEbin,varargin)
tic;
%%
p = inputParser;
addParameter(p, 'padding_between_event',0) % create padding between events, 1 = 1 SPIKEbin apart between two neighbouring events

parse(p,varargin{:});
padding_between_event = p.Results.padding_between_event;

%%
if padding_between_event ~= 0
    padding = zeros(length(spikes.UID),padding_between_event);
    padding_ID = ones(1,padding_between_event);

else
    padding = [];
end

%% create padding between event
%% ripple event spikemat 
spkmat_all_event = [];
spkmat_all_eventID = [];
for evt = 1:length(rippleID)
    evtID = rippleID(evt);
    tw = ripple_event_struct.timestamps(evtID,:);
    edge = tw(1):SPIKEbin:tw(2);
    spkmat_event = zeros(length(spikes.UID),length(edge)-1);
    spkmat_eventID = evtID*ones(1,length(edge)-1);
    for  cc = 1:length(spikes.UID)
        spk_event_ind = InIntervals(spikes.times{1,cc},tw);
        spk_event_ts = spikes.times{1,cc}(spk_event_ind);
        spkmat_event(cc,:) = histcounts(spk_event_ts,edge);
    end

    spkmat_all_eventID = [spkmat_all_eventID,padding_ID*evtID,spkmat_eventID,padding_ID*evtID];
    spkmat_all_event = [spkmat_all_event,padding,spkmat_event,padding];
    
end
toc;