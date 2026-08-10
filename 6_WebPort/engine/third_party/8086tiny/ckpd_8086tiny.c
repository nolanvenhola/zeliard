/* Private 8086tiny instance for the exact 209CKPD town-side renderer. */
#define zel_tiny86_reset zel_ckpd86_reset
#define zel_tiny86_set_out_callback zel_ckpd86_set_out_callback
#define zel_tiny86_set_step_callback zel_ckpd86_set_step_callback
#define zel_tiny86_run zel_ckpd86_run
#define zel_tiny86_memory zel_ckpd86_memory
#define zel_tiny86_memory_size zel_ckpd86_memory_size
#define zel_tiny86_registers zel_ckpd86_registers
#define zel_tiny86_byte_registers zel_ckpd86_byte_registers
#define zel_tiny86_ip zel_ckpd86_ip
#define zel_tiny86_set_ip zel_ckpd86_set_ip
#define zel_tiny86_set_flags zel_ckpd86_set_flags
#define zel_tiny86_set_io_port zel_ckpd86_set_io_port
#define set_CF zel_ckpd86_set_CF
#define set_AF zel_ckpd86_set_AF
#define set_OF zel_ckpd86_set_OF
#define set_AF_OF_arith zel_ckpd86_set_AF_OF_arith
#define make_flags zel_ckpd86_make_flags
#define set_flags zel_ckpd86_set_flags_internal
#define set_opcode zel_ckpd86_set_opcode
#define pc_interrupt zel_ckpd86_pc_interrupt
#define AAA_AAS zel_ckpd86_AAA_AAS
#define audio_callback zel_ckpd86_audio_callback

#include "8086tiny.c"
