% Demo_Spacecraft_RL.m
% 验证基于RL的扰动估计器在航天器姿态系统中的有效性
clear; clc; close all;

%% 1. 仿真设置
T_total = 20;       % 总时间 (s)
dt = 0.001;         % 步长 (s)
time = 0:dt:T_total;
N = length(time);

% 航天器参数 (惯量矩阵 kg*m^2)
J_inertia = [10 1 0.5; 1 9 0.5; 0.5 0.5 8]; 
inv_J = inv(J_inertia);

% 初始状态 [欧拉角(rad); 角速度(rad/s)]
x = [0.1; -0.1; 0.2; 0; 0; 0]; 

% 期望轨迹 (简单的调节控制，期望为0)
xd = zeros(3, 1);
dxd = zeros(3, 1);

%% 2. 初始化 RL 估计器
m = 3; % 3轴姿态
L_nodes = 50; % 隐含层节点数

% 参数调整 (根据系统量级调整)
rl_params.gamma = 0.5;
rl_params.Q_gain = 50; 
rl_params.eta_J = 2.0; % 学习率需要根据误差量级调试
rl_params.eta_w = 5.0; 
rl_params.k_J = 0.1;   % 衰减项避免权重爆炸
rl_params.k_w = 0.1;
rl_params.K_w = [1; 1; 1] * 0.1;

estimator = RLEstimator(m, L_nodes, rl_params);

%% 3. 数据记录容器
log_x = zeros(6, N);
log_u = zeros(3, N);
log_d_real = zeros(3, N);
log_d_est = zeros(3, N);
log_error_norm = zeros(1, N);

%% 4. 主循环
fprintf('开始仿真...\n');
for k = 1:N
    t = time(k);
    
    % --- 状态获取 ---
    angles = x(1:3);
    omega = x(4:6);
    
    % --- 误差定义 (简化版，未包含论文中的误差转换函数) ---
    % 注意：论文使用了 prescribed performance function (PPF) 和误差转换
    % 这里为了单纯测试估计器，直接使用物理误差。
    % 若要完全复现论文，需在此处加入 rho(t) 和 sigma(t) 的转换逻辑。
    e1 = angles - xd;       % 姿态误差
    e2 = omega - dxd;       % 角速度误差 (假设为滑模面/速度误差)
    
    % 简单的虚拟误差变量 h1, h2 (对应论文变量)
    h1 = e1; 
    h2 = e2; 
    
    % 计算 h 的导数 (用于RL更新)
    % 在实际系统中，dh1 ~ h2, dh2 ~ 动力学方程
    dh1 = h2; 
    % dh2 近似值 (上一时刻的加速度，或忽略控制项的简单估计)
    % 为了代码严谨，这里在循环外先不计算dh2，而是传入当前的观测值
    % 但在 update 函数中需要 dh2。
    % 这里我们用简单的数值差分或假设模型已知部分来获取 dh2 的结构
    % dh2 = inv_J * (u + d - w x Jw) - dd_xd
    % 由于 d 未知，这里传入给RL的 dh2 只能是基于当前状态的标称值
    % 或者使用上一步的数值差分。这里使用数值差分。
    if k > 1
        dh2 = (h2 - h2_prev) / dt;
    else
        dh2 = zeros(3,1);
    end
    
    % --- RL 估计器更新 ---
    % 获取当前的扰动估计值
    d_hat = estimator.getEstimation(h1, h2);
    
    % 更新权重 (学习过程)
    estimator.step(dt, h1, h2, dh1, dh2);
    
    % --- 真实干扰生成 (用于验证) ---
    % 包含常值偏差和正弦波动
    d_real = [0.5 + 0.2*sin(t); 
              -0.3 + 0.1*cos(2*t); 
              0.4 + 0.15*sin(0.5*t)];
    
    % --- 控制器设计 (PD + 扰动补偿) ---
    % 基础PD控制
    Kp = 10 * eye(3);
    Kd = 20 * eye(3);
    u_pd = -Kp * e1 - Kd * e2;
    
    % 补偿非线性项 (gyroscopic term)
    u_dyn = cross(omega, J_inertia * omega);
    
    % *关键*: 减去估计的扰动 (Fault Tolerant Control)
    u = u_pd + u_dyn - d_hat; 
    
    % --- 系统动力学更新 (RK4或欧拉) ---
    % dot_omega = inv_J * (u + d_real - w x Jw)
    total_torque = u + d_real - cross(omega, J_inertia * omega);
    d_omega = inv_J * total_torque;
    d_angles = omega; % 简化运动学 (小角度假设)
    
    dx = [d_angles; d_omega];
    x = x + dx * dt; % 欧拉积分
    
    % --- 记录数据 ---
    log_x(:, k) = x;
    log_d_real(:, k) = d_real;
    log_d_est(:, k) = d_hat;
    h2_prev = h2; % 存储用于差分
end
fprintf('仿真结束。\n');

%% 5. 绘图结果
figure('Color', 'w');

subplot(3,1,1);
plot(time, log_d_real(1,:), 'k', 'LineWidth', 1.5); hold on;
plot(time, log_d_est(1,:), 'r--', 'LineWidth', 1.5);
ylabel('Disturbance X (Nm)'); legend('Real', 'Estimated');
title('RL Disturbance Estimation Performance'); grid on;

subplot(3,1,2);
plot(time, log_d_real(2,:), 'k', 'LineWidth', 1.5); hold on;
plot(time, log_d_est(2,:), 'g--', 'LineWidth', 1.5);
ylabel('Disturbance Y (Nm)'); grid on;

subplot(3,1,3);
plot(time, log_d_real(3,:), 'k', 'LineWidth', 1.5); hold on;
plot(time, log_d_est(3,:), 'b--', 'LineWidth', 1.5);
ylabel('Disturbance Z (Nm)'); xlabel('Time (s)'); grid on;

figure('Color', 'w');
plot(time, log_x(1:3, :));
title('Spacecraft Attitude Angles');
xlabel('Time (s)'); ylabel('Angle (rad)'); legend('\phi', '\theta', '\psi');
grid on;