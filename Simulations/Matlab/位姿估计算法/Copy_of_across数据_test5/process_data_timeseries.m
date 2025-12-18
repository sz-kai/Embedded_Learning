clc;
clear;
load PX4data.mat
%% 为Simulink准备IMU数据
% 假设原始数据 IMU_AccX/Y/Z, IMU_GyroX/Y/Z 和 time 变量已存在于工作区

% 1. 创建 timeseries 对象
% 加速度计
ts_AccX = timeseries(IMU_AccX, time, 'Name', 'AccX');
ts_AccY = timeseries(IMU_AccY, time, 'Name', 'AccY');
ts_AccZ = timeseries(IMU_AccZ, time, 'Name', 'AccZ');
% 陀螺仪
ts_GyroX = timeseries(IMU_GyroX, time, 'Name', 'GyroX');
ts_GyroY = timeseries(IMU_GyroY, time, 'Name', 'GyroY');
ts_GyroZ = timeseries(IMU_GyroZ, time, 'Name', 'GyroZ');

% 2. 将 timeseries 对象组织到结构体中
% 结构体的层次将定义Simulink总线的层次
IMU_Data.Acc.X = ts_AccX;
IMU_Data.Acc.Y = ts_AccY;
IMU_Data.Acc.Z = ts_AccZ;

IMU_Data.Gyro.X = ts_GyroX;
IMU_Data.Gyro.Y = ts_GyroY;
IMU_Data.Gyro.Z = ts_GyroZ;

% 3. 从结构体创建 Simulink.Bus 对象
busInfo = Simulink.Bus.createObject(IMU_Data);

% 4. 将自动生成的总线对象重命名为 'IMU_Bus' 并清理临时变量
assignin('base', 'IMU_Bus', evalin('base', busInfo.busName));
evalin('base', ['clear ', busInfo.busName]);

% 5. (可选) 清理掉临时的 timeseries 变量，保持工作区干净
clear ts_AccX ts_AccY ts_AccZ ts_GyroX ts_GyroY ts_GyroZ

%% 磁力计数据
ts_MagX = timeseries(IMU_MagX, time, 'Name', 'MagX');
ts_MagY = timeseries(IMU_MagY, time, 'Name', 'MagY');
ts_MagZ = timeseries(IMU_MagZ, time, 'Name', 'MagZ');

% 组织到结构体中
MAG_Data.X = ts_MagX;
MAG_Data.Y = ts_MagY;
MAG_Data.Z = ts_MagZ;
% 创建 Simulink.Bus 对象
busInfoMag = Simulink.Bus.createObject(MAG_Data);
% 重命名为 'MAG_Bus'
assignin('base', 'MAG_Bus', evalin('base', busInfoMag.busName));
evalin('base', ['clear ', busInfoMag.busName]);
% 清理临时变量
clear ts_MagX ts_MagY ts_MagZ

%% 气压计数据
ts_Pressure = timeseries(SENS_BaroAlt, time, 'Name', 'Pressure');

% 组织到结构体中
PRESSURE_Data.Pressure = ts_Pressure;
% 创建 Simulink.Bus 对象
busInfoPressure = Simulink.Bus.createObject(PRESSURE_Data);
% 重命名为 'PRESSURE_Bus'
assignin('base', 'PRESSURE_Bus', evalin('base', busInfoPressure.busName));
evalin('base', ['clear ', busInfoPressure.busName]);
% 清理临时变量
clear ts_Pressure

%% GPS数据
ts_GPS_Lat = timeseries(GPS_Lat, time, 'Name', 'GPS_Lat');
ts_GPS_Lon = timeseries(GPS_Lon, time, 'Name', 'GPS_Lon');
ts_GPS_Alt = timeseries(GPS_Alt, time, 'Name', 'GPS_Alt');
ts_GPS_VelN = timeseries(GPS_VelN, time, 'Name', 'GPS_VelN');
ts_GPS_VelE = timeseries(GPS_VelE, time, 'Name', 'GPS_VelE');
ts_GPS_VelD = timeseries(GPS_VelD, time, 'Name', 'GPS_VelD');



