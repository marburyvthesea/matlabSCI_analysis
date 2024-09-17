function [allShuffledDataOut, actualDataActiveCellDistancesOut] = getJaccardsForSciFN(cellDistancesInput, within_frames_to_analyze_trimmedInput, XY_coords_arrayInput, paddedSignalPeaksInput, micronsPerPixelInput)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


framesToAnalyzeTrimmed  = within_frames_to_analyze_trimmedInput;
%                    = cellXYcoords;
%                    = numCells;
%                    = cellDistances;
%                    = numBins;
%                    = binVector;
%                    = 1;

paddedSignalPeaksFramesToAnalyze = paddedSignalPeaksInput(:, framesToAnalyzeTrimmed);

nComparisons = length(cellDistancesInput);%just to keep track of the number of cell-cell comparisons


% calculate Jaccards per frame on actual data
perFrameJaccard = zeros(nComparisons, length(framesToAnalyzeTrimmed));
actualDataActiveCellDistancesOut = table();
for i=1:length(framesToAnalyzeTrimmed)
    thisFrame_PaddedSignalPeaks = paddedSignalPeaksFramesToAnalyze(:, i);
    CellJaccards = 1-pdist(thisFrame_PaddedSignalPeaks,'jaccard');
    activeCellDistances = cellDistancesInput(CellJaccards == 1);
    columnName = ['frameIdx', num2str(i)];
    actualDataActiveCellDistancesOut.(columnName)=activeCellDistances; 
    perFrameJaccard(:, 1)=CellJaccards;
end

%% compute Jaccards for shuffled data

% Preallocate a cell array to store 1000 shuffled tables
allShuffledDataOut = cell(1, 1000);
tic;
for shuffle=1:1000
    
    % Initialize table with the number of columns known
    columnNames = arrayfun(@(x) ['frameIdx', num2str(x)], 1:length(framesToAnalyzeTrimmed), 'UniformOutput', false);
    thisShuffleDataActiveCellDistances = array2table(cell(1, length(framesToAnalyzeTrimmed)), 'VariableNames', ...
    arrayfun(@(x) ['frameIdx', num2str(x)], 1:length(framesToAnalyzeTrimmed), 'UniformOutput', false));
    
    %do shuffle on cell coordinates 
    thisShuffleIndicies = randperm(size(XY_coords_arrayInput, 1));
    thisShuffleXY_coords_array = XY_coords_arrayInput(thisShuffleIndicies,:); 
    thisShuffleCellDistances = pdist(thisShuffleXY_coords_array, 'euclidean')*micronsPerPixelInput;
   
    parfor i=1:length(framesToAnalyzeTrimmed)
        thisFrame_PaddedSignalPeaks = paddedSignalPeaksFramesToAnalyze(:, i);
        CellJaccardsThisFrame  = 1-pdist(thisFrame_PaddedSignalPeaks,'jaccard');
        % get distances between active cells, from independently shuffled data set, for the active cells in this frame 
        activeCellDistances = thisShuffleCellDistances(CellJaccardsThisFrame == 1);
        % Assign to table
        thisShuffleDataActiveCellDistances{1, i} = {activeCellDistances};
    end

    allShuffledDataOut{shuffle} = thisShuffleDataActiveCellDistances;

end

elapsedTime = toc;
% Measure end time and display elapsed time

disp(['Elapsed time: ', num2str(elapsedTime), ' seconds']);

end