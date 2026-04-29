function [letter, score] = task6RecognizeCharacters(img, alphabetDir)
    %INPUT PARAMETERS:
    %   -charImg: segmented character (from Task 3)
    %   -alphabetDir: folder containing templates (A.png, B.png, …)
    % OUTPUT PARAMETERS:
    %   - letter: predicted character
    %   - score: similarity score
    charNorm = im2double(task4PreprocessingCharacters(img, 32)); % apply task4 preprocessing
    %  to convert each characterImage into fixed size 32x32 and double precision [0,1]
    
    letters = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'; %define search space
    scores  = zeros(1, 27); %preallocate for speed
    
    for k = 1:27 %iterate over each possible letter
        refPath = fullfile(alphabetDir, [letters(k) '.png']); %build complete path, portable
        ref = imresize(ref, [32 32]);   % ensure same size

        if ~exist(refPath, 'file'); continue; end %skip missing templates (score remains 0)
        
        ref = im2double(imread(refPath)); % read existing template image, converting to double
        % normalize (zero mean, unit variance)
        ref = (ref - mean(ref(:))) / std(ref(:));
        cn  = (charNorm - mean(charNorm(:))) / std(charNorm(:));
        
        scores(k) = sum(sum(cn .* ref)); %it is faster than built-in corr2

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