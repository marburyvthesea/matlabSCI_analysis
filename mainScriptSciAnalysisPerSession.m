%% set paths to e.g. single session data

dir_path = '/Users/johnmarshall/Documents/Analysis/miniscope_analysis/SCI_analysis/'; 
session = 'DIO_r2_19_Day_1_14_20_58';

save_path = strcat('/Users/johnmarshall/Documents/Analysis/miniscope_analysis/SCI_analysis/', session); 


%% analysis parameters
micronsPerPixel = 1.85; %2.5 microns (inscopix), 1 (v3), 1.85 (v4)
frameFileInput = 'all_frames';
peakThreshold=2.5;
maxDist = 500 ; 
binSize = 50 ; 
bStart = 50 ;
numBins = 9; %9 for 50um Size

%% code from jaccardCompute script
% load all frames from CNMF-E file, store as a table 
within_frames_to_analyze = 'all'; 
%load filtered fluorescence traces from python output
disp('loading data')
cell_eg = readtable(strcat(dir_path,session,'_C_traces_filtered.csv'),'ReadVariableNames', true);
%variable names in the table will be x1, x2 etc... for cell 1, cell 2

%% cell centroids 
% load data on cell centroids
cellXYcoords = readtable(strcat(dir_path,session,'_com_filtered.csv'), 'ReadVariableNames', true);
%convert fluorescence traces to array
%remove 1st column, which is just index 
size_array = size(cell_eg);
cell_traces = table2array(cell_eg(:,2:size_array(1,2)));
%convert fluoresence traces to nCells x nFrames matrix
cell_traces = cell_traces';
%% get "peaks" in signal, F/F0 above a, here 2.5, SD threshold
disp('finding signal peaks')
[signalPeaks, ~, ~] = computeSignalPeaks(cell_traces, 'doMovAvg', 0, 'reportMidpoint', 1, 'numStdsForThresh', peakThreshold);
%%in the PD paper, we pad each 'event' to make is 1-s duration. Note that we
%no longer do this with our GCaMP7f data, but I would do it with GCaMP6
%data. 
disp('padding signal peaks')
%should adjust padded signal peaks to work with different input sampling intervals 
paddedSignalPeaks = getPaddedSignalPeaks(signalPeaks);
%compute the distances between all the pairs of cells
%convert cellXYcoords table to array
size_com_table = size(cellXYcoords);
XY_coords_array = table2array(cellXYcoords(:,2:size_com_table(1,2))); 
XY_coords_array = XY_coords_array';
%convert pixel distance to mm distance
%2.5 microns (inscopix), 1 (v3), 1.85 (v4)
cellDistances = pdist(XY_coords_array, 'euclidean')*micronsPerPixel; %distances multiplied by 2.5 = microns (inscopix), 1 (v3), 1.85 (v4)
%ouput squareform array for comparison in python later 
cellDistances_squareform = squareform(cellDistances); 

% transpose and add 1 to correct for python 0 indexing
% for SCI I will anlayze all frames in the recording here 
frames_to_analyze = 1:size(cell_traces, 2);
if strcmp(frameFileInput, 'all_frames')
    within_frames_to_analyze_trimmed = frames_to_analyze ;
else
    within_frames_to_analyze = frameSubsetIndicies.'+1;
    %remove values exceeding cnmfe length 
    logical_index = within_frames_to_analyze <= height(cell_eg);
    within_frames_to_analyze_trimmed = within_frames_to_analyze(logical_index);
end
%within_frames_to_analyze = frameSubsetIndicies.'+1;

%% get jaccards and suffled jaccards using fn
[allShuffledData, actualDataActiveCellDistances] = getJaccardsForSciFN(cellDistances, ...
    within_frames_to_analyze_trimmed, XY_coords_array, paddedSignalPeaks, micronsPerPixel);

%% compute CDF on actual frame by frame data
numFrames=length(within_frames_to_analyze_trimmed); 
actualDataCDFs = getCDFsActualData(session, numFrames, actualDataActiveCellDistances);

%% aggregate active cell distances across shuffled data 
matObjOutAggregatedDistances = aggregateShuffledDistances(dir_path, session, numFrames, allShuffledData);

%% compute CDF on aggregated shuffled data
matObjCDF = getCDFsShuffledData(dir_path, session, numFrames);

%% Calculate SCI 

perFrameSCI=zeros(1, numFrames);

%aggregatedShuffledCDFs=aggregatedShuffledCDFsStored;
aggregatedShuffledCDFs = matObjCDF.aggregatedShuffledCDFsOut;

for frameIdx=1:numFrames 
    % Perform a one-tailed Kolmogorov–Smirnov test to see if frameDistances1
    % is stochastically greater (right-shifted) than frameDistances2
    frameDistancesActual = actualDataCDFs{frameIdx}{1};
    frameDistancesShuffledCell = aggregatedShuffledCDFs(1,frameIdx);
    frameDistancesShuffled = frameDistancesShuffledCell{1}{1} ; 
    %is "Actual" smaller/"left-shifted"/more clustered versus Shuffled 
    [h_Acutal, p_Actual] = kstest2(frameDistancesActual, frameDistancesShuffled, 'Tail', 'smaller');
    %is "Shuffled" smaller/"left-shifted"/more clustered versus Actual 
    [h_Shuffled, p_Shuffled] = kstest2(frameDistancesShuffled, frameDistancesActual, 'Tail', 'smaller');

    %if Actual values are more clustered than shuffled (smaller p value
    if p_Shuffled>p_Actual
        frameSCI = log10(p_Actual)*1; 
    elseif p_Actual>p_Shuffled
        frameSCI = log10(p_Shuffled)*-1;
    else
        frameSCI = 0; 
    end 

    perFrameSCI(1, frameIdx) =  frameSCI; 
    
end 
%% save perFrameSCI
fnameToSaveMAT = strcat(dir_path, session, '_perFrameSCI', '.mat'); 
fnameToSaveCSV = strcat(dir_path, session, '_perFrameSCI', '.csv'); 
% save to file 
save(fnameToSaveMAT, 'perFrameSCI');
writematrix(fnameToSaveCSV, fnameToSaveCSV);

%% load velocity to plot with perFrameSCI
%velocity_eg = readtable(strcat(dir_path,'DIO_r2.20_16_02_16velocity_resampled.csv'),'ReadVariableNames', true);
