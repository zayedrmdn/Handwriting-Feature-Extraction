function finalStrokeThickness = stroke_thickness(imagePath)
% STROKE_THICKNESS: Determines average stroke width.

%% Load Image
I = imread(imagePath);
grayImg = rgb2gray(I);
bwImg = ~imbinarize(grayImg);

%% Feature Extraction Visualization
figure;
subplot(1,2,1);
imshow(grayImg);
title('Grayscale Image');

subplot(1,2,2);
imshow(bwImg);
title('Binarized Image');

%% Compute Stroke Thickness
cc = bwconncomp(bwImg);
stats = regionprops(cc, 'MajorAxisLength');
thicknessScore = mean([stats.MajorAxisLength]);

%% Additional Classification: Calligraphy or Italic (Based on Thickness Score)
if thicknessScore > 4
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Thickness Score: %.2f\n', thicknessScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

%% Classification
if thicknessScore < 2
    classification = 'Thin Strokes';
elif thicknessScore < 5
    classification = 'Moderate Strokes';
else
    classification = 'Thick Strokes';
end

finalStrokeThickness = struct('Score', thicknessScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end
