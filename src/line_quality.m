function finalLineQuality = line_quality(imagePath)
% LINE_QUALITY: Analyzes stroke consistency and clarity.

%% Parameters
smoothingThreshold = 10; 
showProcessedImage = true;

%% Load Image
if ~isfile(imagePath)
    error('File not found: %s', imagePath);
end
I = imread(imagePath);
grayImg = rgb2gray(I);
bwImg = imbinarize(grayImg);

%% Edge Detection for Stroke Analysis
edges = edge(bwImg, 'Canny');

%% Compute Stroke Smoothness (Line Quality)
smoothnessScore = sum(edges(:)) / numel(edges);

%% Display Processed Image
if showProcessedImage
    figure; imshow(edges); title('Detected Edges for Line Quality');
end

%% Classification
if smoothnessScore < smoothingThreshold
    classification = 'Smooth & Clear';
else
    classification = 'Rough & Inconsistent';
end

finalLineQuality = struct('Score', smoothnessScore, 'Type', classification);
end