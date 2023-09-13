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


%% Use 'readtable' to create a table from the data file

clear; clc; close all;

% Set the filename
filename = 'C:\Users\hyoju\Desktop\eis\eis_data.txt';

% Read the data using readtable
data = readtable(filename, 'Delimiter', '\t', 'HeaderLines', 1, 'ReadVariableNames', false);

% Rename the variables
data.Properties.VariableNames = {'freq', 'Re_Z', 'Im_Z'};

% Extract data from the table
freq = data.freq;
Re_Z = data.Re_Z;
Im_Z = -data.Im_Z;

% Plot
figure;
plot(Re_Z, -Im_Z, 'b', 'LineWidth', 1.5);
xlabel('Re(Z) (Ohm)');
ylabel('-Im(Z) (Ohm)');
title('Impedance');
legend('real data');
