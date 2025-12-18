%% 0. 初始化环境
%==========================================================================
clc;
clear;
close all;

fprintf('开始处理 PX4 ULog 日志并转换为 Simulink 格式...\n');

%% 1. 加载 ULog 文件
%==========================================================================
% 请修改为你的实际文件名
% logFileName = '1f31953d-08f7-4eee-86d1-13f9d0385e5e.ulg'; 
logFileName = '3bd7f49c-e3f3-4041-b094-869fb530d4d8.ulg'; 


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
    % 如果后续需要期望值，可以取消注释下面这行
    % 'vehicle_attitude_setpoint' 
};

% 批量读取话题 (返回的是一个包含 TopicMessages 的 Table)
fprintf('正在读取话题数据...\n');
rawTopicsTable = readTopicMsgs(ulog, 'TopicNames', topicNames);

%% 2. 数据提取与预处理 (生成 Timeseries)
%==========================================================================
% 创建字典容器
tsDict = struct();

% 计算全局基准时间 (为了让 Simulink 从 0 秒开始仿真)
globalStartTime = get_global_start_time(rawTopicsTable);
fprintf('全局起始时间已校准，数据将归零至 0 秒开始。\n');

% --- 2.1 IMU 数据 (Instance 0) ---
% 原始数据中 accelerometer_m_s2 是一个 Nx3 的数组
% 我们需要将其拆分为 X, Y, Z 三个独立的 timeseries 以适配 Simulink 总线定义
% colIndex: 1=X, 2=Y, 3=Z

% Accel (从 sensor_combined 提取)
tsDict.IMU_AccX  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'accelerometer_m_s2', globalStartTime, 1);
tsDict.IMU_AccY  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'accelerometer_m_s2', globalStartTime, 2);
tsDict.IMU_AccZ  = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'accelerometer_m_s2', globalStartTime, 3);

% Gyro (从 sensor_combined 提取)
tsDict.IMU_GyroX = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'gyro_rad', globalStartTime, 1);
tsDict.IMU_GyroY = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'gyro_rad', globalStartTime, 2);
tsDict.IMU_GyroZ = extract_ts(rawTopicsTable, 'sensor_combined', 0, 'gyro_rad', globalStartTime, 3);

% --- 2.2 磁力计 (Instance 0) ---
% vehicle_magnetometer 中的 magnetometer_ga 也是 Nx3 数组
tsDict.IMU_MagX  = extract_ts(rawTopicsTable, 'vehicle_magnetometer', 0, 'magnetometer_ga', globalStartTime, 1);
tsDict.IMU_MagY  = extract_ts(rawTopicsTable, 'vehicle_magnetometer', 0, 'magnetometer_ga', globalStartTime, 2);
tsDict.IMU_MagZ  = extract_ts(rawTopicsTable, 'vehicle_magnetometer', 0, 'magnetometer_ga', globalStartTime, 3);

% --- 2.3 气压计 (Instance 0) ---
tsDict.SENS_BaroAlt = extract_ts(rawTopicsTable, 'vehicle_air_data', 0, 'baro_alt_meter', globalStartTime);

% --- 2.4 GPS 数据 ---
tsDict.GPS_Lat  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'latitude_deg', globalStartTime);
tsDict.GPS_Lon  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'longitude_deg', globalStartTime);
tsDict.GPS_Alt  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'altitude_msl_m', globalStartTime);
tsDict.GPS_VelN = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'vel_n_m_s', globalStartTime);
tsDict.GPS_VelE = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'vel_e_m_s', globalStartTime);
tsDict.GPS_VelD = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'vel_d_m_s', globalStartTime);
tsDict.GPS_eph  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'eph', globalStartTime);
tsDict.GPS_epv  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'epv', globalStartTime);
tsDict.GPS_satellites_used  = extract_ts(rawTopicsTable, 'vehicle_gps_position', 0, 'satellites_used', globalStartTime);

