function result = slant_detection(imagePath)
% SLANT_DETECTION: Detects handwriting slant using Hough Transform for a single image (GUI-compatible).

% -------------------- CLEANUP --------------------
clc;            % Clear the command window
close all;      % Close all open figure windows

%% -------------------- TWEAKABLE PARAMETERS --------------------
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
%% -------------------------------------------------------------

% Check if file exists
if ~isfile(imagePath)
    error('File not found: %s', imagePath);
end

fprintf('Processing image: %s\n', imagePath);

%% STEP 1: Read & Resize Image (Standardization)
img = imread(imagePath);

% Resize while preserving aspect ratio
img = imresize(img, [targetHeight, NaN]);
if size(img, 2) > targetWidth
    img = imresize(img, [NaN, targetWidth]);
end

% Pad the image to the target size (if needed)
padHeight = targetHeight - size(img, 1);
padWidth = targetWidth - size(img, 2);
img = padarray(img, [padHeight, padWidth], 255, 'post'); % White padding

%% STEP 2: Convert to Grayscale & Preprocessing
grayImg = rgb2gray(img);
bwImg = imbinarize(grayImg, graythresh(grayImg));
bwImg = bwareaopen(bwImg, 20);
bwImg = imclose(bwImg, strel('disk', 1));

%% STEP 3: Edge Detection
edges = edge(bwImg, 'canny', [0.1 0.2]);

%% STEP 4: Hough Transform
[H, T, R] = hough(edges);
peaks = houghpeaks(H, numPeaks, 'threshold', ceil(houghThreshold * max(H(:))));
lines = houghlines(edges, T, R, peaks);

%% STEP 5: Extract Valid Line Angles
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

%% STEP 6: Compute Slant (Dominant Direction Only)
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

%% STEP 7: Visualization (Only draw filtered lines)
fig = figure;
imshow(img); hold on;
title(sprintf('%s - %s (%.2f°)', getFileName(imagePath), slantType, meanSlant));

for i = 1:length(lines)
    pt1 = lines(i).point1;
    pt2 = lines(i).point2;
    currentAngle = atan2d(pt2(2) - pt1(2), pt2(1) - pt1(1));
    lineLength = norm([pt2(1) - pt1(1), pt2(2) - pt1(2)]);

    if abs(currentAngle) > minAngle && abs(currentAngle) < maxAngle && lineLength > minLineLength
        plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'r-', 'LineWidth', 2);
    end
end
hold off;
drawnow;

%% STEP 8: Print and Return Result
fprintf('Handwriting Slant: %s (Mean Angle: %.2f degrees)\n', slantType, meanSlant);
result = struct('Angle', meanSlant, 'Type', slantType);

end

%% Helper: Strip path to just file name
function name = getFileName(path)
[~, name, ext] = fileparts(path);
name = [name ext];
end
