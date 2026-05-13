function allChars = task3SegmentCharacters(row)
%Now we have to segment the characters on each row 

% Logical format, to ensure that is work in black and white 
row = logical(row);

% Vertical proyection. For each column how many pixels of character we have
% We have a matrix where the zeros are spaces and the non zeros letters.
charProyection = sum(row, 1);

%To detect zones where we have characters => Get a vector per row w/ spaces
%and characters
threshold=0;
binaryProyection = charProyection > threshold;

% %PARA COMRPOBAR LUEGO QUITAR 
% figure();
% plot(binaryProyection);
% title('Proyection');

%Detection of characters
%diff get the difference beetween to consecutive elements: x(2)-x(1)
d = diff([0 binaryProyection 0]);
%Create a vector with the start and end positions
startChar = find(d==1);
endChar = find(d==-1) - 1;  %d=-1 because the dif should be negative. We substract one because the diff reduce one element of the vector so we will have the end character in the previous position
%find will return the positions. Inicio y final de cada bloque i

%We add a margin to avoid the 'cutted' characters
startCharMargin = max(startChar - 1,1); %We reassign the positions substracting 1 to the startChar and start to segment on this position
endCharMargin   = min(endChar + 1,size(row,2)); %We increase the endChar and compare it with the maximum size of the row to see if it is the last. 


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


%Setting a width and get the mean of all
% widths = endCharMargin-startCharMargin;
% Lucía changed this because it inflates every width, due to the added margin
widths   = endChar - startChar + 1;
avgWidth = mean(widths);
gaps=startChar(2:end) - endChar(1:end-1); %dist entre dos letras consecutivos
spaceThreshold= 1.5*mean(gaps);%si el espacio entre characteres es mayor que esto LO CONSIDERAMOS ESPACIO
%ponemos 1.5 porque el espacio entre palabras > espacio entre letras
k = 1;

%For loop in order to get 
for i = 1:numChars
    width = widths(i);

    %Compare the width
    if width > 1.5 * avgWidth
        
        %Round the cut where we divide the characters and store it
        cut = round((startCharMargin(i)+endCharMargin(i))/2)-1; %quit the -1????
        
        chars{k} = row(:, startCharMargin(i):cut);
        k = k+1;

        %Overlapping segment
        chars{k} = row(:, cut-1:endCharMargin(i));
        % LUCIA: Starting at (cut) gives a clean 1-column overlap
        % that is sufficient to avoid stroke loss.
        % chars{k} = row(:, cut:endCharMargin(i));
        k = k+1;

    else
        chars{k} = row(:, startCharMargin(i):endCharMargin(i));
        k= k+1;
    end

    %%andrea added this, to identify spaces between words
    if i<numChars %si todavia quedan characters qu eprocesar
        gap=startChar(i+1) - endChar(i); %la diferencia entre donde empieza la siguiente letra y donde termina la actual 
        if gap > spaceThreshold %si supera el threshold: condideramos espacio
            chars{k} = 'SPACE'; %en vez de meter al cell array la imagen metemos eso para distinguir
            k=k+1;
        end
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
