/**
 ******************************************************************************
 * @file    ms5611.h
 * @author
 * @version V2.0.0
 * @date    2023-10-27
 * @brief   MS5611 pressure sensor driver header file.
 *          
 ******************************************************************************
 */

#ifndef __MS5611_H
#define __MS5611_H

#include <stdint.h>

/*状态机状态定义，MS5611每次开始转换数据需要等待一段时间，状态机机制与任务调用间隔配合可以避免阻塞式等待*/
typedef enum
{
    MS5611_STATE_WAIT_PRESSURE,    // 等待压力数据
    MS5611_STATE_WAIT_TEMPERATURE, // 等待温度数据
} ms5611_state_t;

/* OSR (Over Sampling Ratio) settings */
typedef enum
{
    MS5611_OSR_256 = 0x00,  // Conversion time: 0.60 ms
    MS5611_OSR_512 = 0x02,  // Conversion time: 1.17 ms
    MS5611_OSR_1024 = 0x04, // Conversion time: 2.28 ms
    MS5611_OSR_2048 = 0x06, // Conversion time: 4.54 ms
    MS5611_OSR_4096 = 0x08  // Conversion time: 9.04 ms
} ms5611_osr_t;

/**
 * @brief Hardware interface function pointer types
 */
typedef uint8_t (*ms5611_spi_txrx_t)(uint8_t tx_data);
typedef void (*ms5611_cs_ctrl_t)(uint8_t state);
typedef void (*ms5611_delay_ms_t)(uint32_t ms);
typedef uint32_t (*ms5611_get_time_ms_t)(void);



/**
 * @brief Structure to hold final sensor data.
 */
typedef struct
{
    int32_t pressure_pa;      // Pressure in Pascals (e.g., 101325 Pa)
    int32_t temperature_degC; // Temperature in degrees Celsius * 100 (e.g., 25.12°C -> 2512)
} ms5611_data_t;

/**
 * @brief MS5611 device handle structure.
 *        This should be initialized by the user and passed to driver functions.
 */
typedef struct
{
    // PROM calibration data
    uint16_t c1, c2, c3, c4, c5, c6;

    // Over-sampling ratio setting
    ms5611_osr_t osr;

    // User-provided hardware interface functions
    ms5611_spi_txrx_t spi_txrx; // Pointer to SPI transmit/receive function
    ms5611_cs_ctrl_t cs_ctrl;   // Pointer to CS control function (0 for low, 1 for high)
    ms5611_delay_ms_t delay_ms; // Pointer to millisecond delay function
    ms5611_get_time_ms_t get_time_ms;

    ms5611_state_t state;
    uint32_t conversion_start_time;
    uint32_t raw_pressure;    // D1
    uint32_t raw_temperature; // D2
    // Last valid data
    ms5611_data_t last_data;
} ms5611_handle_t;





int8_t ms5611_init(ms5611_handle_t *dev);
int8_t ms5611_read(ms5611_handle_t *dev);
void ms5611_get_data(ms5611_handle_t *dev, ms5611_data_t *data);

#endif /* __MS5611_H */


