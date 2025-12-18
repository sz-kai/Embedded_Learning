/**
  ******************************************************************************
  * @file    task_integrated_navigation.c
  * @author  kai
  * @version V1.0.0
  * @data    2025/09/30
  * @brief   组合导航任务
  ******************************************************************************
  * @attention
  *
  * 组合导航任务
  *
  ******************************************************************************
  */
#include "task_integrated_navigation.h"


Attitude_Estimate_t att_est;/*姿态解算结构体*/
Position_Estimate_t pos_est;/*位置估计结构体*/
/**
  * @brief  组合导航任务初始化
  * @note   
  * @param  无
  * @retval 无
  */
void Task_IntegratedNavigation_Init(void)
{
    att_est.attitude_estimate_init_flag = false;

    pos_est.init_flag = false;
    pos_est.baro_offset = 0.0f;
    pos_est.baro_init_count = 0;
}

/**
  * @brief  组合导航任务
  * @note   
  * @param  无
  * @retval 无
  */

void Task_IntegratedNavigation(void)
{
    /*姿态解算，更新三轴欧拉角*/
    attitude_estimate_update(&att_est,&flgt_ctl.sensor);
    att_est_get_data(&att_est,&flgt_ctl.attitude);
    /*位置估计，更新位置、速度，50hz*/
    if (LOOP_FREQ_SET(LOOP_50_Hz, Tick, LOOP_500_Hz))
    {
        position_estimate_update(&pos_est,&flgt_ctl);
        position_estimate_get_pos_vel(&pos_est,&flgt_ctl.pos_vel);
    }
}


