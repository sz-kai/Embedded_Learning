%% 0. 初始化环境
%==========================================================================
clc;
clear;
close all;

fprintf('开始处理 PX4 ULog 日志文件...\n');

%% 1. 加载 ULog 文件并批量读取所有话题
%==========================================================================
logFileName = 'd410173f-ed1f-474c-97ec-4834222cc734.ulg'; 

try
    ulog = ulogreader(logFileName);
catch ME
    error('无法读取 ULog 文件: %s\n请确保文件存在且路径正确。\n错误信息: %s', logFileName, ME.message);
end

topicNames = {
    'sensor_accel', 'sensor_gyro', 'sensor_mag', 'sensor_baro', ...
    'sensor_gps', ...
    'estimator_attitude', 'estimator_local_position', 'estimator_global_position', ...
    'vehicle_attitude', 'vehicle_local_position', 'vehicle_global_position', ...
    'vehicle_gps_position', 'vehicle_magnetometer', 'vehicle_imu', ...
    'vehicle_acceleration'
};

allMsgs = readTopicMsgs(ulog, 'TopicNames', topicNames);

%% 2. 将数据整理到结构体中
%==========================================================================
logData = struct();

for i = 1:height(allMsgs)
    topicName = allMsgs.TopicNames{i};
    if ~isempty(allMsgs.TopicMessages{i})
        logData.(topicName) = allMsgs.TopicMessages{i};
        fprintf('已提取话题: %s (共 %d 条消息)\n', topicName, height(logData.(topicName)));
    else
        fprintf('警告: 话题 %s 在日志中未找到或没有消息。\n', topicName);
    end
end

clear allMsgs ulog i topicName;

%% 3. 将数据转换为 Simulink 兼容的 timeseries 对象
%==========================================================================
fprintf('\n正在将数据转换为 Simulink timeseries 对象...\n');

% 检查logData是否存在，避免后续出错
if isempty(fieldnames(logData))
    error('logData 结构体为空，没有任何数据被提取，脚本终止。');
end

% 设定一个统一的仿真起始时间（通常以第一个传感器数据为准）
% 检查 sensor_accel 是否存在
if isfield(logData, 'sensor_accel') && ~isempty(logData.sensor_accel)
    startTime = logData.sensor_accel.timestamp(1);
else
    % 如果没有accel数据，找一个存在的数据作为时间基准
    fnames = fieldnames(logData);
    startTime = logData.(fnames{1}).timestamp(1);
    fprintf('警告: 未找到 sensor_accel，使用 %s 作为时间基准。\n', fnames{1});
end


% --- 传感器数据 ---
if isfield(logData, 'sensor_accel')
    time_vec = seconds(logData.sensor_accel.timestamp - startTime);
    data_mat = [logData.sensor_accel.x, logData.sensor_accel.y, logData.sensor_accel.z];
    sensor_accel_ts = timeseries(data_mat, time_vec, 'Name', 'Accelerometer');
end

if isfield(logData, 'sensor_gyro')
    time_vec = seconds(logData.sensor_gyro.timestamp - startTime);
    data_mat = [logData.sensor_gyro.x, logData.sensor_gyro.y, logData.sensor_gyro.z];
    sensor_gyro_ts = timeseries(data_mat, time_vec, 'Name', 'Gyroscope');
end

if isfield(logData, 'sensor_mag')
    time_vec = seconds(logData.sensor_mag.timestamp - startTime);
    data_mat = [logData.sensor_mag.x, logData.sensor_mag.y, logData.sensor_mag.z];
    sensor_mag_ts = timeseries(data_mat, time_vec, 'Name', 'Magnetometer');
end

if isfield(logData, 'sensor_baro')
    time_vec = seconds(logData.sensor_baro.timestamp - startTime);
    data_mat = logData.sensor_baro.pressure;
    sensor_baro_ts = timeseries(data_mat, time_vec, 'Name', 'Barometer');
end

