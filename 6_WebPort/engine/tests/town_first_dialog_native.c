#include "../game/town_dialog.h"
#include "../load/fill_buffer.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static u8 *read_file(const char *name, size_t *size) {
    FILE *file = fopen(name, "rb");
    if (!file) return NULL;
    fseek(file, 0, SEEK_END);
    const long length = ftell(file);
    rewind(file);
    u8 *data = length > 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        data = NULL;
    }
    fclose(file);
    *size = length > 0 ? (size_t)length : 0;
    return data;
}

static int load_raw(u8 *destination, size_t capacity, const char *name) {
    size_t size = 0;
    u8 *data = read_file(name, &size);
    if (!data || size < 4) { free(data); return 0; }
    const size_t declared = (size_t)data[0] | ((size_t)data[1] << 8) |
        ((size_t)data[2] << 16) | ((size_t)data[3] << 24);
    if (declared > size - 4 || declared > capacity) {
        free(data);
        return 0;
    }
    memcpy(destination, data + 4, declared);
    free(data);
    return 1;
}

static int load_font(u8 *segment) {
    size_t size = 0, decoded_size = 0;
    u8 *data = read_file("assets/font.grp", &size);
    u8 *decoded = data ? fill_buffer_decompress(data, size, &decoded_size) : NULL;
    free(data);
    if (!decoded || decoded_size > 0x0B00) { free(decoded); return 0; }
    memcpy(segment + 0xF500, decoded, decoded_size);
    free(decoded);
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 value = (u16)(segment[0xF500 + offset] |
                                ((u16)segment[0xF501 + offset] << 8));
        const u16 relocated = (u16)(value + 0xF500);
        segment[0xF500 + offset] = (u8)relocated;
        segment[0xF501 + offset] = (u8)(relocated >> 8);
    }
    return 1;
}

static unsigned long long matrix_hash_byte(unsigned long long hash, u8 value) {
    hash ^= value;
    return hash * 0x100000001B3ULL;
}

static int test_all_town_dialog_entries(void) {
    /* The high-water dialog IDs come directly from each release MDT's NPC
     * records.  Bosque IDs 12/13 are the two branches of ID 11's Yes/No
     * control, so include them even though no NPC points at them directly. */
    static const struct {
        const char *asset;
        u8 dialog_count;
    } towns[] = {
        {"assets/cmap.mdt", 4}, {"assets/mrmp.mdt", 9},
        {"assets/stmp.mdt", 7}, {"assets/bsmp.mdt", 14},
        {"assets/hlmp.mdt", 11}, {"assets/tmmp.mdt", 8},
        {"assets/drmp.mdt", 12}, {"assets/llmp.mdt", 20},
        {"assets/prmp.mdt", 13}, {"assets/esmp.mdt", 7},
    };
    u8 segment[0x10000], scratch[0x10000], vga[0x10000];
    u8 background[0x10000];
    for (size_t i = 0; i < sizeof(background); ++i)
        background[i] = (u8)(i * 29u + 3u);
    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    unsigned entries = 0;
    unsigned long long hash = 0xCBF29CE484222325ULL;

    for (size_t town = 0; ok && town < sizeof(towns) / sizeof(towns[0]);
         ++town) {
        for (u8 id = 0; ok && id < towns[town].dialog_count; ++id) {
            memset(segment, 0, sizeof(segment));
            memset(scratch, 0, sizeof(scratch));
            memcpy(vga, background, sizeof(vga));
            memcpy(segment + 0x2000, driver, driver_size);
            ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin") &&
                  load_raw(segment + 0xC000, 0x4000, towns[town].asset) &&
                  load_font(segment);
            if (!ok) break;

            /* Exercise the insufficient-funds path in Llama's cape script.
             * The successful purchase, No branch, event mutation, and repeat
             * visit are pinned separately by test_llama_cape_and_elf_crest. */
            segment[0x008B] = segment[0x008C] = 0;
            zeliard_town_dialog_t dialog = {0};
            const int begun = zeliard_town_dialog_begin_scripted(
                &dialog, segment, scratch, vga, sizeof(vga), id, 0x0918);
            ok &= begun == 0 && dialog.active &&
                  dialog.pending_sound_cue == 0x1E;
            unsigned steps = 0;
            while (ok && dialog.active && steps++ < 20000) {
                if (dialog.scroll_active || dialog.scroll_resume_pending ||
                    dialog.prompt_cursor_anim_active) {
                    ok &= zeliard_town_dialog_advance_pit(
                        &dialog, segment, vga, sizeof(vga)) >= 0;
                } else if (dialog.waiting) {
                    segment[0xFF1D] = 0xFF;
                    ok &= zeliard_town_dialog_continue(
                        &dialog, segment, scratch, vga, sizeof(vga)) >= 0;
                }
            }
            ok &= !dialog.active && steps < 20000 &&
                  memcmp(vga, background, sizeof(vga)) == 0;
            hash = matrix_hash_byte(hash, (u8)town);
            hash = matrix_hash_byte(hash, id);
            hash = matrix_hash_byte(hash, (u8)dialog.glyph_count);
            hash = matrix_hash_byte(hash, (u8)(dialog.glyph_count >> 8));
            hash = matrix_hash_byte(hash, (u8)dialog.scroll_count);
            hash = matrix_hash_byte(hash, segment[0x0034]);
            hash = matrix_hash_byte(hash, segment[0x009A]);
            hash = matrix_hash_byte(hash, segment[0x0004]);
            ++entries;
        }
    }
    free(driver);
    ok &= entries == 105 && hash == 0xB12C6DFF0A49E00AULL;
    printf("town_dialog_matrix: %s entries=%u hash=%016llx\n",
           ok ? "PASS" : "FAIL", entries, hash);
    return ok;
}

