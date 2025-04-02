function results = stroke_connectivity_batch()
% STROKE_CONNECTIVITY_BATCH: Measures stroke connectivity on multiple cursive images.
% Displays connected components, classifies, and plots summary.

clc; clearvars; close all;

%% -------------------- TWEAKABLE PARAMETERS --------------------
imageFolder = 'C:\Users\Zayed\Documents\GitHub\Handwriting-Feature-Extraction\test_images\';
filePattern = fullfile(imageFolder, 'cursive (*.png');

% Preprocessing
minComponentArea = 1500;             % Remove noise
connectivityThreshold = 550;       % Threshold to classify Cursive vs Print
showOverlay = true;                % Show labeled components
%% -------------------------------------------------------------

% Get image list
imageFiles = dir(filePattern);
if isempty(imageFiles)
    error('No images found for pattern: %s\n', filePattern);
end

fprintf('\n--- Processing Cursive Stroke Connectivity ---\n');
results = [];

%% Loop through each image
for k = 1:length(imageFiles)
    imagePath = fullfile(imageFiles(k).folder, imageFiles(k).name);
    fprintf('\nImage: %s\n', imageFiles(k).name);

    % STEP 1: Read & Preprocess Image
    img = imread(imagePath);
    grayImg = rgb2gray(img);
    bwImg = imbinarize(grayImg);

    % Remove small noise
    bwImg = bwareaopen(~bwImg, minComponentArea);  % White = background
    bwImg = ~bwImg;

    % STEP 2: Get Connected Components
    cc = bwconncomp(~bwImg);
    stats = regionprops(cc, 'Area');
    componentAreas = [stats.Area];

    % STEP 3: Analyze Component Size
    if isempty(componentAreas)
        avgSize = NaN;
        strokeType = 'Unknown';
    else
        avgSize = median(componentAreas);

        if avgSize > connectivityThreshold
            strokeType = 'Cursive (High Connectivity)';
        else
            strokeType = 'Print (Low Connectivity)';
        end
    end

    % STEP 4: Visualization
    if showOverlay
        labeledImg = labelmatrix(cc);
        rgbLabel = label2rgb(labeledImg, 'jet', 'k', 'shuffle');
        figure('Name', ['Components - ' imageFiles(k).name]);
        imshow(rgbLabel);
        title(sprintf('%s - %s (%.0f px)', imageFiles(k).name, strokeType, avgSize));
    end

    % STEP 5: Store Results
    results(end+1).filename = imageFiles(k).name;
    results(end).avgSize = avgSize;
    results(end).type = strokeType;

    % Output to console
    fprintf('Average Component Size: %.2f px\n', avgSize);
    fprintf('Classification: %s\n', strokeType);
end

%% STEP 6: Summary Bar Chart
fileNames = {results.filename};
sizes = [results.avgSize];
types = {results.type};

% Assign bar colors
barColors = zeros(length(types), 3);
for i = 1:length(types)
    if contains(types{i}, 'Cursive')
        barColors(i,:) = [0.2 0.6 1];  % Blue
    elseif contains(types{i}, 'Print')
        barColors(i,:) = [1 0.4 0.4];  % Red
    else
        barColors(i,:) = [0.6 0.6 0.6]; % Gray
    end
end

figure('Name', 'Figure 3.X - Stroke Connectivity (Cursive)');
b = bar(sizes, 'FaceColor', 'flat');
b.CData = barColors;

set(gca, 'XTickLabel', fileNames, 'XTick', 1:length(fileNames), 'XTickLabelRotation', 30);
ylabel('Median Connected Component Area (px)');
xlabel('Sample Filename');
title('Figure 3.X: Stroke Connectivity - Cursive Samples');
grid on;

end
