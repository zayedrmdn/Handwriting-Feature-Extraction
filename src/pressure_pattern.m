function finalPressureScore = pressure_pattern(imagePath)
% PRESSURE_PATTERN: Evaluates handwriting pressure intensity.

%% Load & Convert Image
I = imread(imagePath);
grayImg = rgb2gray(I);

%% Feature Extraction Visualization
figure;
subplot(1,2,1);
imshow(grayImg);
title('Grayscale Image');

subplot(1,2,2);
histogram(grayImg);
title('Intensity Histogram');
xlabel('Pixel Intensity');
ylabel('Frequency');

%% Compute Pressure Score
pressureScore = mean(grayImg(:));

%% Additional Classification: Calligraphy or Italic (Based on Intensity Variance)
intensityVariance = std(double(grayImg(:)));
if intensityVariance > 50
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Pressure Score: %.2f\n', pressureScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

%% Classification
if pressureScore < 100
    classification = 'Light Pressure';
elif pressureScore < 180
    classification = 'Moderate Pressure';
else
    classification = 'Heavy Pressure';
end

finalPressureScore = struct('Score', pressureScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end