% GPS 逻辑信号 (已修改：强制置为 1)
gpsTable = get_topic_timetable(rawTopicsTable, 'vehicle_gps_position', 0);
if ~isempty(gpsTable)
    t_gps = seconds(gpsTable.timestamp - globalStartTime);
    
    % --- 修改开始 ---
    % 生成一个与时间戳长度相同的全 1 数组
    isFix = ones(length(t_gps), 1); 
    
    tsDict.GPS_GotP = timeseries(isFix, t_gps);
    tsDict.GPS_GotV = timeseries(isFix, t_gps);
    % --- 修改结束 ---
else
    tsDict.GPS_GotP = timeseries(0, 0);
    tsDict.GPS_GotV = timeseries(0, 0);
end

% --- 2.5 姿态 (Attitude) ---
attTable = get_topic_timetable(rawTopicsTable, 'vehicle_attitude', 0);
if ~isempty(attTable)
    t_att = seconds(attTable.timestamp - globalStartTime);
    
    % 处理 q 为 Nx4 数组的情况
    if ismember('q', attTable.Properties.VariableNames)
        q_val = attTable.q; % 直接获取数组
    elseif ismember('q_0', attTable.Properties.VariableNames)
        % 兼容旧版拆分字段
        q_val = [attTable.q_0, attTable.q_1, attTable.q_2, attTable.q_3];
    else
        warning('无法在 vehicle_attitude 中找到四元数数据');
        q_val = repmat([1 0 0 0], length(t_att), 1);
    end

    % 转换为欧拉角 (ZYX顺序: Yaw, Pitch, Roll)
    eul = quat2eul(q_val); 
    
    tsDict.ATT_Yaw   = timeseries(eul(:, 1), t_att);
    tsDict.ATT_Pitch = timeseries(eul(:, 2), t_att);
    tsDict.ATT_Roll  = timeseries(eul(:, 3), t_att);
else
    warning('未找到 vehicle_attitude');
    tsDict.ATT_Yaw = timeseries(0,0); tsDict.ATT_Pitch = timeseries(0,0); tsDict.ATT_Roll = timeseries(0,0);
end

% --- 2.6 姿态角速度 (Rates) ---
% 由于你注释掉了 vehicle_angular_velocity，我们直接复用 IMU 的 Gyro 数据
% 这样可以保证 Simulink 总线中有数据
tsDict.ATT_RollRate  = tsDict.IMU_GyroX;
tsDict.ATT_PitchRate = tsDict.IMU_GyroY;
tsDict.ATT_YawRate   = tsDict.IMU_GyroZ;

% --- 2.7 期望姿态 (Setpoint) - 填充默认零值 ---
% 由于相关部分被注释，这里创建与姿态时间轴相同的零数据，防止 Simulink 报错
if ~isempty(attTable)
    dummyData = zeros(length(tsDict.ATT_Roll.Data), 1);
    dummyTime = tsDict.ATT_Roll.Time;
    tsDict.ATSP_RollSP  = timeseries(dummyData, dummyTime);
    tsDict.ATSP_PitchSP = timeseries(dummyData, dummyTime);
    tsDict.ATSP_YawSP   = timeseries(dummyData, dummyTime);
else
    tsDict.ATSP_RollSP = timeseries(0,0); tsDict.ATSP_PitchSP = timeseries(0,0); tsDict.ATSP_YawSP = timeseries(0,0);
end

% --- 2.8 本地位置 (Local Position) ---
tsDict.LPOS_X  = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'x', globalStartTime);
tsDict.LPOS_VX = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'vx', globalStartTime);
tsDict.LPOS_Y  = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'y', globalStartTime);
tsDict.LPOS_VY = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'vy', globalStartTime);
tsDict.LPOS_Z  = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'z', globalStartTime);
tsDict.LPOS_VZ = extract_ts(rawTopicsTable, 'vehicle_local_position', 0, 'vz', globalStartTime);


