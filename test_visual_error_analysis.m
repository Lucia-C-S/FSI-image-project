% =========================================================================
% TEST: VISUAL ERROR ANALYSIS
% Builds a 26×26 confusion matrix from all test images, then:
%   1. Displays a colour-scaled heatmap (predicted vs true label)
%   2. Saves a labelled montage of every misclassified character patch
%
% OUTPUTS:
%   - Figure 1 : confusion matrix heatmap (log-scaled for readability)
%   - Figure 2 : montage grid — each cell shows the image patch with
%                the label "True→Pred" underneath
%   - confmat.csv  : raw confusion matrix (rows=true, cols=predicted)
%   - misclassified_montage.png : saved PNG of the montage figure
% =========================================================================

clear; clc; close all;

fprintf('=== VISUAL ERROR ANALYSIS ===\n\n');

% -------------------------------------------------------------------------
% CONFIGURATION
% -------------------------------------------------------------------------
TEST_IMAGES = { ...
    'test1.png', ...
    'test2.png', ...
    'test3.png', ...
    'test4.png', ...
    'test5.png', ...
    'test6.png'  ...
};

GT_TEXTS = { ...
    'THE DOG STOOD ON THE OLD ROAD BESIDE THE CLOCK', ...
    'TOM AND ANNA SAT BESIDE THE SMALL BLACK TABLE', ...
    'PABLO PAINTED A HAPPY BIRD WITH WHITE INK', ...
    'OSCAR CLOSED THE COLD OFFICE DOOR CAREFULLY', ...
    'EL BANCO BLANCO ESTABA BAJO LA SOMBRA DEL BOSQUE', ...
    'WILLIAM HID THE PAPER INSIDE THE BIG BOX'
};

ALPHABET_IMAGE   = 'alphabet.png';
MONTAGE_OUT_FILE = 'misclassified_montage.png';
CONFMAT_CSV_FILE = 'confmat.csv';

% Maximum misclassified examples to show per (true, predicted) pair in the
% montage; keeping this low prevents the figure from becoming unreadable.
MAX_EXAMPLES_PER_PAIR = 2;

% Normalised patch size for the montage (pixels per character thumbnail)
THUMB_SIZE = 48;

% -------------------------------------------------------------------------
% SAFETY CHECKS
% -------------------------------------------------------------------------
assert(isfile(ALPHABET_IMAGE), 'Alphabet image not found: "%s"', ALPHABET_IMAGE);
assert(length(TEST_IMAGES) == length(GT_TEXTS), ...
    'TEST_IMAGES and GT_TEXTS must have the same length.');

numImages = length(TEST_IMAGES);
LETTERS   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
nL        = 26;

% -------------------------------------------------------------------------
% BUILD ALPHABET
% -------------------------------------------------------------------------
fprintf('Building alphabet...\n');
[alphabet, ~] = task5CreatingAlphabet(ALPHABET_IMAGE, 32, LETTERS);
fprintf('Done.\n\n');

% -------------------------------------------------------------------------
% STORAGE
% confMat(i,j) = number of times letter i was predicted as letter j
% letterIdx('A') = 1, ..., letterIdx('Z') = 26
% -------------------------------------------------------------------------
confMat = zeros(nL, nL);   % rows = true class, columns = predicted class

% misExamples: cell(nL, nL) — each cell holds up to MAX_EXAMPLES_PER_PAIR
% image patches (32×32 logical) for that (true, pred) pair
misExamples = cell(nL, nL);

% -------------------------------------------------------------------------
% PIPELINE LOOP — collect (true label, predicted label, patch) triples
% -------------------------------------------------------------------------
for imgIdx = 1:numImages
    imgPath = TEST_IMAGES{imgIdx};
    gtText  = upper(GT_TEXTS{imgIdx});
    gtText  = gtText(gtText ~= ' ');   % flat char vector

    fprintf('Processing image %d/%d: "%s"\n', imgIdx, numImages, imgPath);

    if ~isfile(imgPath)
        fprintf('  [SKIP] File not found.\n');
        continue;
    end

    % --- Task 1 ---
    imBin = task1BinarizationAdvanced(imgPath);

    % --- Task 2 ---
    [rowStarts, rowEnds, ~] = task2SegmentRows(imBin);
    if isempty(rowStarts)
        fprintf('  [SKIP] No rows detected.\n');
        continue;
    end
    rowImages = task2ExtractRows(imBin, rowStarts, rowEnds);

    % --- Task 3 ---
    numRows  = length(rowImages);
    allChars = cell(numRows, 1);
    for r = 1:numRows
        allChars{r} = task3SegmentCharacters(rowImages{r});
    end

    % --- Task 4 ---
    imageResized = task4PreprocessingCharacters(allChars, 32);

    % --- Task 6: recognition + confusion accumulation ---
    % We need to align predictions to GT using Levenshtein to correctly
    % attribute each patch to a true label even when insertions/deletions
    % shift the position.

    % Build flat list of (patch, predicted_letter) pairs
    patches  = {};
    predVec  = '';
    for r = 1:numRows
        charsRow = imageResized{r};
        for j = 1:length(charsRow)
            [letter, ~] = task6RecognizeCharacters(charsRow{j}, alphabet);
            patches{end+1}  = charsRow{j};   %#ok<AGROW>
            predVec(end+1)  = letter;         %#ok<AGROW>
        end
    end

    % Align GT and predictions (Levenshtein back-trace)
    [alignGT, alignPred, alignPatches] = levenshteinAlignWithPatches( ...
                                             gtText, predVec, patches);

    % Fill confusion matrix
    for c = 1:length(alignGT)
        gChar = alignGT(c);
        pChar = alignPred(c);

        % Skip gap-only entries (pure insertions with no GT counterpart)
        if gChar == '-' || ~isLetter(gChar) || ~isLetter(pChar)
            continue;
        end

        trueIdx = gChar  - 'A' + 1;   % 1-based index into LETTERS
        predIdx = pChar  - 'A' + 1;

        confMat(trueIdx, predIdx) = confMat(trueIdx, predIdx) + 1;

        % Store the patch for misclassified pairs (up to MAX_EXAMPLES_PER_PAIR)
        if trueIdx ~= predIdx && ~isempty(alignPatches{c})
            if size(misExamples{trueIdx, predIdx}, 1) < MAX_EXAMPLES_PER_PAIR
                misExamples{trueIdx, predIdx}{end+1} = alignPatches{c};
            end
        end
    end
