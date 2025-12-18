% 你的数据已经存在于工作区

% 1. 创建 signals 字段
signals_data.values = [IMU_AccX, IMU_AccY, IMU_AccZ]; % 将数据信号合并
signals_data.dimensions = 3; % 信号的维度（有3个信号）

% 2. 创建主结构体
sim_data_struct.time = time; % 时间向量
sim_data_struct.signals = signals_data;