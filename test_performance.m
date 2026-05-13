% =========================================================================
% TEST: PERFORMANCE
% Times each of the 6 pipeline tasks using tic/toc over all test images.
% Measurements are repeated NUM_RUNS times per image to reduce jitter.
%
% OUTPUTS:
%   1. Printed timing table  (mean ± std per task, per image)
%   2. Bar chart of stage time %  (how much of total time each task uses)
%   3. Line plot overlaying accuracy on total processing time
%      (helps identify whether slower runs are also more accurate)
% =========================================================================

clear; clc; close all;

fprintf('=== PERFORMANCE TEST ===\n\n');

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
    'THEQUICKBROWNFOX', ...
    'JUMPSOVERTHELAZYDOG', ...
    'ABCDEFGHIJKLM', ...
    'NOPQRSTUVWXYZ', ...
    'HELLOWORLD', ...
    'MATLABOCR'  ...
};

ALPHABET_IMAGE = 'alphabet.jpeg';

% Number of repeated timing runs per image (median taken to suppress JIT
% warm-up noise on first call)
NUM_RUNS = 3;

% Task labels for plots
TASK_LABELS = {'T1 Binarize', 'T2 Seg Rows', 'T3 Seg Chars', ...
               'T4 Normalize', 'T5 Alphabet', 'T6 Recognize'};

% -------------------------------------------------------------------------
% SAFETY CHECKS
% -------------------------------------------------------------------------
assert(isfile(ALPHABET_IMAGE), ...
    'Alphabet image not found: "%s"', ALPHABET_IMAGE);

numImages = length(TEST_IMAGES);
assert(length(GT_TEXTS) == numImages, ...
    'TEST_IMAGES and GT_TEXTS must have the same length.');

