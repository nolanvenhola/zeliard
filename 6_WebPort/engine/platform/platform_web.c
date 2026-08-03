#include "platform.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>

/* Emscripten's filesystem (when --preload-file is used at link time)
 * makes assets visible via standard fopen at /assets/<name>.  We use
 * that path so the same C code works under emcc and native.
 */
u8* platform_load_asset(const char *name, size_t *out_size) {
    char path[256];
    snprintf(path, sizeof(path), "/assets/%s", name);
    FILE *f = fopen(path, "rb");
    if (!f) {
        platform_log("asset not found: %s", path);
        return NULL;
    }
    fseek(f, 0, SEEK_END);
    long n = ftell(f);
    fseek(f, 0, SEEK_SET);
    u8 *buf = (u8*)malloc((size_t)n);
    if (!buf) { fclose(f); return NULL; }
    size_t got = fread(buf, 1, (size_t)n, f);
    fclose(f);
    if (got != (size_t)n) { free(buf); return NULL; }
    if (out_size) *out_size = (size_t)n;
    return buf;
}

void platform_log(const char *fmt, ...) {
    char buf[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    EM_ASM({ console.log(UTF8ToString($0)); }, buf);
}

EM_JS(int, platform_save_record_js,
      (const char *name_ptr, const u8 *record_ptr, size_t size), {
    try {
        const name = UTF8ToString(name_ptr);
        const record = Array.from(HEAPU8.subarray(record_ptr,
                                                   record_ptr + size));
        localStorage.setItem(`zeliard.save.${name.toUpperCase()}`,
            JSON.stringify({version: 1, name, record}));
        return 1;
    } catch (error) {
        console.error('[zeliard] save failed', error);
        return 0;
    }
});

EM_JS(size_t, platform_list_save_names_js,
      (char *output, size_t capacity), {
    let count = 0;
    try {
        for (let index = 0; index < localStorage.length && count < capacity;
             ++index) {
            const key = localStorage.key(index);
            if (!key || !key.startsWith('zeliard.save.')) continue;
            const value = JSON.parse(localStorage.getItem(key));
            if (!value || value.version !== 1 || !Array.isArray(value.record) ||
                value.record.length !== 0x100 || typeof value.name !== 'string')
                continue;
            const lower = value.name.toLowerCase();
            const base = (lower.endsWith('.usr')
                ? value.name.slice(0, -4) : value.name).slice(0, 8);
            stringToUTF8(base, output + count * 9, 9);
            ++count;
        }
    } catch (error) {
        console.error('[zeliard] save enumeration failed', error);
    }
    return count;
});

int platform_save_record(const char *name, const u8 *record, size_t size) {
    return name && record && size == 0x100
        ? platform_save_record_js(name, record, size) : 0;
}

size_t platform_list_save_names(char (*names)[9], size_t capacity) {
    return names && capacity
        ? platform_list_save_names_js(&names[0][0], capacity) : 0;
}

#else
#  error "platform_web.c built without __EMSCRIPTEN__"
#endif
