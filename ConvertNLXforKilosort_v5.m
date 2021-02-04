%% Convert NLX data to .dat for Kilosort.m

function [RatID,RecDate] = ConvertNLXforKilosort_v5(InFolder,OutFolder,RatID,RecDate,MakeMat)

if MakeMat ==1
    %% save signal from each channel as .mat file.
    % make TempFolder for .mat files if there isn't one yet
    if exist([OutFolder,'\','Temp']) == 0
        mkdir([OutFolder,'\','Temp']);
    end
    
    for ch = 1:64
        % convert .ncs to mat
        InFile = [InFolder,'\','CSC',num2str(ch),'.ncs'];
        [~,~,samples] = readEegDataForKilosort(InFile); % gives 1D array of type double
        samples = int16(samples);
        save([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(ch),'.mat'],'samples','-v7.3')
    end
    
else
    load([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch1','.mat'],'samples')
end
%% read data from all channels per chunk, write to .dat
fs = 20000; %sampling rate
Chunk = 10; %chunklength in minutes
ChunkLen = Chunk*60*fs;  %chunklength in samples
RecLen = length(samples); %get recording length
NumChunks = floor(RecLen/ChunkLen);



for i = 1:NumChunks
    disp(['chunk ',num2str(i),' of ',num2str(NumChunks+1)])
    
    AllChunks=zeros(64,ChunkLen);AllChunks=int16(AllChunks);
    for ch = 1:64
        load([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(ch),'.mat'],'samples');
        SampChunk = samples((i*ChunkLen)+1-ChunkLen:i*ChunkLen);
        AllChunks(ch,:)=SampChunk';
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
    LastChunks = zeros(64,RecLeft);LastChunks = int16(LastChunks); 
    for ch = 1:64
        load([OutFolder,'\','Temp','\',RatID,'_',RecDate,'_ch',num2str(ch),'.mat'],'samples');
        SampChunk = samples(NumChunks*ChunkLen+1:end);
        LastChunks(ch,:)=SampChunk';
    end
    
    fid = fopen(Outfile, 'a');
    fwrite(fid, LastChunks, 'int16');
    fclose(fid);
    
    clear LastChunk LastChunks
end

end


