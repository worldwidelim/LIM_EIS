clear; clc; close all;

% frequency vector
f = logspace(-3, 3, 120); % 20 ppd -> 20*6=120
w = 2*pi*f;

% parameters
R=1;
C=1;
A=0.1;
params = [R, C, A];

% model calculation
z_mod = z_model(w, params);

% noise
z_re_noise = (3*R/100)*(rand(size(z_mod))-0.5); % 0-1을 -0.5-0.5로 바꾸기 위해 0.5를 빼줌
z_im_noise = (4*R/100)*(rand(size(z_mod))-0.5);
z_syn = z_mod + z_re_noise + 1i*z_im_noise;

% % improve: use normal distribution random number with mean and std
% mean_re = 0;
% std_re = 3*R/100;
% 
% mean_im = 0;
% std_im = 4*R/100;
% 
% z_re_noise = normrnd(mean_re, std_re, size(z_mod));
% z_im_noise = normrnd(mean_im, std_im, size(z_mod));
% z_syn = z_mod + z_re_noise + 1i*z_im_noise;

% plot
figure(1)
plot(real(z_mod), -imag(z_mod),'linewidth',2)
hold on
plot(real(z_syn),-imag(z_syn),'o','markersize',4,'linewidth',0.5)

% fitting

% initial guess
initial_params = [1, 1, 0.1];

% define lower and upper bounds
lb = [0, 0, 0]; 
ub = [Inf, Inf, Inf]; 

% define nonlinear constraint function
nonlcon = [];

% fitting using fmincon
options = optimoptions('fmincon', 'Display', 'iter');
params_fit = fmincon(@(params) rmse(z_model(w, params), z_syn), initial_params, [], [], [], [], lb, ub, nonlcon, options);

% extract the fitted parameters
R_fit = params_fit(1);
C_fit = params_fit(2);
A_fit = params_fit(3);

% display fitted parameters
disp(['fitted R: ', num2str(R_fit)]);
disp(['fitted C: ', num2str(C_fit)]);
disp(['fitted A: ', num2str(A_fit)]);

% plot by fitted parameters

function [cost] = rmse(z_model, z_data)

cost = sqrt(sum((real(z_model - z_data)).^2 + (imag(z_model - z_data)).^2));

end


function [Z] = z_model(w,params)

R=params(1);
C=params(2);
A=params(3);

Z_W = A .* (1 - 1i) ./ sqrt(w);
Z_RW = R + Z_W;
Z_C = 1 ./ (1i*w*C);
Z = (Z_RW .* Z_C) ./ (Z_RW + Z_C);

end
