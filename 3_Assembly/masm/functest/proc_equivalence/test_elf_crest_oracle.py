#!/usr/bin/env python3
"""Release-byte oracle for Paguro's complete Elf Crest progression chain."""

from __future__ import annotations

import struct
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]


def payload(archive: str, name: str) -> bytes:
    image = (MASM_ROOT / "bin" / archive / name).read_bytes()
    declared = struct.unpack_from("<I", image)[0]
    assert declared == len(image) - 4
    return image[4:]


def main() -> int:
    paguro = payload("zelres3", "315ZEL2.bin")
    hut = payload("zelres3", "341MP73.mdt")
    town = payload("zelres1", "106TOWN.bin")
    llama = payload("zelres2", "243LLMP.mdt")
    select = payload("zelres2", "201SELCT.bin")
    player = (MASM_ROOT / "bin" / "stdply.bin").read_bytes()

    hut_descriptor = struct.unpack_from("<H", hut)[0] - 0xC000
    paguro_completion = bytes.fromhex("c60630ffffc3")
    crest_award_opcode = bytes.fromhex(
        "800e340080c6069a00ffe85b04e90cff")
    ability_loop = bytes.fromhex("be9a00bb8930b90300")
    defeat_mutations = bytes.fromhex(
        "3000ff03c9ff04c9ff0cc7f00dc7f10ec7f014c7f015c7f016c7f0"
        "d2d001e2d010ead00bf2d00cfad00d02d10e0ad10f12d111ffff")
    award_mutation = bytes.fromhex("340080d2d002d1d000ffff")

    checks = {
        "paguro_hut_descriptor":
            hut[hut_descriptor:hut_descriptor + 5] ==
            bytes.fromhex("99000a12ff") and
            hut[hut_descriptor + 16:hut_descriptor + 20] ==
            bytes.fromhex("3000ffff"),
        "paguro_completion_unique": paguro.count(paguro_completion) == 1,
        "paguro_completion_offset":
            paguro[0x5D9:0x5D9 + len(paguro_completion)] ==
            paguro_completion,
        "paguro_reward_1600": bytes.fromhex("4006") in
                              paguro[0x5DF:0x620],
        "llama_defeat_mutations": llama.count(defeat_mutations) == 1,
        "llama_award_mutation": llama.count(award_mutation) == 1,
        "award_dialog_and_opcode":
            b"I will give you the Elf Crest" in llama and
            b"without it, no one in town will help you.\x83\xff" in llama,
        "town_award_handler_unique": town.count(crest_award_opcode) == 1,
        "town_award_writes": bytes.fromhex("800e340080") in
                             crest_award_opcode and
                             bytes.fromhex("c6069a00ff") in
                             crest_award_opcode,
        "pre_crest_dialog": b"don\\t have the Elf Crest" in llama,
        "post_crest_dialog": b"You\\ve got the Elf Crest. Great!" in llama,
        "inventory_three_slots": select.count(ability_loop) == 1,
        "elf_inventory_first": ability_loop ==
                               bytes.fromhex("be9a00bb8930b90300"),
        "player_record_offsets": len(player) == 233 and
                                 player[0x30] == 0 and
                                 player[0x31] == 0 and
                                 player[0x34] == 0 and
                                 player[0x9A] == 0,
    }
    ok = all(checks.values())
    print("elf_crest_oracle: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print("elf_crest_contract: Paguro=0030/0031 award=0034/80 "
          "inventory=009a npc=LLMP:D0D2:01>02")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM Paguro victory, Llama award, inventory, and "
          "pre/post-Crest dialog chain")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
