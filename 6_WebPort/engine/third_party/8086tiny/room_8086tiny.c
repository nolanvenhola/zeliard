/* A private 8086tiny instance for release room chunks. The audio VM keeps
 * the public instance in 8086tiny.c, so both runtimes retain independent
 * memory, registers, decoder state, and callbacks. */
#define zel_tiny86_reset zel_room86_reset
#define zel_tiny86_set_out_callback zel_room86_set_out_callback
#define zel_tiny86_set_step_callback zel_room86_set_step_callback
#define zel_tiny86_run zel_room86_run
#define zel_tiny86_memory zel_room86_memory
#define zel_tiny86_memory_size zel_room86_memory_size
#define zel_tiny86_registers zel_room86_registers
#define zel_tiny86_byte_registers zel_room86_byte_registers
#define zel_tiny86_ip zel_room86_ip
#define zel_tiny86_set_ip zel_room86_set_ip
#define zel_tiny86_flags zel_room86_flags
#define zel_tiny86_set_flags zel_room86_set_flags
#define zel_tiny86_set_io_port zel_room86_set_io_port
#define set_CF zel_room86_set_CF
#define set_AF zel_room86_set_AF
#define set_OF zel_room86_set_OF
#define set_AF_OF_arith zel_room86_set_AF_OF_arith
#define make_flags zel_room86_make_flags
#define set_flags zel_room86_set_flags_internal
#define set_opcode zel_room86_set_opcode
#define pc_interrupt zel_room86_pc_interrupt
#define AAA_AAS zel_room86_AAA_AAS
#define audio_callback zel_room86_audio_callback

#include "8086tiny.c"
