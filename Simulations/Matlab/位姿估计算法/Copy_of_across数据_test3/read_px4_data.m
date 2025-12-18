%% 0. 初始化环境
%==========================================================================
clc;
clear;
close all;

fprintf('开始处理 PX4 ULog 日志并转换为 Simulink 格式 (修正版)...\n');

%% 1. 加载 ULog 

%==========================================================================
% 请修改为你的实际文件名
logFileName = 'd410173f-ed1f-474c-97ec-4834222cc734.ulg'; 
% logFileName = '980f9d69-a3aa-4949-8b45-0277b7a4c56b.ulg'; 



try
    ulog = ulogreader(logFileName);
catch ME
    error('无法读取 ULog 文件: %s\n请确保文件存在。', logFileName);
end

% 定义需要从日志中提取的话题列表
topicNames = {
    'sensor_combined', ...
    'vehicle_magnetometer', ...
    'vehicle_air_data', ...
    'vehicle_gps_position', ...
    'vehicle_attitude', ...
    'vehicle_local_position', ...
};

% 批量读取话题 (返回的是一个包含 TopicMessages 的 Table)
fprintf('正在读取话题数据...\n');
rawTopicsTable = readTopicMsgs(ulog, 'TopicNames', topicNames);

%% 2. 数据提取与预处理 (生成 Timeseries)
%==========================================================================
% 创建字典容器
tsDict = struct();

% 计算全局基准时间 (为了让 Simulink 从 0 秒开始仿真)
% 也就是找到所有感兴趣数据的最早时间点
globalStartTime = get_global_start_time(rawTopicsTable);
fprintf('全局起始时间已校准，数据将归零至 0 秒开始。\n');

% --- 2.1 IMU 数据 (Instance 0) ---
% Accel: x, y, z
% tsDict.IMU_AccX  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'gyro_rad', globalStartTime);
% tsDict.IMU_AccY  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'gyro_rad', globalStartTime);
% tsDict.IMU_AccZ  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'z', globalStartTime);
tsDict.IMU_Acc  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'accelerometer_m_s2', globalStartTime);

% Gyro: x, y, z
% tsDict.IMU_GyroX = extract_ts(rawTopicsTable, 'sensor_gyro', 0, 'x', globalStartTime);
% tsDict.IMU_GyroY = extract_ts(rawTopicsTable, 'sensor_gyro', 0, 'y', globalStartTime);
% tsDict.IMU_GyroZ = extract_ts(rawTopicsTable, 'sensor_gyro', 0, 'z', globalStartTime);
tsDict.IMU_Gyro = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'gyro_rad', globalStartTime);

% --- 2.2 磁力计 (Instance 0) ---
tsDict.IMU_MagX  = extract_ts(rawTopicsTable, 'vehicle_magnetometer', 0, 'magnetometer_ga', globalStartTime);

% --- 2.3 气压计 (Instance 0) ---
tsDict.SENS_BaroAlt = extract_ts(rawTopicsTable, 'vehicle_air_data', 0, 'baro_alt_meter', globalStartTime);

% --- 2.4 GPS 数据 ---
tsDict.GPS_Lat  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'latitude_deg', globalStartTime);
tsDict.GPS_Lon  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'longitude_deg', globalStartTime);
tsDict.GPS_Alt  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'altitude_msl_m', globalStartTime);
tsDict.GPS_VelN = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'vel_n_m_s', globalStartTime);
tsDict.GPS_VelE = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'vel_e_m_s', globalStartTime);
tsDict.GPS_VelD = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'vel_d_m_s', globalStartTime);
% 精度因子
tsDict.GPS_eph  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'eph', globalStartTime);
tsDict.GPS_epv  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'epv', globalStartTime);

% GPS 逻辑信号 (根据 fix_type 判断)
% fix_type: 0-1=No Fix, 2=2D, 3=3D, etc.
gpsTable = get_topic_timetable(rawTopicsTable, 'vehicle_gps_position', 0);
if ~isempty(gpsTable)
    % 【修改点】使用 .timestamp 而不是 .Time
    t_gps = seconds(gpsTable.timestamp - globalStartTime);
    isFix = double(gpsTable.fix_type >= 3); % 3D Fix 视为有效
    tsDict.GPS_GotP = timeseries(isFix, t_gps);
    tsDict.GPS_GotV = timeseries(isFix, t_gps);
else
    tsDict.GPS_GotP = timeseries(0, 0);
    tsDict.GPS_GotV = timeseries(0, 0);
end

% --- 2.5 姿态 (Attitude) - 四元数转欧拉角 ---
attTable = get_topic_timetable(rawTopicsTable, 'vehicle_attitude', 0);
if ~isempty(attTable)
    % 【修改点】使用 .timestamp 而不是 .Time
    t_att = seconds(attTable.timestamp - globalStartTime);
    
    % PX4 quaternion: q_0, q_1, q_2, q_3 (w, x, y, z)
    q = [attTable.q(:,1), attTable.q(:,2), attTable.q(:,3), attTable.q(:,4)];
    % 转换为欧拉角 (ZYX顺序: Yaw, Pitch, Roll)
    eul = quat2eul(q); 
    
    tsDict.ATT_Yaw   = timeseries(eul(:, 1), t_att);
    tsDict.ATT_Pitch = timeseries(eul(:, 2), t_att);
    tsDict.ATT_Roll  = timeseries(eul(:, 3), t_att);
else
    warning('未找到 vehicle_attitude');
    tsDict.ATT_Yaw = timeseries(0,0); tsDict.ATT_Pitch = timeseries(0,0); tsDict.ATT_Roll = timeseries(0,0);
end

