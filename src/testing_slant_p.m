function results = slant_detection()
% SLANT_DETECTION: Detects handwriting slant on multiple print images using Hough Transform.

% -------------------- CLEANUP --------------------
clc; clearvars; close all;

%% -------------------- TWEAKABLE PARAMETERS --------------------
% Folder containing print images
imageFolder = 'C:\Users\Zayed\Documents\GitHub\Handwriting-Feature-Extraction\test_images\';
filePattern = fullfile(imageFolder, 'print (*.png'); % All "print (x).png" files

% Standardized image size (4:3 ratio)
targetWidth = 2000;
targetHeight = 1500;

% Hough Transform parameters
numPeaks = 60;
houghThreshold = 0.3;
minAngle = 1;            % Allow near-vertical lines
maxAngle = 80;           % Exclude near-horizontal lines
minLineLength = 20;
useMedian = false;
flipAngle = false;
neutralThreshold = 45;   % Within ±15° is considered Neutral
%% -------------------------------------------------------------

% Output storage
results = [];

% Read all matching images
imageFiles = dir(filePattern);
if isempty(imageFiles)
    error('No images found matching pattern: %s', filePattern);
end

%% Loop through each image
for k = 1:length(imageFiles)
    imagePath = fullfile(imageFolder, imageFiles(k).name);
    fprintf('\nProcessing image: %s\n', imagePath);

    % STEP 1: Read & Resize Image
    img = imread(imagePath);
    img = imresize(img, [targetHeight, NaN]);
    if size(img, 2) > targetWidth
        img = imresize(img, [NaN, targetWidth]);
    end
    padHeight = targetHeight - size(img, 1);
    padWidth = targetWidth - size(img, 2);
    img = padarray(img, [padHeight, padWidth], 255, 'post');

    % STEP 2: Preprocessing
    grayImg = rgb2gray(img);
    bwImg = imbinarize(grayImg, graythresh(grayImg));
    bwImg = bwareaopen(bwImg, 20);
    bwImg = imclose(bwImg, strel('disk', 1));

    % STEP 3: Edge Detection
    edges = edge(bwImg, 'canny', [0.1 0.2]);

    % STEP 4: Hough Transform
    [H, T, R] = hough(edges);
    peaks = houghpeaks(H, numPeaks, 'threshold', ceil(houghThreshold * max(H(:))));
    allLines = houghlines(edges, T, R, peaks);

    % STEP 5: Extract & Filter Angles
    angles = [];
    filteredLines = allLines([]);  
    
    for i = 1:length(allLines)
        pt1 = allLines(i).point1;
        pt2 = allLines(i).point2;
        angle = atan2d(pt2(2) - pt1(2), pt2(1) - pt1(1));
        lineLength = norm([pt2(1) - pt1(1), pt2(2) - pt1(2)]);
        
        if abs(angle) > minAngle && abs(angle) < maxAngle && lineLength > minLineLength
            angles(end+1) = angle;
            filteredLines(end+1) = allLines(i);  % ✅ Correctly append as struct
        end
    end

    % STEP 6: Classify Slant
    if isempty(angles)
        meanSlant = NaN;
        slantType = 'Neutral';
    else
        meanSlant = useMedian * median(angles) + (~useMedian) * mean(angles);
        if flipAngle
            meanSlant = -meanSlant;
        end

        % Use angle thresholds for classification
        if abs(meanSlant) <= neutralThreshold
            slantType = 'Neutral';
        elseif meanSlant > neutralThreshold
            slantType = 'Left-Slanted';
        elseif meanSlant < -neutralThreshold
            slantType = 'Right-Slanted';
        end
    end

    % STEP 7: Visualization (Filtered Lines Only)
    figure; imshow(img); hold on;
    title(sprintf('%s - %s (%.2f°)', imageFiles(k).name, slantType, meanSlant));

    for i = 1:length(filteredLines)
        pt1 = filteredLines(i).point1;
        pt2 = filteredLines(i).point2;
        plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'r-', 'LineWidth', 2);
    end
    hold off;

    % STEP 8: Store Results
    results(end+1).filename = imageFiles(k).name;
    results(end).angle = meanSlant;
    results(end).slant = slantType;

    fprintf('Handwriting Slant: %s (Mean Angle: %.2f degrees)\n', slantType, meanSlant);
end

%% STEP 9: Summary Bar Chart - Figure 3.8
fileNames = {results.filename};
angles = [results.angle];
types = {results.slant};

% Assign bar colors
barColors = zeros(length(types), 3);
for i = 1:length(types)
    if strcmp(types{i}, 'Left-Slanted')
        barColors(i, :) = [0.2 0.6 1];    % Blue
    elseif strcmp(types{i}, 'Right-Slanted')
        barColors(i, :) = [1 0.4 0.4];    % Red
    else
        barColors(i, :) = [0.6 0.6 0.6];  % Gray
    end
end

% Draw bar chart
figure('Name', 'Figure 3.8 - Slant Summary');
b = bar(angles, 'FaceColor', 'flat');
b.CData = barColors;

set(gca, 'XTickLabel', fileNames, 'XTick', 1:length(fileNames), 'XTickLabelRotation', 30);
ylabel('Average Slant Angle (°)');
xlabel('Sample Filename');
title('Figure 3.8: Summary of Average Slant Angle Across All Print Samples');
grid on;
set(gca, 'YDir', 'reverse');  % Optional: flip bars if most are negative

end
