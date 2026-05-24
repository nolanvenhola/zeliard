/* fill_buffer — SAR chunk decompressor for all 8 fill_buffer methods.
 *
 * Port of _fill_buffer() in 2_SAR/Tools/decompress_sar.py, reverse-engineered
 * from the Spice86 CPU trace of the loader at 041F:0DAD.
 * Verified: zelres1 chunk 22 → 5786/5786 bytes match.
 *
 * Calling convention for all method_N helpers: the buf/size pointers are to
 * the METHOD-PAYLOAD bytes (i.e. original fill_buffer stream starting AFTER
 * the opcode byte buf[0]).  This matches the Python si=1 baseline.
 */

#include "fill_buffer.h"
#include <stdlib.h>
#include <string.h>

/* ---- grow-on-demand output buffer --------------------------------------- */
typedef struct { u8 *buf; size_t n; size_t cap; } out_t;

static int out_init(out_t *o, size_t hint) {
    o->buf = (u8*)malloc(hint ? hint : 1);
    o->n = 0; o->cap = hint ? hint : 1;
    return o->buf ? 0 : -1;
}
static int out_push(out_t *o, u8 b) {
    if (o->n >= o->cap) {
        size_t nc = o->cap * 2 + 256;
        u8 *t = (u8*)realloc(o->buf, nc);
        if (!t) return -1;
        o->buf = t; o->cap = nc;
    }
    o->buf[o->n++] = b;
    return 0;
}
static int out_fill(out_t *o, u8 v, size_t cnt) {
    for (size_t i = 0; i < cnt; i++)
        if (out_push(o, v)) return -1;
    return 0;
}
#define FAIL(o) do { free((o).buf); *out_size = 0; return NULL; } while(0)

/* ---- method 0: verbatim copy -------------------------------------------- */
static u8* method0(const u8 *d, size_t n, size_t *out_size) {
    u8 *out = (u8*)malloc(n ? n : 1);
    if (!out) { *out_size = 0; return NULL; }
    memcpy(out, d, n);
    *out_size = n;
    return out;
}

/* ---- method 1: lo-nibble-keyed table RLE -------------------------------- */
/* Table: [key, val] pairs where key & 0x0F == 0; terminator byte 0xFF.
 * Stream bytes: if hi-nibble matches a table key, expand count×val. */