static int test_muralla_multipage_dialog(void) {
    static const unsigned long long expected_scroll_steps[] = {
        0x24CB66E41A5DBC53ULL, 0x2F82EE743B806666ULL,
        0xDF3B4F3D058423F8ULL, 0xA46EC27677EF7F79ULL,
        0xB3D9F195B1809D75ULL, 0x2EBB4276EE9495B7ULL,
        0x59E8958980B3871CULL, 0xDE632A2E14D1B0EDULL,
        0x6B1AD5219D0E042DULL, 0xFFB12319111FCC4DULL,
        0xE4D74FD15F086069ULL, 0xA0081FC4DF3B4CFBULL,
        0xF720A98B0BA13DF4ULL, 0x61FFD82C7CCA92DFULL,
        0x4492CCC49406CFC1ULL, 0x8F17880A59A7B1A0ULL,
        0xDC510002420EE61FULL, 0x167E5948F1B2CF1DULL,
        0xC0C74121CDF987FDULL, 0x15344942CA81D4BDULL,
    };
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000];
    u8 background[0x10000];
    zeliard_town_dialog_t dialog = {0};
    for (size_t i = 0; i < sizeof(vga); ++i)
        vga[i] = background[i] = (u8)(i * 13u + 7u);
    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    if (ok) memcpy(segment + 0x2000, driver, driver_size);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin") &&
             load_raw(segment + 0xC000, 0x4000, "assets/mrmp.mdt") &&
             load_font(segment);
    segment[0x0080] = 0x70;
    segment[0x0083] = 0x0B;
    segment[0x00C2] = 0;
    const int begin = ok ? zeliard_town_dialog_begin(
        &dialog, segment, scratch, vga, sizeof(vga), 0x0082) : -99;
    const unsigned long long first = fnv1a64(vga, sizeof(vga));
    u8 first_frame[0x10000];
    memcpy(first_frame, vga, sizeof(first_frame));
    const u16 first_glyphs = dialog.glyph_count;
    const u16 first_draw = (u16)(segment[0x7C4E] |
        ((u16)segment[0x7C4F] << 8));
    ok &= begin == 0 && dialog.active && dialog.page_wait;
    ok &= first == 0x2CE6A7710F269E11ULL;

    segment[0xFF1D] = 0xFF;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 0;
    unsigned long long scroll_steps[20] = {0};
    size_t scroll_step_count = 0;
    unsigned scroll_ticks = 0;
    u16 previous_steps = dialog.scroll_step_count;
    for (unsigned tick = 0;
         tick < 1000 && (!dialog.final_wait || dialog.scroll_active ||
                         dialog.scroll_resume_pending);
         ++tick) {
        ++scroll_ticks;
        const int advanced = zeliard_town_dialog_advance_pit(
            &dialog, segment, vga, sizeof(vga));
        ok &= advanced >= 0;
        if (dialog.scroll_step_count != previous_steps) {
            if (scroll_step_count < 20)
                scroll_steps[scroll_step_count] = fnv1a64(vga, sizeof(vga));
            ++scroll_step_count;
            previous_steps = dialog.scroll_step_count;
        }
    }
    const unsigned long long second = fnv1a64(vga, sizeof(vga));
    size_t page_diff = 0;
    for (size_t i = 0; i < sizeof(vga); ++i)
        page_diff += first_frame[i] != vga[i];
    ok &= dialog.active && dialog.final_wait && !dialog.page_wait;
    ok &= scroll_step_count == 20;
    /* Twenty MASM GMMCGA calls plus one parser-resume tick per scroll. */
    ok &= scroll_ticks == 22;
    ok &= memcmp(scroll_steps, expected_scroll_steps,
                 sizeof(expected_scroll_steps)) == 0;
    ok &= second == 0xB95556613E17D5DAULL;
    ok &= dialog.pending_sound_cue == 0x1D && segment[0xFF75] == 0x1D;

    segment[0xFF1D] = 0xFF;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 1;
    ok &= !dialog.active && dialog.glyph_count == 206;
    ok &= memcmp(vga, background, sizeof(vga)) == 0;
    printf("town_muralla_dialog_pages: %s first=%016llx second=%016llx "
           "glyphs=%u/%u diff=%zu scroll=%u cue=%02x draw=%04x cols=%u row=%u\n",
           ok ? "PASS" : "FAIL",
           first, second, first_glyphs, dialog.glyph_count, page_diff,
           dialog.scroll_count, dialog.pending_sound_cue, first_draw, segment[0x7C54],
           segment[0x7C57]);
    return ok;
}

