function characterOut = task4PreprocessingCharacters(characterArray, N)
%Goal: convert each segmented character from task3 into a NxN image
%being characterArray a cell array with image of each segmented character

%PRESERVING ROW STRUCTURE TO FACILITATE RECOGNITION!!!

numRows=length(characterArray);
characterOut = cell(numRows, 1); %create a cell array with 1 column and as many rows as images we have

for i = 1:numRows
    currentRow = characterArray{i};
    numCharsRow = length(currentRow);
    processedRow= cell(1,numCharsRow);

for k=1:numCharsRow
    image = currentRow{k};

    [height, width]=size(image); %size of the image containing each char

    % --- BUG FIX (Bug 7) ---
    % The original code used the variable name 'diff', which shadows
    % MATLAB's built-in diff() function (used in task2 and task3).
    % Although task4 itself does not call diff(), the shadowing can cause
    % confusing "Undefined function" errors if MATLAB's workspace leaks or
    % if this function is ever called from a script where diff is needed.
    % Renamed to 'padDiff' throughout.

    if height > width
        padDiff     = height - width;
        zerosRight  = ceil(padDiff / 2);
        zerosLeft   = floor(padDiff / 2);
        imgSquare   = padarray(image,    [0 zerosLeft],  0, 'pre');
        imgSquare   = padarray(imgSquare,[0 zerosRight], 0, 'post');

    elseif width > height
        padDiff     = width - height;
        zerosTop    = ceil(padDiff / 2);
        zerosBottom = floor(padDiff / 2);
        imgSquare   = padarray(image,    [zerosTop    0], 0, 'pre');
        imgSquare   = padarray(imgSquare,[zerosBottom 0], 0, 'post');
     
     %if the image is already square
    else
        imgSquare = image;
    end
    
    % IMPROVEMENT: use nearest-neighbour interpolation for resizing instead
    % of the default bilinear.  The input is already a binary (logical) image.
    % Bilinear resize produces grey-valued pixels at stroke edges, then the
    % hard > 0.5 threshold randomly deletes thin strokes (the middle bar of E,
    % the serif of I, the diagonals of W and V).  Nearest-neighbour keeps
    % every pixel either fully black or fully white, preserving stroke integrity.
    processedRow{k} = imresize(imgSquare, [N N], 'nearest');

end
    characterOut{i} = processedRow; %adding in each iteration the WHOLE ROW of resized square images to the next pos of the cell array 
    
end

% visualizacion para debug (COMENTAR LUEGO!!!!!)

% numImShow = min(numchars, 100); %probamos con los primeros 100 o menos
% for i = 1:numImShow
%     figure();
%     imshow(characterOut{i}); %With {} = content. We need to show all the images
% end

end