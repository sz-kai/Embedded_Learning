classdef RLEstimator < handle
    % RLEstimator 基于强化学习的复合干扰估计器
    % 参考文献: Engineering Applications of Artificial Intelligence 140 (2025) 109734
    % "Predefined time convergence guaranteed performance control for uncertain systems based on reinforcement learning"
    %
    % 功能: 
    %   利用Actor-Critic结构 (ELM网络) 在线估计系统的集总扰动 eta(t)。
    %   包含评价网络(Critic)和动作网络(Actor)。
    %
    % 适用对象:
    %   MIMO非线性系统，如航天器姿态控制、机械臂等。
    
    properties
        % --- 系统维度 ---
        n_in  % 输入层维度 (2*m, 对应 Z = [h1; h2])
        n_out % 输出层维度 (m, 对应干扰 eta 的维度)
        n_L   % 隐含层节点数 (ELM节点数)
        
        % --- 网络权重 (ELM随机权重，固定不更新) ---
        V_J   % 评价网络输入权重 [n_in x n_L]
        b_J   % 评价网络偏置 [n_L x 1]
        V_w   % 动作网络输入权重 [n_in x n_L]
        b_w   % 动作网络偏置 [n_L x 1]
        
        % --- 网络权重 (需要在线更新) ---
        W_J   % 评价网络输出权重 [n_L x 1]
        W_w   % 动作网络输出权重 [n_L x n_out]
        
        % --- 超参数 (参考论文 Table 2) ---
        gamma % 折扣因子 (Discount factor)
        Q     % 惩罚矩阵 Q [2m x 2m] (对角阵系数)
        eta_J % 评价网络学习率
        k_J   % 评价网络衰减系数
        eta_w % 动作网络学习率
        k_w   % 动作网络衰减系数
        K_w   % 设计向量/矩阵 [n_out x 1] 或 [n_out x n_out]
        
        % --- 状态存储 ---
        last_time
    end
    
    methods
        function obj = RLEstimator(m, L, params)
            % 构造函数
            % 输入:
            %   m: 系统自由度 (航天器姿态通常为3)
            %   L: 隐含层节点数 (如 100)
            %   params: 结构体，包含超参数 (可选)
            
            obj.n_in = 2 * m;
            obj.n_out = m;
            obj.n_L = L;
            
            % 1. 初始化ELM的随机输入权重和偏置 (随机生成后固定)
            % 使用 Xavier 初始化或简单的 randn
            obj.V_J = randn(obj.n_in, obj.n_L);
            obj.b_J = randn(obj.n_L, 1);
            
            obj.V_w = randn(obj.n_in, obj.n_L);
            obj.b_w = randn(obj.n_L, 1);
            
            % 2. 初始化可更新的输出权重 (通常初始化为0)
            obj.W_J = zeros(obj.n_L, 1);
            obj.W_w = zeros(obj.n_L, obj.n_out);
            
            % 3. 加载参数 (如果未提供则使用论文默认值或经验值)
            if nargin < 3
                params = struct();
            end
            obj.loadParams(params);
            
            obj.last_time = 0;
        end
        
        function loadParams(obj, p)
            % 设置默认参数，如果传入参数存在则覆盖
            % 参考论文 Table 2 的数值
            
            % 惩罚矩阵 Q (Positive definite matrix)
            if isfield(p, 'Q_gain'), q_val = p.Q_gain; else, q_val = 100; end
            obj.Q = q_val * eye(obj.n_in); 
            
            % 折扣因子 gamma > 0
            if isfield(p, 'gamma'), obj.gamma = p.gamma; else, obj.gamma = 0.1; end
            
            % 评价网络参数
            if isfield(p, 'eta_J'), obj.eta_J = p.eta_J; else, obj.eta_J = 1.2; end
            if isfield(p, 'k_J'), obj.k_J = p.k_J; else, obj.k_J = 10; end
            
            % 动作网络参数
            if isfield(p, 'eta_w'), obj.eta_w = p.eta_w; else, obj.eta_w = 1.5; end
            if isfield(p, 'k_w'), obj.k_w = p.k_w; else, obj.k_w = 10; end
            
            % 设计参数 Kw (Eq 33)
            if isfield(p, 'K_w'), obj.K_w = p.K_w; else, obj.K_w = ones(obj.n_out, 1); end
        end
        
        function [eta_hat, dW_J, dW_w] = update(obj, h1, h2, dh1, dh2)
            % update 计算估计值及权重导数
            % 该函数不直接积分权重，而是返回导数供外部ODE求解器或欧拉积分使用
            %
            % 输入:
            %   h1: 变换后的位置误差变量 [m x 1] (论文中的 h_1)
            %   h2: 速度误差变量 [m x 1] (论文中的 h_2)
            %   dh1: h1 的导数 [m x 1] (用于链式法则计算 Phi_dot)
            %   dh2: h2 的导数 [m x 1] 
            %
            % 输出:
            %   eta_hat: 当前时刻的集总扰动估计值 [m x 1]
            %   dW_J: 评价网络权重导数
            %   dW_w: 动作网络权重导数
            
            % 构造输入向量 Z (Eq 24下方)
            Z = [h1; h2];       % [2m x 1]
            dZ = [dh1; dh2];    % [2m x 1]
            
            % --- 1. 计算激活函数及其导数 ---
            % Phi_J(Z) = tanh(V_J'*Z + b_J)
            net_J = obj.V_J' * Z + obj.b_J;
            Phi_J = tanh(net_J); % [L x 1]
            
            % Phi_J 对时间的导数 d(Phi_J)/dt
            % tanh(x)' = 1 - tanh^2(x)
            % d(Phi)/dt = diag(1-Phi.^2) * V_J' * dZ
            d_tanh_J = 1 - Phi_J.^2;
            Phi_J_dot = d_tanh_J .* (obj.V_J' * dZ); % 元素对应相乘 [L x 1]
            
            % Phi_w(Z) = tanh(V_w'*Z + b_w)
            net_w = obj.V_w' * Z + obj.b_w;
            Phi_w = tanh(net_w); % [L x 1]
            
            % --- 2. 评价网络 (Critic) 计算 ---
            % 估计的代价函数 J_hat (Eq 27)
            J_hat = obj.W_J' * Phi_J; 
            
            % 计算 TD Error / 评价网络误差 e_J (Eq 28)
            % e_J = Z'*Q*Z + W_J'*(Phi_J_dot - gamma*Phi_J)
            % 注意：论文公式(28)最后一行 W_J' * (...) 是标量
            term_critic = Phi_J_dot - obj.gamma * Phi_J;
            e_J = Z' * obj.Q * Z + obj.W_J' * term_critic;
            
            % 计算 W_J 的更新率 (Eq 30)
            % dot_W_J = -eta_J * e_J * term_critic - eta_J * k_J * W_J
            dW_J = -obj.eta_J * e_J * term_critic - obj.eta_J * obj.k_J * obj.W_J;
            
            % --- 3. 动作网络 (Actor) 计算 ---
            % 计算扰动估计值 eta_hat (Eq 32)
            eta_hat = obj.W_w' * Phi_w; % [m x 1]
            
            % 计算动作网络误差 e_w (Eq 33)
            % e_w = W_w'*Phi_w + h2 + Kw * J_hat
            % 注意维度: [m x 1]
            if isvector(obj.K_w)
                 Kw_term = obj.K_w * J_hat;
            else
                 Kw_term = obj.K_w * ones(obj.n_out, 1) * J_hat; % 简单处理，视Kw定义而定
            end
            e_w = eta_hat + h2 + Kw_term;
            
            % 计算 W_w 的更新率 (Eq 35)
            % dot_W_w = -eta_w * Phi_w * e_w^T - eta_w * k_w * W_w
            % 维度: [L x 1] * [1 x m] -> [L x m]
            dW_w = -obj.eta_w * Phi_w * e_w' - obj.eta_w * obj.k_w * obj.W_w;
        end
        
        function step(obj, dt, h1, h2, dh1, dh2)
            % step 单步欧拉积分更新
            % 适用于定步长仿真循环
            
            [~, dW_J, dW_w] = obj.update(h1, h2, dh1, dh2);
            
            % 更新权重
            obj.W_J = obj.W_J + dW_J * dt;
            obj.W_w = obj.W_w + dW_w * dt;
        end
        
        function eta_hat = getEstimation(obj, h1, h2)
            % 仅获取当前估计值（不更新权重）
            Z = [h1; h2];
            Phi_w = tanh(obj.V_w' * Z + obj.b_w);
            eta_hat = obj.W_w' * Phi_w;
        end
    end
end