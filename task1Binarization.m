function imOut = task1Binarization(imgPath, threshold)
% Goal ➔ convert image into logical (false: black, true: white).
% • Read image (RGB/grayscale).
% • Apply a reasoned threshold. (0-1)
% • Invert the image (to get character pixels into "active/true").

% Advanced option: compute threshold from image. Is there any matlab
% function? Can you find any algorithm for this (find documentation and give references).
img = imread(imgPath);
if size(img, 3) == 3
   img = rgb2gray(img); %if RGB, convert to gray
end
   img = im2double(img); %convert to double
   %apply binarization
   imOut = ~imbinarize(img, threshold); % white background → dark text → invert logic
    %other method => BW = img < threshold; 
   figure; imshow(imOut); %SOLO PARA TESTEO, QUITAR LUEGO

end