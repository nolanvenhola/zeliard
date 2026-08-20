# Zeliard 2 Save Format

Zeliard 2 saves are versioned JSON integrity envelopes. Save state refers to immutable content definitions by stable IDs and never embeds or mutates authored Resources.

## Current envelope

Schema version 2 stores:

- campaign and current-room IDs;
- current player health;
- owned item IDs;
- quest stages keyed by quest ID;
- boolean or scalar flags.

The payload is wrapped with the format name and a SHA-256 checksum calculated from canonical, key-sorted JSON. Integrity detects truncation and accidental or external modification; it is not encryption or an anti-cheat mechanism.

## Write and recovery contract

`ZeliardSaveStore` writes and flushes a temporary file, decodes it again, rotates a valid primary to `.backup`, then atomically renames the verified temporary file into place.

- A corrupt primary is quarantined as `.corrupt` rather than promoted over a valid backup.
- Loading tries the primary, then the backup, without changing either file.
- Failed loads never repair, rewrite, or delete recoverable data.
- A failed install leaves the last valid backup available for recovery.

## Migration contract

Legacy payloads are migrated one version at a time in memory. Version 1 used `campaign`, `room`, `health`, `inventory`, and `quests`; version 2 gives those fields explicit state-oriented names. Migration never rewrites the source file during load.

Every future schema bump must add:

1. one deterministic migration step from the immediately previous version;
2. committed input and expected-output fixtures;
3. round-trip, integrity, and recovery regression tests.
