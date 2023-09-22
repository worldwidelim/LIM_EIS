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
Z_data = data(2,:) - 1i*data(3,:);

% Use the frequency from the data
w = 2 * pi * freq;

% parameter
R1 = 0.03;
R2 = 0.017;
C = 0.1;
A = 0.03;
params_0 = [R1, R2, C, A];

% model calculation
z_mod = z_model(w, params_0);

% fitting
options = optimoptions('fmincon', 'Display', 'iter');
params_fit = fmincon(@(params) rmse(w, params, Z_data), params_0, [], [], [], [], [0, 0, 0, 0], [Inf, Inf, Inf, Inf], [], options);

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
plot(real(Z_data), -imag(Z_data), 'b', 'LineWidth', 1.5);
hold on;
fitted_Z = z_model(w, params_fit);
plot(real(fitted_Z), -imag(fitted_Z), 'r', 'LineWidth', 1.5);
xlabel('Re(Z) (Ohm)');
ylabel('-Im(Z) (Ohm)');
title('Impedance');
legend('real data', 'fitted curve');

function [cost] = rmse(w, params, z_data)
    z_modeleval = z_model(w,params);
    cost = sqrt(sum((real(z_modeleval - z_data)).^2 + (imag(z_modeleval - z_data)).^2));
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Use the frequency from the data
w = 2 * pi * freq;

% parameter
R1 = 0.03;
R2 = 0.017;
C = 0.1;
A = 0.03;
params = [R1, R2, C, A];

% model calculation
z_mod = z_model(w, params);

% fitting
options = optimoptions('fmincon', 'Display', 'iter');
params_fit = fmincon(@(params) rmse(z_model(w, params), Re_Z + 1i * Im_Z), params, [], [], [], [], [0, 0, 0, 0], [Inf, Inf, Inf, Inf], [], options);

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
