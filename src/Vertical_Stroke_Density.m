function result = Vertical_Stroke_Density(imagePath)
% VERTICAL_STROKE_DENSITY: Computes the density of vertical strokes by applying
% vertical edge detection and calculating the ratio of detected edge pixels.
%
% Input:
%   imagePath - Path to the handwriting image.
%
% Output:
%   result - Structure containing:
%            Result : Calculated vertical edge density.
%            Type   : 'High Vertical Stroke Density' or 'Low Vertical Stroke Density'.
%
% Author: [Your Name]
% Date: [Current Date]

%% --- Tweakable Parameters ---
edgeThreshold = 0.2;
bwareaopenThreshold = 30;

%% --- Step 1: Image Acquisition and Preprocessing ---
Image = imread(imagePath);
if size(Image,3) == 3
    grayImage = rgb2gray(Image);
else
    grayImage = Image;
end

binaryImage = imbinarize(grayImage);

%% --- Step 2: Feature Extraction ---
verticalKernel = fspecial('sobel')';  
verticalEdges = imfilter(double(binaryImage), verticalKernel);
verticalEdges = abs(verticalEdges);

verticalEdgeMap = verticalEdges > (edgeThreshold * max(verticalEdges(:)));
verticalEdgeDensity = sum(verticalEdgeMap(:)) / numel(verticalEdgeMap);

if verticalEdgeDensity > 0.05
    classification = 'High Vertical Stroke Density';
else
    classification = 'Low Vertical Stroke Density';
end

%% --- Display Feature Summary ---
fprintf('\n[Vertical Stroke Density Feature - Regular Writing Analysis]\n');
fprintf('Vertical Stroke Density: %.4f\n', verticalEdgeDensity);
fprintf('Classification: %s\n', classification);

%% --- Visualization ---
figure('Name', 'Vertical Stroke Density Feature Extraction', 'NumberTitle', 'off', 'Position', [300, 100, 1000, 700]);
subplot(2,3,1); imshow(Image); title('1. Original Image');
subplot(2,3,2); imshow(grayImage); title('2. Grayscale Image');
subplot(2,3,3); imshow(binaryImage); title('3. Binarized Image');
subplot(2,3,4); imshow(verticalEdges, []); title('4. Vertical Edge Detection');
subplot(2,3,5); imshow(verticalEdgeMap); title('5. Final Edge Map');
subplot(2,3,6);
text(0.1, 0.5, sprintf('Vertical Stroke Density: %.4f\nClassification: %s', verticalEdgeDensity, classification), 'FontSize', 12);
axis off;

%% Return Result
result = struct('Result', verticalEdgeDensity, 'Type', classification);
end