%% 3. 配置 Simulink 映射 (保持不变)
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
gpsConfig.GPS_satellites_used = 'satellites_used';
% Attitude
attConfig.ATT_Roll = 'Roll'; attConfig.ATT_Pitch = 'Pitch'; attConfig.ATT_Yaw = 'Yaw';
attConfig.ATT_RollRate = 'RollRate'; attConfig.ATT_PitchRate = 'PitchRate'; attConfig.ATT_YawRate = 'YawRate';
attConfig.ATSP_RollSP = 'RollSP'; attConfig.ATSP_PitchSP = 'PitchSP'; attConfig.ATSP_YawSP = 'YawSP';
% LPOS
lposConfig.LPOS_X = 'X'; lposConfig.LPOS_VX = 'VX';
lposConfig.LPOS_Y = 'Y'; lposConfig.LPOS_VY = 'VY';
lposConfig.LPOS_Z = 'Z'; lposConfig.LPOS_VZ = 'VZ';

%% 4. 生成总线与结构体 (保持不变)
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

fprintf('处理完成！\n变量已生成：IMU_Data, GPS_Data 等。\n请在 Simulink 中使用 "From Workspace" 模块读取。\n');

%% 辅助函数 (保持不变)
%==========================================================================

function tt = get_topic_timetable(rawTable, topicName, instanceID)
    rowIdx = strcmp(rawTable.TopicNames, topicName) & rawTable.InstanceID == instanceID;
    if any(rowIdx)
        tt = rawTable.TopicMessages{rowIdx};
    else
        tt = [];
    end
end

function ts = extract_ts(rawTable, topicName, instanceID, fieldName, startTime, colIndex)
    % colIndex: 用于提取数组字段的特定列 (1=X, 2=Y, 3=Z)
    if nargin < 6, colIndex = 0; end
    
    tt = get_topic_timetable(rawTable, topicName, instanceID);
    
    if isempty(tt)
        % 仅在非可选数据时警告
        % warning('未找到话题: %s (Instance %d)', topicName, instanceID);
        ts = timeseries(0, 0);
        return;
    end
    
    if ismember(fieldName, tt.Properties.VariableNames)
        val = tt.(fieldName);
        
        % 处理数组列 (关键步骤)
        if colIndex > 0
            if size(val, 2) >= colIndex
                val = val(:, colIndex);
            else
                warning('字段 %s 的列数不足 %d', fieldName, colIndex);
                val = zeros(size(val, 1), 1);
            end
        end
        
        % 使用 timestamp 并转为 double 秒
        t_sec = seconds(tt.timestamp - startTime);
        
        ts = timeseries(val, t_sec);
        ts.Name = fieldName;
    else
        warning('话题 %s 中不存在字段 %s', topicName, fieldName);
        ts = timeseries(0, 0);
    end
end

function globalStart = get_global_start_time(rawTable)
    globalStart = duration(Inf, 0, 0);
    for i = 1:height(rawTable)
        tt = rawTable.TopicMessages{i};
        if ~isempty(tt)
            if tt.timestamp(1) < globalStart
                globalStart = tt.timestamp(1);
            end
        end
    end
    if globalStart == duration(Inf, 0, 0)
        globalStart = seconds(0); 
    end
end

function dataStruct = assemble_structure_and_bus(busName, mapConfig, sourceDataDict)
    dataStruct = struct();
    sourceKeys = fieldnames(mapConfig);
    
    for i = 1:length(sourceKeys)
        srcKey = sourceKeys{i};
        destPath = mapConfig.(srcKey);
        
        if isfield(sourceDataDict, srcKey)
            tsObj = sourceDataDict.(srcKey);
        else
            tsObj = timeseries(0, 0);
        end
        
        pathParts = strsplit(destPath, '.');
        dataStruct = setfield_nested(dataStruct, pathParts, tsObj);
    end
    
    busInfo = Simulink.Bus.createObject(dataStruct);
    assignin('base', busName, evalin('base', busInfo.busName));
    evalin('base', ['clear ', busInfo.busName]);
end

function s = setfield_nested(s, fields, value)
    if isempty(fields)
        s = value;
    else
        field = fields{1};
        if isscalar(fields)
            s.(field) = value;
        else
            if ~isfield(s, field)
                s.(field) = struct();
            end
            s.(field) = setfield_nested(s.(field), fields(2:end), value);
        end
    end
end