% BSL Code
clc; clear; close all;

%% Interface

% data folder
data_folder_1 = 'G:\공유 드라이브\Battery Software Lab\Data\Hyundai_dataset\OCV\FCC_(5)_OCV_C20.mat';
data_folder_2 = 'G:\공유 드라이브\Battery Software Lab\Data\Hyundai_dataset\OCV2\HNE_(6)_FCC_OCV2.mat';
[save_folder_1, save_name_1] = fileparts(data_folder_1); % fileparts는 파일 경로 문자열을 디렉토리 경로, 파일 이름 및 확장자로 분할함
[save_folder_2, save_name_2] = fileparts(data_folder_2);


%% Engine
OCV_1 = load(data_folder_1);
OCV_2 = load(data_folder_2);

golden_1 = OCV_1.OCV_golden;
golden_1_chg = golden_1.OCVchg;
golden_1_dis = golden_1.OCVdis;

golden_2 = OCV_2.OCV_golden;
golden_2_chg = golden_2.OCVchg;
golden_2_dis = golden_2.OCVdis;

x1_chg = golden_1.OCVchg(:, 1);
y1_chg = golden_1.OCVchg(:, 2);
x1_dis = golden_1.OCVdis(:, 1);
y1_dis = golden_1.OCVdis(:, 2);

x2_chg = golden_2.OCVchg(:, 1);
y2_chg = golden_2.OCVchg(:, 2);
x2_dis = golden_2.OCVdis(:, 1);
y2_dis = golden_2.OCVdis(:, 2);

%% plot
figure('position',[0,0,1600,600]);

lw = 2;  % Desired line width
msz = 11;  % Marker size

%charge
subplot(1,2,1)
plot(x1_chg, y1_chg, 'r-', 'MarkerSize', msz, 'LineWidth', lw);
hold on;
plot(x2_chg, y2_chg, 'b-', 'MarkerSize', msz, 'LineWidth', lw);
axis([0 1 2.4 4.4]);
xlabel('SOC');
ylabel('OCV (V)');
title('FCC Charge Compare at 0.05C');
set(gca, 'FontSize', 16, 'LineWidth', 2)
legend('OCV1', 'OCV2');

%discharge
subplot(1,2,2)
plot(x1_dis, y1_dis, 'r-', 'MarkerSize', msz, 'LineWidth', lw);
hold on;
plot(x2_dis, y2_dis, 'b-', 'MarkerSize', msz, 'LineWidth', lw);
axis([0 1 2.4 4.4]);
xlabel('SOC');
ylabel('OCV (V)');
title('FCC Discharge Compare at 0.05C');
set(gca, 'FontSize', 16, 'LineWidth', 2)
legend('OCV1', 'OCV2');