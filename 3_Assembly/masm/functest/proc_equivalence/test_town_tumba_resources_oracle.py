#!/usr/bin/env python3
"""Release-resource oracle for Tumba town, story state, and services."""

import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]
REPO_ROOT = MASM_ROOT.parents[1]


def payload(path: Path) -> bytes:
    data = path.read_bytes()
    declared = int.from_bytes(data[:4], "little")
    if declared > len(data) - 4:
        raise ValueError(f"bad payload length in {path}")
    return data[4:4 + declared]


def release_asset(name: str) -> Path:
    for path in (
        MASM_ROOT / "bin" / "zelres2" / name,
        REPO_ROOT / "3_Assembly" / "tasm" / "bin" / "zelres2" / name,
    ):
        if path.exists():
            return path
    raise FileNotFoundError(name)


def main() -> int:
    tumba_path = release_asset("241TMMP.mdt")
    tumba_file = tumba_path.read_bytes()
    tumba = payload(tumba_path)
    armory_path = release_asset("212ARMRP.bin")
    armory_file = armory_path.read_bytes()
    armory = payload(armory_path)
    inn = payload(release_asset("216INNAP.bin"))
    bank = payload(release_asset("213BANKP.bin"))

    header = bytes.fromhex(
        "8bc80e0190c8059ec8a6c8b7c8dec8accf87c88000c1c8")
    boundaries = bytes.fromhex("8100ffff8001ffff")
    doors = bytes.fromhex(
        "2c00035d0007800002b50006e70004ffff")
    routes = bytes.fromhex("5e000b010b83000a000b")
    story_events = bytes.fromhex(
        "220002d3cf08dbcf09ffff240080ebcf0affff"
        "240002ebcf0bffffffff")
    title = b"\x1a\xaf\x00\x0aTumba Town"
    npcs = bytes.fromhex(
        "1a0081a701030000ce0081ab010600063500820000010001"
        "470083ab0002000456008200010300027a00830001050003"
        "a40084ab00020005c80003ab00010007ffff")
    pirika_before = b"ordinary shoes will not protect you"
    pirika_after = b"Those are the Pirika shoes."
    glory_before = b"the Crest of Glory"
    glory_owned = rb"Isn\t that the Crest of Glory?"
    glory_traded = b". . . . . ."
    knight_prompt = (
        rb"Isn\t that the crest of honor you bear? Please come in"
    )
    knight_result = rb"here is your knight\s sword"
    trade_signature = bytes.fromhex(
        "c606920004c6069b0000b004bbab182eff161c208026d600ef"
        "800e240002")

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    inn_prices = tuple(int.from_bytes(inn[0x2D1 + i:0x2D3 + i], "little")
                       for i in range(0, 16, 2))
    checks = {
        "sha256": hashlib.sha256(tumba_file).hexdigest() ==
                  "f568a1df5589c89837d0e7e5c2538a5ef5e4199ac3dbd664005e566ad411351a",
        "header": tumba[:0x17] == header,
        "title": title in tumba,
        "boundaries": tumba[0x89E:0x8A6] == boundaries,
        "doors": tumba[0x8A6:0x8A6 + len(doors)] == doors,
        "routes": tumba[0x8B7:0x8C1] == routes,
        "story_events": tumba[0x8C1:0x8C1 + len(story_events)] ==
                        story_events,
        "npcs": tumba[0xFAC:0xFAC + len(npcs)] == npcs,
        "pirika_before": pirika_before in tumba,
        "pirika_after": pirika_after in tumba,
        "glory_before": glory_before in tumba,
        "glory_owned": glory_owned in tumba,
        "glory_traded": glory_traded in tumba,
        "inn_100": inn_prices[4] == 100,
        "bank_1_to_2": exchange[8:10] == bytes((1, 2)),
        "armory_sha256": hashlib.sha256(armory_file).hexdigest() ==
                         "ed837bbb17e8540d89b2e182047c954de5a5dea45422c06d563738ed049641d4",
        "knight_prompt": knight_prompt in armory,
        "knight_result": knight_result in armory,
        "knight_trade_writes": trade_signature in armory,
    }
    ok = all(checks.values())
    print("town_tumba_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_tumba_routes: {routes.hex()} inn={inn_prices} "
          f"exchange={exchange.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Tumba descriptor/service/story contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
