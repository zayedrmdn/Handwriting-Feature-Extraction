function result = stroke_detection(imagePath)
% STROKE_DETECTION: Measures stroke connectivity for print vs. cursive classification.

%% -------------------- TWEAKABLE PARAMETERS --------------------
% Minimum component area (removes noise)
minComponentArea = 30;  

% Classification threshold (adjusted for print vs cursive)
connectivityThreshold = 550;  

% Display settings
showConnectedComponents = true;  
%% -------------------------------------------------------------

% Check if file exists
if ~isfile(imagePath)
    error('File not found: %s', imagePath);
end

fprintf('Processing image: %s\n', imagePath);

%% Load Image
img = imread(imagePath);

% Convert to grayscale and binarize
grayImg = rgb2gray(img);
bwImg = imbinarize(grayImg);

% Remove small noise
bwImg = bwareaopen(~bwImg, minComponentArea);
bwImg = ~bwImg;

%% Compute Connected Components
cc = bwconncomp(~bwImg);
stats = regionprops(cc, 'Area');

% Extract component sizes
componentAreas = [stats.Area];

% Handle case where no components are detected
if isempty(componentAreas)
    avgComponentSize = NaN;
    strokeType = 'Unknown';
else
    avgComponentSize = median(componentAreas);
    
    % Classification Based on Connectivity
    if avgComponentSize > connectivityThreshold
        strokeType = 'Cursive (High Connectivity)';
    else
        strokeType = 'Print (Low Connectivity)';
    end
end

%% Visualization
if showConnectedComponents
    labeledImg = labelmatrix(cc);
    figure; imshow(label2rgb(labeledImg, 'jet', 'k', 'shuffle'));
    title('Connected Components');
end

% Display Results
fprintf('Average Component Size: %.2f pixels\n', avgComponentSize);
fprintf('Classification: %s\n', strokeType);

% Return Result to GUI
result = struct('AvgComponentSize', avgComponentSize, 'Type', strokeType);
end
