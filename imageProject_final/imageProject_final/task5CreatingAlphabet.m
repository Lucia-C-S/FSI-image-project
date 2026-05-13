function [alphabet, alphabetChars] = task5CreatingAlphabet(alphabetImagePath, N, labels)
% Goal: create an alphabet of character templates from an alphabet image.
% input: 
% alphabetImagePath :'alphabet.png'
% N : final size of each character( 32)
% labels: character labels, ('ABCDEFGHIJKLMNOPQRSTUVWXYZ')

% output:
% alphabet: structure containing the templates (alphabet.A, alphabet.B...)
% alphabetChars -> cell array with the preprocessed character images

if nargin < 2
    N = 32;
end %if the user does not enter a value for N, we use 32 by default

if nargin < 3
    labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
end %if the user does not enter the labels, the function uses an alphabet of 26 letters by defult

% binarize the alphabet image
imAlphabet = task1BinarizationAdvanced(alphabetImagePath);

% we apply task2: segment rows
% in 'alphabet.png' two lines appear, 
% rowStarts: saves where each row starts
% rowEnds: saves where each row ends
% ignore third exit (~)
[rowStarts, rowEnds, ~] = task2SegmentRows(imAlphabet);

% extract each row, it creates two separate images
rowImages = task2ExtractRows(imAlphabet, rowStarts, rowEnds);

% segment characters in each row
numRows = length(rowImages);
allChars = cell(numRows, 1); % we create an empty cell where we are saving the characters 

for i = 1:numRows
    allChars{i} = task3SegmentCharacters(rowImages{i});
end

% preprocess characters to obtain NxN images
processedChars = task4PreprocessingCharacters(allChars, N);

% convert the result into a simple cell array
alphabetChars = flattenCharacterCells(processedChars);

% check that the number of characters matches the labels
if length(alphabetChars) ~= length(labels)
    error('Alphabet mismatch: segmented %d characters but %d labels were provided. ', length(alphabetChars), length(labels));
end
% create alphabet structure, where we save labels  
alphabet = struct;

for k = 1:length(labels)
    currentLabel = labels(k);
    alphabet.(currentLabel) = alphabetChars{k};
end

end


function flatChars = flattenCharacterCells(chars)
% Converts nested cell arrays into a simple cell array, necessary because
% characteres are separated by rows

flatChars = {}; % We create an empty cell where we are saving every character in order

if iscell(chars) % check chars is a cell
    for i = 1:numel(chars)
        if iscell(chars{i})
            innerChars = flattenCharacterCells(chars{i});
            flatChars = [flatChars innerChars];
        else
            flatChars{end + 1} = chars{i};
        end
    end
else
    error('The preprocessed characters must be stored in a cell array.');
end

end