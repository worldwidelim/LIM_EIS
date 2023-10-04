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

% initial guess
R1 = 0.03;
R2 = 0.017;
C = 0.1;
A = 0.03;
t = 100; % t는 시상수 τ를 나타냄
params = [R1, R2, C, A, t];

% model calculation
z_mod = z_model(w, params);

% fitting
options = optimoptions('fmincon', 'Display', 'iter');
params_fit = fmincon(@(params) rmse(w, params, Re_Z + 1i * Im_Z), params, [], [], [], [], [0, 0, 0, 0, 0], [Inf, Inf, Inf, Inf, Inf], [], options);

% Extract the fitted parameters
R1_fit = params_fit(1);
R2_fit = params_fit(2);
C_fit = params_fit(3);
A_fit = params_fit(4);
t_fit = params_fit(5);

% Display fitted parameters
disp(['Fitted R1: ', num2str(R1_fit)]);
disp(['Fitted R2: ', num2str(R2_fit)]);
disp(['Fitted C: ', num2str(C_fit)]);
disp(['Fitted A: ', num2str(A_fit)]);
disp(['Fitted t: ', num2str(t_fit)]);

% Plot real data and fitted curve
figure;
plot(real(z_mod), -imag(z_mod),'g')
hold on;
plot(Re_Z, -Im_Z, 'b', 'LineWidth', 1.5)
hold on;
fitted_Z = z_model(w, params_fit);
plot(real(fitted_Z), -imag(fitted_Z), 'r', 'LineWidth', 1.5)
xlabel('Re(Z) (Ohm)');
ylabel('-Im(Z) (Ohm)');
title('Impedance');
legend('initial guess', 'real data', 'fitted curve');
axis([0 0.15 0 0.15])

function [cost] = rmse(w, params, z_data)
    z_modeleval = z_model(w,params);
    cost = sqrt(sum((real(z_modeleval - z_data)).^2 + (imag(z_modeleval - z_data)).^2));
end

function [Z] = z_model(w, params)
    R1 = params(1);
    R2 = params(2);
    C = params(3);
    A = params(4);
    t = params(5);

    Z_W = A * coth(sqrt(1i*w*t)) ./ sqrt(1i*w*t);
    Z_C = 1./(1i*w*C);
    Z = R1 + (R2 + Z_W) .* Z_C ./ ((R2 + Z_W) + Z_C);
end
