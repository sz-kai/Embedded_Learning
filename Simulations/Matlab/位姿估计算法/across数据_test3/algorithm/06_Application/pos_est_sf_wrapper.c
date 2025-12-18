
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



/* %%%-SFUNWIZ_wrapper_includes_Changes_BEGIN --- EDIT HERE TO _END */
#include <math.h>
#include "com_data.h"
#include "task_integrated_navigation.h"
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 3
#define u_1_width 3
#define u_2_width 3
#define u_3_width 1
#define u_4_width 10
#define y_width 3
#define y_1_width 3
#define y_2_width 3

/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Output function
 *
 */
void pos_est_sf_Outputs_wrapper(const real_T *Acc,
			const real_T *Gyro,
			const real_T *Mag,
			const real_T *Baro,
			const real_T *GPS,
			real_T *pos,
			real_T *vel,
			real_T *angle)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
flgt_ctl.sensor.acc.x = Acc[0];
    flgt_ctl.sensor.acc.y = Acc[1];
    flgt_ctl.sensor.acc.z = Acc[2];
    flgt_ctl.sensor.gyro.x = Gyro[0];
    flgt_ctl.sensor.gyro.y = Gyro[1];
    flgt_ctl.sensor.gyro.z = Gyro[2];
    flgt_ctl.sensor.mag.x = Mag[0];
    flgt_ctl.sensor.mag.y = Mag[1];
    flgt_ctl.sensor.mag.z = Mag[2];
    flgt_ctl.sensor.baro_alt = Baro[0];
    flgt_ctl.sensor.gps.lat = GPS[0];
    flgt_ctl.sensor.gps.lon = GPS[1];
    flgt_ctl.sensor.gps.alt = GPS[2];
    flgt_ctl.sensor.gps.vel_n_m_s = GPS[3];
    flgt_ctl.sensor.gps.vel_e_m_s = GPS[4];
    flgt_ctl.sensor.gps.vel_d_m_s = GPS[5];
    flgt_ctl.sensor.gps.eph = GPS[6];
    flgt_ctl.sensor.gps.epv = GPS[7];
    flgt_ctl.sensor.gps._got_posllh = GPS[8];
    flgt_ctl.sensor.gps._got_velned = GPS[9];
    Task_IntegratedNavigation();
    pos[0] = flgt_ctl.pos_vel.pos.x;
    pos[1] = flgt_ctl.pos_vel.pos.y;
    pos[2] = flgt_ctl.pos_vel.pos.z;
    vel[0] = flgt_ctl.pos_vel.vel.x;
    vel[1] = flgt_ctl.pos_vel.vel.y;
    vel[2] = flgt_ctl.pos_vel.vel.z;
    angle[0] = flgt_ctl.euler.roll;
    angle[1] = flgt_ctl.euler.pitch;
    angle[2] = flgt_ctl.euler.yaw;
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}


