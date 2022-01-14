function spkTS_all_event = getRipSpikeTs(spikes,ripple_event_struct, rippleID,varargin)
tic;
%%
p = inputParser;
addParameter(p, 'padding',0.05) % create padding for event, defult = plot 50ms before and after the start and end of the envent
parse(p,varargin{:});
padding = p.Results.padding;

%%
% if padding_between_event ~= 0
%     padding = zeros(length(spikes.UID),padding_between_event);
% else
%     padding = [];
% end

%% create padding between event
%% ripple event spikemat 
spkTS_all_event = {};
%spkTs_all_eventID = [];
for evt = 1:length(rippleID)
    evtID = rippleID(evt);
    tw = [ripple_event_struct(evtID).timestamps(1,1)-padding, ripple_event_struct(evtID).timestamps(1,2)+padding];
%     edge = tw(1):SPIKEbin:tw(2);
%     spkmat_event = zeros(length(spikes.UID),length(edge)-1);
    %spkmat_eventID = evtID*ones(1,length(edge)-1);
    spkTS_event = {};
    for  cc = 1:length(spikes.UID)
        spkTS_event{cc} = spikes.times{1,cc}(InIntervals(spikes.times{1,cc},tw));
       
    end

    %spkmat_all_eventID = [spkmat_all_eventID,spkmat_eventID,padding(1,:)];
    spkTS_all_event(evt).eventID = evtID;
    spkTS_all_event(evt).eventTS = spkTS_event;
    spkTS_all_event(evt).intervals = tw;
end
toc;