end

fprintf('\nConfusion matrix built.\n');

% -------------------------------------------------------------------------
% METRICS DERIVED FROM CONFUSION MATRIX
% -------------------------------------------------------------------------
totalPredicted = sum(confMat(:));   % total characters classified
correct        = sum(diag(confMat));
overallAcc     = correct / max(totalPredicted, 1) * 100;

fprintf('Total characters evaluated : %d\n', totalPredicted);
fprintf('Correctly classified       : %d\n', correct);
fprintf('Overall accuracy           : %.2f %%\n\n', overallAcc);

% Per-class precision, recall, F1
fprintf('%-4s %8s %8s %8s %8s\n', 'Let', 'TP', 'Recall', 'Precis', 'F1');
fprintf('%s\n', repmat('-', 1, 42));
for k = 1:nL
    tp  = confMat(k, k);
    fn  = sum(confMat(k, :)) - tp;   % true class k predicted as other
    fp  = sum(confMat(:, k)) - tp;   % other classes predicted as k
    rec = tp / max(tp + fn, 1);
    pre = tp / max(tp + fp, 1);
    f1  = 2*pre*rec / max(pre + rec, eps);
    fprintf('  %c  %8d %8.3f %8.3f %8.3f\n', LETTERS(k), tp, rec, pre, f1);
end
fprintf('%s\n', repmat('-', 1, 42));

% -------------------------------------------------------------------------
% SAVE CONFUSION MATRIX AS CSV
% -------------------------------------------------------------------------
fid = fopen(CONFMAT_CSV_FILE, 'w');
% Header row
fprintf(fid, 'True\\Pred');
for k = 1:nL;  fprintf(fid, ',%c', LETTERS(k));  end
fprintf(fid, '\n');
% Data rows
for i = 1:nL
    fprintf(fid, '%c', LETTERS(i));
    for j = 1:nL;  fprintf(fid, ',%d', confMat(i,j));  end
    fprintf(fid, '\n');
end
fclose(fid);
fprintf('\nConfusion matrix saved to "%s"\n', CONFMAT_CSV_FILE);

% =========================================================================
% FIGURE 1: CONFUSION MATRIX HEATMAP
% =========================================================================
figure('Name', 'Confusion Matrix Heatmap', 'Position', [50 50 820 720]);

% Log-scale the count for display so rare errors are still visible.
% confMatDisp: replace 0 with NaN so they render as a distinct (white) colour.
confMatDisp = double(confMat);
confMatDisp(confMatDisp == 0) = NaN;
confMatLog  = log10(confMatDisp);   % NaN stays NaN

imagesc(confMatLog, 'AlphaData', ~isnan(confMatLog));
set(gca, 'Color', [1 1 1]);   % white background for zero cells
colormap(flipud(hot));         % white=low, dark red=high
cb = colorbar;
cb.Label.String = 'log_{10}( count )';

% Overlay the raw count as text for every non-zero cell
for i = 1:nL
    for j = 1:nL
        v = confMat(i, j);
        if v > 0
            % White text on dark cells, black on light cells
            textCol = [0 0 0];
            if v >= max(confMat(:)) * 0.6;  textCol = [1 1 1];  end
            text(j, i, num2str(v), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment',   'middle', ...
                 'FontSize', 6, 'Color', textCol);
        end
    end
end

set(gca, 'XTick', 1:nL, 'XTickLabel', cellstr(LETTERS(:)), ...
         'YTick', 1:nL, 'YTickLabel', cellstr(LETTERS(:)), ...
         'FontSize', 8);
xlabel('Predicted Label');
ylabel('True Label');
title(sprintf('Confusion Matrix  |  Overall accuracy: %.1f %%', overallAcc));
axis square;

