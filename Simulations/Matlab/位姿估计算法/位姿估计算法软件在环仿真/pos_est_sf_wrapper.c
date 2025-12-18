
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
#include "pro_config.h"
#include "task_integrated_navigation.h"
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
#define y_5_width 3
#define y_6_width 3

/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
/*角速度积分解算姿态*/
extern Euler_Test_t gyro_euler;
/*加速度、磁力计解算姿态*/
extern Euler_Test_t acc_mag_euler;
extern float est_z_perd[2];
extern float est_x_perd[2];
extern float est_y_perd[2];
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Start function
 *
 */
void pos_est_sf_Start_wrapper(void)
{
/* %%%-SFUNWIZ_wrapper_Start_Changes_BEGIN --- EDIT HERE TO _END */
Task_IntegratedNavigation_Init();
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
			real_T *att_gyro,
			real_T *alt_acc,
			real_T *vel_acc)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
flgt_ctl.sensor.acc.x = IMU->Acc.X;
    flgt_ctl.sensor.acc.y = IMU->Acc.Y;
    flgt_ctl.sensor.acc.z = IMU->Acc.Z;
    flgt_ctl.sensor.gyro.x = IMU->Gyro.X;
    flgt_ctl.sensor.gyro.y = IMU->Gyro.Y;
    flgt_ctl.sensor.gyro.z = IMU->Gyro.Z;
    flgt_ctl.sensor.mag.x = Mag->X;
    flgt_ctl.sensor.mag.y = Mag->Y;
    flgt_ctl.sensor.mag.z = Mag->Z;
    flgt_ctl.sensor.baro_alt = Baro->Pressure;
    flgt_ctl.sensor.gps.lat = GPS->Lat;
    flgt_ctl.sensor.gps.lon = GPS->Lon;
    flgt_ctl.sensor.gps.alt = GPS->Alt;
    flgt_ctl.sensor.gps.vel_n_m_s = GPS->VelN;
    flgt_ctl.sensor.gps.vel_e_m_s = GPS->VelE;
    flgt_ctl.sensor.gps.vel_d_m_s = GPS->VelD;
    flgt_ctl.sensor.gps.eph = GPS->eph;
    flgt_ctl.sensor.gps.epv = GPS->epv;
    flgt_ctl.sensor.gps._got_posllh = GPS->GotP;
    flgt_ctl.sensor.gps._got_velned = GPS->GotV;
    flgt_ctl.sensor.gps.satellites_used = GPS->satellites_used;
    Task_IntegratedNavigation();

    pos[0] = flgt_ctl.pos_vel.pos.x;
    pos[1] = flgt_ctl.pos_vel.pos.y;
    pos[2] = flgt_ctl.pos_vel.pos.z;

    vel[0] = flgt_ctl.pos_vel.vel.x;
    vel[1] = flgt_ctl.pos_vel.vel.y;
    vel[2] = flgt_ctl.pos_vel.vel.z;
    
    att[0] = flgt_ctl.attitude.euler.roll;
    att[1] = flgt_ctl.attitude.euler.pitch;
    att[2] = flgt_ctl.attitude.euler.yaw;

    att_acc_mag[0] = acc_mag_euler.roll;
    att_acc_mag[1] = acc_mag_euler.pitch;
    att_acc_mag[2] = acc_mag_euler.yaw;

    att_gyro[0] = gyro_euler.roll;
    att_gyro[1] = gyro_euler.pitch;
    att_gyro[2] = gyro_euler.yaw;

    alt_acc[0] = est_x_perd[0];
    alt_acc[1] = est_y_perd[0];
    alt_acc[2] = est_z_perd[0];

    vel_acc[0] = est_x_perd[1];
    vel_acc[1] = est_y_perd[1];
    vel_acc[2] = est_z_perd[1];
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}