static u8* method1(const u8 *d, size_t n, size_t *out_size) {
    /* Find 0xFF terminator — table entries lie before it, stream after. */
    size_t tbl_end = 0;
    while (tbl_end < n && d[tbl_end] != 0xFF) tbl_end++;
    size_t si = (tbl_end < n) ? tbl_end + 1 : tbl_end;  /* stream start */

    out_t o; if (out_init(&o, n * 3 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 al = d[si++];
        u8 ah = al & 0xF0;
        size_t cx = 1;
        for (size_t tbp = 0; tbp + 1 < tbl_end; tbp += 2) {
            u8 ek = d[tbp];
            if ((ek & 0x0F) != 0) break;  /* not a valid table entry */
            if (ah == ek) { cx = (al & 0x0F) + 2; al = d[tbp + 1]; break; }
        }
        if (out_fill(&o, al, cx)) FAIL(o);
    }
    *out_size = o.n; return o.buf;
}

/* ---- method 2: hi-nibble marker RLE ------------------------------------ */
/* First byte = marker; if (stream_byte & 0xF0) == marker → RLE trigger. */
static u8* method2(const u8 *d, size_t n, size_t *out_size) {
    if (n < 1) { *out_size = 0; return NULL; }
    u8 ah = d[0]; size_t si = 1;
    out_t o; if (out_init(&o, n * 3 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 al = d[si++];
        size_t cx = 1;
        if ((al & 0xF0) == ah) {
            if (si >= n) break;
            cx = (al & 0x0F) + 3;
            al = d[si++];
        }
        if (out_fill(&o, al, cx)) FAIL(o);
    }
    *out_size = o.n; return o.buf;
}

/* ---- method 3: hi-nibble-keyed table RLE -------------------------------- */
/* Mirror of method 1: key has hi_nibble=0; lo-nibble of stream byte is key;
 * hi-nibble of stream byte is count-2. */
static u8* method3(const u8 *d, size_t n, size_t *out_size) {
    size_t tbl_end = 0;
    while (tbl_end < n && d[tbl_end] != 0xFF) tbl_end++;
    size_t si = (tbl_end < n) ? tbl_end + 1 : tbl_end;

    out_t o; if (out_init(&o, n * 3 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 al = d[si++];
        u8 ah = al & 0x0F;  /* lo nibble = key */
        size_t cx = 1;
        for (size_t tbp = 0; tbp + 1 < tbl_end; tbp += 2) {
            u8 ek = d[tbp];
            if ((ek & 0xF0) != 0) break;
            if (ah == ek) { cx = (al >> 4) + 2; al = d[tbp + 1]; break; }
        }
        if (out_fill(&o, al, cx)) FAIL(o);
    }
    *out_size = o.n; return o.buf;
}

/* ---- method 4: lo-nibble marker RLE ------------------------------------ */
static u8* method4(const u8 *d, size_t n, size_t *out_size) {
    if (n < 1) { *out_size = 0; return NULL; }
    u8 ah = d[0]; size_t si = 1;
    out_t o; if (out_init(&o, n * 3 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 al = d[si++];
        size_t cx = 1;
        if ((al & 0x0F) == ah) {
            if (si >= n) break;
            cx = (al >> 4) + 3;
            al = d[si++];
        }
        if (out_fill(&o, al, cx)) FAIL(o);
    }
    *out_size = o.n; return o.buf;
}

/* ---- method 5: same-byte-pair RLE (K=2) -------------------------------- */
/* If current byte == next byte: read count byte → emit current × (count+2). */
static u8* method5(const u8 *d, size_t n, size_t *out_size) {
    size_t si = 0;
    out_t o; if (out_init(&o, n * 3 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 al = d[si];
        size_t cx = 1;
        if (si + 1 < n && d[si + 1] == al) {
            if (si + 2 < n) { cx = (size_t)d[si + 2] + 2; si += 2; }
            else si++;
        }
        si++;
        if (out_fill(&o, al, cx)) FAIL(o);
    }
    *out_size = o.n; return o.buf;
}

/* ---- method 6: 2-byte table RLE (K=2) ---------------------------------- */
/* Table: [key, val] pairs terminated by 0xFF 0xFF.
 * When key appears in stream: read count byte → emit val × (count+2). */
static u8* method6(const u8 *d, size_t n, size_t *out_size) {
    u8  tbl_val[256];
    int tbl_has[256];
    memset(tbl_has, 0, sizeof(tbl_has));

    size_t si = 0;
    while (si + 1 < n) {
        u8 k = d[si], v = d[si + 1]; si += 2;
        if (k == 0xFF && v == 0xFF) break;
        tbl_val[(unsigned)k] = v; tbl_has[(unsigned)k] = 1;
    }

    out_t o; if (out_init(&o, n * 4 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 b = d[si++];
        if (tbl_has[(unsigned)b]) {
            if (si >= n) break;
            size_t cnt = (size_t)d[si++] + 2;
            if (out_fill(&o, tbl_val[(unsigned)b], cnt)) FAIL(o);
        } else {
            if (out_push(&o, b)) FAIL(o);
        }
    }
    *out_size = o.n; return o.buf;
}

/* ---- method 7: escape-byte RLE (K=3) ----------------------------------- */
/* First byte = escape; [escape][value][count] → value × (count+3). */
static u8* method7(const u8 *d, size_t n, size_t *out_size) {
    if (n < 1) { *out_size = 0; return NULL; }
    u8 escape = d[0]; size_t si = 1;
    out_t o; if (out_init(&o, n * 4 + 64)) { *out_size = 0; return NULL; }
    while (si < n) {
        u8 b = d[si++];
        if (b == escape) {
            if (si + 1 >= n) break;
            u8 value = d[si++];
            size_t cnt = (size_t)d[si++] + 3;
            if (out_fill(&o, value, cnt)) FAIL(o);
        } else {
            if (out_push(&o, b)) FAIL(o);
        }
    }
    *out_size = o.n; return o.buf;
}

/* ---- public API --------------------------------------------------------- */

u8* fill_buffer_decompress(const u8 *file_data, size_t file_size, size_t *out_size) {
    *out_size = 0;
    if (file_size < 5) return NULL;

    u32 chunk_size = (u32)file_data[0] | ((u32)file_data[1] << 8)
                   | ((u32)file_data[2] << 16) | ((u32)file_data[3] << 24);
    u8 flag = file_data[4];

    const u8 *buf; size_t buf_size;
    if (flag == 0) {
        size_t avail = (chunk_size >= 1) ? chunk_size - 1 : 0;
        if (5 + avail > file_size) avail = (file_size > 5) ? file_size - 5 : 0;
        buf = file_data + 5;
        buf_size = avail;
    } else {
        if (file_size < 9) return NULL;
        u16 skip = (u16)file_data[5] | ((u16)file_data[6] << 8);
        u16 rdsz = (u16)file_data[7] | ((u16)file_data[8] << 8);
        size_t start = 9 + skip;
        if (start + rdsz > file_size) return NULL;
        buf = file_data + start;
        buf_size = rdsz;
    }

    if (buf_size == 0) return NULL;
    int opcode = buf[0] & 7;
    const u8 *d = buf + 1;      /* payload (after opcode byte) */
    size_t    dsz = buf_size - 1;

    switch (opcode) {
        case 0: return method0(d, dsz, out_size);
        case 1: return method1(d, dsz, out_size);
        case 2: return method2(d, dsz, out_size);
        case 3: return method3(d, dsz, out_size);
        case 4: return method4(d, dsz, out_size);
        case 5: return method5(d, dsz, out_size);
        case 6: return method6(d, dsz, out_size);
        case 7: return method7(d, dsz, out_size);
        default: return NULL;
    }
}
