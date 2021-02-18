MakeMat = 0; 
FileList = 'D:\FileList2.txt'; 

InList = fopen(FileList);
InFiles = textscan(InList,'%s%s%s%s%s');
fclose(InList);
 
for f = 1:size(InFiles{1},1)

InFolder = InFiles{1}{f};
OutFolder = InFiles{2}{f};
RatID = InFiles{3}{f};
RecDate = InFiles{4}{f};
BadChans = InFiles{5}{f}; BadChans = str2num(BadChans)

disp(['file ',num2str(f),' of ',num2str(size(InFiles{1},1))])
disp(['processing ',InFolder])

%[~,~] = ConvertNLXforKilosort_v2(InFolder,OutFolder,RatID,RecDate);
[~,~] = ConvertNLXforKilosort_v5(InFolder,OutFolder,RatID,RecDate,BadChans,MakeMat);
disp(['completed ',InFolder])

end
