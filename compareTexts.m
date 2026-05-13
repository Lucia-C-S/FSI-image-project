function [numerrors, failedChars, accuracy, errorrate] = compareTexts(expected, recognized)

len=min(length(expected), length(recognized)); %para no acceder a posiciones que no existen

numerrors=0;
failedChars = cell(len,2);%para guardar los errores encontrados, prealocate!!
errorindex=1; %para saber en que fila guardar el siguiente error

for i=1:len
    if expected(i) ~= recognized(i) %si son distintas es que HAY ERROR
        numerrors = numerrors + 1;
        failedChars(errorindex,:) = {expected(i), recognized(i)};%cada fila tiene la letra esperada y la reconocida
        errorindex = errorindex+1;
    end

end

failedChars = failedChars(1:errorindex-1,:);%elimino las filas vacias pq no todas tienen por q tener errores

extraErrors= abs(length(expected)-length(recognized));%si tienen distinta longitud es que hay errores

numerrors=numerrors + extraErrors;

totalChars=length(expected);

%el numero de letras acertadas respecto del total
accuracy = ((totalChars-numerrors) / totalChars)*100;

%porcentaje de error
errorrate = (numerrors/totalChars)*100;

fprintf('\nFailed letters:\n');

for i = 1:size(failedChars,1) %en la columna 1 me imprime la letra correcta y en la 2 la que reconoció

    fprintf('Expected %s   Recognized %s\n', failedChars{i,1},  failedChars{i,2});

end

fprintf('Errors: %d\n', numerrors);

fprintf('Accuracy: %.2f %%\n', accuracy); %con dos decimales

fprintf('Error rate: %.2f %%\n', errorrate);



end