% =========================================================================
% FIGURE 2: MONTAGE OF MISCLASSIFIED CHARACTERS
% =========================================================================

% Collect all (trueIdx, predIdx, patch) triples where trueIdx ≠ predIdx
montageItems = {};   % each cell: {patchImg, labelString}

for i = 1:nL
    for j = 1:nL
        if i == j;  continue;  end
        examples = misExamples{i, j};
        for e = 1:length(examples)
            patch = examples{e};
            lbl   = sprintf('%c→%c', LETTERS(i), LETTERS(j));
            montageItems{end+1} = {patch, lbl}; %#ok<AGROW>
        end
    end
end

if isempty(montageItems)
    fprintf('\nNo misclassified examples to show in montage.\n');
else
    nItems   = length(montageItems);
    nCols    = min(nItems, 13);   % at most 13 per row (one per letter pair)
    nRows    = ceil(nItems / nCols);

    % Build a large canvas: each cell is THUMB_SIZE×THUMB_SIZE pixels,
    % plus 14 pixels at the bottom for the text label.
    LABEL_H  = 14;
    cellH    = THUMB_SIZE + LABEL_H;
    cellW    = THUMB_SIZE;
    canvas   = ones(nRows * cellH, nCols * cellW, 'uint8') * 200; % grey bg

    for idx = 1:nItems
        row = ceil(idx / nCols);
        col = mod(idx - 1, nCols) + 1;
        rStart = (row-1)*cellH + 1;
        cStart = (col-1)*cellW + 1;

        patch = montageItems{idx}{1};
        % Resize patch to thumbnail size
        thumb = imresize(uint8(~patch) * 255, [THUMB_SIZE THUMB_SIZE]);
        canvas(rStart : rStart+THUMB_SIZE-1, cStart : cStart+cellW-1) = thumb;
        % (Label text is rendered via text() in the figure below)
    end

    figM = figure('Name', 'Misclassified Characters Montage', ...
                  'Position', [100 100 min(nCols*60,1300) nRows*70+60]);
    imshow(canvas, [0 255]);
    hold on;

    % Overlay text labels under each thumbnail
    for idx = 1:nItems
        row    = ceil(idx / nCols);
        col    = mod(idx - 1, nCols) + 1;
        lbl    = montageItems{idx}{2};
        xC     = (col - 0.5) * cellW;
        yLabel = row * cellH - LABEL_H/2;   % pixel row of label centre
        text(xC, yLabel, lbl, ...
             'Color', 'red', 'FontSize', 7, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
    hold off;
    title(sprintf('Misclassified Examples  (%d total)', nItems), ...
          'FontSize', 11);

    % Save PNG
    exportgraphics(figM, MONTAGE_OUT_FILE, 'Resolution', 150);
    fprintf('Montage saved to "%s"\n', MONTAGE_OUT_FILE);
end

% =========================================================================
% LOCAL HELPERS
% =========================================================================

function tf = isLetter(c)
    % Returns true if c is an uppercase letter A-Z
    tf = c >= 'A' && c <= 'Z';
end

function [alignA, alignB, alignPatch] = levenshteinAlignWithPatches(a, b, patches)
    % Levenshtein alignment that also tracks which patch corresponds to
    % each position in the predicted string.
    %
    % INPUTS:
    %   a       : GT string (length m)
    %   b       : predicted string (length n)
    %   patches : cell(1,n) of image patches matching b
    % OUTPUTS:
    %   alignA,B    : aligned strings (gaps = '-')
    %   alignPatch  : cell(1, len(aligned)) — patch for each aligned pos
    %                 (empty {} where a gap was inserted)

    m = length(a);
    n = length(b);

    % DP cost matrix
    D = zeros(m+1, n+1);
    for i = 1:m+1;  D(i,1) = i-1;  end
    for j = 1:n+1;  D(1,j) = j-1;  end
    for i = 2:m+1
        for j = 2:n+1
            cost    = (a(i-1) ~= b(j-1));
            D(i,j)  = min([ D(i-1,j)+1, D(i,j-1)+1, D(i-1,j-1)+cost ]);
        end
    end

    % Back-trace
    alignA = '';   alignB = '';   alignPatch = {};
    i = m+1;       j = n+1;

    while i > 1 || j > 1
        if i > 1 && j > 1 && D(i,j) == D(i-1,j-1) + (a(i-1)~=b(j-1))
            alignA     = [a(i-1) alignA];
            alignB     = [b(j-1) alignB];
            patchHere  = {};
            if j-1 <= length(patches);  patchHere = {patches{j-1}};  end
            alignPatch = [patchHere, alignPatch];
            i = i-1;  j = j-1;
        elseif i > 1 && D(i,j) == D(i-1,j) + 1
            alignA     = [a(i-1) alignA];
            alignB     = ['-'    alignB];
            alignPatch = [{[]},  alignPatch];   % deletion: no patch
            i = i-1;
        else
            alignA     = ['-'    alignA];
            alignB     = [b(j-1) alignB];
            patchHere  = {};
            if j-1 <= length(patches);  patchHere = {patches{j-1}};  end
            alignPatch = [patchHere, alignPatch];
            j = j-1;
        end
    end
end
