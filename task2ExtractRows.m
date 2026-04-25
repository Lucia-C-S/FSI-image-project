function rowImages = task2ExtractRows(imBin, rowStarts, rowEnds)
% Goal: Extracting each detected text row as a separate image

numRows = length(rowStarts); % Number of text lines detected
rowImages = cell(numRows, 1); % Creamos una celda columna para guardar cada recorte

figure;
for k = 1:numRows
    rowImages{k} = imBin(rowStarts(k):rowEnds(k), :); %Recorto una banda horizontal de la imagen
    
    subplot(numRows, 1, k); %Dividimos la figura en numRows partes verticales
    imshow(rowImages{k});
    title(['Row ', num2str(k)]);
end

end