static int run_bosque_sentry_answer(int choose_no,
                                    unsigned long long *prompt_hash,
                                    unsigned long long *response_hash,
                                    u16 *response_end,
                                    u8 *guard_flags,
                                    int *repeat_begin) {
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000] = {0};
    zeliard_town_dialog_t dialog = {0};
    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    if (ok) memcpy(segment + 0x2000, driver, driver_size);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin");
    ok &= load_raw(segment + 0xC000, 0x4000, "assets/bsmp.mdt");
    ok &= load_font(segment);
    segment[0x00C2] = 0;

    const int begin = ok ? zeliard_town_dialog_begin_facing(
        &dialog, segment, scratch, NULL, 0, NULL, 0,
        vga, sizeof(vga), 0x0009) : -99;
    ok &= begin == 0 && dialog.active;
    for (unsigned guard = 0; guard < 200 && !dialog.prompt_active; ++guard) {
        if (dialog.scroll_active || dialog.scroll_resume_pending) {
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        } else if (dialog.waiting) {
            segment[0xFF1D] = 0xFF;
            ok &= zeliard_town_dialog_continue(
                &dialog, segment, scratch, vga, sizeof(vga)) >= 0;
        }
    }
    *prompt_hash = fnv1a64(vga, sizeof(vga));
    ok &= dialog.prompt_active && dialog.prompt_selection == 0 &&
          memcmp(segment + 0x7513, "Yes", 4) == 0 &&
          memcmp(segment + 0x7517, "No", 3) == 0;

    /* Explicitly select both visible rows. Release 106TOWN maps Yes to
     * dialog 12 ("Don't lie") and No to dialog 13 ("You cannot pass"). */
    segment[0xFF17] = choose_no ? 2 : 1;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 0;
    if (choose_no) {
        ok &= dialog.prompt_cursor_anim_active &&
              dialog.prompt_selection == 0;
        for (unsigned tick = 0; tick < 20; ++tick)
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        ok &= dialog.prompt_cursor_anim_active &&
              dialog.prompt_cursor_anim_step == 5 &&
              dialog.prompt_selection == 0;
        for (unsigned tick = 0; tick < 20; ++tick)
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        ok &= !dialog.prompt_cursor_anim_active &&
              dialog.prompt_cursor_anim_step == 10;
    }
    ok &= dialog.prompt_selection == (u8)choose_no;
    segment[0xFF17] = 0;
    segment[0xFF1D] = 0xFF;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 0;
    *response_end = (u16)(segment[0x7C58] |
                          ((u16)segment[0x7C59] << 8));
    *response_hash = fnv1a64(vga, sizeof(vga));
    ok &= dialog.active && !dialog.prompt_active && dialog.final_wait;
    segment[0xFF17] = 4;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 0;
    ok &= dialog.active;
    segment[0xFF17] = 8;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 0;
    ok &= dialog.active;
    segment[0xFF17] = 0;
    segment[0xFF1D] = 0xFF;
    ok &= zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga)) == 1;
    *guard_flags = segment[0xCCFA];
    *repeat_begin = zeliard_town_dialog_begin_facing(
        &dialog, segment, scratch, NULL, 0, NULL, 0,
        vga, sizeof(vga), 0x0009);
    return ok;
}

