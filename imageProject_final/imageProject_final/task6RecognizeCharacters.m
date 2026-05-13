function [letter, score] = task6RecognizeCharacters(img, alphabet)
    % INPUT PARAMETERS:
    %   -img: segmented character (from Task 4)
    %   -alphabet: struct of alphabet, each a 32x32 template
    % OUTPUT PARAMETERS:
    %   - letter: predicted character (or '?' if low confidence)
    %   - score: similarity score: best corr2 similarity score in [-1, 1]

    charNorm = imresize(im2double(img), [32 32]);
    letters = fieldnames(alphabet);
% 'ABCDEFGHIJKLMNOPQRSTUVWXYZ': define search space
    n = length(letters);
    scores = -inf(1, n); %preallocate for speed,inf stays for empty templates
    
    for k = 1:n %iterate over each possible letter
         %skip missing templates (score remains 0)
        if isempty(alphabet.(letters{k}))
            continue;
        end
        ref = imresize(im2double(alphabet.(letters{k})), [32 32]);  % Get reference template from struct
        % and resize to ensure same size
        
        % 2-D normalised cross-correlation coefficient (range [-1, 1]).
        % corr2 is scale-invariant: mean-centres and unit-normalises both        % -Output range: [-1, 1]
        % Independent of image size
        scores(k) = corr2(charNorm, ref);
    end
    % Sort all 26 scores descending; keep top-2 for confidence gap check
    [sortedScores, idxs] = sort(scores, 'descend');
    
    best = sortedScores(1); %select best match
    second = sortedScores(2);

    %TO PLOT OUR SEGMENTATIONS LUEGO BORRAR
    if letters{idxs(1)} == 'D' && letters{idxs(2)} == 'O'

    figure;

    subplot(1,3,1)
    imshow(charNorm)
    title('Segmented Character')

    subplot(1,3,2)
    imshow(alphabet.D)
    title('Template D')

    subplot(1,3,3)
    imshow(alphabet.O)
    title('Template O')

    end

    %To check the scores of the letters
     % disp(['BEST: ' letters{idxs(1)} ' ' num2str(sortedScores(1))])
     % disp(['SECOND: ' letters{idxs(2)} ' ' num2str(sortedScores(2))])

    letter = letters{idxs(1)}; %map from index to letter 
    secondLetter = letters{idxs(2)};
    score  = best;

    % Confidence check
    % if best < 0.3 || (best - second) < 0.03 % confidence threshold   %andrea changed these thresholds!!!!!!
    %Try changes => to a threshold less strict 
    if best < 0.2  || (best-second)<0.005 %Diego change this
        letter = '?';   % low confidence threshold - instead of silently propagating a wrong letter
        warning('Low confidence recognition (score=%.2f)', score);
    end
   
    %Diego add this
    %Specific cases for the letters previously identified characters that were interchanged.
    % Lucía improved comparison with function strcmp instead of ==
    diffScore = abs(best-second);

    %O-D Confusion
    if strcmp(letter, 'D') && strcmp(secondLetter, 'O') && diffScore < 0.08
        letter = 'O';
    end
    
    %O-C Confusion 
    if strcmp(letter,'C') && strcmp(secondLetter, 'O') && diffScore < 0.04
        letter = 'O';
    end

    %B-S Confusion
      if strcmp(letter, 'B') && strcmp(secondLetter, 'S') && diffScore < 0.01
        letter = 'S';
      end
end