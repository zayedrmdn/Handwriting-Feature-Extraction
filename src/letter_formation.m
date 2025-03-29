function finalLetterFormation = letter_formation(imagePath)
% LETTER_FORMATION: Evaluates how well-formed letters are.

%% Load Image
img = imread(imagePath);
grayImg = rgb2gray(img);
bwImg = imbinarize(grayImg);

%% Feature Extraction Visualization
figure;
subplot(1,2,1);
imshow(grayImg);
title('Grayscale Image');

subplot(1,2,2);
imshow(bwImg);
title('Binarized Image');

%% Extract Connected Components
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'Eccentricity', 'Solidity');

%% Compute Letter Formation Score
formationScore = mean([stats.Eccentricity]);
solidityScore = mean([stats.Solidity]);

%% Classification Based on Eccentricity
if formationScore < 0.5
    classification = 'Well-Formed';
else
    classification = 'Distorted';
end

%% Additional Classification: Calligraphy or Italic (Based on Solidity)
if solidityScore > 0.85
    handwritingStyle = 'Calligraphy';
else
    handwritingStyle = 'Italic';
end

%% Display Results
fprintf('Formation Score: %.2f\n', formationScore);
fprintf('Handwriting Style: %s\n', handwritingStyle);

finalLetterFormation = struct('Score', formationScore, 'Type', classification, 'HandwritingStyle', handwritingStyle);
end
