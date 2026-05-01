labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
[alphabet, alphabetChars] = task5CreatingAlphabet('alphabet.jpeg', 32, labels);

correct = 0;

for k = 1:length(labels)
    
    testChar = alphabetChars{k};   % already an image
    
    [pred, score] = task6RecognizeCharacters(testChar, alphabet);
    trueLabel = labels(k);   % char

    fprintf('True: %s | Pred: %s | Score: %.2f\n', ...
    char(trueLabel), char(pred), score);

    
    if char(pred) == char(trueLabel)
        correct = correct + 1;
    end
end

accuracy = (correct / length(labels)) * 100;
fprintf('Accuracy: %d %%\n', accuracy);

