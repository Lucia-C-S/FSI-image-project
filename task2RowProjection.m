function rowProjection = task2RowProjection(imBin)
% Goal: Obtaining and drawing row projection

rowProjection = sum(imBin, 2); % sumar la matriz por filas (how many active pixels (letters) in each row)

figure;
plot(rowProjection);
title('Row projection');
xlabel('Row index');
ylabel('Active pixels per row');

% Result: column vector with as many values as the image has rows

end