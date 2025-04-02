function results = slant_detection()
% SLANT_DETECTION: Detects handwriting slant on multiple cursive images using Hough Transform.

% -------------------- CLEANUP --------------------
clc;            % Clear the command window
clearvars;      % Clear all variables from the workspace
close all;      % Close all open figure windows

%% -------------------- TWEAKABLE PARAMETERS --------------------
% Folder containing cursive images
imageFolder = 'C:\Users\Zayed\Documents\GitHub\Handwriting-Feature-Extraction\test_images\';
filePattern = fullfile(imageFolder, 'cursive (*.png'); % All "cursive (x).png" files

% Standardized image size (4:3 ratio)
targetWidth = 2000;
targetHeight = 1500;

% Hough Transform parameters
numPeaks = 80;        
houghThreshold = 0.3; 
minAngle = 15;       
maxAngle = 85;       
minLineLength = 10;  
useMedian = false;   
flipAngle = false;   

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

    % Resize while preserving aspect ratio
    img = imresize(img, [targetHeight, NaN]);
    if size(img, 2) > targetWidth
        img = imresize(img, [NaN, targetWidth]);
    end

    % Pad to target size (if needed)
    padHeight = targetHeight - size(img, 1);
    padWidth = targetWidth - size(img, 2);
    img = padarray(img, [padHeight, padWidth], 255, 'post');

    % Convert to grayscale
    grayImg = rgb2gray(img);

    % STEP 2: Preprocessing
    bwImg = imbinarize(grayImg, graythresh(grayImg));
    bwImg = bwareaopen(bwImg, 20);
    bwImg = imclose(bwImg, strel('disk', 1));

    % STEP 3: Edge Detection
    edges = edge(bwImg, 'canny', [0.1 0.2]);

    % STEP 4: Hough Transform
    [H, T, R] = hough(edges);
    peaks = houghpeaks(H, numPeaks, 'threshold', ceil(houghThreshold * max(H(:))));
    lines = houghlines(edges, T, R, peaks);

    % STEP 5: Extract Angles
    angles = [];
    for i = 1:length(lines)
        pt1 = lines(i).point1;
        pt2 = lines(i).point2;
        currentAngle = atan2d(pt2(2) - pt1(2), pt2(1) - pt1(1));
        lineLength = norm([pt2(1) - pt1(1), pt2(2) - pt1(2)]);

        if abs(currentAngle) > minAngle && abs(currentAngle) < maxAngle && lineLength > minLineLength
            angles = [angles, currentAngle];
        end
    end

    % STEP 6: Compute Slant (Dominant Direction Only)
    leftAngles = angles(angles > 0);
    rightAngles = angles(angles < 0);

    if isempty(angles)
        meanSlant = NaN;
        slantType = 'Neutral';
    else
        if length(leftAngles) > length(rightAngles)
            meanSlant = mean(leftAngles);
            slantType = 'Left-Slanted';
        elseif length(rightAngles) > length(leftAngles)
            meanSlant = mean(rightAngles);
            slantType = 'Right-Slanted';
        else
            meanSlant = 0;
            slantType = 'Neutral';
        end
    end

    % STEP 7: Visualization (Only show filtered lines)
    figure; imshow(img); hold on;
    title(sprintf('%s - %s (%.2f°)', imageFiles(k).name, slantType, meanSlant));

    for i = 1:length(lines)
        pt1 = lines(i).point1;
        pt2 = lines(i).point2;
        currentAngle = atan2d(pt2(2) - pt1(2), pt2(1) - pt1(1));
        lineLength = norm([pt2(1) - pt1(1), pt2(2) - pt1(2)]);

        % Draw only the lines that passed the slant filter
        if abs(currentAngle) > minAngle && abs(currentAngle) < maxAngle && lineLength > minLineLength
            plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'r-', 'LineWidth', 2);
        end
    end
    hold off;

    % STEP 8: Store Result
    results(end+1).filename = imageFiles(k).name;
    results(end).angle = meanSlant;
    results(end).slant = slantType;

    fprintf('Handwriting Slant: %s (Mean Angle: %.2f degrees)\n', slantType, meanSlant);
end

%% STEP 9: Summary Plot - Figure 3.8
fileNames = {results.filename};
angles = [results.angle];
types = {results.slant};

% Assign colors based on slant type
barColors = zeros(length(types), 3); % RGB colors
for i = 1:length(types)
    if strcmp(types{i}, 'Left-Slanted')
        barColors(i, :) = [0.2 0.6 1];  % Blue
    elseif strcmp(types{i}, 'Right-Slanted')
        barColors(i, :) = [1 0.4 0.4];  % Red
    else
        barColors(i, :) = [0.6 0.6 0.6]; % Gray for Neutral
    end
end

% Create bar chart
b = bar(angles, 'FaceColor', 'flat');
b.CData = barColors;
set(gca, 'XTickLabel', fileNames, 'XTick', 1:length(fileNames), 'XTickLabelRotation', 30);
ylabel('Average Slant Angle (°)');
xlabel('Sample Filename');
title('Figure 3.8: Summary of Average Slant Angle Across All Samples');
grid on;
set(gca, 'YDir', 'reverse');  % Optional: flip so negative slants go upward

end  % <--- This is the actual end of the function