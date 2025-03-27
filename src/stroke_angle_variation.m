function finalStrokeAngleVar = stroke_angle_variation(imagePath)
% STROKE_ANGLE_VARIATION: Analyzes angular consistency of strokes.

%% Load Image
grayImg = rgb2gray(imread(imagePath));
bwImg = imbinarize(grayImg);
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'Orientation');
angleVariationScore = std([stats.Orientation]);

%% Classification
if angleVariationScore < 10
    classification = 'Consistent Angles';
else
    classification = 'Inconsistent Angles';
end

finalStrokeAngleVar = struct('Score', angleVariationScore, 'Type', classification);
end