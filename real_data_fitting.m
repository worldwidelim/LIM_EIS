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

% Use the frequency from the data
w = 2 * pi * freq;

% parameter
R1 = 0.01;
R2 = 0.01;
C = 1;
A = 1;
params = [R1, R2, C, A];

% model calculation
z_mod = z_model(w, params);

% fitting
options = optimoptions('fmincon', 'Display', 'iter');
params_fit = fmincon(@(params) rmse(z_model(w, params), Re_Z - 1i * Im_Z), params, [], [], [], [], [0, 0, 0, 0], [Inf, Inf, Inf, Inf], [], options);

% Extract the fitted parameters
R1_fit = params_fit(1);
R2_fit = params_fit(2);
C_fit = params_fit(3);
A_fit = params_fit(4);

% Display fitted parameters
disp(['Fitted R1: ', num2str(R1_fit)]);
disp(['Fitted R2: ', num2str(R2_fit)]);
disp(['Fitted C: ', num2str(C_fit)]);
disp(['Fitted A: ', num2str(A_fit)]);

% Plot real data and fitted curve
figure;
plot(Re_Z, -Im_Z, 'b', 'LineWidth', 1.5);
hold on;
fitted_Z = z_model(w, params_fit);
plot(real(fitted_Z), -imag(fitted_Z), 'r', 'LineWidth', 1.5);
xlabel('Re(Z) (Ohm)');
ylabel('-Im(Z) (Ohm)');
title('Impedance');
legend('real data', 'fitted curve');

function [cost] = rmse(z_model, z_data)
    cost = sqrt(sum((real(z_model - z_data)).^2 + (imag(z_model - z_data)).^2));
end

function [Z] = z_model(w, params)
    R1 = params(1);
    R2 = params(2);
    C = params(3);
    A = params(4);
    Z_W = A .* (1 - 1i) ./ sqrt(w);
    Z_C = 1./(1i*w*C);
    Z = R1 + (R2 + Z_W) .* Z_C ./ ((R2 + Z_W) + Z_C);
end