% 组织到结构体中
GPS_Data.Lat = ts_GPS_Lat;
GPS_Data.Lon = ts_GPS_Lon;
GPS_Data.Alt = ts_GPS_Alt;
GPS_Data.VelN = ts_GPS_VelN;
GPS_Data.VelE = ts_GPS_VelE;
GPS_Data.VelD = ts_GPS_VelD;

% 创建 Simulink.Bus 对象
busInfoGPS = Simulink.Bus.createObject(GPS_Data);
% 重命名为 'GPS_Bus'
assignin('base', 'GPS_Bus', evalin('base', busInfoGPS.busName));
evalin('base', ['clear ', busInfoGPS.busName]);
% 清理临时变量
clear ts_GPS_Lat ts_GPS_Lon ts_GPS_Alt ts_GPS_VelN ts_GPS_VelE ts_GPS_VelD

%% 姿态数据 (ATT)
ts_ATT_Roll = timeseries(ATT_Roll, time, 'Name', 'Roll');
ts_ATT_Pitch = timeseries(ATT_Pitch, time, 'Name', 'Pitch');
ts_ATT_Yaw = timeseries(ATT_Yaw, time, 'Name', 'Yaw');
ts_ATT_RollRate = timeseries(ATT_RollRate, time, 'Name', 'RollRate');
ts_ATT_PitchRate = timeseries(ATT_PitchRate, time, 'Name', 'PitchRate');
ts_ATT_YawRate = timeseries(ATT_YawRate, time, 'Name', 'YawRate');
ts_ATT_RollSP = timeseries(ATSP_RollSP, time, 'Name', 'RollSP');% 设定点
ts_ATT_PitchSP = timeseries(ATSP_PitchSP, time, 'Name', 'PitchSP');% 设定点
ts_ATT_YawSP = timeseries(ATSP_YawSP, time, 'Name', 'YawSP');% 设定点

% 组织到结构体中
ATT_Data.Roll = ts_ATT_Roll;
ATT_Data.Pitch = ts_ATT_Pitch;
ATT_Data.Yaw = ts_ATT_Yaw;
ATT_Data.RollRate = ts_ATT_RollRate;
ATT_Data.PitchRate = ts_ATT_PitchRate;
ATT_Data.YawRate = ts_ATT_YawRate;
ATT_Data.RollSP = ts_ATT_RollSP;
ATT_Data.PitchSP = ts_ATT_PitchSP;
ATT_Data.YawSP = ts_ATT_YawSP;
% 创建 Simulink.Bus 对象
busInfoATT = Simulink.Bus.createObject(ATT_Data);
% 重命名为 'ATT_Bus'
assignin('base', 'ATT_Bus', evalin('base', busInfoATT.busName));
evalin('base', ['clear ', busInfoATT.busName]);
% 清理临时变量
clear ts_ATT_Roll ts_ATT_Pitch ts_ATT_Yaw ts_ATT_RollRate ts_ATT_PitchRate ts_ATT_YawRate ts_ATT_RollSP ts_ATT_PitchSP ts_ATT_YawSP

%% 本地位置数据 (LPOS)
ts_LPOS_Z = timeseries(LPOS_Z, time, 'Name', 'LPOS_Z');
ts_LPOS_VZ = timeseries(LPOS_VZ, time, 'Name', 'LPOS_VZ');

% 组织到结构体中
LPOS_Data.Z = ts_LPOS_Z;
LPOS_Data.VZ = ts_LPOS_VZ;

% 创建 Simulink.Bus 对象
busInfoLPOS = Simulink.Bus.createObject(LPOS_Data);
% 重命名为 'LPOS_Bus'
assignin('base', 'LPOS_Bus', evalin('base', busInfoLPOS.busName));
evalin('base', ['clear ', busInfoLPOS.busName]);
% 清理临时变量
clear ts_LPOS_Z ts_LPOS_VZ
