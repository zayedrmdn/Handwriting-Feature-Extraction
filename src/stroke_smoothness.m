function finalStrokeSmoothness = stroke_smoothness(imagePath)
% STROKE_SMOOTHNESS: Analyzes fluidity of strokes.

%% Load Image
grayImg = rgb2gray(imread(imagePath));
bwImg = imbinarize(grayImg);
edges = edge(bwImg, 'Sobel');
smoothnessScore = sum(edges(:)) / numel(edges);

%% Classification
if smoothnessScore < 0.05
    classification = 'Very Smooth';
elseif smoothnessScore < 0.1
    classification = 'Moderately Smooth';
else
    classification = 'Rough';
end

finalStrokeSmoothness = struct('Score', smoothnessScore, 'Type', classification);
end