function alphabet = task5CreatingAlphabet(characterArray, labels)
% TASK 5: Creating Alphabet
% Goal: create an alphabet of templates from preprocessed characters

if length(characterArray) ~= length(labels)
    error('The number of character images must match the number of labels.');
end

alphabet = struct;

for k = 1:length(labels)
    currentLabel = labels(k);
    alphabet.(currentLabel) = characterArray{k};
end

end