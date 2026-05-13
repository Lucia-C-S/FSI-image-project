function [rowStarts, rowEnds, rowMask] = task2SegmentRows(imBin)
% Goal: Detecting text rows using row projection after morphological joining

% Join nearby components inside the same text line
imRows = imclose(imBin, strel('rectangle', [7 25]));

% Row projection on the processed image
rowProjection = sum(imRows, 2);

% Threshold to separate text rows from background
threshold = 0.1 * max(rowProjection);
rowMask = rowProjection > threshold;

% Smooth row mask to fill small gaps
rowMask = imclose(rowMask, ones(15,1));

% Detect row start and end indices
changes = diff([0; rowMask; 0]);
rowStarts = find(changes == 1);
rowEnds = find(changes == -1) - 1;

% Remove very small detections (noise)
minHeight = 10;
validRows = (rowEnds - rowStarts + 1) >= minHeight;
rowStarts = rowStarts(validRows);
rowEnds = rowEnds(validRows);

% Show result
figure;
plot(rowProjection);
title('Detected text rows');
xlabel('Row index');
ylabel('Active pixels per row');
hold on;
plot(rowStarts, rowProjection(rowStarts), 'ro');
plot(rowEnds, rowProjection(rowEnds), 'go');
hold off;

end