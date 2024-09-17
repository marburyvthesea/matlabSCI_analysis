function [matObjOutAggregatedDistances] = aggregateShuffledDistances(dir_path, session, numFramesInput, allShuffledDataInput)

distancesFile = strcat(dir_path, session, '_aggregated_distances_shuffled.mat');
aggregatedDistances = cell(1, numFramesInput);
aggregatedDistancesStored = cell(1, numFramesInput);
% Preallocate the entire variable in the MAT-file (this ensures it exists in the correct format)
save(distancesFile, 'aggregatedDistances', '-v7.3');
% Use matfile to modify the .mat file incrementally
matObjOutAggregatedDistances = matfile(distancesFile, 'Writable', true);
numShuffles=length(allShuffledDataInput);

tic 
for frameIdx = 1:numFramesInput
    if mod(frameIdx,10)==0
        disp(frameIdx);
    end 
    aggregatedFrameDistances = [];  % Temporary storage for this frame's distances across shuffles
    for shuffleIdx = 1:numShuffles
        % Get the table from the current shuffle
        thisShuffleTable = allShuffledDataInput{shuffleIdx};        
        % Extract the distances for the current frame (column)
        frameDistances = thisShuffleTable{1, frameIdx}{:};  % Extract distances as a numeric array      
        % Append these distances to the aggregate list
        aggregatedFrameDistances = [aggregatedFrameDistances, frameDistances];    
    end

    aggregatedDistancesStored{frameIdx} = aggregatedFrameDistances;
    % Directly write the current frame's distances to the MAT-file (updating only this cell)
    matObjOutAggregatedDistances.aggregatedDistances(1, frameIdx) = {aggregatedFrameDistances};  
    % Clear temporary data from memory
    clear aggregatedFrameDistances;
end 
toc
end