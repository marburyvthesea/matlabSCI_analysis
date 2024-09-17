function nUpdateWaitbar(~, hWaitBar, progress, totalShuffles)
    progress = progress + 1;
    waitbar(progress / totalShuffles, hWaitBar, ...
        sprintf('Completed %d of %d shuffles', progress, totalShuffles));
end