function finalStrokeCurvature = stroke_curvature(imagePath)
% STROKE_CURVATURE: Measures stroke bending degree.

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

%% Compute Stroke Curvature
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'EulerNumber');
curvatureScore = mean([stats.EulerNumber]);

%% Additional Classification: Calligraphy or Italic (Based on Curvature Score)
if curvatureScore < -2
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Curvature Score: %.2f\n', curvatureScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

%% Classification
if curvatureScore < -5
    classification = 'Highly Curved';
else
    classification = 'Mostly Straight';
end

finalStrokeCurvature = struct('Score', curvatureScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end
