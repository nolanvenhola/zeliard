# Opening AdLib Sound Oracles

These PCM clips are decoded from the original DOSBox-X AdLib output in
`3_Assembly/masm/bin/capture/OpeningDemo-Capture.mp4`. They are retained only
as differential-listening oracles. The browser executes the original
`SNDADLIB.DRV` bytes in the shared 8086 audio runtime and sends the resulting
ports `388h/389h` writes to the Opal OPL core.

The cue identities come from `100OPDMO.asm` and the verified driver table:

| Cue | MASM source | Capture interval |
|---:|---|---:|
| `02h` | `stick.asm` pause handler (`gvar_volume_b = 2`) | dedicated release capture, 0.606021-0.963667 s |
| `04h` | DMAOU animation (`gvar_volume_b = 4`) | 52.719-65.839 s |
| `3Dh` | `text_attr = '='` | 625.936-626.186 s |
| `3Eh` | `text_attr = '>'` | 483.538-483.788 s |
| `3Fh` | `text_attr = '?'` | 422.713-422.963 s |
| `40h` | `text_attr = '@'` | 509.535-509.785 s |
| `41h` | `text_attr = 'A'` | 336.171-336.421 s |

Cue timing and mailbox writes come from the translated MASM procedures. The
driver reads the original `FF75h` cue mailbox, uses the original INT `60h`
service bridge, and runs before `MSCADLIB.DRV` on each timer tick as specified
by `stick.asm`. Production asset copying removes all seven WAV files so they
cannot become an accidental playback path.

## Opening music oracle

The OGG files are retained only as captured comparison artifacts. Browser music
executes the original `MSCADLIB.DRV` against the original `zopn.msd` and
`zend.msd` bytes in the same WASM audio runtime. Production asset copying
explicitly removes the old OGG playback files.

| File | MASM load/start | Capture interval | Duration |
|---|---|---:|---:|
| `music_zopn_adlib.ogg` | `100OPDMO.asm`: load `zopn.msd`, `AX=0`, `INT 60h` | 68.810-190.863 s | 122.053 s |
| `music_zend_adlib.ogg` | `opening_next_scene`: load `zend.msd`, `AX=0`, `INT 60h` | 190.863-271.800 s | 80.937 s |

The second clip remains useful for differential listening. The live path gets
the stepped credits fade and completion directly from MSCADLIB's `FF24-FF26`
state rather than reproducing them with WebAudio gain automation.
