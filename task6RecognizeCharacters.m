function [letter, score] = task6RecognizeCharacters(img, alphabetDir)
    % INPUT PARAMETERS:
    %   -img: segmented character (from Task 3)
    %   -alphabetDir: folder containing templates (A.png, B.png, …)
    % OUTPUT PARAMETERS:
    %   - letter: predicted character
    %   - score: similarity score
    
    % charNormCell = task4PreprocessingCharacters({img}, 32); % apply task4 preprocessing to cell array of img
    % %  to convert each image (character) into fixed size 32x32 and double precision [0,1]
    % charNorm = im2double(charNormCell{1}); %extract unique index

    % --- Step 1: normalize single character ---
    img = im2double(img);

    [h, w] = size(img);

    if h > w
        dif = h - w;
        left  = floor(dif/2);
        right = ceil(dif/2);
        img = padarray(img, [0 left], 0, 'pre');
        img = padarray(img, [0 right], 0, 'post');

    elseif w > h
        dif = w - h;
        top    = floor(dif/2);
        bottom = ceil(dif/2);
        img = padarray(img, [top 0], 0, 'pre');
        img = padarray(img, [bottom 0], 0, 'post');
    end

    charNorm = imresize(img, [32 32]);


    letters = fieldnames(alphabetDir);
% 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; %define search space
    scores  = zeros(1, 26); %preallocate for speed
    
    for k = 1:26 %iterate over each possible letter
        ref = alphabetDir.(letters{k});  % Get reference template from struct
        ref = im2double(ref);
        ref = imresize(ref, [32 32]);   % ensure same size

         %skip missing templates (score remains 0)
          % --- Skip missing or empty templates ---
        if ~isfield(alphabetDir, letters{k}) || isempty(alphabetDir.(letters{k}))
            continue;
        end
        
        % normalize (zero mean, unit variance) into -1,1
        scores(k) = corr2(charNorm, ref);
    end
    
    [sortedScores, idxs] = sort(scores, 'descend');
    
    best = sortedScores(1); %select best match
    second = sortedScores(2);

    letter = letters(idxs(1)); %map from index to letter
    score  = best;

    % Confidence check
    if best < 0.5 || (best - second) < 0.055 % confidence threshold
        letter = '?';   % low confidence threshold
        warning('Low confidence recognition (score=%.2f)', score);
    end
end