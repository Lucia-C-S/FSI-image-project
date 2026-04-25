function characterOut = task4PreprocessingCharacters(characterArray, N)
%Goal: convert each segmented character from task3 into a NxN image
%being characterArray a cell array with image of each segmented character

numchars = length(characterArray);
characterOut = cell(numchars, 1); %create a cell array with 1 column and as many rows as images we have
 
for k=1:numchars
    image = characterArray{k};

    [height, width]=size(image); %size of the image containing each char

    %padding: ZEROS(BLACK) because is is the background (letters white)

    %if it has more height than width: add columns to make it square
    if height > width
        diff = height - width; %cuanto añado para hacerla cuadrada? la dif entre sus dimensiones!
        %add half that diff to each side, so the char stays centered!
        zerosRight= ceil(diff/2); %redondeo hacia arriba
        zerosLeft= floor(diff/2); %redondeo hacia abajo 
        %ceil en uno y floor en otro porque si uso el mismo, si diff es impar no me daria el tamaño NxN buscado
        imgSquare= padarray(image, [0 zerosLeft], 0, 'pre'); %[0 zerosLeft] adds black('0') columns at the left ('pre') of the image
        imgSquare= padarray(imgSquare, [0 zerosRight], 0, 'post');

    %if it has more width than height: add rows to make it square
    elseif width > height
        diff = width - height;
        zerosTop= ceil(diff/2);
        zerosBottom=floor(diff/2);
        imgSquare= padarray(image, [zerosTop 0], 0, 'pre'); %same as before but it adds rows here ([zerosTop 0])
        imgSquare= padarray(imgSquare, [zerosBottom 0], 0, 'post');
     
     %if the image is already square
    else
        imgSquare = image;
    end

    %resize the square image
    resizedImage = imresize(imgSquare, [N N]); %being NxN the dimensions of the output image
    characterOut{k} = resizedImage; %adding in each iteration the resized square image to the next pos of the cell array 
end

% visualizacion para debug (COMENTAR LUEGO!!!!!)
figure;
numImShow = min(numchars, 10); %probamos con los primeros 10 o menos
for i = 1:numImShow
    subplot(1, numImShow, i); %plotea una fila de tantas columnas como elementos vayamos a mostrar (max 10)
    imshow(characterOut{i});
end

end


