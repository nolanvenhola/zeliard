#!/usr/bin/env python3
"""Release-resource oracle for Llama town, story state, and services."""

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
    llama_path = release_asset("243LLMP.mdt")
    llama_file = llama_path.read_bytes()
    llama = payload(llama_path)
    inn = payload(release_asset("216INNAP.bin"))
    bank = payload(release_asset("213BANKP.bin"))
    stdply = release_root_asset("stdply.bin").read_bytes()

    header = bytes.fromhex(
        "dbc81801e0c807eec8eec808c961c9cbd0d7c8470017c9")
    metadata = bytes.fromhex(
        "1f00c8000401ff000119af030a4c6c616d6120546f776e")
    doors = bytes.fromhex(
        "0800092700034700026800048e0006b000070d0108de000affff")
    routes = bytes.fromhex("010016001298000701121b000d0015")
    story_events = bytes.fromhex(
        "3000ff03c9ff04c9ff0cc7f00dc7f10ec7f014c7f015c7f016c7f0d2d001e2d010ead00bf2d00cfad00d02d10e0ad10f12d111ffff"
        "340080d2d002d1d000ffff340040dad009ffffff")
    npcs = bytes.fromhex(
        "dc00020001038000ff0003000103000318008100010300120e0080000106000a"
        "32000200000600137c008300010300135b00820000010013c000830001050013"
        "9f00810001060013ffff")

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    inn_prices = tuple(int.from_bytes(inn[0x2D1 + i:0x2D3 + i], "little")
                       for i in range(0, 16, 2))
    checks = {
        "sha256": hashlib.sha256(llama_file).hexdigest() ==
                  "00140a4065e22c71e33b0c9620f2d1e9b5f49d168c00ebdfe832117c72dcf2a2",
        "header": llama[:0x17] == header,
        "metadata": llama[0x8D7:0x8EE] == metadata,
        "doors": llama[0x8EE:0x908] == doors,
        "routes": llama[0x908:0x917] == routes,
        "story_events": llama[0x917:0x960] == story_events,
        "npcs": llama[0x10CB:0x10CB + len(npcs)] == npcs,
        "creature": b"A terrible creature is in our hut" in llama,
        "elf_crest": b"I will give you the Elf Crest" in llama,
        "crest_control": b"without it, no one in town will help you.\x83\xff" in llama,
        "asbestos_cape": b"an Asbestos cape that will protect you from the heat" in llama,
        "cape_price": b"It will cost you 2500&almas" in llama,
        "cape_controls": b"protect you from the heat.\x87It\\s not free" in llama and
                         b"2500&almas.///\x89" in llama,
        "inferno": b"caverns with a flaming inferno" in llama,
        "correr": b"in Correr Cave" in llama,
        "inn_200": inn_prices[6] == 200,
        "bank_4_to_2": exchange[12:14] == bytes((4, 2)),
        "magic_stock": stdply[0xCF] == 0x4B,
        "sword_stock": stdply[0xD8] == 0x38,
        "shield_stock": stdply[0xE1] == 0x1C,
    }
    ok = all(checks.values())
    print("town_llama_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_llama_routes: {routes.hex()} inn={inn_prices} "
          f"exchange={exchange.hex()} stock={stdply[0xCF]:02x}/"
          f"{stdply[0xD8]:02x}/{stdply[0xE1]:02x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Llama descriptor/service/story contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
