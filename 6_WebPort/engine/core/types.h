#ifndef ZELIARD_TYPES_H
#define ZELIARD_TYPES_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef int8_t   i8;
typedef int16_t  i16;
typedef int32_t  i32;

#define ZELIARD_WIDTH  320
#define ZELIARD_HEIGHT 200
#define ZELIARD_FB_SIZE (ZELIARD_WIDTH * ZELIARD_HEIGHT)

#endif
