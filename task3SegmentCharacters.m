%Now we have to segment the characters on each row 
function allChars = task3SegmentCharacters(row)

% Logical format, to ensure we work in black and white 
row = logical(row);

% IMPROVEMENT 1: morphological closing along the horizontal axis.
% Bridges tiny gaps inside a single character (e.g. the gap between the
% two diagonals of W, or thin breaks in I/T at low resolution) so they
% are not split into two blobs by the projection.
% Kernel: 1 row x 3 cols — only closes horizontal gaps, will not merge
% neighbouring characters which are separated by more than 3 columns.
row = imclose(row, strel('rectangle', [1 3]));

%Vertical proyection. For each column how many pixels of character we have
%We have a matrix where the zeros are spaces and the non zeros letters.
charProyection = sum(row, 1);

% Vertical projection: for each column, how many ink pixels exist


% IMPROVEMENT 2: use threshold=1 instead of 0.
% threshold=0 means a single noise pixel in any column opens a new blob.
% Requiring at least 2 ink pixels per column eliminates isolated noise dots
% without affecting real character strokes (which span many pixels tall).
threshold = 1;
binaryProyection = charProyection > threshold;

% Detect character blobs
d = diff([0 binaryProyection 0]);
startChar = find(d ==  1);
endChar   = find(d == -1) - 1;

% IMPROVEMENT 3: drop blobs narrower than 3 pixels — these are noise or
% scanning artifacts, not characters. Without this filter they skew avgWidth
% and cause real characters to be wrongly flagged as merged pairs.
blobWidths = endChar - startChar + 1;
validBlobs = blobWidths >= 3;
startChar  = startChar(validBlobs);
endChar    = endChar(validBlobs);

% Add a 1-pixel margin around each blob to avoid cutting edge strokes
startCharMargin = max(startChar - 1, 1);
endCharMargin   = min(endChar   + 1, size(row,2));


%Extract the characters of each row 
%The length go in blocks, not in number of letters. StartChar contain all
%the start point of the blocks
numChars = length(startCharMargin);
chars = cell(1, numChars); 

% %Iterate in all the blocks 'cutted'. For i=1 1st Char, for i=2 2nd Char...
% for i = 1:numChars
%     chars{i} = row(:, startCharMargin(i):endCharMargin(i)); %We assign to the chars variable all the characters. 
% end
% %Store all chars. 


% --- BUG FIX (Bug 5) ---
% Compute widths from the RAW (pre-margin) boundaries.
% Using endCharMargin-startCharMargin inflates every width by ~2 px,
% which biases avgWidth upward and causes the split condition to
% under-trigger (merged character pairs are missed).
widths   = endChar - startChar + 1;   % raw pixel width of each blob
avgWidth = mean(widths);
k = 1;

for i = 1:numChars
    width = widths(i);   % use raw width for the comparison

    if width > 1.5 * avgWidth
        % This blob is likely two merged characters.  Split at the midpoint.
        % We keep a 1-column overlap on the right half to avoid cutting
        % ink strokes that fall exactly on the split column.

        % Midpoint column (in margin-padded coordinates)
        cut = round((startCharMargin(i) + endCharMargin(i)) / 2);

        % Left half:  startMargin … cut  (inclusive)
        chars{k} = row(:, startCharMargin(i):cut);
        k = k + 1;

        % --- BUG FIX (Bug 6) ---
        % Original code started the right half at cut-1, so columns
        % (cut-1) and (cut) were included in BOTH halves — a 2-column
        % double-count.  Starting at (cut) gives a clean 1-column overlap
        % that is sufficient to avoid stroke loss.
        chars{k} = row(:, cut:endCharMargin(i));
        k = k + 1;

    else
        chars{k} = row(:, startCharMargin(i):endCharMargin(i));
        k = k + 1;
    end
end

allChars = chars;

%For show the characters in order to check.
% for j = 1:length(allChars)
%     figure();
%     imshow(allChars{j}); %With {} = content. We need to show all the images
%     title(['Character ' num2str(j)]);
% end

end