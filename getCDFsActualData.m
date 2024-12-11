function [actualDataCDFsOut] = getCDFsActualData(dirpath, sessionInput, numFramesInput, actualDataActiveCellDistancesInput)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%numFrames = 5000;  % Number of frames (columns in the tables)
actualDataCDFsOut = cell(1, numFramesInput);

cdfFileActualOut = strcat(dirpath, sessionInput, '_', 'aggregated_cdfs_actual.mat');
save(cdfFileActualOut, 'actualDataCDFsOut');  % Save an initial version

parfor frameIdx = 1:numFramesInput
    frameDistances = actualDataActiveCellDistancesInput{1, frameIdx}; % Extract distances as a numeric array
    if ~isempty(frameDistances)
        [f, x] = ecdf(frameDistances);
        % store 
        actualDataCDFsOut{frameIdx} = {x, f};
    else 
        actualDataCDFsOut{frameIdx} = {[0], [0]};
    end
end

save(cdfFileActualOut, 'actualDataCDFsOut', '-append');

end