static int test_bosque_sentry_prompt(void) {
    unsigned long long yes_prompt = 0, yes_response = 0;
    unsigned long long no_prompt = 0, no_response = 0;
    u16 yes_end = 0, no_end = 0;
    u8 yes_flags = 0, no_flags = 0;
    int yes_repeat = 0, no_repeat = 0;
    int ok = run_bosque_sentry_answer(
        0, &yes_prompt, &yes_response, &yes_end,
        &yes_flags, &yes_repeat);
    ok &= run_bosque_sentry_answer(
        1, &no_prompt, &no_response, &no_end,
        &no_flags, &no_repeat);
    ok &= yes_prompt == 0x26F8F2DC2A165E3FULL &&
          no_prompt == yes_prompt &&
          yes_response != no_response &&
          yes_end == 0xCC5A && no_end == 0xCCB5 &&
          yes_flags == 0x40 && no_flags == 0x40 &&
          yes_repeat == -2 && no_repeat == -2;
    printf("town_bosque_sentry_prompt: %s prompt=%016llx "
           "yes=%016llx/%04x no=%016llx/%04x "
           "flags=%02x/%02x repeat=%d/%d\n",
           ok ? "PASS" : "FAIL", yes_prompt,
           yes_response, yes_end, no_response, no_end,
           yes_flags, no_flags, yes_repeat, no_repeat);
    return ok;
}

