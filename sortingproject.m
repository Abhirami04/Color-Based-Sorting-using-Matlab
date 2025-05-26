% Read the input image
rgbImage = imread('leaf.jpg');

% Convert the image to LAB color space
labImage = rgb2lab(rgbImage);

% Extract the 'a' and 'b' channels (color information)
a = labImage(:,:,2);
b = labImage(:,:,3);

% Define color thresholds for different diseases
% These thresholds are approximate and should be adjusted based on your images
leafSpotThreshold = 0; % Threshold for leaf spot
rustThreshold = 20;    % Threshold for rust
otherThreshold = 40;   % Threshold for other diseases

% Create masks for different diseases
leafSpotMask = (a > leafSpotThreshold) & (b > leafSpotThreshold);
rustMask = (a > rustThreshold) & (b > rustThreshold) & ~leafSpotMask;
otherMask = (a > otherThreshold) & (b > otherThreshold) & ~leafSpotMask & ~rustMask;

% Clean up the masks (remove small noise)
leafSpotMask = bwareaopen(leafSpotMask, 100);
rustMask = bwareaopen(rustMask, 100);
otherMask = bwareaopen(otherMask, 100);

% Combine the masks to get the overall diseased area
diseasedAreaMask = leafSpotMask | rustMask | otherMask;

% Overlay the masks on the original image to visualize
resultImage = rgbImage;
resultImage(repmat(~diseasedAreaMask, [1 1 3])) = 0;

% Subtract the diseased areas from the original image
resultImageSubtracted = rgbImage;
resultImageSubtracted(repmat(diseasedAreaMask, [1 1 3])) = 0;

% Count the number of pixels for each disease
numLeafSpotPixels = nnz(leafSpotMask);
numRustPixels = nnz(rustMask);
numOtherPixels = nnz(otherMask);

% Calculate the total number of pixels in the leaf
totalLeafPixels = numel(diseasedAreaMask);

% Calculate percentages
percentageLeafSpot = (numLeafSpotPixels / totalLeafPixels) * 100;
percentageRust = (numRustPixels / totalLeafPixels) * 100;
percentageOther = (numOtherPixels / totalLeafPixels) * 100;

% Output results to the command window
fprintf('Detected Disease Information:\n');
fprintf(' - Number of Leaf Spot Pixels: %d\n', numLeafSpotPixels);
fprintf(' - Number of Rust Pixels: %d\n', numRustPixels);
fprintf(' - Number of Other Disease Pixels: %d\n', numOtherPixels);
fprintf('\n');
fprintf('Percentage of Diseased Areas:\n');
fprintf(' - Leaf Spot: %.2f%%\n', percentageLeafSpot);
fprintf(' - Rust: %.2f%%\n', percentageRust);
fprintf(' - Other Diseases: %.2f%%\n', percentageOther);

% Determine and display the dominant disease type
[diseasePixels, diseaseType] = max([numLeafSpotPixels, numRustPixels, numOtherPixels]);

fprintf('\n');
fprintf('Dominant Disease Type:\n');
if diseaseType == 1
    fprintf(' - Leaf Spot\n');
elseif diseaseType == 2
    fprintf(' - Rust\n');
else
    fprintf(' - Other\n');
end

% Create a histogram for the percentages of diseases only
figure;
% subplot(2, 2, 1);
imshow(rgbImage);
title('Original Image');

figure
% subplot(2, 2, 2);
imshow(resultImageSubtracted);
title('Detected Diseased Areas');

figure;
% subplot(2, 2, [3, 4]);
bar(1:3, [percentageLeafSpot, percentageRust, percentageOther]);
xticks(1:3);
xticklabels({'Leaf Spot', 'Rust', 'Other Diseases'});
ylabel('Percentage');
title('Percentage of Leaf Area by Disease Type');
grid on;

% Optionally, if you want to save the resulting image
imwrite(resultImageSubtracted, 'subtracted_leaf_image.jpg');