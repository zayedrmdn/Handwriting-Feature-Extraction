function finalStrokeAngleVar = stroke_angle_variation(imagePath)
% STROKE_ANGLE_VARIATION: Analyzes angular consistency of strokes.

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

%% Compute Stroke Orientation Variation
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'Orientation');
angleVariationScore = std([stats.Orientation]);

%% Additional Classification: Calligraphy or Italic (Based on Angle Variance)
if angleVariationScore < 15
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Angle Variation Score: %.2f\n', angleVariationScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

%% Classification
if angleVariationScore < 10
    classification = 'Consistent Angles';
else
    classification = 'Inconsistent Angles';
end

finalStrokeAngleVar = struct('Score', angleVariationScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end
