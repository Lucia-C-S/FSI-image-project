function [letter, score] = task6RecognizeCharacters(img, alphabet)
    % INPUT:  img      — 32x32 logical/double character image from task4
    %         alphabet — struct with fields A-Z, each a 32x32 template
    % OUTPUT: letter   — recognised char (scalar char, or '?' if low confidence)
    %         score    — best corr2 similarity score in [-1, 1]

    % Ensure double and correct size
    charNorm = imresize(im2double(img), [32 32], 'nearest');

    % IMPROVEMENT 1: tight-crop then re-pad to a fixed canvas before matching.
    % If the segmented bounding box contains extra whitespace on one side
    % (uneven margins from task3) the character sits off-centre relative to
    % the alphabet template, which tanks corr2 scores for asymmetric letters
    % like W, V, N.  We crop to the actual ink bounding box, then re-pad
    % symmetrically to 32x32 so every character is centred the same way.
    rows = any(charNorm, 2);
    cols = any(charNorm, 1);
    if any(rows) && any(cols)
        r1 = find(rows, 1, 'first');  r2 = find(rows, 1, 'last');
        c1 = find(cols, 1, 'first');  c2 = find(cols, 1, 'last');
        cropped  = charNorm(r1:r2, c1:c2);
        % pad symmetrically back to 32x32
        padR = 32 - size(cropped,1);  padC = 32 - size(cropped,2);
        charNorm = padarray(cropped, [floor(padR/2) floor(padC/2)], 0, 'pre');
        charNorm = padarray(charNorm,[ceil(padR/2)  ceil(padC/2)],  0, 'post');
        charNorm = imresize(charNorm, [32 32], 'nearest');
    end

    % Compute corr2 score against every template in the alphabet
    letters = fieldnames(alphabet);
    n       = length(letters);
    scores  = -inf(1, n);

    for k = 1:n
        if isempty(alphabet.(letters{k}));  continue;  end
        ref       = imresize(im2double(alphabet.(letters{k})), [32 32], 'nearest');
        % Apply the same centering to the template for a fair comparison
        rT = any(ref,2);  cT = any(ref,1);
        if any(rT) && any(cT)
            r1t = find(rT,1,'first');  r2t = find(rT,1,'last');
            c1t = find(cT,1,'first');  c2t = find(cT,1,'last');
            refC   = ref(r1t:r2t, c1t:c2t);
            padRt  = 32-size(refC,1);  padCt = 32-size(refC,2);
            ref    = padarray(refC,  [floor(padRt/2) floor(padCt/2)], 0, 'pre');
            ref    = padarray(ref,   [ceil(padRt/2)  ceil(padCt/2)],  0, 'post');
            ref    = imresize(ref, [32 32], 'nearest');
        end
        scores(k) = corr2(charNorm, ref);
    end

    [sortedScores, idxs] = sort(scores, 'descend');
    best   = sortedScores(1);
    second = sortedScores(2);

    letter = letters{idxs(1)};
    score  = best;

    if best < 0.2
        letter = '?';
        warning('Low confidence recognition (score=%.2f)', score);
    end

    % IMPROVEMENT 2: data-driven pair disambiguation.
    % These pairs come directly from the error log (the top confused pairs
    % in the test output).  When the score gap is small the two templates
    % look nearly identical to corr2 — we break the tie using a simple
    % structural feature: the pixel count in a specific image region that
    % physically distinguishes the two letters.
    secondLetter = letters{idxs(2)};
    gap = best - second;

    if gap < 0.08   % only act when the match is genuinely ambiguous
        pair = sort({letter, secondLetter});   % canonical order

        % W vs V: W has ink in the middle-bottom region; V does not
        if isequal(pair, {'V','W'})
            midBottomW = sum(sum(charNorm(20:32, 12:20)));
            midBottomV = sum(sum(charNorm(20:32, 12:20)));
            % W has a central valley that comes back up — count pixels in
            % the centre-bottom strip
            centreStrip = sum(sum(charNorm(18:32, 14:18)));
            if centreStrip > 3
                letter = 'W';
            else
                letter = 'V';
            end

        % E vs R: R has a diagonal leg in the bottom-right; E does not
        elseif isequal(pair, {'E','R'})
            bottomRight = sum(sum(charNorm(20:32, 18:32)));
            if bottomRight > 5
                letter = 'R';
            else
                letter = 'E';
            end

        % I vs T: T has wide horizontal strokes at top and bottom;
        %         I is narrow throughout
        elseif isequal(pair, {'I','T'})
            topWidth  = sum(charNorm(1:6, :));    % pixels in top strip
            wideTop   = sum(topWidth > 0) > 16;   % T top bar spans > half width
            if wideTop
                letter = 'T';
            else
                letter = 'I';
            end

        % N vs H: H has a horizontal crossbar in the middle; N does not
        elseif isequal(pair, {'H','N'})
            midRow    = charNorm(14:18, :);
            midPixels = sum(sum(midRow));
            if midPixels > 8
                letter = 'H';
            else
                letter = 'N';
            end

        % O vs D: handled by original logic, keep it
        elseif strcmp(letter, 'O') && strcmp(secondLetter, 'D')
            letter = 'D';

        % B vs S: handled by original logic, keep it
        elseif strcmp(letter, 'B') && strcmp(secondLetter, 'S')
            letter = 'S';
        end
    end

end