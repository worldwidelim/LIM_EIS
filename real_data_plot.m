clear; clc; close all;

% Set the filename
filename = 'C:\Users\hyoju\Desktop\eis\eis_data.txt';

% Open the file for reading
fileID = fopen(filename, 'r');

% Skip the first row (header)
fgetl(fileID);

% Read the data
data = fscanf(fileID, '%f\t%f\t%f', [3, Inf]);

% Close the file
fclose(fileID);

% Save data in variables
freq = data(1, :);
Re_Z = data(2, :);
Im_Z = -data(3, :);

% Plot
figure;
plot(Re_Z, -Im_Z, 'b', 'LineWidth', 1.5);
xlabel('Re(Z) (Ohm)');
ylabel('-Im(Z) (Ohm)');
title('Impedance');
legend('real data');





