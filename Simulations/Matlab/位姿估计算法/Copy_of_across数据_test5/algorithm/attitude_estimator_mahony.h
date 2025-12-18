#ifndef __ATTITUDE_ESTIMATOR_MAHONY_H
#define __ATTITUDE_ESTIMATOR_MAHONY_H

#include "stdint.h"

#define sq(x) ((x)*(x))
#define DEGREES_TO_RADIANS(angle) ((angle) * 0.0174532925f)

typedef struct{
	float x;
	float y;
	float z;
}Vector3_Float;

typedef struct{
	Vector3_Float accf;
	Vector3_Float gyrof;
	Vector3_Float magf;
	float roll;
	float pitch;
	float yaw;
	
	uint8_t xy_valid;
	uint8_t z_valid;
	uint8_t v_xy_valid;
	uint8_t v_z_valid;
	
	//position and velocity in NED frame
	float x, y, z;
	float vx, vy, vz;
	float pre_vx,pre_vy,pre_vz;
	float xacc,yacc,zacc;
	
	double ref_lat;
	double ref_lon;
	float ref_alt;
	float Altitude_Ground;
	
}Control_state;

static void imuComputeRotationMatrix(void);
void imuInit(void);
static float invSqrt(float x);

static void imuMahonyAHRSupdate(float dt, float gx, float gy, float gz,
                                uint8_t useAcc, float ax, float ay, float az,
                                uint8_t useMag, float mx, float my, float mz,
                                uint8_t useYaw, float yawError);
static void imuUpdateEulerAngles(void);
static uint8_t imuIsAccelerometerHealthy(void);
static uint8_t isMagnetometerHealthy(void);
void imuCalculateEstimatedAttitude(void);

extern float attitude_roll,attitude_pitch,attitude_yaw;			
extern float rMat[3][3];																
																
#endif

