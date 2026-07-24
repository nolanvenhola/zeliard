#ifndef ZELIARD_OPENING_TRACE_H
#define ZELIARD_OPENING_TRACE_H

#include "../core/types.h"
#include <stddef.h>

/* Runtime evidence for mechanically translated 100OPDMO service boundaries.
 * This is diagnostic-only: MASM remains the expected event source. */
typedef enum {
    ZEL_OPDMO_TRACE_GFX_PALETTE,
    ZEL_OPDMO_TRACE_GFX_MODE,
    ZEL_OPDMO_TRACE_GFX_DRAW,
    ZEL_OPDMO_TRACE_DISP_GAME,
    ZEL_OPDMO_TRACE_SAR_LOAD,
    ZEL_OPDMO_TRACE_DECOMPRESS_IMAGE,
    ZEL_OPDMO_TRACE_DISP_LOAD_SETUP,
    ZEL_OPDMO_TRACE_GFX_UPDATE,
    ZEL_OPDMO_TRACE_MERGE_GFX_PLANES,
    ZEL_OPDMO_TRACE_XOR_MASK_RENDER,
    ZEL_OPDMO_TRACE_SCRIPT_WAIT,
    ZEL_OPDMO_TRACE_SCRIPT_BYTE,
    ZEL_OPDMO_TRACE_SCRIPT_GLYPH,
    ZEL_OPDMO_TRACE_SCRIPT_CONTROL,
} zel_opdmo_trace_kind_t;

typedef struct {
    zel_opdmo_trace_kind_t kind;
    u16 ax;
    u16 bx;
    u16 cx;
    u16 di;
    u16 es_delta;
    u16 script_pc;
} zel_opdmo_trace_event_t;

void zel_opdmo_trace_reset(void);
void zel_opdmo_trace_emit(zel_opdmo_trace_kind_t kind, u16 ax, u16 bx,
                          u16 cx, u16 di, u16 es_delta, u16 script_pc);
size_t zel_opdmo_trace_copy(zel_opdmo_trace_event_t *out, size_t max_events);
size_t zel_opdmo_trace_dropped(void);

#endif
