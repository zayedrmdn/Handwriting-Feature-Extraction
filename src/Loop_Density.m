function result = Loop_Density(imagePath)
% LOOP_DENSITY: Computes loop density by detecting and counting enclosed loops in a handwriting sample.
%
% Input:
%   imagePath - Path to the handwriting image.
%
% Output:
%   result - Structure containing:
%            Result : Number of detected loops.
%            Type   : 'High Loop Density' or 'Low Loop Density'.
%
% Author: [Your Name]
% Date: [Current Date]

%% --- Step 1: Image Acquisition & Preprocessing ---
Image = imread(imagePath);
if size(Image, 3) == 3
    grayImage = rgb2gray(Image);
else
    grayImage = Image;
end

binaryImage = imbinarize(grayImage);
invertedImage = imcomplement(binaryImage);
filledImage = imfill(invertedImage, 'holes');

%% --- Feature Extraction ---
minLoopArea = 10;
loopsImage = filledImage & ~invertedImage;
loopsImage = bwareaopen(loopsImage, minLoopArea);

cc = bwconncomp(loopsImage);
loopCount = cc.NumObjects;

% Set a threshold for loop density classification (example threshold: 10 loops)
loopThreshold = 10;
if loopCount >= loopThreshold
    classification = 'High Loop Density';
else
    classification = 'Low Loop Density';
end

%% --- Visualization ---
figure('Name', 'Loop Density Feature Extraction', 'NumberTitle', 'off', 'Position', [300, 100, 1000, 700]);
subplot(2,3,1); imshow(Image); title('1. Original Image');
subplot(2,3,2); imshow(grayImage); title('2. Grayscale Image');
subplot(2,3,3); imshow(binaryImage); title('3. Binarized Image');
subplot(2,3,4); imshow(invertedImage); title('4. Inverted Image');
subplot(2,3,5); imshow(filledImage); title('5. Filled Image');
subplot(2,3,6);
imshow(loopsImage); title('6. Detected Loops');
text(10, 20, sprintf('Loop Count: %d\nClassification: %s', loopCount, classification), ...
    'Color','yellow', 'FontSize',12, 'FontWeight','bold', 'BackgroundColor','black');

%% Return Result
result = struct('Result', loopCount, 'Type', classification);
end
