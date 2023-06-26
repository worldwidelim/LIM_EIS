% BSL OCV Code
clc; clear; close all;

%% Interface

% data folder
data_folder = 'G:\공유 드라이브\Battery Software Lab\Data\Hyundai_dataset\OCV\FCC_(5)_OCV_C20';
[save_folder, save_name] = fileparts(data_folder); % fileparts는 파일 경로 문자열을 디렉토리 경로, 파일 이름 및 확장자로 분할함    
% save_folder와 save_name 변수에 각각 폴더 경로와 파일 이름이 할당됨

% cathode, full cell, or anode
id_cfa = 2; % 1 for cathode, 2 for full cell, 3 for anode, 0 for automatic (not yet implemented)

% OCV steps
    % chg/dis sub notation: with respect to the full cell operation % 충전/방전 서브 표기: 풀셀 동작을 기준으로 함
    step_ocv_chg = 4;
    step_ocv_dis = 6;

% parameters
y1 = 0.215685; % cathode stoic at soc = 100% (soc=1일 때 양극 y1만큼 채워져 있음). reference : AVL NMC811
x_golden = 0.5;


%% Engine
slash = filesep; % slash를 filesep으로 지정함, filesep은 파일 경로 구분자
files = dir([data_folder slash '*.mat']); % dir 함수를 사용해서 데이터 폴더 내의 모든 .mat 파일을 가져옴

