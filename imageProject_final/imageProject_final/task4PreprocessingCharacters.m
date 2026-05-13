function characterOut = task4PreprocessingCharacters(characterArray, N)
%Goal: convert each segmented character from task3 into a NxN image
%being characterArray a cell array with image of each segmented character

%PRESERVING ROW STRUCTURE TO FACILITATE RECOGNITION!!!

numRows=length(characterArray);
characterOut = cell(numRows, 1); %create a cell array with 1 column and as many rows as images we have

for i = 1:numRows
    currentRow = characterArray{i};
    numCharsRow = length(currentRow);
    processedRow= cell(1,numCharsRow);

for k=1:numCharsRow
    image = currentRow{k};

    %si es un espacio no lo proceso porque padarray solo procesa
    %matrices!!!
    if ischar(image) && strcmp(image, 'SPACE')
        processedRow{k} = 'SPACE'; %en vez de comparar con el alphabet, si tenemos esto escribirá un espacio
        continue;
    end

    [height, width]=size(image); %size of the image containing each char

    %padding: ZEROS(BLACK) because is is the background (letters white)

    %if it has more height than width: add columns to make it square
    if height > width
        padDif = height - width; %cuanto añado para hacerla cuadrada? la dif entre sus dimensiones!
        %add half that diff to each side, so the char stays centered!
        zerosRight= ceil(padDif/2); %redondeo hacia arriba
        zerosLeft= floor(padDif/2); %redondeo hacia abajo 
        %ceil en uno y floor en otro porque si uso el mismo, si diff es impar no me daria el tamaño NxN buscado
        imgSquare= padarray(image, [0 zerosLeft], 0, 'pre'); %[0 zerosLeft] adds black('0') columns at the left ('pre') of the image
        imgSquare= padarray(imgSquare, [0 zerosRight], 0, 'post');

    %if it has more width than height: add rows to make it square
    elseif width > height
        padDif = width - height;
        zerosTop= ceil(padDif/2);
        zerosBottom=floor(padDif/2);
        imgSquare= padarray(image, [zerosTop 0], 0, 'pre'); %same as before but it adds rows here ([zerosTop 0])
        imgSquare= padarray(imgSquare, [zerosBottom 0], 0, 'post');
     
     %if the image is already square
    else
        imgSquare = image;
    end
    
    %resize the square image
    processedRow{k}=imresize(imgSquare, [N N]); %being NxN the dimensions of the output image
    
    %Diego add this for setting values (0.1) spaces and pixels for more as
    %we did previously in other tasks, to provide more sensitivity
    processedRow{k} = processedRow{k} > 0.5; 

end
    characterOut{i} = processedRow; %adding in each iteration the WHOLE ROW of resized square images to the next pos of the cell array 
    
end

% visualizacion para debug (COMENTAR LUEGO!!!!!)

% numImShow = min(numchars, 100); %probamos con los primeros 100 o menos
% for i = 1:numImShow
%     figure();
%     imshow(characterOut{i}); %With {} = content. We need to show all the images
% end

end


