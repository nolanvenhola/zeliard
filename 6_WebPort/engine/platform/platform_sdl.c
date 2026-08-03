#include "platform.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#ifdef _WIN32
#include <windows.h>
#else
#include <dirent.h>
#include <strings.h>
#endif

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

int platform_save_record(const char *name, const u8 *record, size_t size) {
    if (!name || !record || size != 0x100) return 0;
    FILE *file = fopen(name, "wb");
    if (!file) return 0;
    const size_t written = fwrite(record, 1, size, file);
    const int closed = fclose(file) == 0;
    const int ok = written == size && closed;
    if (!ok) remove(name);
    return ok;
}

size_t platform_list_save_names(char (*names)[9], size_t capacity) {
    if (!names || !capacity) return 0;
#ifdef _WIN32
    WIN32_FIND_DATAA entry;
    HANDLE search = FindFirstFileA("*.usr", &entry);
    if (search == INVALID_HANDLE_VALUE) return 0;
    size_t count = 0;
    do {
        if (entry.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) continue;
        const size_t length = strlen(entry.cFileName);
        if (length < 5 || length > 12 ||
            _stricmp(entry.cFileName + length - 4, ".usr") != 0)
            continue;
        const size_t base_length = length - 4 > 8 ? 8 : length - 4;
        memcpy(names[count], entry.cFileName, base_length);
        names[count][base_length] = '\0';
        ++count;
    } while (count < capacity && FindNextFileA(search, &entry));
    FindClose(search);
    return count;
#else
    DIR *directory = opendir(".");
    if (!directory) return 0;
    size_t count = 0;
    struct dirent *entry;
    while (count < capacity && (entry = readdir(directory)) != NULL) {
        const size_t length = strlen(entry->d_name);
        if (length < 5 || length > 12 ||
            strcasecmp(entry->d_name + length - 4, ".usr") != 0)
            continue;
        const size_t base_length = length - 4 > 8 ? 8 : length - 4;
        memcpy(names[count], entry->d_name, base_length);
        names[count][base_length] = '\0';
        ++count;
    }
    closedir(directory);
    return count;
#endif
}
