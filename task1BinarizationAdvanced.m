function imOut = task1BinarizationAdvanced(imagePath)
% OTSU'S METHOD: Otsu finds the threshold that minimizes intra-class
% variance (between-class variance maximized).

img = imread(imagePath);
if size(img,3) == 3
    img = rgb2gray(img); % If RGB, convert to grayscale
end

img = im2double(img);
T = graythresh(img);           % Otsu's method — returns value in [0,1]
%we use MATLAB's implementation -- EXPLAIN DEEPLY IN REPORT
fprintf('Otsu threshold: %.3f\n', T);
imOut = ~imbinarize(img, T);      % invert: text becomes true
end