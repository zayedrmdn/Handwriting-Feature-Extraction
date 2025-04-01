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

%% Feature Extraction Visualization
figure;
subplot(1,3,1);
imshow(grayImg);
title('Grayscale Image');

subplot(1,3,2);
imshow(bwImg);
title('Binarized Image');

%% Edge Detection for Stroke Analysis
edges = edge(bwImg, 'Canny');

subplot(1,3,3);
imshow(edges);
title('Detected Edges');

%% Compute Stroke Smoothness (Line Quality)
smoothnessScore = sum(edges(:)) / numel(edges);

%% Additional Classification: Calligraphy or Italic (Based on Edge Density)
edgeDensity = sum(edges(:)) / numel(bwImg);
if edgeDensity > 0.15
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Smoothness Score: %.2f\n', smoothnessScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

%% Classification
if smoothnessScore < smoothingThreshold
    classification = 'Smooth & Clear';
else
    classification = 'Rough & Inconsistent';
end

finalLineQuality = struct('Score', smoothnessScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end