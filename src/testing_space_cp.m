function results = letter_spacing_batch()
% LETTER_SPACING_BATCH: Extracts letter spacing features for both cursive and print samples.
% Generates separate bar charts with visual overlays.

clc; clearvars; close all;

%% -------------------- TWEAKABLE PARAMETERS --------------------
imageFolder = 'C:\Users\Zayed\Documents\GitHub\Handwriting-Feature-Extraction\test_images\';
cursivePattern = fullfile(imageFolder, 'cursive (*.png');
printPattern   = fullfile(imageFolder, 'print (*.png');

% Line detection
lineThreshold = 40;
minLettersPerLine = 3;
minLetterArea = 100;

% Image standardization
targetWidth = 2000;
targetHeight = 1500;

% Overlay display
showOverlay = true;
%% -------------------------------------------------------------

% Run batch for each set
cursiveResults = process_batch(cursivePattern, 'Cursive', ...
    targetWidth, targetHeight, lineThreshold, minLettersPerLine, minLetterArea, showOverlay);

printResults = process_batch(printPattern, 'Print', ...
    targetWidth, targetHeight, lineThreshold, minLettersPerLine, minLetterArea, showOverlay);

% Plot spacing bar charts
plot_spacing_chart(cursiveResults, 'Figure 3.X: Letter Spacing - Cursive Samples');
plot_spacing_chart(printResults,   'Figure 3.Y: Letter Spacing - Print Samples');

% Combine results
results.cursive = cursiveResults;
results.print = printResults;

end

%% -------------------------------------------------------------
function batchResults = process_batch(filePattern, batchName, targetWidth, targetHeight, ...
                                      lineThreshold, minLettersPerLine, minLetterArea, showOverlay)

imageFiles = dir(filePattern);
if isempty(imageFiles)
    warning('No images found for pattern: %s\n', filePattern);
    batchResults = [];
    return;
end

fprintf('\n--- Processing %s Samples ---\n', batchName);
batchResults = [];

for k = 1:length(imageFiles)
    imagePath = fullfile(imageFiles(k).folder, imageFiles(k).name);
    fprintf('\nImage: %s\n', imageFiles(k).name);

    % Load and preprocess
    img = imread(imagePath);
    img = imresize(img, [targetHeight, targetWidth]);
    grayImg = rgb2gray(img);
    bwImg = imbinarize(grayImg);

    % Remove small noise
    bwImg = bwareaopen(~bwImg, 20);  
    bwImg = ~bwImg;

    % Extract components
    cc = bwconncomp(~bwImg);
    stats = regionprops(cc, 'BoundingBox', 'Centroid', 'Area');

    letterMidX = [];
    letterMidY = [];
    for i = 1:length(stats)
        if stats(i).Area < minLetterArea, continue; end
        bbox = stats(i).BoundingBox;
        x = bbox(1) + bbox(3)/2;
        y = bbox(2) + bbox(4)/2;
        letterMidX = [letterMidX, x];
        letterMidY = [letterMidY, y];
    end

    % Sort and group into lines
    [sortedY, sortIdx] = sort(letterMidY);
    sortedX = letterMidX(sortIdx);

    currentX = sortedX(1);
    currentY = sortedY(1);
    textLines = {};
    
    for i = 2:length(sortedY)
        if abs(sortedY(i) - sortedY(i-1)) > lineThreshold
            [lineX, idx] = sort(currentX);
            lineY = currentY(idx);
            textLines{end+1} = [lineX(:), lineY(:)];
            currentX = sortedX(i);
            currentY = sortedY(i);
        else
            currentX = [currentX; sortedX(i)];
            currentY = [currentY; sortedY(i)];
        end
    end
    [lineX, idx] = sort(currentX);
    lineY = currentY(idx);
    textLines{end+1} = [lineX(:), lineY(:)];

    % Analyze spacing
    spacingValues = [];
    for i = 1:length(textLines)
        line = textLines{i};
        if size(line, 1) < minLettersPerLine, continue; end
        d = diff(line(:,1));  % spacing between Xs
        spacingValues = [spacingValues, d'];
    end

    if isempty(spacingValues)
        meanSpacing = NaN;
        cvSpacing = NaN;
        spacingType = 'Unknown';
    else
        meanSpacing = mean(spacingValues);
        stdSpacing = std(spacingValues);
        cvSpacing = stdSpacing / meanSpacing;

        if cvSpacing < 0.51
            spacingType = 'Uniform (Print)';
        else
            spacingType = 'Variable (Possibly Cursive)';
        end
    end

    % Overlay Visualization
    if showOverlay
        figure('Name', sprintf('%s - %s', batchName, imageFiles(k).name));
        imshow(img); hold on;
        title(sprintf('%s - %s', batchName, imageFiles(k).name));
    
        for i = 1:length(textLines)
            line = textLines{i};
            if size(line,1) < minLettersPerLine, continue; end
            x = line(:,1);
            y = line(:,2);

            for j = 1:length(x) - 1
                plot([x(j), x(j+1)], [y(j), y(j+1)], 'b-', 'LineWidth', 2);
            end
            scatter(x, y, 50, 'g', 'filled');
        end
        hold off;
    end

    % Store and display
    batchResults(end+1).filename = imageFiles(k).name;
    batchResults(end).meanSpacing = meanSpacing;
    batchResults(end).cvSpacing = cvSpacing;
    batchResults(end).type = spacingType;

    fprintf('Mean Spacing: %.2f px\n', meanSpacing);
    fprintf('CV: %.2f → %s\n', cvSpacing, spacingType);
end
end

%% -------------------------------------------------------------
function plot_spacing_chart(results, figTitle)
if isempty(results), return; end

fileNames = {results.filename};
spacingMeans = [results.meanSpacing];
types = {results.type};

barColors = zeros(length(types), 3);
for i = 1:length(types)
    if contains(types{i}, 'Uniform')
        barColors(i, :) = [0.2 0.6 1];   % Blue
    elseif contains(types{i}, 'Variable')
        barColors(i, :) = [1 0.4 0.4];   % Red
    else
        barColors(i, :) = [0.6 0.6 0.6]; % Gray
    end
end

figure('Name', figTitle);
b = bar(spacingMeans, 'FaceColor', 'flat');
b.CData = barColors;

set(gca, 'XTickLabel', fileNames, 'XTick', 1:length(fileNames), 'XTickLabelRotation', 30);
ylabel('Average Letter Spacing (pixels)');
xlabel('Sample Filename');
title(figTitle);
grid on;
end
