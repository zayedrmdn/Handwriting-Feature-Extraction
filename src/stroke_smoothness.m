function finalStrokeSmoothness = stroke_smoothness(imagePath)
% STROKE_SMOOTHNESS: Analyzes fluidity of strokes.

%% Load Image
I = imread(imagePath);
grayImg = rgb2gray(I);
bwImg = imbinarize(grayImg);

%% Feature Extraction Visualization
figure;
subplot(1,2,1);
imshow(grayImg);
title('Grayscale Image');

subplot(1,2,2);
imshow(bwImg);
title('Binarized Image');

%% Edge Detection for Smoothness Analysis
edges = edge(bwImg, 'Sobel');
figure;
imshow(edges);
title('Detected Edges (Smoothness Analysis)');

%% Compute Stroke Smoothness
smoothnessScore = sum(edges(:)) / numel(edges);

%% Additional Classification: Calligraphy or Italic (Based on Smoothness Score)
if smoothnessScore < 0.08
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Smoothness Score: %.4f\n', smoothnessScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

%% Classification
if smoothnessScore < 0.05
    classification = 'Very Smooth';
elif smoothnessScore < 0.1
    classification = 'Moderately Smooth';
else
    classification = 'Rough';
end

finalStrokeSmoothness = struct('Score', smoothnessScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end
