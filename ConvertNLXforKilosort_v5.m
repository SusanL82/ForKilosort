%% Convert NLX data to .dat for Kilosort.m

function [RatID,RecDate] = ConvertNLXforKilosort_v6(InFolder,OutFolder,RatID,RecDate,BadChans,MakeMat)
%% settings for read/write .dat file
fs = 20000; %sampling rate
Chunk = 10; %chunklength in minutes
ChunkLen = Chunk*60*fs;  %chunklength in samples
NumChans = 64;

%% make list of good channels
GoodChans = setdiff([1:NumChans],BadChans);


%% save signal from each good channel as .mat file.
if MakeMat ==1
    
    % make TempFolder for .mat files if there isn't one yet
    if exist([OutFolder,'\','Temp']) == 0
        mkdir([OutFolder,'\','Temp']);
    end
    
    for ch = 1:numel(GoodChans)
        % convert .ncs to mat
        InFile = [InFolder,'\','CSC',num2str(GoodChans(ch)),'.ncs'];
        [~,~,samples] = readEegDataForKilosort(InFile); % gives 1D array of type double
        samples = int16(samples);
        save([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(ch),'.mat'],'samples','-v7.3')
    end
    
else
    load([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(GoodChans(1)),'.mat'],'samples') %load first channel to get rec length
end

%% read data from all channels per chunk, write to .dat
RecLen = length(samples); %get recording length
NumChunks = floor(RecLen/ChunkLen);

for i = 1:NumChunks
    disp(['chunk ',num2str(i),' of ',num2str(NumChunks+1)])
    
    AllChunks=zeros(NumChans,ChunkLen);AllChunks=int16(AllChunks);
    for ch = 1:numel(GoodChans)
        load([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(GoodChans(ch)),'.mat'],'samples');
        SampChunk = samples((i*ChunkLen)+1-ChunkLen:i*ChunkLen);
        AllChunks(GoodChans(ch),:)=SampChunk';
        clear samples
    end
    
    
    %write chunk to .dat file
    Outfile = [OutFolder,'\',RatID,'_',RecDate,'.dat'];
    if i==1 %make file for first chunk
        fid = fopen(Outfile, 'w');
        fwrite(fid, AllChunks, 'int16');
        fclose(fid);
    else %append to file for next chunks
        fid = fopen(Outfile, 'a');
        fwrite(fid, AllChunks, 'int16');
        fclose(fid);
    end
    
end
clear AllChunks SampChunk

disp(['chunk ',num2str(NumChunks+1),' of ',num2str(NumChunks+1)])
% write remaining data to .dat
if RecLen > (NumChunks*ChunkLen)
    RecLeft = RecLen-(NumChunks*ChunkLen);
    LastChunks = zeros(NumChans,RecLeft);LastChunks = int16(LastChunks); 
    for ch = 1:NumChans
        load([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(GoodChans(ch)),'.mat'],'samples');
        SampChunk = samples(NumChunks*ChunkLen+1:end);
        LastChunks(GoodChans(ch),:)=SampChunk';
    end
    
    fid = fopen(Outfile, 'a');
    fwrite(fid, LastChunks, 'int16');
    fclose(fid);
    
    clear LastChunk LastChunks
end

end


