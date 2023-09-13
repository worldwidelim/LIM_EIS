clear; clc; close all;

% frequency vector
f = logspace(-3, 3, 120); % 20 ppd -> 20*6=120
w = 2*pi*f;

% parameter
R = 1;
C = 1;
A = 0.1;
params = [R, C, A];

% model calculation
z_mod = z_model(w, params);

% noise
z_re_noise = (3*R/100)*(rand(size(z_mod))-0.5); % 0-1을 -0.5-0.5로 바꾸기 위해 0.5를 빼줌
z_im_noise = (4*R/100)*(rand(size(z_mod))-0.5);
z_syn = z_mod + z_re_noise + 1i*z_im_noise;

% define the weighting matrix
w_switch = 0; % choose between minimizing (0) absolute error; (1) relative error
% if minimizing the relative error
if w_switch == 1
    weight = (real(z_syn).^2 + imag(z_syn).^2).^0.5;
    weight_matrix = [weight weight];
% if minimizing the absolute error
elseif w_switch == 0
    weight_matrix = ones(size(z_syn));
end

% plot
figure(1)
plot(real(z_mod), -imag(z_mod),'linewidth',2)
hold on
plot(real(z_syn),-imag(z_syn),'o','markersize',4,'linewidth',0.5)

% calculate RMSE with weighting
cost = rmse(z_mod, z_syn, weight_matrix);
fprintf('weighted rmse: %f\n', cost);

% define the cost function for fitting
function [cost] = rmse(z_model, z_data, weight_matrix)
    if nargin < 3
        weight_matrix = ones(size(z_data));
    end
    
    % calculate weighted rmse
    real_error = real(z_model - z_data);
    imag_error = imag(z_model - z_data);
    weighted_error = weight_matrix .* (real_error.^2 + imag_error.^2);
    cost = sqrt(sum(weighted_error));
end

% define the model function
function [Z] = z_model(w, params)

R = params(1);
C = params(2);
A = params(3);

Z_W = A .* (1 - 1i) ./ sqrt(w);
Z_RW = R + Z_W; 
Z_C = 1 ./ (1i*w*C);
Z = (Z_RW .* Z_C) ./ (Z_RW + Z_C);

end
