function result = space_detection(imagePath)
% SPACE_DETECTION: Detects handwriting letter spacing and classifies it.

%% -------------------- TWEAKABLE PARAMETERS --------------------
% Line detection parameters
lineThreshold = 60;  % Max vertical distance for letters to be grouped in the same line
minLettersPerLine = 3;  

% Display settings
showLetterSpacing = true;  

% Standard image size
targetWidth = 2000;
targetHeight = 1500;

% Minimum letter area to be considered
minLetterArea = 100;  
%% -------------------------------------------------------------

% Check if file exists
if ~isfile(imagePath)
    error('File not found: %s', imagePath);
end

fprintf('Processing image: %s\n', imagePath);

%% Load and Standardize Image
img = imread(imagePath);
img = imresize(img, [targetHeight, targetWidth]);

grayImg = rgb2gray(img);  
bwImg = imbinarize(grayImg);

% Remove small noise
bwImg = bwareaopen(~bwImg, 20);  
bwImg = ~bwImg;  

%% Extract Letter Boundaries
cc = bwconncomp(~bwImg);  
stats = regionprops(cc, 'BoundingBox', 'Centroid', 'Area');

%% Get Letter Midpoints
letterMidpointsX = [];
letterMidpointsY = [];

for i = 1:length(stats)
    if stats(i).Area < minLetterArea
        continue;
    end

    bbox = stats(i).BoundingBox;  
    xCenter = bbox(1) + bbox(3) / 2;  
    yCenter = bbox(2) + bbox(4) / 2;  

    letterMidpointsX = [letterMidpointsX, xCenter];
    letterMidpointsY = [letterMidpointsY, yCenter];
end

% Sort letters by Y-coordinates first
[sortedY, sortIdx] = sort(letterMidpointsY);
sortedX = letterMidpointsX(sortIdx);

% Initialize text line detection
textLines = {};
currentLineX = [sortedX(1)];
currentLineY = [sortedY(1)];

for i = 2:length(sortedY)
    if abs(sortedY(i) - sortedY(i-1)) > lineThreshold
        % Ensure letters are sorted left-to-right in each detected line
        [sortedCurrentX, sortXIdx] = sort(currentLineX);
        sortedCurrentY = currentLineY(sortXIdx);
        textLines{end+1} = [sortedCurrentX(:), sortedCurrentY(:)];

        % Start new line
        currentLineX = [sortedX(i)];
        currentLineY = [sortedY(i)];
    else
        currentLineX = [currentLineX; sortedX(i)];
        currentLineY = [currentLineY; sortedY(i)];
    end
end

% Add the last processed line
[sortedCurrentX, sortXIdx] = sort(currentLineX);
sortedCurrentY = currentLineY(sortXIdx);
textLines{end+1} = [sortedCurrentX(:), sortedCurrentY(:)];

%% Compute Letter Spacing for Each Line
spacingValues = [];

figure;
imshow(img); hold on;
title('Letter Spacing');

for i = 1:length(textLines)
    lineData = textLines{i};
    adaptiveMinLetters = max(2, round(0.2 * length(lineData)));  
    if size(lineData, 1) < adaptiveMinLetters, continue; end

    % Compute spacing between consecutive letters
    letterXs = lineData(:,1);  
    letterSpacings = diff(letterXs);  

    % Store spacing values for analysis
    spacingValues = [spacingValues, letterSpacings'];

    % Visualization: Draw lines between letters
    if showLetterSpacing
        for j = 1:length(letterSpacings)
            x1 = letterXs(j);
            x2 = letterXs(j+1);
            y = lineData(j,2);  
            plot([x1, x2], [y, y], 'b-', 'LineWidth', 2);  
        end
    end

    % Plot letter midpoints
    scatter(lineData(:,1), lineData(:,2), 50, 'go', 'filled');  
end
hold off;

%% Compute Spacing Statistics
if isempty(spacingValues)
    meanSpacing = NaN;
    cvSpacing = NaN;
    spacingType = 'Unknown';
else
    spacingMean = mean(spacingValues);
    spacingStd = std(spacingValues);
    cvSpacing = spacingStd / spacingMean;  

    % Classification Based on Spacing Variability
    if cvSpacing < 0.5
        spacingType = 'Uniform Spacing (Print)';
    else
        spacingType = 'Variable Spacing (Possibly Cursive)';
    end
end

% Display Results
fprintf('Mean Letter Spacing: %.2f pixels\n', spacingMean);
fprintf('Coefficient of Variation: %.2f\n', cvSpacing);
fprintf('Classification: %s\n', spacingType);

% Return Result to GUI
result = struct('MeanSpacing', spacingMean, 'CVSpacing', cvSpacing, 'Type', spacingType);
end