% % --- 2.6 姿态角速度 (Rates) ---
% % 优先使用 vehicle_angular_velocity (滤波后数据)，如果没有则用 sensor_gyro
% rateTable = get_topic_timetable(rawTopicsTable, 'vehicle_angular_velocity', 0);
% if ~isempty(rateTable)
%     % vehicle_angular_velocity 包含 xyz (rad/s)
%     % idx 1 = x, idx 2 = y, idx 3 = z
%     tsDict.ATT_RollRate  = extract_ts(rawTopicsTable, 'vehicle_angular_velocity', 0, 'xyz', globalStartTime, 1); 
%     tsDict.ATT_PitchRate = extract_ts(rawTopicsTable, 'vehicle_angular_velocity', 0, 'xyz', globalStartTime, 2); 
%     tsDict.ATT_YawRate   = extract_ts(rawTopicsTable, 'vehicle_angular_velocity', 0, 'xyz', globalStartTime, 3); 
% else
%     % fallback 到 IMU 数据
%     tsDict.ATT_RollRate  = tsDict.IMU_GyroX;
%     tsDict.ATT_PitchRate = tsDict.IMU_GyroY;
%     tsDict.ATT_YawRate   = tsDict.IMU_GyroZ;
% end

% --- 2.7 期望姿态 (Setpoint) ---
% spTable = get_topic_timetable(rawTopicsTable, 'vehicle_attitude_setpoint', 0);
% if ~isempty(spTable)
%     % 【修改点】使用 .timestamp 而不是 .Time
%     t_sp = seconds(spTable.timestamp - globalStartTime);
% 
%     % 通常 setpoint 包含 q_d (期望四元数)
%     if ismember('q_d_0', spTable.Properties.VariableNames)
%         q_sp = [spTable.q_d_0, spTable.q_d_1, spTable.q_d_2, spTable.q_d_3];
%         eul_sp = quat2eul(q_sp);
%         tsDict.ATSP_YawSP   = timeseries(eul_sp(:, 1), t_sp);
%         tsDict.ATSP_PitchSP = timeseries(eul_sp(:, 2), t_sp);
%         tsDict.ATSP_RollSP  = timeseries(eul_sp(:, 3), t_sp);
%     else
%         tsDict.ATSP_RollSP = timeseries(zeros(size(t_sp)), t_sp);
%         tsDict.ATSP_PitchSP = timeseries(zeros(size(t_sp)), t_sp);
%         tsDict.ATSP_YawSP = timeseries(zeros(size(t_sp)), t_sp);
%     end
% else
%     tsDict.ATSP_RollSP = timeseries(0,0); tsDict.ATSP_PitchSP = timeseries(0,0); tsDict.ATSP_YawSP = timeseries(0,0);
% end

% --- 2.8 本地位置 (Local Position) ---
tsDict.LPOS_Z  = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'z', globalStartTime);
tsDict.LPOS_VZ = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'vz', globalStartTime);


%% 3. 配置 Simulink 映射
%==========================================================================
% IMU
imuConfig.IMU_AccX = 'Acc.X'; imuConfig.IMU_AccY = 'Acc.Y'; imuConfig.IMU_AccZ = 'Acc.Z';
imuConfig.IMU_GyroX = 'Gyro.X'; imuConfig.IMU_GyroY = 'Gyro.Y'; imuConfig.IMU_GyroZ = 'Gyro.Z';
% MAG
magConfig.IMU_MagX = 'X'; magConfig.IMU_MagY = 'Y'; magConfig.IMU_MagZ = 'Z';
% Pressure
pressureConfig.SENS_BaroAlt = 'Pressure';
% GPS
gpsConfig.GPS_Lat = 'Lat'; gpsConfig.GPS_Lon = 'Lon'; gpsConfig.GPS_Alt = 'Alt';
gpsConfig.GPS_VelN = 'VelN'; gpsConfig.GPS_VelE = 'VelE'; gpsConfig.GPS_VelD = 'VelD';
gpsConfig.GPS_eph = 'eph'; gpsConfig.GPS_epv = 'epv';
gpsConfig.GPS_GotP = 'GotP'; gpsConfig.GPS_GotV = 'GotV';
% Attitude
attConfig.ATT_Roll = 'Roll'; attConfig.ATT_Pitch = 'Pitch'; attConfig.ATT_Yaw = 'Yaw';
attConfig.ATT_RollRate = 'RollRate'; attConfig.ATT_PitchRate = 'PitchRate'; attConfig.ATT_YawRate = 'YawRate';
attConfig.ATSP_RollSP = 'RollSP'; attConfig.ATSP_PitchSP = 'PitchSP'; attConfig.ATSP_YawSP = 'YawSP';
% LPOS
lposConfig.LPOS_Z = 'Z'; lposConfig.LPOS_VZ = 'VZ';

%% 4. 生成总线与结构体
%==========================================================================
allConfigs = {
    {'IMU_Data',      'IMU_Bus',      imuConfig};
    {'MAG_Data',      'MAG_Bus',      magConfig};
    {'PRESSURE_Data', 'PRESSURE_Bus', pressureConfig};
    {'GPS_Data',      'GPS_Bus',      gpsConfig};
    {'ATT_Data',      'ATT_Bus',      attConfig};
    {'LPOS_Data',     'LPOS_Bus',     lposConfig};
};

for i = 1:length(allConfigs)
    targetStructName = allConfigs{i}{1};
    busName          = allConfigs{i}{2};
    mapConfig        = allConfigs{i}{3};
    
    createdStruct = assemble_structure_and_bus(busName, mapConfig, tsDict);
    assignin('base', targetStructName, createdStruct);
end

fprintf('处理完成！\n变量已生成：IMU_Data, GPS_Data, ATT_Data 等。\n');

