clear;clc;close all;

%IMPORTANTE! FORMATO: entre los corchetes 'im1.png', 'im2.png' 
%con todas las imagenes que usemos para probar
imageFiles = {'gaudeamus.png', 'origen.png', 'banco.png', 'dog.png', 'oscar.png', 'pablo.png', 'tom.png', 'willy.png','zack.png', 'computer.png', 'winter.png', 'bus.png', 'birthday.png', 'car.png', 'photo.png'};

%FORMATO: metemos el texto de cada imagen por ej 'HELLO WORLD', 'HOLA'
expectedTexts={'GAUDEAMUS IGITUR IUVENES DUM SUMUS IUVENES DUM SUMUS POST IUCUNDAM IUVENTUTEM POST MOLESTAM SENECTUTEM NOS HABEBIT HUMUS', 'MUCHO TIEMPO DESPUES FRENTE AL PELOTON DE FUSILAMIENTO EL CORONEL AURELIANO BUENDIA HABIA DE RECORDAR AQUELLA TARDE REMOTA EN QUE SU PADRE LO LLEVO A CONOCER EL HIELO',  'EL BANCO BLANCO ESTABA BAJO LA SOMBRA DEL BOSQUE', 'THE DOG STOOD ON THE OLD ROAD BESIDE THE CLOCK', 'OSCAR CLOSED THE COLD OFFICE DOOR CAREFULLY', 'PABLO PAINTED A HAPPY BIRD WITH WHITE INK', 'TOM AND ANNA SAT BESIDE THE SMALL BLACK TABLE', 'WILLIAM HID THE PAPER INSIDE THE BIG BOX', 'ZACK HIT THE CROSSBAR IN THE GAME AT THE OLD TOWN', 'THE COMPUTER SCREEN SHOWED STRANGE SYMBOLS TODAY', 'THE WINTER WIND MOVED OVER THE VALLEY', 'THE BUS STATION IS IN A BAD POSITION FOR THE VILLAGE', 'YESTERDAY WAS THE BIRTHDAY OF SO MANY PEOPLE', 'MY CAR WAS TESTED BY THE MECHANIC FOR TONIGHTS RACE', 'THE PHOTOS TAKEN DURING THE TRIP WERE SPECTACULAR'};

numTests = length(imageFiles);
allFailedChars = cell(numTests,1);
totalErrors=0;


for i=1:numTests

    fprintf('\nTEST %d\n', i);

    %ejecuto el OCR(es basicamente el script que hicimos convertido a funcion 
    %pero devuelve el recognized text en una string
    recognized = runOCR(imageFiles{i});
    expected = expectedTexts{i}; %el que le metimos manualmente

    %comparo
    [numErrors, failedChars, accuracy, errorrate] = compareTexts(expected, recognized);

    totalErrors = totalErrors + numErrors;
    
    allFailedChars{i} = failedChars; %voy metiendo los que fallo en una celda
end

globalFailedChars = vertcat(allFailedChars{:}); %contateno todos las letras falladas
analyzeGlobalFailedChars(globalFailedChars);
