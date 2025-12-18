/**
  ******************************************************************************
  * @file    com_data.h
  * @author  kai
  * @version V1.0.0
  * @data    2025/07/21
  * @brief   全局数据
  ******************************************************************************
  * @attention
  *
  * 
  *
  ******************************************************************************
  */
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __COM_DATA_H
#define __COM_DATA_H
/* Includes ------------------------------------------------------------------*/
#include "stdint.h"
#include "com_type.h"
#include "ringbuff.h"
/**********************************通用数据类型******************************************/
/*三轴有符号16位数据*/
typedef union
{
    struct
    {
        int16_t x;
        int16_t y;
        int16_t z;
    };
    int16_t axis_arr[3];
} Axis3_i16_u;

/*三轴无符号16位数据*/
typedef union
{
    struct
    {
        uint16_t x;
        uint16_t y;
        uint16_t z;
    };
    uint16_t axis_arr[3];
} Axis3_u16_u;

/*三轴有符号32位数据*/
typedef union
{
    struct
    {
        int32_t x;
        int32_t y;
        int32_t z;
    };
    int32_t axis_arr[3];
} Axis3_i32_u;

/*三轴无符号32位数据*/
typedef union
{
    struct
    {
        uint32_t x;
        uint32_t y;
        uint32_t z;
    };
    uint32_t axis_arr[3];
} Axis3_u32_u;


/*三轴有符号64位数据*/
typedef union
{
    struct
    {
        int64_t x;
        int64_t y;
        int64_t z;
    };
    int64_t axis_arr[3];
} Axis3_i64_u;

/*三轴无符号64位数据*/
typedef union
{
    struct
    {
        uint64_t x;
        uint64_t y;
        uint64_t z;
    };
    uint64_t axis_arr[3];
} Axis3_u64_u;

/*三轴浮点数数据*/
typedef union
{
    struct
    {
        float x;
        float y;
        float z;
    };
    float axis_arr[3];
} Axis3_f_u;



/**********************************定时器相关******************************************/
extern uint32_t Tick;
/*主循环频率更新标志位*/
extern volatile FlagStatus Main_Loop_Update_Flag;

/*归一化后的遥控器数据(9通道)*/
// extern __IO rc_data_norm_t rc_data_norm;
/*遥控数据处理总结构体*/
extern volatile rc_state_t rc_state;

/**********************************数据记录*************************************/
extern ringbuff_t SD_W_RingBuffMgr;

/**********************************传感器任务相关*************************************/
/******************IMU相关************************/

typedef struct
{
    Axis3_i16_u acc;
    Axis3_i16_u gyro;
} IMU_RawData_t;


typedef struct
{
    Axis3_f_u acc;
    Axis3_f_u gyro;
} IMU_Data_t;


/*imu原始数据*/
extern IMU_RawData_t imu_raw_data;
/*imu校准数据*/
extern IMU_Data_t imu_cal_data;
/*imu滤波数据*/
extern IMU_Data_t imu_filter_data;

/******************磁力计相关************************/
typedef Axis3_i16_u MAG_RawData_t;
typedef Axis3_f_u MAG_Data_t;
/*磁力计原始数据*/
extern MAG_RawData_t mag_raw_data;
/*磁力计转换数据(高斯)*/
extern MAG_Data_t mag_gauss_data;
/*磁力计校准数据*/
extern MAG_Data_t mag_cal_data;
/*磁力计滤波数据*/
extern MAG_Data_t mag_filter_data;


/******************气压计相关************************/
/*气压计原始数据*/
typedef struct
{
    int32_t pressure;      /*大气压强，单位：帕斯卡*/
    int32_t temperature; /*温度，单位：摄氏度*/
} BARO_RawData_t;

/*气压计数据结构体*/
typedef struct
{
    float pressure;    /*大气压强，单位：帕斯卡*/
    float temperature; /*温度，单位：摄氏度*/
} BARO_Data_t;

/*气压计原始数据*/
extern BARO_RawData_t baro_raw_data;
/*气压计滤波数据*/
extern BARO_Data_t baro_filter_data;

typedef struct
{
    uint64_t timestamp; // required for logger
    uint64_t time_utc_usec;
    int32_t lat;
    int32_t lon;
    int32_t alt;
    int32_t alt_ellipsoid;
    float s_variance_m_s;
    float c_variance_rad;
    float eph;
    float epv;
    float hdop;
    float vdop;
    int32_t noise_per_ms;
    int32_t jamming_indicator;
    float vel_m_s;
    float vel_n_m_s;
    float vel_e_m_s;
    float vel_d_m_s;
    float cog_rad;
    int32_t timestamp_time_relative;
    uint8_t fix_type;
    uint8_t vel_ned_valid;
    uint8_t satellites_used;
    uint8_t _padding0[5]; // required for logger

    volatile uint8_t _got_posllh;                          /*解析到位置数据标志*/
    volatile uint8_t _got_velned;                          /*解析到速度数据标志*/
} GPS_Data_t;

/**********************************飞行控制数据******************************************/
/*三轴枚举*/
typedef enum
{
    ROLL,      /*滚转*/
    PITCH,     /*俯仰*/
    YAW,       /*偏航*/
    AXIS_COUNT /*轴数量*/
} Axis_e;

/*状态结构体*/
typedef struct
{
    float angle;        /*角度*/
    float angle_target; /*期望角度*/
    float rate;         /*角速度*/
    float rate_target;  /*期望角速度*/
} Axis_State_t;

/*三轴欧拉角*/
typedef union
{
    struct
    {
        float roll;
        float pitch;
        float yaw;
    };
    float axis_arr[3];
} Euler_u;

/*姿态解算结果数据结构体*/
typedef struct
{
    Euler_u euler;
    float rotation_matrix[3][3];
} attitude_t;

/*传感器数据结构体*/
typedef struct
{
    Axis3_f_u gyro;
    Axis3_f_u acc;
    Axis3_f_u mag;
    float baro_alt;
    GPS_Data_t gps;
} Sensor_t;

/*位置、速度估计数据结构体*/
typedef struct
{
    Axis3_f_u pos;
    Axis3_f_u vel;
    bool pos_valid;/*估计位置可用*/
    bool vel_valid;/*估计速度可用*/
} Pos_Vel_t;
/*飞行控制状态结构体*/
typedef struct
{
    Axis_State_t control_state[AXIS_COUNT]; /*三轴控制状态*/
    Sensor_t sensor;
    attitude_t attitude; /*姿态解算数据(包括欧拉角、旋转矩阵)*/
    Pos_Vel_t pos_vel;
    /*其他状态*/
    float throttle; /*油门*/
} Flight_Control_State_t;
/*飞行控制状态结构体*/
extern volatile Flight_Control_State_t flgt_ctl;

#endif /* __FILE_H */
