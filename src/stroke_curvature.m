function finalStrokeCurvature = stroke_curvature(imagePath)
% STROKE_CURVATURE: Measures stroke bending degree.

%% Load Image
grayImg = rgb2gray(imread(imagePath));
bwImg = imbinarize(grayImg);
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'EulerNumber');
curvatureScore = mean([stats.EulerNumber]);

%% Classification
if curvatureScore < -5
    classification = 'Highly Curved';
elseif curvatureScore < 0
    classification = 'Moderately Curved';
else
    classification = 'Mostly Straight';
end

finalStrokeCurvature = struct('Score', curvatureScore, 'Type', classification);
end