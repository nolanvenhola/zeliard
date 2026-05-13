#ifndef ZELIARD_PLATFORM_H
#define ZELIARD_PLATFORM_H

#include "../core/types.h"

/* Platform abstraction.  All web-specific code lives in platform_web.c;
 * native desktop builds use platform_sdl.c.  The C engine never depends
 * on anything outside this header.
 */

/* Synchronous asset load.  Returns malloc'd buffer (caller frees) and
 * writes size to *out_size.  Returns NULL on failure.  The web build
 * preloads assets at startup so the call is non-blocking. */
u8* platform_load_asset(const char *name, size_t *out_size);

/* Log a message.  Web: console.log; Native: stderr. */
void platform_log(const char *fmt, ...);

#endif
