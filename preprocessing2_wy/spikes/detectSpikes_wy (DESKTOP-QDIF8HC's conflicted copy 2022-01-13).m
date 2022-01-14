function spikes = detectSpikes_wy(basepath,varargin)

%basepath = 'F:\HPC_RSC\wyD3_2\wyD3_2_211222';

p = inputParser;
addParameter(p,'spikesDetectionThreshold',-60);

parse(p,varargin{:})
spikesDetectionThreshold = p.Results.spikesDetectionThreshold;

%% load session
basename = bz_BasenameFromBasepath(basepath);
cd(basepath);
load([basename, '.session.mat']);
samplingRate = session.extracellular.sr;
amplifier_channels = session.channels;
num_channels = length(amplifier_channels); % amplifier channel info from header file
num_bad = length(session.channelTags.Bad.channels); % bad channles to skip 
%% load dat file
tic 
disp('loading data file')
ephys = bz_LoadBinary([basepath '\' basename '.dat'],...
                  'frequency',samplingRate,'nchannels',num_channels,...
                  'channels',amplifier_channels);
toc



%% apply high pass filter
[filter.b2, filter.a2] = butter(3, 500/(session.extracellular.sr/2), 'high');

%% detect spikes by finding activities that cross spikesDetectionThreshold
num_good = num_channels-num_bad;
spikes.times = cell(1,num_good);
spikes.amplitudes = cell(1,num_good);

tic
disp('Detecting spikes channel by channel...')
cc  =1;
for channel = 1:num_channels
    if ~ismember(channel,session.channelTags.Bad.channels)
        
        ephys_filt = filtfilt(filter.b2, filter.a2, double(ephys(:,channel)));
        idx = find(diff(ephys_filt < spikesDetectionThreshold)==1)+1;
        if ~isempty(idx)
            spikes.times{1,cc} = idx;
            spikes.amplitudes{1,cc} = ephys_filt(idx);
        end
        spikes.region{1,cc} = session.region(1, channel);
        spikes.channelID{cc} = channel;
        cc = cc + 1;

    end
end
toc

spikes.UID = 1:length(spikes.channelID);

spikes.basepath = basepath;
spikes.processinginfo.function = 'detectSpikes_wy';
spikes.processinginfo.date = datetime;
spikes.params.spikesDetectionThreshold = -60;

%% save
tic
disp('Saving the detected spike...')
save([basepath, '\',basename, '.spikes.muinfo.mat'], 'spikes','-v7.3'); %For variables larger than 2GB use MAT-file version 7.3 or
toc
%later. 

