
/*
 * Include Files
 *
 */
#if defined(MATLAB_MEX_FILE)
#include "tmwtypes.h"
#include "simstruc_types.h"
#else
#define SIMPLIFIED_RTWTYPES_COMPATIBILITY
#include "rtwtypes.h"
#undef SIMPLIFIED_RTWTYPES_COMPATIBILITY
#endif

#include "pos_est_sf_bus.h"

/* %%%-SFUNWIZ_wrapper_includes_Changes_BEGIN --- EDIT HERE TO _END */
#include <math.h>
#include "attitude_estimator_mahony.h"
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 1
#define u_1_width 1
#define u_2_width 1
#define u_3_width 1
#define y_width 3
#define y_1_width 3
#define y_2_width 3
#define y_3_width 3
#define y_4_width 3

/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
/* 声明算法中的全局输出变量 */
extern float attitude_roll;
extern float attitude_pitch;
extern float attitude_yaw;
//控制反馈数据
extern Control_state  Ctrl_state;
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Start function
 *
 */
void pos_est_sf_Start_wrapper(void)
{
/* %%%-SFUNWIZ_wrapper_Start_Changes_BEGIN --- EDIT HERE TO _END */
imuInit();
/* %%%-SFUNWIZ_wrapper_Start_Changes_END --- EDIT HERE TO _BEGIN */
}
/*
 * Output function
 *
 */
void pos_est_sf_Outputs_wrapper(const MAG_Bus *Mag,
			const PRESSURE_Bus *Baro,
			const GPS_Bus *GPS,
			const IMU_Bus *IMU,
			real_T *pos,
			real_T *vel,
			real_T *att,
			real_T *att_acc_mag,
			real_T *att_gyro)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
Ctrl_state.accf.x = IMU->Acc.X;
    Ctrl_state.accf.y = IMU->Acc.Y;
    Ctrl_state.accf.z = IMU->Acc.Z;
    Ctrl_state.gyrof.x = IMU->Gyro.X;
    Ctrl_state.gyrof.y = IMU->Gyro.Y;
    Ctrl_state.gyrof.z = IMU->Gyro.Z;
    Ctrl_state.magf.x = Mag->X;
    Ctrl_state.magf.y = Mag->X;
    Ctrl_state.magf.z = Mag->X;
    imuCalculateEstimatedAttitude();
    att[0] = (real_T)(attitude_roll * 57.29578f);
    att[1] = -(real_T)(attitude_pitch * 57.29578f);
    att[2] = -(real_T)(attitude_yaw * 57.29578f);
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}


