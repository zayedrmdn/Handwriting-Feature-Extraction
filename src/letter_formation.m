function finalLetterFormation = letter_formation(imagePath)
% LETTER_FORMATION: Evaluates how well-formed letters are.

%% Load Image
grayImg = rgb2gray(imread(imagePath));
bwImg = imbinarize(grayImg);
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'Eccentricity');

%% Compute Letter Formation Score
formationScore = mean([stats.Eccentricity]);

%% Classification
if formationScore < 0.5
    classification = 'Well-Formed';
else
    classification = 'Distorted';
end

finalLetterFormation = struct('Score', formationScore, 'Type', classification);
end

