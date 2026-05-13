function recognizedString = runOCR(imageFile)

%%TASK1. BINARIZATION

imBinarized = task1BinarizationAdvanced(imageFile); %otsu finds optimal threshold (lower threshold, lineas mas finas, capta menos)

%%TASK2. SEGMENTING ROWS

% Method: vertical projection
% Sum image rows to detect text lines
rowProjection = task2RowProjection(imBinarized); 
[rowStarts, rowEnds, rowMask] = task2SegmentRows(imBinarized);
rowImages = task2ExtractRows(imBinarized, rowStarts, rowEnds);

%%TASK3. SEGMENTING CHARACTERS
numRows = length(rowImages);
allChars = cell(numRows, 1); %por que nuestra funcion trabaja con celdas y rowImages es una matriz
for i= 1:numRows
    characterInd = task3SegmentCharacters(rowImages{i});
    allChars{i} = characterInd;
end

%%TASK4. PREPROCESSING CHARACTERS
imageResized = task4PreprocessingCharacters(allChars,32);

%%TASK5. CREATING ALPHABET
[alphabet, alphabetChars] = task5CreatingAlphabet('alphabet.png', 32, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');

%%TASK6. RECOGNITION
recognizedText = cell(numRows,1); %store recognized text of each row, cell porque cada fila puede tener distinto num de letras

for i = 1:numRows %itero sobre cada fila
    charsRow = imageResized{i};   %contains all chars from row i

    numChars = length(charsRow);
    letters = char(zeros(1, numChars)); %preallocate for speed
    
    for j = 1:numChars %itero sobre los characteres de cada fila
        imageCharacter = charsRow{j};   % imagen del char

        %SI ES ESPCIO no me hace falta ir a task6 a comparar con el
        %alphabeto!! pongo directamente el espacio
        if ischar(imageCharacter) && strcmp(imageCharacter, 'SPACE')
            letters(j) = ' ';
        else
            [letter, score] = task6RecognizeCharacters(imageCharacter, alphabet);
        
            letters(j) = letter; %concatenation of all letters in a row 
        end
    end
    
    recognizedText{i} = letters; %puts all rows togeteher in a text
end

%%disp('Recognized text:')
%%disp(recognizedText)

%HAGO ESTO POR QUE COMPARETEXTS SOLO TRABAJA CON STRINGS!!!
recognizedString = strjoin(recognizedText); %UNE TODOS LOS ELEMENTOS DE LA CELDA EN UN STRING
end