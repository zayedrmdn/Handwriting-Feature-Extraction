function finalStrokeThickness = stroke_thickness(imagePath)
% STROKE_THICKNESS: Determines average stroke width.

%% Load Image
grayImg = rgb2gray(imread(imagePath));
bwImg = ~imbinarize(grayImg);
cc = bwconncomp(bwImg);
stats = regionprops(cc, 'MajorAxisLength');
thicknessScore = mean([stats.MajorAxisLength]);

%% Classification
if thicknessScore < 2
    classification = 'Thin Strokes';
elseif thicknessScore < 5
    classification = 'Moderate Strokes';
else
    classification = 'Thick Strokes';
end

finalStrokeThickness = struct('Score', thicknessScore, 'Type', classification);
end