% -------------------------------------------------------------------------
% BUILD ALPHABET (Task 5) — timed once, reused for all images
% -------------------------------------------------------------------------
fprintf('Timing Task 5 (Alphabet Creation)...\n');
t5_runs = zeros(1, NUM_RUNS);
for run = 1:NUM_RUNS
    tic;
    [alphabet, ~] = task5CreatingAlphabet(ALPHABET_IMAGE, 32, ...
                                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    t5_runs(run) = toc;
end
t5_median = median(t5_runs);
fprintf('  Task 5 median time: %.4f s\n\n', t5_median);

% -------------------------------------------------------------------------
% STORAGE: timings and accuracy per image
% timings: numImages × 6 matrix (columns = tasks 1-4, 5 fixed, 6)
% -------------------------------------------------------------------------
timings  = zeros(numImages, 6);   % mean times in seconds
timingsS = zeros(numImages, 6);   % std across runs
accPerImage = zeros(1, numImages);

% -------------------------------------------------------------------------
% MAIN TIMING LOOP
% -------------------------------------------------------------------------
for imgIdx = 1:numImages
    imgPath = TEST_IMAGES{imgIdx};
    gtFlat  = upper(GT_TEXTS{imgIdx});
    gtFlat  = gtFlat(gtFlat ~= ' ');

    fprintf('Image %d/%d: "%s"\n', imgIdx, numImages, imgPath);

    if ~isfile(imgPath)
        fprintf('  [SKIP] File not found.\n\n');
        timings(imgIdx, :)  = NaN;
        timingsS(imgIdx, :) = NaN;
        accPerImage(imgIdx) = NaN;
        continue;
    end

    % Accumulate NUM_RUNS timing samples per task
    t1_v = zeros(1, NUM_RUNS);
    t2_v = zeros(1, NUM_RUNS);
    t3_v = zeros(1, NUM_RUNS);
    t4_v = zeros(1, NUM_RUNS);
    t6_v = zeros(1, NUM_RUNS);

    for run = 1:NUM_RUNS

        % ---- TASK 1: Binarization ----------------------------------------
        tic;
        imBin = task1BinarizationAdvanced(imgPath);
        t1_v(run) = toc;

        % ---- TASK 2: Row Segmentation ------------------------------------
        tic;
        [rowStarts, rowEnds, ~] = task2SegmentRows(imBin);
        rowImages = task2ExtractRows(imBin, rowStarts, rowEnds);
        t2_v(run) = toc;
        % Note: task2ExtractRows is included in this block because
        % segmenting and slicing the row strips are conceptually one
        % stage; timing them together avoids artificial task-boundary bias.

        % ---- TASK 3: Character Segmentation ------------------------------
        tic;
        numRows  = length(rowImages);
        allChars = cell(numRows, 1);
        for r = 1:numRows
            allChars{r} = task3SegmentCharacters(rowImages{r});
        end
        t3_v(run) = toc;

        % ---- TASK 4: Normalisation ----------------------------------------
        tic;
        imageResized = task4PreprocessingCharacters(allChars, 32);
        t4_v(run) = toc;

        % ---- TASK 6: Recognition -----------------------------------------
        % (Task 5 is independent of the test image; timed separately above)
        tic;
        predText = '';
        for r = 1:numRows
            charsRow = imageResized{r};
            for j = 1:length(charsRow)
                [letter, ~] = task6RecognizeCharacters(charsRow{j}, alphabet);
                predText = [predText, letter]; %#ok<AGROW>
            end
        end
        t6_v(run) = toc;
    end

    % Take median across runs (more robust than mean against warm-up spike)
    timings(imgIdx, 1) = median(t1_v);
    timings(imgIdx, 2) = median(t2_v);
    timings(imgIdx, 3) = median(t3_v);
    timings(imgIdx, 4) = median(t4_v);
    timings(imgIdx, 5) = t5_median;        % shared; same for all images
    timings(imgIdx, 6) = median(t6_v);

    timingsS(imgIdx, 1) = std(t1_v);
    timingsS(imgIdx, 2) = std(t2_v);
    timingsS(imgIdx, 3) = std(t3_v);
    timingsS(imgIdx, 4) = std(t4_v);
    timingsS(imgIdx, 5) = std(t5_runs);
    timingsS(imgIdx, 6) = std(t6_v);

    % Character accuracy for this image (Levenshtein-based)
    accPerImage(imgIdx) = charAccuracy(gtFlat, predText);

    totalT = sum(timings(imgIdx, :));
    fprintf('  Total: %.4f s  |  Accuracy: %.1f %%\n', ...
            totalT, accPerImage(imgIdx));
    fprintf('  Per-task (s): T1=%.4f  T2=%.4f  T3=%.4f  T4=%.4f  T5=%.4f  T6=%.4f\n\n', ...
            timings(imgIdx, 1), timings(imgIdx, 2), timings(imgIdx, 3), ...
            timings(imgIdx, 4), timings(imgIdx, 5), timings(imgIdx, 6));
end

% -------------------------------------------------------------------------
% TIMING TABLE (mean ± std across all valid images)
% -------------------------------------------------------------------------
validRows = ~any(isnan(timings), 2);

if any(validRows)
    meanT = mean(timings(validRows, :), 1);   % 1×6 mean times
    stdT  = std( timings(validRows, :), 0, 1);

    fprintf('=== MEAN TIMING TABLE (over %d valid images) ===\n', ...
            sum(validRows));
    fprintf('%-16s %10s %10s %8s\n', 'Task', 'Mean (s)', 'Std (s)', 'Share (%)');
    fprintf('%s\n', repmat('-', 1, 46));
    totalMean = sum(meanT);
    for t = 1:6
        pct = meanT(t) / totalMean * 100;
        fprintf('%-16s %10.4f %10.4f %8.1f%%\n', ...
                TASK_LABELS{t}, meanT(t), stdT(t), pct);
    end
    fprintf('%s\n', repmat('-', 1, 46));
    fprintf('%-16s %10.4f\n', 'TOTAL', totalMean);

    % -----------------------------------------------------------------------
    % FIGURE 1: Bar chart — stage time share (%)
    % -----------------------------------------------------------------------
    figure('Name', 'Performance – Stage Time Share', ...
           'Position', [100 100 720 420]);

    pcts = meanT / totalMean * 100;
    b    = bar(pcts, 'FaceColor', 'flat');

    % Colour each bar differently for readability
    colours = [0.20 0.55 0.85;   % T1 blue
               0.35 0.75 0.45;   % T2 green
               0.95 0.65 0.20;   % T3 orange
               0.80 0.35 0.35;   % T4 red
               0.60 0.40 0.80;   % T5 purple
               0.30 0.70 0.80];  % T6 teal
    for t = 1:6
        b.CData(t, :) = colours(t, :);
    end

    set(gca, 'XTickLabel', TASK_LABELS, 'XTick', 1:6);
    xtickangle(30);
    ylabel('Time share (%)');
    title(sprintf('Stage Time Distribution  (total mean = %.3f s)', totalMean));
    grid on; box off;

    % Annotate bar tops with mean ± std
    for t = 1:6
        text(t, pcts(t) + 0.5, ...
             sprintf('%.3fs\n±%.3f', meanT(t), stdT(t)), ...
             'HorizontalAlignment', 'center', 'FontSize', 7.5);
    end

    % -----------------------------------------------------------------------
    % FIGURE 2: Line plot — total time and accuracy per image
    % -----------------------------------------------------------------------
    validIdx = find(validRows);
    if length(validIdx) >= 2
        totalPerImage = sum(timings(validIdx, :), 2);   % column sum per row
        accValid      = accPerImage(validIdx);

        figure('Name', 'Performance – Time vs Accuracy', ...
               'Position', [150 150 720 380]);

        yyaxis left;
        plot(1:length(validIdx), totalPerImage, 'b-o', ...
             'LineWidth', 2, 'MarkerSize', 7, 'MarkerFaceColor', 'b');
        ylabel('Total pipeline time (s)');
        ylim([0, max(totalPerImage)*1.3]);

        yyaxis right;
        plot(1:length(validIdx), accValid, 'r-s', ...
             'LineWidth', 2, 'MarkerSize', 7, 'MarkerFaceColor', 'r');
        ylabel('Character Accuracy (%)');
        ylim([0, 110]);
        yline(95, 'k--', 'LineWidth', 1, 'Label', '95% target');

        set(gca, 'XTick', 1:length(validIdx), ...
                 'XTickLabel', TEST_IMAGES(validIdx));
        xtickangle(30);
        xlabel('Test Image');
        title('Total Processing Time  vs  Recognition Accuracy');
        legend('Total time (s)', 'Accuracy (%)', 'Location', 'best');
        grid on;
    end
else
    fprintf('[WARNING] No valid images found — skipping plots.\n');
end

% =========================================================================
% LOCAL HELPER: Levenshtein-based character accuracy
% =========================================================================
function acc = charAccuracy(gt, pred)
    m = length(gt);
    n = length(pred);
    D = 0:n;
    for i = 1:m
        Dprev = D;
        D(1)  = i;
        for j = 1:n
            cost  = (gt(i) ~= pred(j));
            D(j+1) = min([Dprev(j+1)+1, D(j)+1, Dprev(j)+cost]);
        end
    end
    acc = max(0, (1 - D(n+1) / max(m,1))) * 100;
end
