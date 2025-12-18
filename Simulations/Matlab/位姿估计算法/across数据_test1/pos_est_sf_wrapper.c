
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
// #include "test.h"
#include "com_data.h"
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 1
#define u_1_width 1
#define u_2_width 1
#define u_3_width 1
#define u_4_width 1
#define y_width 3
#define y_1_width 1

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
			real_T *y0,
			real_T *y1)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
// flgt_ctl.sensor.acc.x = Acc[0];
    // flgt_ctl.sensor.acc.y = Acc[1];
    // flgt_ctl.sensor.acc.z = Acc[2];
    // flgt_ctl.sensor.gyro.x = Gyro[0];
    // flgt_ctl.sensor.gyro.y = Gyro[1];
    // flgt_ctl.sensor.gyro.z = Gyro[2];
    // flgt_ctl.sensor.mag.x = Mag[0];
    // flgt_ctl.sensor.mag.y = Mag[1];
    // flgt_ctl.sensor.mag.z = Mag[2];
    // flgt_ctl.sensor.baro_alt = Baro[0];
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}


