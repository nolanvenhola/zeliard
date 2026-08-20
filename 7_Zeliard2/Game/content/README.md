# Production Content

Modern authored Godot resources live here. Every top-level definition derives from `ZeliardContent`, owns a stable `namespace:name` ID, and refers to other definitions by ID rather than file path.

Original Zeliard binaries, extracted assets, and legacy resource formats must not be copied into this directory.

The `example/` campaign is deliberately small but exercises every production schema. It is validation and round-trip evidence, not promised game content.

Pixel art uses lossless PNG runtime exports plus typed asset definitions. Editable sources, pivots, animation clips, palette limits, and provenance follow [ART_PIPELINE.md](../ART_PIPELINE.md); reimported pixels never own gameplay metadata.