static int test_llama_cape_and_elf_crest(void) {
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000] = {0};
    zeliard_town_dialog_t dialog = {0};
    size_t player_size = 0, driver_size = 0;
    u8 *player = read_file("assets/stdply.bin", &player_size);
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = player && player_size <= sizeof(segment) &&
             driver && driver_size <= 0xE000;
    if (ok) {
        memcpy(segment, player, player_size);
        memcpy(segment + 0x2000, driver, driver_size);
    }
    free(player);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin") &&
          load_raw(segment + 0xC000, 0x4000, "assets/llmp.mdt") &&
          load_font(segment);
    segment[0x00C2] = 0;
    segment[0x008B] = (u8)3000;
    segment[0x008C] = (u8)(3000 >> 8);

    const int cape_begin = ok ? zeliard_town_dialog_begin(
        &dialog, segment, scratch, vga, sizeof(vga), 0x00FF) : -99;
    ok &= cape_begin == 0 && dialog.active;
    for (unsigned guard = 0; guard < 2000 && !dialog.prompt_active; ++guard) {
        if (dialog.scroll_active || dialog.scroll_resume_pending) {
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        } else if (dialog.waiting) {
            segment[0xFF1D] = 0xFF;
            ok &= zeliard_town_dialog_continue(
                &dialog, segment, scratch, vga, sizeof(vga)) >= 0;
        }
    }
    const unsigned long long cape_prompt = fnv1a64(vga, sizeof(vga));
    ok &= dialog.prompt_active && dialog.prompt_kind == 1 &&
          dialog.prompt_selection == 0 &&
          cape_prompt == 0xED42F39FAE63627BULL;
    segment[0xFF1D] = 0xFF;
    const int cape_confirm = zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga));
    ok &= cape_confirm == 0;
    const unsigned long long cape_bought = fnv1a64(vga, sizeof(vga));
    const u16 almas = (u16)(segment[0x008B] |
                            ((u16)segment[0x008C] << 8));
    ok &= dialog.final_wait && almas == 500 &&
          (segment[0x0034] & 0x40) && segment[0x00A1] == 5 &&
          segment[0xD0DA] == 9 &&
          cape_bought == 0xC539BB106A8AEE52ULL;

    /* Paguro's completion switches the hut resident to dialog 1. Opcode
     * 83h awards the Elf Crest, sets the portrait/event bit, and immediately
     * reapplies LLMP's authored NPC mutations. */
    memset(&dialog, 0, sizeof(dialog));
    memset(vga, 0, sizeof(vga));
    segment[0x0030] = 0xFF;
    segment[0xD0D2] = 1;
    const int crest_begin = zeliard_town_dialog_begin_facing(
        &dialog, segment, scratch, NULL, 0, NULL, 0,
        vga, sizeof(vga), 0x00DC);
    ok &= crest_begin == 0 && dialog.active;
    for (unsigned guard = 0;
         guard < 2000 &&
             !(dialog.final_wait && segment[0x009A] == 0xFF);
         ++guard) {
        if (dialog.scroll_active || dialog.scroll_resume_pending) {
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        } else if (dialog.waiting) {
            segment[0xFF1D] = 0xFF;
            ok &= zeliard_town_dialog_continue(
                &dialog, segment, scratch, vga, sizeof(vga)) >= 0;
        }
    }
    const unsigned long long crest_award = fnv1a64(vga, sizeof(vga));
    ok &= dialog.final_wait && segment[0x009A] == 0xFF &&
          (segment[0x0034] & 0x80) && segment[0xD0D2] == 2 &&
          segment[0xD0E2] == 16 && segment[0xD0EA] == 11 &&
          crest_award == 0xC053CC50772FD625ULL;

    /* The award event permanently changes the resident from dialog 1 to
     * dialog 2.  Re-entering the conversation therefore cannot execute the
     * 83h award opcode a second time. */
    memset(&dialog, 0, sizeof(dialog));
    memset(vga, 0, sizeof(vga));
    const u8 repeat_flags = segment[0x0034];
    const int crest_repeat_begin = zeliard_town_dialog_begin(
        &dialog, segment, scratch, vga, sizeof(vga), 0x00DC);
    for (unsigned guard = 0;
         guard < 2000 && !dialog.final_wait;
         ++guard) {
        if (dialog.scroll_active || dialog.scroll_resume_pending) {
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        } else if (dialog.waiting) {
            segment[0xFF1D] = 0xFF;
            ok &= zeliard_town_dialog_continue(
                &dialog, segment, scratch, vga, sizeof(vga)) >= 0;
        }
    }
    const unsigned long long crest_repeat = fnv1a64(vga, sizeof(vga));
    ok &= crest_repeat_begin == 0 && dialog.final_wait &&
          segment[0x009A] == 0xFF && segment[0x0034] == repeat_flags &&
          segment[0xD0D2] == 2 &&
          crest_repeat == 0x88C4D4825B57DB92ULL;
    printf("town_llama_cape_crest: %s prompt=%016llx bought=%016llx "
           "crest=%016llx repeat=%016llx almas=%u wearable=%u "
           "flags=%02x/%02x "
           "dialogs=%u/%u/%u repeat_state=%d/%u/%u/%u\n",
           ok ? "PASS" : "FAIL", cape_prompt, cape_bought, crest_award,
           crest_repeat, almas, segment[0x00A1],
           segment[0x0034], segment[0x009A], segment[0xD0D2],
           segment[0xD0DA], segment[0xD0E2], crest_repeat_begin,
           dialog.final_wait, dialog.active, dialog.waiting);
    return ok;
}

static int test_pureza_special_door_warning(void) {
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000], background[0x10000];
    zeliard_town_dialog_t dialog = {0};
    for (size_t i = 0; i < sizeof(vga); ++i)
        vga[i] = background[i] = (u8)(i * 13u + 7u);
    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    if (ok) memcpy(segment + 0x2000, driver, driver_size);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin") &&
          load_raw(segment + 0xC000, 0x4000, "assets/prmp.mdt") &&
          load_font(segment);
    const int begin = ok ? zeliard_town_dialog_begin_scripted(
        &dialog, segment, scratch, vga, sizeof(vga), 0, 0x0918) : -99;
    const unsigned long long warning = fnv1a64(vga, sizeof(vga));
    ok &= begin == 0 && dialog.active && dialog.scripted &&
          dialog.npc_offset == 0xFFFF && dialog.pending_sound_cue == 0x1E;
    for (unsigned guard = 0; ok && dialog.active && guard < 20000; ++guard) {
        if (dialog.scroll_active || dialog.scroll_resume_pending) {
            ok &= zeliard_town_dialog_advance_pit(
                &dialog, segment, vga, sizeof(vga)) >= 0;
        } else if (dialog.waiting) {
            segment[0xFF1D] = 0xFF;
            ok &= zeliard_town_dialog_continue(
                &dialog, segment, scratch, vga, sizeof(vga)) >= 0;
        }
    }
    ok &= !dialog.active && memcmp(vga, background, sizeof(vga)) == 0 &&
          warning == 0xDE68639094AF5E05ULL;
    printf("town_pureza_special_warning: %s frame=%016llx restore=%016llx\n",
           ok ? "PASS" : "FAIL", warning, fnv1a64(vga, sizeof(vga)));
    return ok;
}

