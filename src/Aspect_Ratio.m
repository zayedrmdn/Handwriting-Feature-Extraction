function result = Aspect_Ratio(imagePath)
% ASPECT_RATIO: Computes the maximum aspect ratio (width/height) of merged bounding boxes 
% for signature analysis.

%% --- Tweakable Parameters ---
medianFilterSize       = [5 5];      % Median filter kernel size
adaptiveSensitivity    = 0.7;        % Sensitivity for adaptive binarization
bwareaopenThreshold    = 30;         % Minimum object area to retain
verticalThreshold      = 30;         % Vertical grouping threshold for bounding boxes
horizontalGapThreshold = 30;         % Horizontal gap threshold for merging boxes
aspectRatioThreshold   = 5;          % Classification threshold for aspect ratio

%% --- Step 1: Image Acquisition & Preprocessing ---
Image = imread(imagePath);
if size(Image, 3) == 3
    grayImage = rgb2gray(Image);
else
    grayImage = Image;
end

filteredImage = medfilt2(grayImage, medianFilterSize);
binaryImage = imbinarize(filteredImage, 'adaptive', 'Sensitivity', adaptiveSensitivity);
cleanImage = bwareaopen(binaryImage, bwareaopenThreshold);

%% --- Step 2: Feature Extraction ---
bw = ~cleanImage;  % Invert image so that strokes are white
props = regionprops(bw, 'BoundingBox');

if isempty(props)
    maxAspectRatio = NaN;
    classification  = 'No Content';
    mergedLineBoxes = [];
else
    bboxes = cat(1, props.BoundingBox);
    
    % Group bounding boxes by vertical alignment (line grouping)
    lines = {};
    for i = 1:size(bboxes, 1)
        box = bboxes(i, :);
        centerY = box(2) + box(4)/2;
        added = false;
        for j = 1:length(lines)
            lineY = lines{j}(1,2) + lines{j}(1,4)/2;
            if abs(centerY - lineY) < verticalThreshold
                lines{j} = [lines{j}; box];
                added = true;
                break;
            end
        end
        if ~added
            lines{end+1} = box;
        end
    end

    % Merge horizontally close boxes within each line
    mergedLineBoxes = [];
    for k = 1:length(lines)
        lineBoxes = lines{k};
        [~, sortIdx] = sort(lineBoxes(:,1));
        lineBoxes = lineBoxes(sortIdx, :);
        currentBox = lineBoxes(1, :);
        for i = 2:size(lineBoxes, 1)
            nextBox = lineBoxes(i, :);
            currentRight = currentBox(1) + currentBox(3);
            nextLeft = nextBox(1);
            if nextLeft - currentRight <= horizontalGapThreshold
                x1 = min(currentBox(1), nextBox(1));
                y1 = min(currentBox(2), nextBox(2));
                x2 = max(currentBox(1)+currentBox(3), nextBox(1)+nextBox(3));
                y2 = max(currentBox(2)+currentBox(4), nextBox(2)+nextBox(4));
                currentBox = [x1, y1, x2-x1, y2-y1];
            else
                mergedLineBoxes = [mergedLineBoxes; currentBox];
                currentBox = nextBox;
            end
        end
        mergedLineBoxes = [mergedLineBoxes; currentBox];
    end
    
    aspectRatios = mergedLineBoxes(:,3) ./ mergedLineBoxes(:,4);
    maxAspectRatio = max(aspectRatios);
    
    if maxAspectRatio < aspectRatioThreshold
        classification = 'Low Aspect Ratio';
    else
        classification = 'High Aspect Ratio';
    end
end

%% --- Visualization ---
figure('Name', 'Aspect Ratio Feature Extraction', 'NumberTitle', 'off', 'Position', [300, 100, 1000, 700]);
subplot(2,3,1); imshow(Image); title('1. Original Image');
subplot(2,3,2); imshow(grayImage); title('2. Grayscale Image');
subplot(2,3,3); imshow(filteredImage); title('3. Median Filtered');
subplot(2,3,4); imshow(binaryImage); title('4. Adaptive Binarization');
subplot(2,3,5); imshow(cleanImage); title('5. Morphologically Cleaned');
subplot(2,3,6); imshow(bw); title('6. Detected Strokes & Merged Boxes'); hold on;
for i = 1:numel(props)
    rectangle('Position', props(i).BoundingBox, 'EdgeColor', [0,1,0], 'LineWidth', 1);
end
for i = 1:size(mergedLineBoxes, 1)
    rectangle('Position', mergedLineBoxes(i,:), 'EdgeColor', 'r', 'LineWidth', 2);
end
hold off;

%% Return Result
result = struct('Result', maxAspectRatio, 'Type', classification);
end
