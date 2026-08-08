#!/usr/bin/env python3
"""Release-resource oracle for Pureza town, progression, and services."""

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


def release_asset(name: str, group: str = "zelres2") -> Path:
    for path in (
        MASM_ROOT / "bin" / group / name,
        REPO_ROOT / "3_Assembly" / "tasm" / "bin" / group / name,
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
    pureza_path = release_asset("244PRMP.mdt")
    pureza_file = pureza_path.read_bytes()
    pureza = payload(pureza_path)
    town = payload(release_asset("106TOWN.bin", "zelres1"))
    inn = payload(release_asset("216INNAP.bin"))
    bank = payload(release_asset("213BANKP.bin"))
    stdply = release_root_asset("stdply.bin").read_bytes()

    header = bytes.fromhex(
        "1bca400120ca082fca33ca47ca69ca69d017ca80004cca")
    metadata = bytes.fromhex("480013010201ff0102")
    title = bytes.fromhex("19af020b") + b"Pureza Town"
    boundaries = bytes.fromhex("8100ffff")
    doors = bytes.fromhex(
        "3100045d0007800002b50006e700032601ffffff")
    routes = bytes.fromhex("6f00150117")
    events = bytes.fromhex(
        "420008b1d0ffb2d0ffffff42000890d006ffff2b001090d007ffffffff")
    npcs = bytes.fromhex(
        "16008100030300012c0082000006000344008000030200025400030003030004"
        "79008200030300059a0003000302000cad00000003010008c700810003030009"
        "f70003000306000a240182000303800bffff")

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    inn_prices = tuple(int.from_bytes(inn[0x2D1 + i:0x2D3 + i], "little")
                       for i in range(0, 16, 2))
    checks = {
        "sha256": hashlib.sha256(pureza_file).hexdigest() ==
                  "9feb513c17adeb8158d45918dd6268e661d649c6c8e9f1c5ec217d457231234d",
        "header": pureza[:0x17] == header,
        "metadata": pureza[0xA17:0xA20] == metadata,
        "title": pureza[0xA20:0xA2F] == title,
        "boundaries": pureza[0xA2F:0xA33] == boundaries,
        "doors": pureza[0xA33:0xA47] == doors,
        "routes": pureza[0xA47:0xA4C] == routes,
        "events": pureza[0xA4C:0xA69] == events,
        "npcs": pureza[0x1069:0x1069 + len(npcs)] == npcs,
        "trap_warning": b"Fooled again! Meddlesome fool!" in pureza and
                        b"Taste the past and never return here again" in pureza,
        "lion_key_before": b"lion\\s head key but it was stolen" in pureza,
        "lion_key_after": b"key that was entrusted to me by the Spirits" in pureza,
        "fairy_flame": b"Fairy Flame Sword" in pureza,
        "esco_hint": b"village called Esko" in pureza,
        "special_dorado_selector": bytes.fromhex("b4868826c400") in town,
        "special_dorado_position": bytes.fromhex(
            "c70680008400c60683000d") in town,
        "inn_400": inn_prices[7] == 400,
        "bank_1_to_6": exchange[14:16] == bytes((1, 6)),
        "magic_stock": stdply[0xD0] == 0x01,
        "sword_stock": stdply[0xD9] == 0xF8,
        "shield_stock": stdply[0xE2] == 0x1C,
    }
    ok = all(checks.values())
    print("town_pureza_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_pureza_route: {routes.hex()} inn={inn_prices} "
          f"exchange={exchange.hex()} stock={stdply[0xD0]:02x}/"
          f"{stdply[0xD9]:02x}/{stdply[0xE2]:02x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Pureza descriptor/service/story contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
