#!/usr/bin/env python3
"""Release-resource oracle for Helada town, story state, and services."""

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
    helada_path = release_asset("240HLMP.mdt")
    helada_file = helada_path.read_bytes()
    helada = payload(helada_path)
    inn = payload(release_asset("216INNAP.bin"))
    bank = payload(release_asset("213BANKP.bin"))

    header = bytes.fromhex(
        "33c7e30038c70447c74fc760c77dc7becd2fc72c006ac7")
    boundaries = bytes.fromhex("8100ffff8001ffff")
    doors = bytes.fromhex(
        "2c00025c00076f0003800004940006ffff")
    routes = bytes.fromhex("56001601081000160009")
    story_event = bytes.fromhex(
        "1a0010d5cd07d4cd00edcd09ddcd08ffffffff")
    title = b"\x19\xaf\x00\x0bHelada Town"
    npcs = bytes.fromhex(
        "b100811c010300008b008300000500046900020001038003"
        "a6008300000500024800831b000100059e00820000020006"
        "380081000103000a5000810001060001ffff")
    dialog_before = (
        b"Are you the brave one? My lover, Percel, was killed by "
        b"Jashiin\\s underlings"
    )
    dialog_after = b"I\\m sorry for what I said a short while ago."
    dialog_shoes = b"Ah, the shoes of Percel...."
    dialog_float = b"This brave man with the Ruzeria shoes..."

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    inn_prices = tuple(int.from_bytes(inn[0x2D1 + i:0x2D3 + i], "little")
                       for i in range(0, 16, 2))
    checks = {
        "sha256": hashlib.sha256(helada_file).hexdigest() ==
                  "67af5d4ff9ed9504d5b454bb8b00cdfb0b2e52aeda5d61763c13c0b2e6a76c06",
        "header": helada[:0x17] == header,
        "title": title in helada,
        "boundaries": helada[0x747:0x74F] == boundaries,
        "doors": helada[0x74F:0x74F + len(doors)] == doors,
        "routes": helada[0x760:0x76A] == routes,
        "story_event": helada[0x76A:0x76A + len(story_event)] == story_event,
        "npcs": helada[0xDBE:0xDBE + len(npcs)] == npcs,
        "percel_before": dialog_before in helada,
        "percel_after": dialog_after in helada,
        "ruzeria_dialog": dialog_shoes in helada,
        "floating_shop": dialog_float in helada,
        "inn_70": inn_prices[3] == 70,
        "bank_1_to_4": exchange[6:8] == bytes((1, 4)),
    }
    ok = all(checks.values())
    print("town_helada_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_helada_routes: {routes.hex()} inn={inn_prices} "
          f"exchange={exchange.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Helada descriptor/service/story contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
