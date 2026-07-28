# Opening AdLib Sound Oracles

These PCM clips are decoded from the original DOSBox-X AdLib output in
`3_Assembly/masm/bin/capture/OpeningDemo-Capture.mp4`. They provide browser
playback while the mechanical `SNDADLIB.DRV` bytecode-to-OPL renderer is being
ported.

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

The files are SHA-256 pinned by `6_WebPort/scripts/copy_assets.mjs`. Cue timing
still comes from the translated MASM procedures; the video is only the captured
audio oracle.

## Opening music

The browser score files are captured output from `MSCADLIB.DRV`, not the longer
soundtrack arrangements under `4_Resources/Music/`. This matters at the end of
the credits: the `zend.msd` channel streams reduce their AdLib levels and reach
their `EFh` end commands during the visual handoff. The soundtrack arrangement
does not fade until much later.

| File | MASM load/start | Capture interval | Duration |
|---|---|---:|---:|
| `music_zopn_adlib.ogg` | `100OPDMO.asm`: load `zopn.msd`, `AX=0`, `INT 60h` | 68.810-190.863 s | 122.053 s |
| `music_zend_adlib.ogg` | `opening_next_scene`: load `zend.msd`, `AX=0`, `INT 60h` | 190.863-271.800 s | 80.937 s |

The second clip includes the original stepped credits fade through the first
princess/rain frame. Playback is one-shot, matching the driver's seven-channel
score completion; it must not loop or restart while the C phase remains active.
On credits exit, MASM clears the screen and waits on the music driver's
`gvar_enable_all` completion byte. The host therefore keeps the same playback
source running until the captured score reaches its natural end.
