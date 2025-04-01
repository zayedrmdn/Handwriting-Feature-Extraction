function result = Pen_Pressure_Gradient(imagePath)
% PEN_PRESSURE_GRADIENT: Analyzes the pressure gradient across a signature by dividing 
% the image into vertical slices and computing the mean intensity of each slice.

%% --- Tweakable Parameters ---
medianFilterSize = [3 3];   % Kernel size for median filtering
numSlices        = 50;      % Number of vertical slices for pressure analysis
arrowThreshold   = 10;      % Threshold for visualizing pressure gradient arrows

%% --- Step 1: Image Acquisition & Preprocessing ---
Image = imread(imagePath);
if size(Image, 3) == 3
    grayImage = rgb2gray(Image);
else
    grayImage = Image;
end

grayImageFiltered = medfilt2(grayImage, medianFilterSize);

%% --- Step 2: Feature Extraction: Pressure Profile & Gradient ---
[rows, cols] = size(grayImageFiltered);
sliceWidth = floor(cols / numSlices);
pressureProfile = zeros(1, numSlices);
slicePositions = zeros(numSlices, 2);

for i = 1:numSlices
    colStart = (i-1)*sliceWidth + 1;
    if i == numSlices
        colEnd = cols;
    else
        colEnd = i * sliceWidth;
    end
    slice = grayImageFiltered(:, colStart:colEnd);
    pressureProfile(i) = mean(slice(:));
    slicePositions(i,:) = [colStart, colEnd];
end

pressureGradient = diff(pressureProfile);
meanPressureGradient = mean(abs(pressureGradient));

if meanPressureGradient > arrowThreshold
    classification = 'High Pressure Gradient';
else
    classification = 'Low Pressure Gradient';
end

%% --- Visualization ---
figure('Name', 'Pen Pressure Gradient Feature Extraction', 'NumberTitle', 'off', 'Position', [300, 100, 1000, 700]);
subplot(2,3,1); imshow(Image); title('1. Original Image');
subplot(2,3,2); imshow(grayImage); title('2. Grayscale Image');
subplot(2,3,3); imshow(grayImageFiltered); title('3. Denoised Image');

coloredOverlay = repmat(grayImageFiltered, 1, 1, 3);
for i = 1:numSlices
    colStart = slicePositions(i,1);
    colEnd = slicePositions(i,2);
    normVal = 1 - (pressureProfile(i) / 255);
    coloredOverlay(:, colStart:colEnd, 1) = uint8((1 - normVal) * double(coloredOverlay(:, colStart:colEnd, 1)) + normVal * 255);
end
subplot(2,3,4); imshow(coloredOverlay); title('4. Pressure Profile Overlay');

subplot(2,3,5);
arrowImage = repmat(grayImageFiltered, 1, 1, 3);
imshow(arrowImage); hold on; title('5. Gradient Arrows');
yMid = rows / 2;
for i = 1:length(pressureGradient)
    col1 = mean(slicePositions(i,:));
    col2 = mean(slicePositions(i+1,:));
    grad = pressureGradient(i);
    if abs(grad) > arrowThreshold
        if grad > 0
            quiver(col1, yMid, (col2-col1), 0, 0, 'Color', 'blue', 'LineWidth', 1.5, 'MaxHeadSize', 1);
        else
            quiver(col2, yMid, -(col2-col1), 0, 0, 'Color', 'red', 'LineWidth', 1.5, 'MaxHeadSize', 1);
        end
    end
end
hold off;

subplot(2,3,6);
imshow(grayImageFiltered);
title('6. Final Output: Classification');
text(10, 20, sprintf('Mean Gradient: %.2f\nClassification: %s', meanPressureGradient, classification), ...
    'Color','yellow', 'FontSize',12, 'FontWeight','bold', 'BackgroundColor','black');

%% Return Result
result = struct('Result', meanPressureGradient, 'Type', classification);
end
