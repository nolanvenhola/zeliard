#ifndef ZELIARD_THIRD_PARTY_8086TINY_H
#define ZELIARD_THIRD_PARTY_8086TINY_H

/* Adapted from 8086tiny 1.25 by Adrian Cable. See LICENSE.txt. */

enum {
    ZEL_TINY86_HALTED = 0,
    ZEL_TINY86_YIELDED = 1
};

enum {
    ZEL_TINY86_AX = 0,
    ZEL_TINY86_CX = 1,
    ZEL_TINY86_DX = 2,
    ZEL_TINY86_BX = 3,
    ZEL_TINY86_SP = 4,
    ZEL_TINY86_BP = 5,
    ZEL_TINY86_SI = 6,
    ZEL_TINY86_DI = 7,
    ZEL_TINY86_ES = 8,
    ZEL_TINY86_CS = 9,
    ZEL_TINY86_SS = 10,
    ZEL_TINY86_DS = 11
};

typedef void (*zel_tiny86_out_fn)(void *context, unsigned short port,
                                  unsigned char value);
typedef int (*zel_tiny86_step_fn)(void *context, unsigned short cs,
                                  unsigned short ip);

void zel_tiny86_reset(const unsigned char *bios, unsigned bios_size);
void zel_tiny86_set_out_callback(zel_tiny86_out_fn callback, void *context);
void zel_tiny86_set_step_callback(zel_tiny86_step_fn callback, void *context);
int zel_tiny86_run(unsigned max_instructions);
unsigned char *zel_tiny86_memory(void);
unsigned zel_tiny86_memory_size(void);
unsigned short *zel_tiny86_registers(void);
unsigned char *zel_tiny86_byte_registers(void);
unsigned short zel_tiny86_ip(void);
void zel_tiny86_set_ip(unsigned short value);
void zel_tiny86_set_flags(unsigned short value);
void zel_tiny86_set_io_port(unsigned short port, unsigned char value);

#endif
