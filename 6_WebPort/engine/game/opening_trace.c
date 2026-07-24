#include "opening_trace.h"

enum { ZEL_OPDMO_TRACE_CAPACITY = 8192 };

static zel_opdmo_trace_event_t g_events[ZEL_OPDMO_TRACE_CAPACITY];
static size_t g_count;
static size_t g_dropped;

void zel_opdmo_trace_reset(void) {
    g_count = 0;
    g_dropped = 0;
}

void zel_opdmo_trace_emit(zel_opdmo_trace_kind_t kind, u16 ax, u16 bx,
                          u16 cx, u16 di, u16 es_delta, u16 script_pc) {
    if (g_count == ZEL_OPDMO_TRACE_CAPACITY) {
        g_dropped++;
        return;
    }
    g_events[g_count++] = (zel_opdmo_trace_event_t){
        .kind = kind, .ax = ax, .bx = bx, .cx = cx, .di = di,
        .es_delta = es_delta,
        .script_pc = script_pc,
    };
}

size_t zel_opdmo_trace_copy(zel_opdmo_trace_event_t *out, size_t max_events) {
    size_t count = g_count < max_events ? g_count : max_events;
    for (size_t i = 0; out && i < count; i++)
        out[i] = g_events[i];
    return count;
}

size_t zel_opdmo_trace_dropped(void) {
    return g_dropped;
}
