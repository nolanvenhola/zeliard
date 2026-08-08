#!/usr/bin/env python3
"""Release-resource oracle for Esco town, routes, and services."""

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
    esco_path = release_asset("245ESMP.mdt")
    esco_file = esco_path.read_bytes()
    esco = payload(esco_path)
    town = payload(release_asset("106TOWN.bin", "zelres1"))
    bank = payload(release_asset("213BANKP.bin"))
    drug = payload(release_asset("215DRUGP.bin"))
    stdply = release_root_asset("stdply.bin").read_bytes()

    header = bytes.fromhex(
        "d3c6d700d8c609e8c6e8c6f9c600c7c8c9cfc6ab00fec6")
    metadata = bytes.fromhex("0400ff0001")
    title = bytes.fromhex("19af000c") + b"Esco village"
    shared_boundary_doors = bytes.fromhex(
        "3900036f00048a0006ab0005cd0008ffff")
    routes = bytes.fromhex("7b00060018")
    events = bytes.fromhex("ffff")
    npcs = bytes.fromhex(
        "0800000001030001260002000103000352000000010300027e00020001030000"
        "a900010000000004ad000100000000059f00040001030006ffff")

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    discount_record = bytes.fromhex(
        "00020000c80000280000180100200300500000e8030096")
    checks = {
        "sha256": hashlib.sha256(esco_file).hexdigest() ==
                  "6c43552869e9c323bdbc0875b3af7c2fc12a4fe7acaf5c2e3ab1ce5375990f32",
        "header": esco[:0x17] == header,
        "metadata": esco[0x6D3:0x6D8] == metadata,
        "title": esco[0x6D8:0x6E8] == title,
        "shared_boundary_doors":
            esco[0x6E8:0x6F9] == shared_boundary_doors,
        "route": esco[0x6F9:0x6FE] == routes,
        "events": esco[0x6FE:0x700] == events,
        "npcs": esco[0x9C8:0x9C8 + len(npcs)] == npcs,
        "blue_door_hint": b"door with the blue symbol" in esco,
        "jashiin_route_hint": b"abode of Jashiin" in esco,
        "fruit_garden_hint": b"jumping in front of the ivy" in esco,
        "ctrl_8b_sets_persistent_bit":
            bytes.fromhex("800e040080") in town,
        "bank_1_to_8": exchange[16:18] == bytes((1, 8)),
        "discount_magic_prices": discount_record in drug,
        "magic_stock": stdply[0xD1] == 0xFF,
        "sword_stock": stdply[0xDA] == 0xF8,
        "shield_stock": stdply[0xE3] == 0xFC,
    }
    ok = all(checks.values())
    print("town_esco_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_esco_route: {routes.hex()} exchange={exchange.hex()} "
          f"stock={stdply[0xD1]:02x}/{stdply[0xDA]:02x}/"
          f"{stdply[0xE3]:02x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Esco descriptor/service/progression contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
