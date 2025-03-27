function finalPressureScore = pressure_pattern(imagePath)
% PRESSURE_PATTERN: Evaluates handwriting pressure intensity.

%% Load & Convert Image
grayImg = rgb2gray(imread(imagePath));
pressureScore = mean(grayImg(:));

%% Classification
if pressureScore < 100
    classification = 'Light Pressure';
elseif pressureScore < 180
    classification = 'Moderate Pressure';
else
    classification = 'Heavy Pressure';
end

finalPressureScore = struct('Score', pressureScore, 'Type', classification);
end
