/**
  ******************************************************************************
  * @file    com_data.c
  * @author  kai
  * @version V1.0.0
  * @data    2025/07/21
  * @brief   存放项目需要使用的全局变量、数据类型
  ******************************************************************************
  * @attention
  *
  * 存放的数据类型应该是项目专用,更通用的数据类型在pro_common.h中
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "com_data.h"

/** @addtogroup Drone_F427
* @{
*/ 
/**********************************定时器相关******************************************/
uint32_t Tick = 0;
/*主循环频率更新标志位*/
__IO FlagStatus Main_Loop_Update_Flag = RESET;

// /*遥控器数据(9通道)*/
// __IO rc_data_t rc_data;
// /*归一化映射后的遥控器数据(9通道)*/
// __IO rc_data_norm_t rc_data_norm;
/*遥控数据处理总结构体*/
__IO rc_state_t rc_state;

/**********************************飞行控制数据******************************************/
__IO Flight_Control_State_t flgt_ctl;




/**********************************传感器任务相关*************************************/
/*imu原始数据*/
IMU_RawData_t imu_raw_data;
/*imu校准数据*/
IMU_Data_t imu_cal_data;
/*imu滤波数据*/
IMU_Data_t imu_filter_data;

/*磁力计原始数据*/
Axis3_i16_u mag_raw_data;
/*磁力计转换数据(高斯)*/
Axis3_f_u mag_gauss_data;
/*磁力计校准数据*/
Axis3_f_u mag_cal_data;
///*磁力计滤波数据*/
//HMC5883L_FilterData_t mag_filter_data;

/*气压计原始数据*/
BARO_RawData_t baro_raw_data;
/*气压计滤波数据*/
BARO_Data_t baro_filter_data;

/**
  * @}
  */ 

