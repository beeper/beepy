#pragma once

#define USB_VID				0x1209
#define USB_PID				0xB182
#define USB_PRODUCT			"BBQ20KBD"

#define PIN_INT				0
#define PIN_BKL				25

#define PIN_SDA				18
#define PIN_SCL				23

#define PIN_TP_RESET		16
#define PIN_TP_MOTION		22
#define PIN_TP_SHUTDOWN		24

#define PIN_PUPPET_SDA		28
#define PIN_PUPPET_SCL		29

#define NUM_OF_ROWS			7
#define PINS_ROWS \
	14, \
	13, \
	12, \
	11, \
	10, \
	9, \
	8

#define NUM_OF_COLS			6
#define PINS_COLS \
	1,  \
	2,  \
	3, \
	7, \
	6, \
	5

#define NUM_OF_BTNS			1
#define PINS_BTNS \
	10,
#define BTN_KEYS \
	{ KEY_BTN_RIGHT2 },

#define PIN_GPIOEXP0		20
#define PIN_GPIOEXP1		19
#define PIN_GPIOEXP2		17
//#define PIN_GPIOEXP3		21
//#define PIN_GPIOEXP4		26

//#define PICO_DEFAULT_UART			1
//#define PICO_DEFAULT_UART_TX_PIN	20