% --- 姿态和位置估计数据 ---
if isfield(logData, 'estimator_attitude')
    time_vec = seconds(logData.estimator_attitude.timestamp - startTime);
    data_mat = logData.estimator_attitude.q; % q 本身就是 [N x 4] 矩阵
    estimator_attitude_ts = timeseries(data_mat, time_vec, 'Name', 'Estimator Attitude (Quaternion)');
end

if isfield(logData, 'vehicle_attitude')
    time_vec = seconds(logData.vehicle_attitude.timestamp - startTime);
    data_mat = logData.vehicle_attitude.q; % q 本身就是 [N x 4] 矩阵
    vehicle_attitude_ts = timeseries(data_mat, time_vec, 'Name', 'Vehicle Attitude (Quaternion)');
end

if isfield(logData, 'vehicle_local_position')
    time_vec = seconds(logData.vehicle_local_position.timestamp - startTime);
    data_mat = [logData.vehicle_local_position.x, logData.vehicle_local_position.y, logData.vehicle_local_position.z, ...
                logData.vehicle_local_position.vx, logData.vehicle_local_position.vy, logData.vehicle_local_position.vz];
    vehicle_local_position_ts = timeseries(data_mat, time_vec, 'Name', 'Vehicle Local Position');
end

fprintf('数据转换完成！现在可以在 Simulink From Workspace 模块中使用 _ts 结尾的变量。\n');

% 清理中间变量，只保留转换后的 timeseries 对象
clear logData startTime time_vec data_mat;


