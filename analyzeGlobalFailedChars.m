function analyzeGlobalFailedChars(globalFailedChars) 

%globalFailedChars contains all failedChars from ALL REALIZED TESTS

if isempty(globalFailedChars)
    fprintf('\--- No errors found ---\n');
    return;
end

numErrors = size(globalFailedChars,1);
%chars originales que fueron mal reconocidos QUE ES LA PRIMERA COLUMNA!!!
expectedFailures = globalFailedChars(:,1); 

catFailures = categorical(expectedFailures);
failureLabels= categories(catFailures); %nos muestra las letras que se fallaron
counts=countcats(catFailures); %veces que se falló cada letra de arriba

[sortedCounts, index] = sort(counts, 'descend'); %ordenamos del mas freq al menos freq
sortedLabels = failureLabels(index);

fprintf('%-12s  %-8s  %-12s\n', 'Character', 'Count', 'error% of this letter with respect to total failed letters');

for i=1:length(sortedLabels)
    percentage = (sortedCounts(i)/numErrors) * 100;
    fprintf('%-12s  %-8d  %.2f %%\n', sortedLabels{i}, sortedCounts(i), percentage);
end

fprintf('Total characters failed: %d\n', length(failureLabels));



end