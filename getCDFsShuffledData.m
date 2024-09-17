function [matObjCDFOut] = getCDFsShuffledData(dir_pathInput, ... 
    sessionInput, numFramesInput)

%% compute CDF on aggregated shuffled data
% Initialize a cell array to hold the aggregated distances for each frame
aggregatedShuffledCDFs = cell(1, numFramesInput);
%aggregatedShuffledCDFsStored = cell(1, numFrames);
% Open files to store the data
cdfFile = strcat(dir_pathInput, sessionInput, '_aggregated_cdfs_shuffled.mat');
% Write CDF data to file after each frame
save(cdfFile, 'aggregatedShuffledCDFs', '-v7.3');
% Use matfile to modify the .mat file incrementally
matObjCDFOut = matfile(cdfFile, 'Writable', true);
% Load the file with distances as a matfile object without loading the data into memory
matObj = matfile(strcat(dir_pathInput, sessionInput, '_aggregated_distances_shuffled.mat'));
%%
tic
% Aggregate active cell distances for each frame across all shuffles
for frameIdx = 1:numFramesInput
    if mod(frameIdx,100)==0
        disp(frameIdx);
    end
    aggregatedFrameDistancesCell = matObj.aggregatedDistances(1, frameIdx);
    aggregatedFrameDistances=aggregatedFrameDistancesCell{1}; 
    if ~isempty(aggregatedFrameDistances)
        [f, x] = ecdf(aggregatedFrameDistances);
        % Write CDF data to file after each frame 
        cdfData = {x, f};
    else 
        % Assign empty CDF data
        cdfData = {0, 0};
    end
    % Store the CDF data in both memory and the .mat file
    %aggregatedShuffledCDFsStored{frameIdx} = cdfData;  % Store in memory
    matObjCDFOut.aggregatedShuffledCDFsOut(1, frameIdx) = {cdfData};  % Save to the .mat file
end
toc

end