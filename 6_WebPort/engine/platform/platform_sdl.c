#include "platform.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/* Native build: loads assets from ./assets/<name> relative to cwd. */
u8* platform_load_asset(const char *name, size_t *out_size) {
    char path[512];
    snprintf(path, sizeof(path), "assets/%s", name);
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
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
}
