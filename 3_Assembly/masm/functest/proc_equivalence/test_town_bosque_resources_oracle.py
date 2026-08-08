#!/usr/bin/env python3
"""Release-resource oracle for Bosque town, routes, gate, and services."""

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
    candidates = (
        MASM_ROOT / "bin" / "zelres2" / name,
        REPO_ROOT / "3_Assembly" / "tasm" / "bin" / "zelres2" / name,
    )
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError(name)


def main() -> int:
    bosque_path = release_asset("239BSMP.mdt")
    bosque_file = bosque_path.read_bytes()
    bosque = payload(bosque_path)
    inn = payload(release_asset("216INNAP.bin"))
    bank = payload(release_asset("213BANKP.bin"))

    header = bytes.fromhex(
        "dbc49800e0c403f2c4f2c409c520c5f4ccd7c43c0013c5")
    doors = bytes.fromhex(
        "0700092400063d00025100046000037200078e0008ffff")
    routes = bytes.fromhex("b90013000595000e0106")
    crest_event = bytes.fromhex("120008facc80fbcc0effffffff")
    sentry = bytes.fromhex("090001cc0004c00b")
    title = b"\x18\xaf\x00\x0eBosque village"
    prompt = (b"Hold on there! Do you have the Hero\\s Crest? \x81"
              b"Don\\t lie, it won\\t do any good. Get out of here!\xff")
    denied = (b"You cannot pass here without the Hero\\s Crest. "
              b"My orders are from the Spirits themselves! \xff")
    allowed = (b"Hold on there! You have the Hero\\s Crest, I see. "
               b"You may pass.\xff")

    bank_title = bank.index(b"The Bank")
    exchange = bank[bank_title + len(b"The Bank"):
                    bank_title + len(b"The Bank") + 18]
    inn_prices = tuple(int.from_bytes(inn[0x2D1 + i:0x2D3 + i], "little")
                       for i in range(0, 16, 2))
    checks = {
        "sha256": hashlib.sha256(bosque_file).hexdigest() ==
                  "9af943ae81e431f219784d2d5050976480bbaba48f4c5f8fe07c1ff155d811ff",
        "header": bosque[:0x17] == header,
        "title": bosque[0x4E0:0x4E0 + len(title)] == title,
        "doors": bosque[0x4F2:0x4F2 + len(doors)] == doors,
        "routes": bosque[0x509:0x509 + len(routes)] == routes,
        "crest_event": bosque[0x513:0x513 + len(crest_event)] == crest_event,
        "sentry": bosque[0xCF4:0xCF4 + 8] == sentry,
        "prompt": prompt in bosque,
        "denied": denied in bosque,
        "allowed": allowed in bosque,
        "inn_50": inn_prices[2] == 50,
        "bank_1_to_8": exchange[4:6] == bytes((1, 8)),
    }
    ok = all(checks.values())
    print("town_bosque_resources: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"town_bosque_routes: {routes.hex()} inn={inn_prices} "
          f"exchange={exchange.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release Bosque descriptor/service contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