static int test_ctrl_8b_persistent_flag(void) {
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000] = {0};
    zeliard_town_dialog_t dialog = {0};
    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    if (ok) memcpy(segment + 0x2000, driver, driver_size);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin") &&
          load_font(segment);
    segment[0xC00D] = 0x00;
    segment[0xC00E] = 0xC1;
    segment[0xC100] = 0x20;
    segment[0xC101] = 0xC1;
    memcpy(segment + 0xC120, (const u8[]){'A', 0x8B, 'B', 0xFF}, 4);
    const int begin = ok ? zeliard_town_dialog_begin_scripted(
        &dialog, segment, scratch, vga, sizeof(vga), 0, 0x0918) : -99;
    ok &= begin == 0 && dialog.final_wait && dialog.glyph_count == 2 &&
          (segment[0x0004] & 0x80) != 0;
    printf("town_ctrl_8b: %s flag=%02x glyphs=%u\n",
           ok ? "PASS" : "FAIL", segment[0x0004], dialog.glyph_count);
    return ok;
}

int main(void) {
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000];
    u8 background[0x10000];
    zeliard_town_dialog_t dialog = {0};
    for (size_t i = 0; i < sizeof(vga); ++i)
        vga[i] = background[i] = (u8)(i * 13u + 7u);

    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    if (ok) memcpy(segment + 0x2000, driver, driver_size);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin");
    ok &= load_raw(segment + 0xC000, 0x4000, "assets/cmap.mdt");
    ok &= load_font(segment);
    segment[0x0080] = 0x1E;
    segment[0x0083] = 0x0B;
    segment[0x00C2] = 0;

    const int begin = ok ? zeliard_town_dialog_begin(
        &dialog, segment, scratch, vga, sizeof(vga), 0x0030) : -99;
    const unsigned long long page_hash = fnv1a64(vga, sizeof(vga));
    const u16 text_pc = (u16)(segment[0x7C58] |
                              ((u16)segment[0x7C59] << 8));
    ok &= begin == 0 && dialog.active && dialog.waiting;
    ok &= page_hash == 0x886C34A52FF3FEE5ULL;
    ok &= dialog.glyph_count == 161 && text_pc == 0xC4AC;
    ok &= dialog.pending_sound_cue == 0x1E && segment[0xFF75] == 0x1E;
    ok &= memcmp(segment + 0xC89C,
                 (const u8[]){0x30,0x00,0x81,0x18,0x01,0x07,0x00,0x00}, 8) == 0;

    segment[0xFF29] = 0x0D;
    const int continued = zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga));
    ok &= continued == 1 && !dialog.active && !dialog.waiting;
    ok &= memcmp(vga, background, sizeof(vga)) == 0;
    ok &= memcmp(segment + 0xC89C,
                 (const u8[]){0x30,0x00,0x81,0x18,0x01,0x00,0x00,0x00}, 8) == 0;
    ok &= segment[0xFF1D] == 0 && segment[0xFF1E] == 0 &&
          segment[0xFF29] == 0;

    printf("town_first_dialog: %s page=%016llx glyphs=%u pc=%04x "
           "cue=%02x restore=%016llx\n", ok ? "PASS" : "FAIL", page_hash,
           dialog.glyph_count, text_pc, dialog.pending_sound_cue,
           fnv1a64(vga, sizeof(vga)));
    ok &= test_muralla_multipage_dialog();
    ok &= test_bosque_sentry_prompt();
    ok &= test_llama_cape_and_elf_crest();
    ok &= test_pureza_special_door_warning();
    ok &= test_ctrl_8b_persistent_flag();
    ok &= test_all_town_dialog_entries();
    printf("VERDICT: %s: town dialog MASM parity\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