% %% 3. 为 Simulink From Workspace 模块准备数据
% %==========================================================================
% % 不同话题的采样率不同，需要重采样到一个统一的时间轴上才能合并
% % 我们选择一个高频信号作为时间基准，例如 vehicle_imu
% 
% if isfield(logData, 'vehicle_imu')
%     fprintf('\n正在为 Simulink 准备数据，以 vehicle_imu 时间为基准...\n');
% 
%     % 1. 创建基准时间向量 (单位: 秒)
%     baseTime = seconds(logData.vehicle_imu.timestamp);
% 
%     % 2. 初始化一个 cell 数组来存储所有 timeseries 对象和标签
%     ts_all = {};
%     signal_labels = {};
% 
%     % 3. 遍历 logData 中的每个话题，提取数据并创建 timeseries 对象
%     fields = fieldnames(logData);
%     for i = 1:length(fields)
%         topicName = fields{i};
%         dataTable = logData.(topicName);
% 
%         % 获取当前话题的时间戳
%         time_s = seconds(dataTable.timestamp);
% 
%         % 遍历数据表中的每一列（除了时间戳）
%         for varName = string(dataTable.Properties.VariableNames)
%             if ~strcmp(varName, 'timestamp')
%                 dataVector = dataTable.(varName);
% 
%                 % 如果数据是多维的（例如四元数 q），则分别处理
%                 if size(dataVector, 2) > 1
%                     for k = 1:size(dataVector, 2)
%                         ts = timeseries(dataVector(:,k), time_s, 'Name', sprintf('%s_%s_%d', topicName, varName, k));
%                         ts.DataInfo.Interpolation = zlpi.InterpMethod.Linear; % 设置线性插值
%                         ts_all{end+1} = ts;
%                         signal_labels{end+1} = ts.Name;
%                     end
%                 else % 如果数据是一维的
%                     ts = timeseries(dataVector, time_s, 'Name', sprintf('%s_%s', topicName, varName));
%                     ts.DataInfo.Interpolation = zlpi.InterpMethod.Linear; % 设置线性插值
%                     ts_all{end+1} = ts;
%                     signal_labels{end+1} = ts.Name;
%                 end
%             end
%         end
%     end
% 
%     % 4. 将所有 timeseries 对象重采样到基准时间轴
%     if ~isempty(ts_all)
%         resampled_ts = resample(ts_all{1}, baseTime);
%         resampled_data = resampled_ts.Data;
% 
%         for i = 2:length(ts_all)
%             resampled_ts = resample(ts_all{i}, baseTime);
%             resampled_data = [resampled_data, resampled_ts.Data];
%         end
% 
%         % 5. 创建最终的 Simulink 结构体
%         sim_data.time = baseTime;
%         sim_data.signals.values = resampled_data;
%         sim_data.signals.dimensions = size(resampled_data, 2);
%         sim_data.signals.label = signal_labels; % 存储标签以便参考
% 
%         fprintf('Simulink 数据结构 `sim_data` 创建成功！\n');
%         fprintf('它包含 %d 个时间点和 %d 个信号。\n', length(sim_data.time), sim_data.signals.dimensions);
%         fprintf('您可以在 Simulink 的 "From Workspace" 模块中直接使用变量 `sim_data`。\n');
%     else
%         fprintf('警告:未能提取到任何可用于创建Simulink数据结构的时间序列数据。\n');
%     end
% 
% else
%     fprintf('警告: 未找到基准话题 `vehicle_imu`，跳过 Simulink 数据合并步骤。\n');
% end
% 
% 
% %% 4. 可视化所有提取的数据
% %==========================================================================
% fprintf('\n正在生成数据可视化图表...\n');
% 
% % --- 图 1: 姿态角 (Vehicle Attitude) ---
% if isfield(logData, 'vehicle_attitude')
%     figure('Name', 'Vehicle Attitude', 'NumberTitle', 'off');
% 
%     time_s = seconds(logData.vehicle_attitude.timestamp);
%     q = logData.vehicle_attitude.q;
%     eul_rad = quat2eul(q, 'ZYX'); % [Yaw, Pitch, Roll]
% 
%     subplot(3,1,1);
%     plot(time_s, rad2deg(eul_rad(:,3)), 'LineWidth', 1.5);
%     grid on; title('Roll Angle'); xlabel('Time (s)'); ylabel('Angle (deg)');
% 
%     subplot(3,1,2);
%     plot(time_s, rad2deg(eul_rad(:,2)), 'LineWidth', 1.5);
%     grid on; title('Pitch Angle'); xlabel('Time (s)'); ylabel('Angle (deg)');
% 
%     subplot(3,1,3);
%     plot(time_s, rad2deg(eul_rad(:,1)), 'LineWidth', 1.5);
%     grid on; title('Yaw Angle'); xlabel('Time (s)'); ylabel('Angle (deg)');
% 
%     sgtitle('Vehicle Attitude (Roll, Pitch, Yaw)');
%     linkaxes(findobj(gcf, 'type', 'axes'), 'x'); % 联动 x 轴
% end
% 
% % --- 图 2: IMU 传感器数据 (Accelerometer & Gyroscope) ---
% if isfield(logData, 'sensor_accel') && isfield(logData, 'sensor_gyro')
%     figure('Name', 'IMU Sensor Data', 'NumberTitle', 'off');
% 
%     subplot(2,1,1);
%     time_s = seconds(logData.sensor_accel.timestamp);
%     plot(time_s, logData.sensor_accel.x, time_s, logData.sensor_accel.y, time_s, logData.sensor_accel.z);
%     grid on; title('Accelerometer'); xlabel('Time (s)'); ylabel('m/s^2');
%     legend('Acc X', 'Acc Y', 'Acc Z', 'Location','best');
% 
%     subplot(2,1,2);
%     time_s = seconds(logData.sensor_gyro.timestamp);
%     plot(time_s, logData.sensor_gyro.x, time_s, logData.sensor_gyro.y, time_s, logData.sensor_gyro.z);
%     grid on; title('Gyroscope'); xlabel('Time (s)'); ylabel('rad/s');
%     legend('Gyro X', 'Gyro Y', 'Gyro Z', 'Location','best');
% 
%     sgtitle('IMU Sensor Raw Data');
%     linkaxes(findobj(gcf, 'type', 'axes'), 'x');
% end
% 
% % --- 图 3: 磁力计和气压计数据 ---
% if isfield(logData, 'sensor_mag') && isfield(logData, 'sensor_baro')
%     figure('Name', 'Magnetometer & Barometer', 'NumberTitle', 'off');
% 
%     subplot(2,1,1);
%     time_s = seconds(logData.sensor_mag.timestamp);
%     plot(time_s, logData.sensor_mag.x, time_s, logData.sensor_mag.y, time_s, logData.sensor_mag.z);
%     grid on; title('Magnetometer'); xlabel('Time (s)'); ylabel('Gauss');
%     legend('Mag X', 'Mag Y', 'Mag Z', 'Location','best');
% 
%     subplot(2,1,2);
%     time_s = seconds(logData.sensor_baro.timestamp);
%     plot(time_s, logData.sensor_baro.pressure);
%     grid on; title('Barometer'); xlabel('Time (s)'); ylabel('mbar');
% 
%     sgtitle('Other Sensors Data');
%     linkaxes(findobj(gcf, 'type', 'axes'), 'x');
% end
% 
% % --- 图 4: 本地位置估计 (Vehicle Local Position) ---
% if isfield(logData, 'vehicle_local_position')
%     figure('Name', 'Vehicle Local Position', 'NumberTitle', 'off');
%     time_s = seconds(logData.vehicle_local_position.timestamp);
% 
%     subplot(3,1,1);
%     plot(time_s, logData.vehicle_local_position.x);
%     grid on; title('Position X'); xlabel('Time (s)'); ylabel('meters');
% 
%     subplot(3,1,2);
%     plot(time_s, logData.vehicle_local_position.y);
%     grid on; title('Position Y'); xlabel('Time (s)'); ylabel('meters');
% 
%     subplot(3,1,3);
%     plot(time_s, -logData.vehicle_local_position.z); % Z 轴通常是向下的，取负号表示高度
%     grid on; title('Altitude (from Z)'); xlabel('Time (s)'); ylabel('meters');
% 
%     sgtitle('Vehicle Local Position (NED Frame)');
%     linkaxes(findobj(gcf, 'type', 'axes'), 'x');
% end
% 
% % --- 图 5: 全球位置估计 (GPS vs. Estimated) ---
% if isfield(logData, 'vehicle_global_position') && isfield(logData, 'sensor_gps')
%     figure('Name', 'Global Position', 'NumberTitle', 'off');
% 
%     subplot(3,1,1);
%     hold on;
%     plot(seconds(logData.sensor_gps.timestamp), logData.sensor_gps.lat * 1e-7, '.', 'MarkerSize', 8);
%     plot(seconds(logData.vehicle_global_position.timestamp), logData.vehicle_global_position.lat, 'LineWidth', 1.5);
%     hold off;
%     grid on; title('Latitude'); xlabel('Time (s)'); ylabel('degrees');
%     legend('Raw GPS', 'Estimated', 'Location','best');
% 
%     subplot(3,1,2);
%     hold on;
%     plot(seconds(logData.sensor_gps.timestamp), logData.sensor_gps.lon * 1e-7, '.', 'MarkerSize', 8);
%     plot(seconds(logData.vehicle_global_position.timestamp), logData.vehicle_global_position.lon, 'LineWidth', 1.5);
%     hold off;
%     grid on; title('Longitude'); xlabel('Time (s)'); ylabel('degrees');
%     legend('Raw GPS', 'Estimated', 'Location','best');
% 
%     subplot(3,1,3);
%     hold on;
%     plot(seconds(logData.sensor_gps.timestamp), logData.sensor_gps.alt * 1e-3, '.', 'MarkerSize', 8);
%     plot(seconds(logData.vehicle_global_position.timestamp), logData.vehicle_global_position.alt, 'LineWidth', 1.5);
%     hold off;
%     grid on; title('Altitude'); xlabel('Time (s)'); ylabel('meters');
%     legend('Raw GPS', 'Estimated', 'Location','best');
% 
%     sgtitle('Global Position: Raw GPS vs. Estimated');
%     linkaxes(findobj(gcf, 'type', 'axes'), 'x');
% end
% 
% fprintf('\n处理完成！\n');