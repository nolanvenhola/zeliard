# Original alternate-audio parity

Issues #186 and #187 use the original release drivers as executable oracles,
not a re-authored score player. The browser runs each driver at its original
load address and entry ABI in the existing 8086 VM, then synthesizes the
hardware port stream.

## Canonical loader behavior

- `zeliad.asm:664-694` recognizes only `mscmt.drv` as MT-32 and records the
  flag. `zeliad.asm:214-232` consequently executes `MTINIT.COM`; the browser
  bundles and integrity-checks that release file, while its WebAudio synth is
  the already-initialized MPU/MT-32-compatible endpoint.
- `zeliad.asm:1117-1123` loads music at `0100h` and effects at `1100h`.
  `mscadlib_vm.c` preserves those addresses, music timer entry `0100h`, music
  service entry `0103h`, and SFX timer entry `1100h` for every backend.
- `game.asm:564-601` passes each complete MSD resource to the configured
  driver. The MSD payload contains a first MT-32 stream and a second stream
  shared by AdLib, PCjr, and speaker. Only `mscmt.drv` receives the first.
- `stick.asm:372`, `393-394`, and `979` show that the same `FF75h` cue mailbox,
  `FF27h` enable byte, and music service calls control every configured driver.
  No gameplay call site is backend-specific.

## Release asset identities

| Asset | SHA-256 |
|---|---|
| `mscmt.drv` | `45b169ade347f342560f8c6b285f9a96a6ad5cd6c296ba75fb4ff34425d02d83` |
| `mtinit.com` | `d2964c02e2af6429dffb4d86ac40ad083026992b74bb09898018d7850165a272` |
| `mscjr.drv` | `b09d2045ff959774eef5d82288ede7ace7211743c5891b03af699a65146193f9` |
| `sndjr.drv` | `f66583660a24c5fc8a0c20a5fe00c9af7d1009a45652043af5a0280a25423c70` |
| `mscstd.drv` | `5f49fad4db1394c3469eece482449fcdce4f904fa7e8213f66cfc6262b509047` |
| `sndstd.drv` | `e055088bcb1b5d26d7ddd57989733d98b05cdd277c477241c54cddc3f4e60278` |

`scripts/copy_assets.mjs` rejects any byte mismatch before deployment.

## Deterministic checkpoints

`make test-legacy-audio` executes release `zopn.msd` for 1,024 original PIT
ticks and checks the complete `(tick, port, value)` stream:

| Backend | Writes | FNV-1a |
|---|---:|---:|
| MT-32 | 894 | `666053d7` |
| PCjr | 785 | `5911bbc2` |
| speaker | 1,558 | `70e5ca8a` |

It also checks the release fade completion state (MT-32: 801 ticks; PCjr and
speaker: 1,009 ticks), every gameplay SFX cue currently emitted by the port,
mailbox consumption, non-zero PCM production, and fixed 256-tick MT-32 port
stream hashes for all 14 music-bearing score resources. Existing MSCADLIB/SNDADLIB
write hashes remain unchanged in `mscadlib_vm_native.c`.

The UI defaults to AdLib. A requested backend whose release driver cannot be
loaded or initialized falls back to AdLib and reports that fallback in the UI.
