#include "../render/mcga_runtime.h"
#include "../load/fill_buffer.h"

#include <stdio.h>
#include <stdlib.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; i++) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static unsigned long long fnv1a64_update_u64_le(unsigned long long hash,
                                                  unsigned long long value) {
    for (unsigned shift = 0; shift < 64; shift += 8) {
        hash ^= (u8)(value >> shift);
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static u8 *read_file(const char *path, size_t *out_size) {
    FILE *file = fopen(path, "rb");
    if (!file)
        return NULL;
    fseek(file, 0, SEEK_END);
    long length = ftell(file);
    fseek(file, 0, SEEK_SET);
    if (length <= 0) {
        fclose(file);
        return NULL;
    }
    u8 *data = malloc((size_t)length);
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        fclose(file);
        return NULL;
    }
    fclose(file);
    *out_size = (size_t)length;
    return data;
}

int main(void) {
    size_t driver_size = 0, font_file_size = 0, opdmo_size = 0, font_size = 0;
    u8 *driver = read_file("assets/105GDMCA.bin", &driver_size);
    u8 *font_file = read_file("assets/font.grp", &font_file_size);
    u8 *opdmo = read_file("assets/100opdmo.bin", &opdmo_size);
    u8 *font = font_file ? fill_buffer_decompress(font_file, font_file_size,
                                                   &font_size) : NULL;
    zel_mcga_runtime_t *rt = calloc(1, sizeof(*rt));
    int ok = driver && font && opdmo && rt;
    const size_t stream_offset = 0x6FF0u - 0x6000u + 4u;
    const size_t credits_stream_offset = 0x742Fu - 0x6000u + 4u;
    const size_t alt_stream_offset = 0x7338u - 0x6000u + 4u;

    if (ok) {
        u16 font_ptr_a = (u16)font[0] | ((u16)font[1] << 8);
        zel_mcga_runtime_init(rt);
        ok &= zel_mcga_runtime_load_driver(rt, driver, driver_size);
        ok &= opdmo_size > stream_offset;
        ok &= zel_mcga_runtime_decode_scanline(rt, font, font_size, font_ptr_a,
                                               opdmo + stream_offset,
                                               opdmo_size - stream_offset) == 32;
        for (u16 frame = 0; ok && frame < 10; frame++)
            ok &= zel_mcga_runtime_draw_scanline(rt, frame, 0x0020, 0x5078) == 0;
        ok &= fnv1a64(zel_mcga_runtime_framebuffer(rt), 0xFA00) ==
              0xB5669CFA9BF9B903ULL;
        ok &= fnv1a64(rt->work, sizeof(rt->work)) == 0xE9DEDAEA93F4F1A2ULL;

        ok &= zel_mcga_runtime_tick(rt, 4) == 0;
        ok &= zel_mcga_runtime_tick(rt, 4) == 1;
        ok &= rt->frame_timer == 1;
        ok &= !zel_mcga_runtime_take_timer(rt, 2);
        ok &= zel_mcga_runtime_take_timer(rt, 1);

        zel_mcga_runtime_init(rt);
        ok &= zel_mcga_runtime_load_driver(rt, driver, driver_size);
        ok &= zel_mcga_runtime_begin_scanline_stream(
            rt, font, font_size, font_ptr_a, opdmo + stream_offset,
            opdmo_size - stream_offset) == 0;
        for (u16 frame = 0; ok && frame < 10; frame++) {
            if (frame != 0) {
                ok &= zel_mcga_runtime_advance_scanline(rt) == 0;
                while (rt->frame_timer < 0x1C)
                    (void)zel_mcga_runtime_tick(rt, 4);
            }
            ok &= zel_mcga_runtime_advance_scanline(rt) == 1;
        }
        ok &= fnv1a64(zel_mcga_runtime_framebuffer(rt), 0xFA00) ==
              0xB5669CFA9BF9B903ULL;
        ok &= fnv1a64(rt->work, sizeof(rt->work)) == 0xE9DEDAEA93F4F1A2ULL;
        ok &= rt->scan_stream_pos == 32;
        ok &= rt->scan_frame == 10 && rt->scan_waiting == 1;

        zel_mcga_runtime_init(rt);
        ok &= zel_mcga_runtime_load_driver(rt, driver, driver_size);
        ok &= zel_mcga_runtime_begin_scanline_stream(
            rt, font, font_size, font_ptr_a, opdmo + stream_offset,
            opdmo_size - stream_offset) == 0;
        unsigned rendered = 0;
        unsigned long long ancient_trace = 0xCBF29CE484222325ULL;
        int advance = 0;
        do {
            advance = zel_mcga_runtime_advance_scanline(rt);
            if (advance == 0) {
                while (rt->frame_timer < 0x1C)
                    (void)zel_mcga_runtime_tick(rt, 4);
            } else if (advance == 1) {
                rendered++;
                ancient_trace = fnv1a64_update_u64_le(
                    ancient_trace, fnv1a64(rt->vga, 0xFA00));
                ancient_trace = fnv1a64_update_u64_le(
                    ancient_trace, fnv1a64(rt->work, sizeof(rt->work)));
            }
        } while (advance >= 0 && advance != 2 && rendered <= 700);
        ok &= advance == 2;
        ok &= rendered == 430;
        ok &= rt->scan_exit_frame == 0x78;
        ok &= ancient_trace == 0xB4395F092CA68BE0ULL;
        ok &= fnv1a64(rt->vga, 0xFA00) == 0xDD14FCC6528CAB25ULL;
        ok &= fnv1a64(rt->work, sizeof(rt->work)) == 0xB65F2BB82806E676ULL;

        /* 100OPDMO:6497 credits_scroll_display starts at CS:742F.  The
         * MASM trace records 52 CR/FF entries, ten draws apiece, followed by
         * the same 78h-frame exit loop. */
        zel_mcga_runtime_init(rt);
        ok &= zel_mcga_runtime_load_driver(rt, driver, driver_size);
        ok &= opdmo_size > credits_stream_offset;
        ok &= zel_mcga_runtime_begin_scanline_stream(
            rt, font, font_size, font_ptr_a,
            opdmo + credits_stream_offset,
            opdmo_size - credits_stream_offset) == 0;
        rendered = 0;
        do {
            advance = zel_mcga_runtime_advance_scanline(rt);
            if (advance == 0) {
                while (rt->frame_timer < 0x1C)
                    (void)zel_mcga_runtime_tick(rt, 4);
            } else if (advance == 1) {
                rendered++;
            }
        } while (advance >= 0 && advance != 2 && rendered <= 700);
        ok &= advance == 2;
        ok &= rendered == 52u * 10u + 0x78u;
        ok &= rt->scan_exit_frame == 0x78;

        /* 100OPDMO:69F3 loads SI=7338h, the leading space before "At last".
         * Six CR records and the distinct FF record emit 70 entry draws
         * before the 0A0h exit. */
        zel_mcga_runtime_init(rt);
        ok &= zel_mcga_runtime_load_driver(rt, driver, driver_size);
        ok &= opdmo_size > alt_stream_offset;
        ok &= zel_mcga_runtime_begin_scanline_stream_ex(
            rt, font, font_size, font_ptr_a, opdmo + alt_stream_offset,
            opdmo_size - alt_stream_offset, 0x0014, 0x50A0, 0x00A0) == 0;
        rendered = 0;
        static const unsigned alt_checkpoint_draws[] = {10, 30, 60, 70};
        static const uint64_t alt_checkpoint_visible[] = {
            0x84DB69BD1AF40875ULL, 0x7921BCCDD8C1E423ULL,
            0xB2BC3E6F10A17715ULL, 0x675A3CCD9E0E5715ULL,
        };
        static const uint64_t alt_checkpoint_work[] = {
            0xD4C47EF84D43FF5DULL, 0xE5D43A94A1E16B3EULL,
            0x89CF96916920FE73ULL, 0x75B3B1D9B3713A73ULL,
        };
        size_t alt_checkpoint = 0;
        do {
            advance = zel_mcga_runtime_advance_scanline(rt);
            if (advance == 0) {
                while (rt->frame_timer < 0x1C)
                    (void)zel_mcga_runtime_tick(rt, 4);
            } else if (advance == 1) {
                rendered++;
                if (alt_checkpoint < 4 &&
                    rendered == alt_checkpoint_draws[alt_checkpoint]) {
                    ok &= fnv1a64(rt->vga, 0xFA00) ==
                          alt_checkpoint_visible[alt_checkpoint];
                    ok &= fnv1a64(rt->work, sizeof(rt->work)) ==
                          alt_checkpoint_work[alt_checkpoint];
                    alt_checkpoint++;
                }
            }
        } while (advance >= 0 && advance != 2 && rendered <= 700);
        int alt_ok = advance == 2 && rendered == 70u + 0xA0u &&
                     alt_checkpoint == 4 &&
                     rt->scan_exit_frame == 0xA0;
        printf("mcga_runtime_alt: %s advance=%d draws=%u exit=%u stream=%zu\n",
               alt_ok ? "PASS" : "FAIL", advance, rendered,
               rt->scan_exit_frame, rt->scan_stream_pos);
        ok &= alt_ok;
    }

    printf("mcga_runtime: %s framebuffer=%016llx work=%016llx ticks=%u\n",
           ok ? "PASS" : "FAIL",
           rt ? fnv1a64(rt->vga, 0xFA00) : 0,
           rt ? fnv1a64(rt->work, sizeof(rt->work)) : 0,
           rt ? rt->timer_ticks : 0);
    printf("VERDICT: %s: persistent MCGA scanline runtime\n",
           ok ? "PASS" : "FAIL");

    free(driver);
    free(font_file);
    free(opdmo);
    free(font);
    free(rt);
    return ok ? 0 : 1;
}