for i = 1 : length(files)
    fullpath_now = [data_folder slash files(i).name]; % path for i-th file in the folder
    load(fullpath_now); 

    for j = 1 : length(data) % data field의 개수
        % calculate capacities (용량 계산)
        if length(data(j).t) > 1 % data field에 data가 1개보다 많을 때
            data(j).Q = abs(trapz(data(j).t, data(j).I))/3600; % [Ah] 
            % trapz 함수는 수치 적분을 수행하는 함수. trapz(x, y) : x는 독립 변수의 값이 들어있는 벡터, y는 종속 변수의 값이 들어있는 벡터
            % 적분값에 절댓값을 씌운 후 3600s를 나눠 Ah 단위로 변환
            % data(j).Q는 전체 용량
            data(j).cumQ = abs(cumtrapz(data(j).t, data(j).I))/3600; % [Ah]
            % cumtrapz 함수는 누적 수치 적분을 수행하는 함수, 시간에 따른 누적적인 변화를 추적하고자 할 때 유용하게 사용될 수 있음
            % data(j).cumQ는 해당 시점까지의 전체 누적 용량
        end
    end

    data(step_ocv_chg).soc = data(step_ocv_chg).cumQ/data(step_ocv_chg).Q; % soc = cumQ/Q, charge soc는 0에서 1
    data(step_ocv_dis).soc = 1-data(step_ocv_dis).cumQ/data(step_ocv_dis).Q; % soc = 1-cumQ/Q, discharge soc는 1에서 0

    % stoichiometry for cathode and anode (not for full cell)
    if id_cfa == 1 % cathode
        data(step_ocv_chg).stoic = 1-(1-y1)*data(step_ocv_chg).soc;
        data(step_ocv_dis).stoic = 1-(1-y1)*data(step_ocv_dis).soc;
        % 충전 : soc = 0 -> 1, stoic = 1 -> y1
        % 방전 : soc = 1 -> 0, stoic = y1 -> 1
        % 양극 : 충전할 때 리튬 이온 적어지고 방전할 때 리튬 이온 많아진다
    elseif id_cfa == 3 % anode
        data(step_ocv_chg).stoic = data(step_ocv_chg).soc;
        data(step_ocv_dis).stoic = data(step_ocv_dis).soc;
        % 충전 : soc = 0 -> 1, stoic = 0 -> 1
        % 방전 : soc = 1 -> 0, stoic = 1 -> 0
        % 음극 : 충전할 때 리튬 이온 많아지고 방전할 때 리튬 이온 적어진다
    elseif id_cfa == 2 % full cell
        % stoic is not defined for full cell
    end


    % make an overall OCV struct
    if id_cfa == 1 || id_cfa == 3 % cathode or anode half cell
        x_chg = data(step_ocv_chg).stoic;
        y_chg = data(step_ocv_chg).V;
        z_chg = data(step_ocv_chg).cumQ;
        x_dis = data(step_ocv_dis).stoic;
        y_dis = data(step_ocv_dis).V;
        z_dis = data(step_ocv_dis).cumQ;
    elseif id_cfa == 2 % full cell
        x_chg = data(step_ocv_chg).soc; % full cell일 때 stoic는 정의 안 함
        y_chg = data(step_ocv_chg).V;
        z_chg = data(step_ocv_chg).cumQ;
        x_dis = data(step_ocv_dis).soc;
        y_dis = data(step_ocv_dis).V;
        z_dis = data(step_ocv_dis).cumQ;
    end

    OCV_all(i).OCVchg = [x_chg y_chg z_chg]; % [stoic V cumQ] or [soc V cumQ]
    OCV_all(i).OCVdis = [x_dis y_dis z_dis];

    OCV_all(i).Qchg = data(step_ocv_chg).Q;
    OCV_all(i).Qdis = data(step_ocv_dis).Q;

    % golden criteria
    OCV_all(i).y_golden = (interp1(x_chg, y_chg, 0.5) + interp1(x_dis, y_dis, 0.5))/2;
    % 충전 및 방전 OCV의 soc=0.5에서의 ocv 평균값을 골든 기준으로 정함
    % interp1는 1차원 데이터에 대해 보간을 수행하는 함수. 보간 : 주어진 데이터 포인트 사이에서 새로운 값을 추정하는 과정
    % Vq = interp1(X, V, Xq)
    % X : 기존 데이터 포인트의 위치를 나타내는 벡터
    % V : 해당 위치에서의 값들을 나타내는 벡터, 
    % Xq : 보간된 값을 얻고자 하는 새로운 위치를 나타내는 벡터
    % Vq : Xq 위치에서의 보간된 값들을 반환하는 벡터
   
    % plot 
    color_mat = lines(4);
    % c = lines(n)에서 n은 반환할 선 스타일의 수, c는 n행 3열을 가진 RGB 색상 매트릭스
    if i==1
        figure
    end
    hold on; box on; % box on은 그래프나 도표에 상자 모서리를 표시하는 명령
    plot(x_chg, y_chg, '-', 'Color', color_mat(1, :)) % 색상은 color_mat의 첫 번째 색상을 사용
    plot(x_dis, y_dis, '-', 'Color', color_mat(2, :)) % 색상은 color_mat의 두 번째 색상을 사용
    xlim([0 1]) % xlim는 그래프의 x축 범위를 지정하는 함수
    set(gca, 'Fontsize', 12) % gca는 현재 축을 나타내는 옵션. gca를 사용하면 현재 활성화된 축에 대한 속성을 설정하거나 수정할 수 있음
end


% select an golden OCV
[~, i_golden] = min(abs([OCV_all.y_golden]-median([OCV_all.y_golden]))); 
% ~ : 값 자체는 무시하고 index만 가져오는 것을 의미함
% |(y_golden 값) - (i개의 y_golden값들 중에 중앙값)| -> 이 값들 중 min값 찾기
OCV_golden.i_golden = i_golden;

% save OCV struct
OCV_golden.OCVchg = OCV_all(1, i_golden).OCVchg;
OCV_golden.OCVdis = OCV_all(1, i_golden).OCVdis;

% plot
title_str = strjoin(strsplit(save_name, '_'), ' ');
title(title_str)
plot(OCV_golden.OCVchg(:, 1), OCV_golden.OCVchg(:, 2), '--', 'Color', color_mat(3, :))
plot(OCV_golden.OCVdis(:, 1), OCV_golden.OCVdis(:, 2), '--', 'Color', color_mat(4, :))

% save
save_fullpath = [save_folder filesep save_name '.mat']; % save_fullpath 변수에 저장 경로와 파일 이름을 할당하고 .mat 확장자 추가
save(save_fullpath, 'OCV_golden', 'OCV_all') % 'OCV_golden'과 'OCV_all' 변수를 save_fullpath 경로에 있는 파일에 저장함. 저장된 파일은 '.mat' 형식으로 저장됨

