function result = Contour_Complexity(imagePath)
% CONTOUR_COMPLEXITY: Computes the average contour complexity (perimeter-to-area ratio)
% for regular writing analysis.
%
% Input:
%   imagePath - Path to the handwriting image.
%
% Output:
%   result - Structure containing:
%            Result : Average contour complexity.
%            Type   : 'High Contour Complexity' or 'Low Contour Complexity'.
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
cleanImage = bwareaopen(invertedImage, 30);

%% --- Step 2: Feature Extraction: Contour Complexity ---
stats = regionprops(cleanImage, 'Area', 'Perimeter');
if isempty(stats)
    avgComplexity = NaN;
    classification = 'No Content';
else
    complexityRatios = arrayfun(@(s) s.Perimeter / s.Area, stats);
    avgComplexity = mean(complexityRatios);
    if avgComplexity > 0.8
        classification = 'High Contour Complexity';
    else
        classification = 'Low Contour Complexity';
    end
end

%% --- Visualization ---
figure('Name', 'Contour Complexity Feature Extraction', 'NumberTitle', 'off', 'Position', [300, 100, 1000, 700]);
subplot(2,3,1); imshow(Image); title('1. Original Image');
subplot(2,3,2); imshow(grayImage); title('2. Grayscale Image');
subplot(2,3,3); imshow(binaryImage); title('3. Binarized Image');
subplot(2,3,4); imshow(invertedImage); title('4. Inverted Image');
subplot(2,3,5); imshow(cleanImage); title('5. Cleaned Image');
subplot(2,3,6);
imshow(Image); title('6. Final Output: Boundaries & Metrics');
hold on;
boundaries = bwboundaries(cleanImage);
for k = 1:length(boundaries)
    boundary = boundaries{k};
    plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1);
end
text(10, 20, sprintf('Avg Complexity: %.2f\nClassification: %s', avgComplexity, classification), ...
    'Color','yellow', 'FontSize',12, 'FontWeight','bold', 'BackgroundColor','black');
hold off;

%% Return Result
result = struct('Result', avgComplexity, 'Type', classification);
end
