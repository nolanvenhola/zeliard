#!/usr/bin/env python3
"""Release-resource oracle for Dorado town, story state, and services."""

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


def release_root_asset(name: str) -> Path:
    for path in (
        MASM_ROOT / "bin" / name,
        REPO_ROOT / "3_Assembly" / "tasm" / "bin" / name,
    ):
        if path.exists():
            return path
    raise FileNotFoundError(name)


def main() -> int:
    dorado_path = release_asset("242DRMP.mdt")
    dorado_file = dorado_path.read_bytes()
    dorado = payload(dorado_path)
    inn = payload(release_asset("216INNAP.bin"))
    bank = payload(release_asset("213BANKP.bin"))
    stdply = release_root_asset("stdply.bin").read_bytes()

    header = bytes.fromhex(
        "d3c6d700d8c606e7c6efc600c717c7d4cdcfc65c000ac7")
    boundaries = bytes.fromhex("8100ffff8001ffff")
    doors = bytes.fromhex(
        "2f00034600075c0002800006b80004ffff")
    routes = bytes.fromhex("1f0006010f3b0131000e")
    story_event = bytes.fromhex("2a0004fbcd0c03ce0dffffffff")
    title = b"\x19\xaf\x02\x0bDorado Town"
    npcs = bytes.fromhex(
        "be0081b101000000b40084bb010600018b00800001020002"
        "690002000102000388000029010500046600806001030005"
        "55008000010500069a00824f01070007380080a001050008"
        "240004bb010200097a0082000103000a150083450101000bffff")

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    inn_prices = tuple(int.from_bytes(inn[0x2D1 + i:0x2D3 + i], "little")
                       for i in range(0, 16, 2))
    checks = {
        "sha256": hashlib.sha256(dorado_file).hexdigest() ==
                  "f55ed17ef56c26447469f96ac966c5cd163f3a7ccd23756cad4e02a35d2c0b49",
        "header": dorado[:0x17] == header,
        "title": title in dorado,
        "boundaries": dorado[0x6E7:0x6EF] == boundaries,
        "doors": dorado[0x6EF:0x6EF + len(doors)] == doors,
        "routes": dorado[0x700:0x70A] == routes,
        "story_event": dorado[0x70A:0x70A + len(story_event)] == story_event,
        "npcs": dorado[0xDD4:0xDD4 + len(npcs)] == npcs,
        "welcome": b"Welcome to Dorado." in dorado,
        "taruso": b"peace statue called \\Taruso\\" in dorado,
        "shoes_before": b"Shirukaano shoes are hidden in Tesoro" in dorado,
        "shoes_after": b"Ah! You found the Shirukaano shoes!" in dorado,
        "warning_after": b"Take great care when you enter the next world" in dorado,
        "inn_150": inn_prices[5] == 150,
        "bank_1_to_4": exchange[10:12] == bytes((1, 4)),
        "magic_stock": stdply[0xCE] == 0x4C,
        "sword_stock": stdply[0xD7] == 0x38,
        "shield_stock": stdply[0xE0] == 0x38,
    }
    ok = all(checks.values())
    print("town_dorado_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_dorado_routes: {routes.hex()} inn={inn_prices} "
          f"exchange={exchange.hex()} stock={stdply[0xCE]:02x}/"
          f"{stdply[0xD7]:02x}/{stdply[0xE0]:02x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Dorado descriptor/service/story contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
