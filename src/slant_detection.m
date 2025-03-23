function result = slant_detection(imagePath)
% SLANT_DETECTION: Detects handwriting slant using Hough Transform.

%% -------------------- TWEAKABLE PARAMETERS --------------------
% Standardized image size (4:3 ratio)
targetWidth = 2000;
targetHeight = 1500;

% Hough Transform parameters
numPeaks = 60;        
houghThreshold = 0.3; 
minAngle = 10;       
maxAngle = 80;       
minLineLength = 20;  
useMedian = false;   
flipAngle = false;   

% Line merging parameters
angleTolerance = 5;   
distTolerance = 250;  

% Merged letter handling
maxLetterWidth = 100; 
%% -------------------------------------------------------------

% Check if file exists
if ~isfile(imagePath)
    error('File not found: %s', imagePath);
end

fprintf('Processing image: %s\n', imagePath);

%% STEP 1: Read & Resize Image (Standardization)
img = imread(imagePath);

% Resize while preserving aspect ratio
img = imresize(img, [targetHeight, NaN]); % Resize height, keep aspect ratio
if size(img, 2) > targetWidth
    img = imresize(img, [NaN, targetWidth]); % Resize width if necessary
end

% Pad the image to the target size (if needed)
padHeight = targetHeight - size(img, 1);
padWidth = targetWidth - size(img, 2);
img = padarray(img, [padHeight, padWidth], 255, 'post'); % Pad with white background

%% Convert to grayscale
grayImg = rgb2gray(img);

%% STEP 2: Preprocessing - Binarization & Noise Removal
bwImg = imbinarize(grayImg, graythresh(grayImg));
bwImg = bwareaopen(bwImg, 20); 
bwImg = imclose(bwImg, strel('disk', 1)); 

%% STEP 3: Edge Detection
edges = edge(bwImg, 'canny', [0.1 0.2]); 

%% STEP 4: Hough Transform to Detect Lines
[H, T, R] = hough(edges); 
peaks = houghpeaks(H, numPeaks, 'threshold', ceil(houghThreshold * max(H(:))));
lines = houghlines(edges, T, R, peaks); 

%% STEP 5: Extract Line Angles
angles = []; 

for i = 1:length(lines)
    pt1 = lines(i).point1;
    pt2 = lines(i).point2;
    
    currentAngle = atan2d(pt2(2) - pt1(2), pt2(1) - pt1(1));
    lineLength = sqrt((pt2(1) - pt1(1))^2 + (pt2(2) - pt1(2))^2);

    % Filter lines by angle and length
    if abs(currentAngle) > minAngle && abs(currentAngle) < maxAngle && lineLength > minLineLength
        angles = [angles, currentAngle]; 
    end
end

%% STEP 6: Compute Slant Angle
if isempty(angles)
    meanSlant = NaN;
    slantType = 'Neutral';
else
    meanSlant = useMedian * median(angles) + (~useMedian) * mean(angles);
    if flipAngle
        meanSlant = -meanSlant;
    end

    % Classify Slant Type
    if meanSlant < -10
        slantType = 'Right-Slanted';
    elseif meanSlant > 10
        slantType = 'Left-Slanted';
    else
        slantType = 'Neutral';
    end
end

%% STEP 7: Visualization
fig = figure;
imshow(img); hold on;
title('Detected Slant Lines');

% Draw detected lines
for i = 1:length(lines)
    pt1 = lines(i).point1;
    pt2 = lines(i).point2;
    plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'r-', 'LineWidth', 2);
end

hold off;
drawnow; % Ensure figure updates properly

%% STEP 8: Display & Return Result
fprintf('Handwriting Slant: %s (Mean Angle: %.2f degrees)\n', slantType, meanSlant);

% Return Result to GUI
result = struct('Angle', meanSlant, 'Type', slantType);
end
