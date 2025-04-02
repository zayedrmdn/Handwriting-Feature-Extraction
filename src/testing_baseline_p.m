function results = baseline_batch_print()
% BASELINE_BATCH_PRINT: Detects baseline consistency on all print images.
% Shows visual overlay and creates a summary bar chart.

clc; clearvars; close all;

%% -------------------- TWEAKABLE PARAMETERS --------------------
imageFolder = 'C:\Users\Zayed\Documents\GitHub\Handwriting-Feature-Extraction\test_images\';
filePattern = fullfile(imageFolder, 'print (*.png');

targetHeight = 1500;
targetWidth  = 2000;

lineThreshold      = 20;
minLettersPerLine  = 5;
printThreshold     = 15;

showOverlay = true;
%% -------------------------------------------------------------

% Load image files
imageFiles = dir(filePattern);
if isempty(imageFiles)
    error('No print images found in: %s', imageFolder);
end

fprintf('--- Processing Print Baseline Detection ---\n');
results = [];

%% Loop through each image
for k = 1:length(imageFiles)
    imagePath = fullfile(imageFiles(k).folder, imageFiles(k).name);
    fprintf('\nImage: %s\n', imageFiles(k).name);

    %% LOAD & RESIZE
    I = imread(imagePath);
    [h, w, ~] = size(I);

    scale = max(targetHeight / h, targetWidth / w);
    R = imresize(I, scale);
    [rh, rw, ~] = size(R);

    if rh >= targetHeight && rw >= targetWidth
        y0 = floor((rh - targetHeight) / 2) + 1;
        x0 = floor((rw - targetWidth) / 2) + 1;
        img = R(y0:y0 + targetHeight - 1, x0:x0 + targetWidth - 1, :);
    else
        img = uint8(zeros(targetHeight, targetWidth, 3));
        yOffset = floor((targetHeight - rh) / 2) + 1;
        xOffset = floor((targetWidth - rw) / 2) + 1;
        img(yOffset:yOffset + rh - 1, xOffset:xOffset + rw - 1, :) = R;
    end

    %% GRAYSCALE & BINARY
    grayImg = rgb2gray(img);
    bwImg = imbinarize(grayImg);

    %% EXTRACT BOUNDARIES
    cc = bwconncomp(~bwImg);
    stats = regionprops(cc, 'BoundingBox', 'Centroid');

    baselineY = [];
    letterX = [];

    for i = 1:numel(stats)
        bbox = stats(i).BoundingBox;
        y1 = max(1, round(bbox(2)));
        y2 = min(targetHeight, round(bbox(2) + bbox(4)));
        x1 = max(1, round(bbox(1)));
        x2 = min(targetWidth, round(bbox(1) + bbox(3)));

        letterRegion = bwImg(y1:y2, x1:x2);
        rows = find(any(letterRegion == 0, 2));

        if isempty(rows)
            bottomY = y2;
        else
            bottomY = y1 + max(rows) - 1;
        end

        baselineY(end+1) = bottomY;
        letterX(end+1)   = bbox(1) + bbox(3)/2;
    end

    %% REMOVE OUTLIERS
    meanY = mean(baselineY);
    stdY  = std(baselineY);
    validIdx = (baselineY > meanY - 2 * stdY) & (baselineY < meanY + 2 * stdY);

    filteredX = letterX(validIdx)';
    filteredY = baselineY(validIdx)';

    %% GROUP INTO LINES
    [sortedY, sortIdx] = sort(filteredY);
    sortedX = filteredX(sortIdx);

    textLines = {};
    currentLine = [sortedX(1), sortedY(1)];

    for i = 2:numel(sortedY)
        if abs(sortedY(i) - sortedY(i - 1)) > lineThreshold
            textLines{end+1} = currentLine;
            currentLine = [sortedX(i), sortedY(i)];
        else
            currentLine = [currentLine; sortedX(i), sortedY(i)];
        end
    end
    textLines{end+1} = currentLine;

    %% FIT BASELINES
    baselineDeviation = [];

    if showOverlay
        figure('Name', ['Baseline - ' imageFiles(k).name]);
        imshow(img); hold on;
        title(['Baseline Detection: ' imageFiles(k).name]);
    end

    for i = 1:numel(textLines)
        lineData = textLines{i};
        if size(lineData, 1) < minLettersPerLine, continue; end

        p = polyfit(lineData(:,1), lineData(:,2), 1);
        fitted = polyval(p, lineData(:,1));
        dev = std(lineData(:,2) - fitted);
        baselineDeviation(end+1) = dev;

        if showOverlay
            plot(lineData(:,1), fitted, 'r-', 'LineWidth', 2);
            scatter(lineData(:,1), lineData(:,2), 50, 'g', 'filled');
        end
    end

    if showOverlay
        hold off;
    end

    %% CLASSIFICATION
    finalScore = mean(baselineDeviation);

    if finalScore < printThreshold
        classification = 'PRINT (Aligned)';
    else
        classification = 'CURSIVE (Wavy)';
    end

    fprintf('Baseline Score: %.2f → %s\n', finalScore, classification);

    % Store
    results(end+1).filename = imageFiles(k).name;
    results(end).score = finalScore;
    results(end).type = classification;
end

%% PLOT SUMMARY BAR CHART
fileNames = {results.filename};
scores = [results.score];
types = {results.type};

barColors = zeros(length(types), 3);
for i = 1:length(types)
    if contains(types{i}, 'PRINT')
        barColors(i, :) = [0.2 0.6 1]; % Blue
    elseif contains(types{i}, 'CURSIVE')
        barColors(i, :) = [1 0.4 0.4]; % Red
    else
        barColors(i, :) = [0.6 0.6 0.6]; % Gray
    end
end

figure('Name', 'Figure 3.X - Baseline Deviation (Print)');
b = bar(scores, 'FaceColor', 'flat');
b.CData = barColors;

set(gca, 'XTickLabel', fileNames, 'XTick', 1:length(fileNames), 'XTickLabelRotation', 30);
ylabel('Baseline Deviation Score');
xlabel('Sample Filename');
title('Figure 3.X: Baseline Consistency - Print Samples');
grid on;

end
