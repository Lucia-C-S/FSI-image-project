function imOut = task1BinarizationAdvanced(imagePath)
% OTSU'S METHOD: Otsu finds the threshold that minimizes intra-class
% variance (between-class variance maximized).
img = im2double(rgb2gray(imread(imagePath)));
T = graythresh(img);           % Otsu's method — returns value in [0,1]
%we use MATLAB's implementation -- EXPLAIN DEEPLY IN REPORT
fprintf('Otsu threshold: %.3f\n', T);
imOut = ~imbinarize(img, T);      % invert: text becomes true
end