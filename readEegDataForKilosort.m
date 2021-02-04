
%% read EEG data function (from KJ) for reading NLX .ncs files
function [time,fs,samples] = readEegDataForKilosort(file)


% Set the field selection for reading the EEG files. 1 = Add parameter, 0 = skip
% parameter
fieldSelection(1) = 1; % Timestamps
fieldSelection(2) = 0; % Channel numbers
fieldSelection(3) = 1; % Sample frequency
fieldSelection(4) = 1; % Number of valid samples
fieldSelection(5) = 1; % EEG samples
% Do we return header 1 = Yes, 0 = No.
extractHeader = 0;
% Extract all data
extractMode = 1;

% Get EEG timestamp, sampling frequency and samples.
[ts, frequency, numValidSamp, samples2D] = Nlx2MatCSC(file, fieldSelection, extractHeader, extractMode); %KJ _V3

% Get the sampling frequency
fs = frequency(1);

% *** Transform EEG samples array from 2D to 1D
M = size(samples2D,2);
samples = zeros(512*M,1);

for jj = 1:M
    samples(((jj-1)*512)+1:512*jj) = samples2D(1:512,jj);
    
    
%     if numValidSamp(jj) < 512
%         % Set invalid samples to NaN (Otherwise they just contain a random
%         % value)
%         samples((512*(jj-1))+numValidSamp(jj):(512*jj)) = NaN;
%     end
end


% Interpolate timestamps
time = zeros(512*M,1);
for jj = 1:M-1
    % Time increment between each sample
    timeStep = (ts(jj+1)-ts(jj))/512;
    % Set time stamps for this 512-samples segment
    time(((jj-1)*512)+1:512*jj) = ts(jj):timeStep:ts(jj)+511*timeStep;
end
% Use same time step as the previous for the last segment
time(((M-1)*512)+1:512*M) = ts(M):timeStep:ts(M)+511*timeStep;

% Convert timestamps to seconds
time = time/1000000;
end


