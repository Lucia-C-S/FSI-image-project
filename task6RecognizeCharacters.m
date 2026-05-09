function [letter, score] = task6RecognizeCharacters(img, alphabet)
    % INPUT PARAMETERS:
    %   -img: segmented character (from Task 3)
    %   -alphabet: struct of alphabet
    % OUTPUT PARAMETERS:
    %   - letter: predicted character
    %   - score: similarity score

    % --- Step 1: normalize single character ---
    % img = im2double(img);
    % [h, w] = size(img);
    % % PADDING
    % % we convert any character image into a square image before resizing, 
    % % because distortion happens if we resize non-square images directly
    % if h > w % case image is taller than wide
    %     dif = h - w; %missing width
    %     left  = floor(dif/2);
    %     right = ceil(dif/2); %bc if d is odd we would not split equally
    %     img = padarray(img, [0 left], 0, 'pre'); %add rows on left
    %     img = padarray(img, [0 right], 0, 'post');%add rows on right
    % 
    % elseif w > h %width of image>height
    %     dif = w - h;
    %     top    = floor(dif/2);
    %     bottom = ceil(dif/2);
    %     img = padarray(img, [top 0], 0, 'pre'); %add rows on top
    %     img = padarray(img, [bottom 0], 0, 'post'); % bottom
    % end
    % 
    % charNorm = imresize(img, [32 32]);

    % charNormCell = task4PreprocessingCharacters({{img}}, 32); %cambio andrea, puse dos {{}} pq modifique tarea4
    % charNorm = im2double(charNormCell{1}{1});

    %Diego change this in order to reduce possible errors
    %Try changes!! No reproccess the characters again => more error margin
    charNorm = im2double(img);

    letters = fieldnames(alphabet);
% 'ABCDEFGHIJKLMNOPQRSTUVWXYZ': define search space
    n = length(letters);
    scores = -inf(1, n); %preallocate for speed
    
    for k = 1:n %iterate over each possible letter
         %skip missing templates (score remains 0)
        if isempty(alphabet.(letters{k}))
            continue;
        end
        ref = im2double(alphabet.(letters{k}));  % Get reference template from struct
        ref = imresize(ref, [32 32]);   % ensure same size
        
        % normalize (zero mean, unit variance) into -1,1 bc corr2 is:
        % -Output range: [-1, 1]
        % Scale invariant
        % Independent of image size
        scores(k) = corr2(charNorm, ref);
    end
    
    [sortedScores, idxs] = sort(scores, 'descend');
    
    best = sortedScores(1); %select best match
    second = sortedScores(2);

    %To check the scores of the letters
    % disp(['BEST: ' letters{idxs(1)} ' ' num2str(sortedScores(1))])
    % disp(['SECOND: ' letters{idxs(2)} ' ' num2str(sortedScores(2))])

    letter = letters{idxs(1)}; %map from index to letter  
    score  = best;

    % Confidence check
    % if best < 0.3 || (best - second) < 0.03 % confidence threshold   %andrea changed these thresholds!!!!!!
    %Try changes => to a threshold less strict 
    if best < 0.2  %|| (best-second)<0.005 %Diego change this
        letter = '?';   % low confidence threshold
        warning('Low confidence recognition (score=%.2f)', score);
    end
   
    %Diego add this
    %Specific cases for the letters previously identified characters that were interchanged.

    if letter == 'B'

    secondLetter = letters{idxs(2)};

    if secondLetter == 'S' && abs(best-second) < 0.01
        letter = 'S';
    end
    end
    if letter == 'O'

    secondLetter = letters{idxs(2)};

    if secondLetter == 'D' && abs(best-second) < 0.01
        letter = 'D';
    end
    end
    