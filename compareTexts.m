function [numerrors, failedChars, accuracy, errorrate] = compareTexts(expected, recognized)
% compareTexts - compares expected vs recognized text using edit distance
% alignment so that one missing/extra character does NOT cascade errors to
% every subsequent position.
%
% The original version used positional comparison (expected(i) vs
% recognized(i)). If the OCR drops or inserts one character anywhere, every
% character after that point is counted as wrong even if perfectly correct.
% This inflates the error count massively for realistic OCR output.
%
% This version uses Levenshtein (edit distance) alignment: it finds the
% minimum-cost sequence of substitutions, insertions and deletions that
% transforms recognized into expected, then counts only real errors.

% strip spaces before comparing (pipeline joins rows with spaces,
% expected strings also have spaces between words)
expected   = upper(expected(expected ~= ' '));
recognized = upper(recognized(recognized ~= ' '));

m = length(expected);
n = length(recognized);

% build DP cost matrix
D = zeros(m+1, n+1);
for ii = 1:m+1;  D(ii,1) = ii-1;  end
for jj = 1:n+1;  D(1,jj) = jj-1;  end

for ii = 2:m+1
    for jj = 2:n+1
        cost = (expected(ii-1) ~= recognized(jj-1));
        D(ii,jj) = min([ D(ii-1,jj)+1, ...       % deletion  (OCR missed a char)
                          D(ii,jj-1)+1, ...       % insertion (OCR added extra char)
                          D(ii-1,jj-1)+cost ]);   % match / substitution
    end
end

% back-trace to recover aligned pairs
alignExp = '';  alignRec = '';
ii = m+1;  jj = n+1;

while ii > 1 || jj > 1
    if ii > 1 && jj > 1 && D(ii,jj) == D(ii-1,jj-1) + (expected(ii-1)~=recognized(jj-1))
        alignExp = [expected(ii-1)   alignExp];
        alignRec = [recognized(jj-1) alignRec];
        ii = ii-1;  jj = jj-1;
    elseif ii > 1 && D(ii,jj) == D(ii-1,jj) + 1
        alignExp = [expected(ii-1) alignExp];
        alignRec = ['-'            alignRec];  % deletion: OCR missed this char
        ii = ii-1;
    else
        alignExp = ['-'              alignExp];
        alignRec = [recognized(jj-1) alignRec]; % insertion: OCR added extra char
        jj = jj-1;
    end
end

% count errors from alignment
numerrors  = 0;
failedChars = {};
errorindex  = 1;

for k = 1:length(alignExp)
    e = alignExp(k);
    r = alignRec(k);
    if e ~= r
        numerrors = numerrors + 1;
        failedChars{errorindex, 1} = e;
        failedChars{errorindex, 2} = r;
        errorindex = errorindex + 1;
    end
end

if isempty(failedChars)
    failedChars = cell(0, 2);
end

totalChars = m;
accuracy   = ((totalChars - numerrors) / totalChars) * 100;
errorrate  = (numerrors / totalChars) * 100;

% print results
fprintf('\nFailed letters:\n');
for k = 1:size(failedChars, 1)
    e = failedChars{k,1};
    r = failedChars{k,2};
    if e == '-'
        fprintf('  Inserted (extra):   %s\n', r);
    elseif r == '-'
        fprintf('  Deleted  (missed):  %s\n', e);
    else
        fprintf('  Expected %s   Recognized %s\n', e, r);
    end
end

fprintf('Errors: %d\n',          numerrors);
fprintf('Accuracy: %.2f %%\n',   accuracy);
fprintf('Error rate: %.2f %%\n', errorrate);

end