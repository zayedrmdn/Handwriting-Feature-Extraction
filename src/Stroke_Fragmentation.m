function result = Stroke_Fragmentation(imagePath)
% STROKE_FRAGMENTATION: Evaluates the fragmentation of strokes (pen-lift frequency)
% for signature analysis.
%
% Input:
%   imagePath - Path to the signature image.
%
% Output:
%   result - Structure containing:
%            Result : Number of stroke fragments.
%            Type   : 'Low Fragmentation', 'Moderate Fragmentation', or 'High Fragmentation'.
%
%% --- Tweakable Parameters ---
medianFilterSize       = [5 5];
binarizationSensitivity  = 0.7;
minObjectSize          = 30;
lowFragThreshold       = 10;
mediumFragThreshold    = 50;
 
%% --- Step 1: Image Acquisition and Preprocessing ---
Image = imread(imagePath);
if size(Image, 3) == 3
    grayImage = rgb2gray(Image);
else
    grayImage = Image;
end

filteredImage = medfilt2(grayImage, medianFilterSize);
binaryImage = imbinarize(filteredImage, 'adaptive', 'Sensitivity', binarizationSensitivity);
cleanImage = bwareaopen(binaryImage, minObjectSize);

%% --- Feature Extraction: Stroke Fragmentation ---
bw = ~cleanImage;
cc = bwconncomp(bw);
strokeFragmentation = cc.NumObjects;

if strokeFragmentation < lowFragThreshold
    fragCategory = 'Low Fragmentation';
elseif strokeFragmentation < mediumFragThreshold
    fragCategory = 'Moderate Fragmentation';
else
    fragCategory = 'High Fragmentation';
end

%% --- Visualization ---
fprintf('\n[Stroke Fragmentation Feature - Signature Analysis]\n');
fprintf('Stroke Fragmentation (Pen-Lifts): %d\n', strokeFragmentation);
fprintf('Classification: %s\n', fragCategory);

figure('Name', 'Stroke Fragmentation Feature Extraction', 'NumberTitle', 'off', 'Position', [300, 100, 1000, 700]);
subplot(2,3,1); imshow(Image); title('1. Original Image');
subplot(2,3,2); imshow(grayImage); title('2. Grayscale');
subplot(2,3,3); imshow(filteredImage); title('3. Median Filtered');
subplot(2,3,4); imshow(binaryImage); title('4. Adaptive Binarization');
subplot(2,3,5); imshow(cleanImage); title('5. Morphologically Cleaned');

labeledImage = labelmatrix(cc);
rgbLabelImage = label2rgb(labeledImage, 'jet', 'k', 'shuffle');
subplot(2,3,6); imshow(rgbLabelImage);
title(sprintf('Stroke Fragmentation: %d Segments', strokeFragmentation));
hold off;

%% Return Result
result = struct('Result', strokeFragmentation, 'Type', fragCategory);
end
