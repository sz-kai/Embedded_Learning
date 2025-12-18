clc;
clear;
close all;
load PX4data.mat

%% 数据处理配置
% 使用结构体定义每个总线的配置
% 字段名 = 原始数据变量名
% 字段值 = 在最终结构体中的路径

% IMU 配置
imuConfig.IMU_AccX = 'Acc.X';
imuConfig.IMU_AccY = 'Acc.Y';
imuConfig.IMU_AccZ = 'Acc.Z';
imuConfig.IMU_GyroX = 'Gyro.X';
imuConfig.IMU_GyroY = 'Gyro.Y';
imuConfig.IMU_GyroZ = 'Gyro.Z';

% 磁力计配置
magConfig.IMU_MagX = 'X';
magConfig.IMU_MagY = 'Y';
magConfig.IMU_MagZ = 'Z';

% 气压计配置
pressureConfig.SENS_BaroAlt = 'Pressure';

% 由于原始数据中没有这几个值，所以这里创建下
GPS_eph=ones(54762, 1);
GPS_epv=ones(54762, 1);
GPS_GotP=ones(54762, 1);
GPS_GotV=ones(54762, 1);
% GPS 配置
gpsConfig.GPS_Lat = 'Lat';
gpsConfig.GPS_Lon = 'Lon';
gpsConfig.GPS_Alt = 'Alt';
gpsConfig.GPS_VelN = 'VelN';
gpsConfig.GPS_VelE = 'VelE';
gpsConfig.GPS_VelD = 'VelD';
gpsConfig.GPS_eph = 'eph';
gpsConfig.GPS_epv = 'epv';
gpsConfig.GPS_GotP = 'GotP';
gpsConfig.GPS_GotV = 'GotV';

% 姿态(ATT)配置
attConfig.ATT_Roll = 'Roll';
attConfig.ATT_Pitch = 'Pitch';
attConfig.ATT_Yaw = 'Yaw';
attConfig.ATT_RollRate = 'RollRate';
attConfig.ATT_PitchRate = 'PitchRate';
attConfig.ATT_YawRate = 'YawRate';
attConfig.ATSP_RollSP = 'RollSP';
attConfig.ATSP_PitchSP = 'PitchSP';
attConfig.ATSP_YawSP = 'YawSP';

% 本地位置(LPOS)配置
lposConfig.LPOS_Z = 'Z';
lposConfig.LPOS_VZ = 'VZ';


%% 批量创建Simulink数据和总线
% 主循环，处理所有配置
allConfigs = {
    {'IMU_Data', 'IMU_Bus', imuConfig};
    {'MAG_Data', 'MAG_Bus', magConfig};
    {'PRESSURE_Data', 'PRESSURE_Bus', pressureConfig};
    {'GPS_Data', 'GPS_Bus', gpsConfig};
    {'ATT_Data', 'ATT_Bus', attConfig};
    {'LPOS_Data', 'LPOS_Bus', lposConfig};
};

for i = 1:length(allConfigs)
    config = allConfigs{i};
    dataStructName = config{1};
    busName = config{2};
    signalConfig = config{3};
    
    % 调用辅助函数来完成所有工作
    createdStruct = create_bus_object(busName, signalConfig, time);
    
    % 将生成的数据结构体（如IMU_Data）赋值到base工作区，供Simulink使用
    assignin('base', dataStructName, createdStruct);
end

%% 清理工作区
% 清理掉所有配置变量，保持工作区干净
clear imuConfig magConfig pressureConfig gpsConfig attConfig lposConfig;
clear allConfigs config dataStructName busName signalConfig createdStruct i;

% disp('所有Simulink总线和数据结构已成功创建！');
% disp('工作区中的主要变量:');
% whos