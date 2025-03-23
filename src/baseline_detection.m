function finalBaselineScore = baseline_detection(imagePath)
% BASELINE_DETECTION: Detects handwriting baseline consistency 
% and classifies it as PRINT or CURSIVE.

%% -------------------- TWEAKABLE PARAMETERS --------------------
% Baseline detection parameters
lineThreshold      = 40;  
minLettersPerLine  = 5;   
printThreshold     = 15;  

% Display settings
showDetectedPoints = true;  
showFittedBaselines= true;  

% Target dimensions for image standardization (height x width)
targetHeight = 1500;
targetWidth  = 2000;
%% -------------------------------------------------------------

%% LOAD & RESIZE IMAGE (From GUI Instead of Folder)
if ~isfile(imagePath)
    error('File not found: %s', imagePath);
end

I = imread(imagePath);
[h, w, ~] = size(I);

% Compute scaling factor to ensure full coverage
scale = max(targetHeight / h, targetWidth / w);
R = imresize(I, scale);
[rh, rw, ~] = size(R);

% Ensure final size is exactly 1500 × 2000
if rh >= targetHeight && rw >= targetWidth
    % Crop to center
    y0 = floor((rh - targetHeight) / 2) + 1;
    x0 = floor((rw - targetWidth) / 2) + 1;
    img = R(y0:y0 + targetHeight - 1, x0:x0 + targetWidth - 1, :);
else
    % Pad to center
    img = uint8(zeros(targetHeight, targetWidth, 3));
    yOffset = floor((targetHeight - rh) / 2) + 1;
    xOffset = floor((targetWidth - rw) / 2) + 1;
    img(yOffset:yOffset + rh - 1, xOffset:xOffset + rw - 1, :) = R;
end

%% CONVERT TO GRAYSCALE & BINARY
grayImg = rgb2gray(img);
bwImg   = imbinarize(grayImg);

%% EXTRACT LETTER BOUNDARIES
cc    = bwconncomp(~bwImg);  
stats = regionprops(cc, 'BoundingBox', 'Centroid');

baselineY = [];  
letterX   = [];  

for i = 1:numel(stats)
    bbox = stats(i).BoundingBox;

    % Clamp bounding box to avoid out-of-bounds indexing
    y1 = max(1, round(bbox(2)));
    y2 = min(targetHeight, round(bbox(2) + bbox(4)));
    x1 = max(1, round(bbox(1)));
    x2 = min(targetWidth, round(bbox(1) + bbox(3)));

    % Extract the letter region
    letterRegion = bwImg(y1:y2, x1:x2);

    % Find lowest row containing black pixels (handwriting strokes)
    rows = find(any(letterRegion == 0, 2));
    if isempty(rows)
        bottomY = y2;
    else
        bottomY = y1 + max(rows) - 1;
    end

    % Store coordinates
    baselineY(end+1) = bottomY;
    letterX(end+1)   = bbox(1) + bbox(3) / 2;  
end

%% REMOVE OUTLIERS
meanY = mean(baselineY);
stdY  = std(baselineY);
validIdx = (baselineY > meanY - 2 * stdY) & (baselineY < meanY + 2 * stdY);

filteredX = letterX(validIdx)';
filteredY = baselineY(validIdx)';

%% SORT AND GROUP INTO LINES
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

%% FIT BASELINES AND COMPUTE DEVIATION
baselineDeviation = [];

figure; imshow(img); hold on;
title('Detected Baselines');

for i = 1:numel(textLines)
    lineData = textLines{i};
    if size(lineData, 1) < minLettersPerLine, continue; end
    
    % Fit straight line to baseline points
    p = polyfit(lineData(:,1), lineData(:,2), 1);
    fittedBaseline = polyval(p, lineData(:,1));

    % Compute deviation from fitted line
    lineDeviation = std(lineData(:,2) - fittedBaseline);
    baselineDeviation(end+1) = lineDeviation;

    % Plot detected baseline
    if showFittedBaselines
        plot(lineData(:,1), fittedBaseline, 'r-', 'LineWidth', 2);
    end
    if showDetectedPoints
        scatter(lineData(:,1), lineData(:,2), 'go', 'filled');
    end
end
hold off;

%% CLASSIFICATION (PRINT VS CURSIVE)
finalBaselineScore = mean(baselineDeviation);
disp(['Final Baseline Score: ', num2str(finalBaselineScore)]);

if finalBaselineScore < printThreshold
    disp('Handwriting is PRINT (Aligned Baseline)');
    classificationResult = 'PRINT';
else
    disp('Handwriting is CURSIVE (Wavy Baseline)');
    classificationResult = 'CURSIVE';
end

% Return Classification & Score
finalBaselineScore = struct('Score', finalBaselineScore, 'Type', classificationResult);
end
