# Clink Vietnamese — Telex language pack

Independent community Vietnamese language pack for Clink, modeled on the
resource/build/release structure of the community Chinese pack
dayifulalala-del/clink-chinese.

## Package

The release contains:

- vi.clex — Vietnamese frequency dictionary.
- vi.cngm — next-word model from Tatoeba Vietnamese sentences.
- vi.cime — generated Vietnamese Telex reading table.
- vi.emoji.json — Vietnamese emoji aliases.
- manifest.json — release manifest with SHA-256 checksums.
- README.md, NOTICE.md, LICENSE.md and RELEASE-NOTES.md.

The build uses Python. PowerShell and shell scripts provide repeatable local
maintenance and publishing helpers. The Lua adapter from earlier experiments
has been removed.

## Telex rules

The established rules are preserved:

- aa -> â
- aw -> ă
- ee -> ê
- oo -> ô
- ow -> ơ
- uw -> ư
- dd -> đ
- s/f/r/x/j -> sắc/huyền/hỏi/ngã/nặng
- z -> remove the current tone
- uppercase shape and tone forms are supported.

The repository also keeps the earlier regression coverage for word boundaries,
tone placement, valid Vietnamese syllable/coda handling, repeated keys and
UTF-8-safe editing in the development history. The packaged CIME is generated
from the same Telex rules instead of embedding a Lua hook.

Important: Python, PowerShell and shell do not execute as the interactive
keystroke engine. They build and package the data. The runtime consumer must
support the Clink CIME language-pack resource for the generated table to be
used.

## Build locally

    python3 tools/fetch-vietnamese-sources.py
    python3 tools/build-pack.py vi source/vi_50k.txt
    python3 tools/build-next-word.py vi source/vi_50k.txt source/vie_sentences.tsv
    python3 tools/build-telex-cime.py vi source/vi_50k.txt
    python3 tools/validate-pack.py vi
    python3 tools/validate-catalog.py
    python3 -m unittest discover -s tools -p 'test_*.py' -v

On Windows PowerShell, use python instead of python3 where appropriate.

## Sources and licensing

The dictionary source is FrequencyWords Vietnamese 2018, distributed under
CC BY-SA 4.0. The next-word source is the Tatoeba Vietnamese sentence export,
which is distributed under CC BY 2.0 FR with some CC0 material. The pack
tooling is independent and documents its provenance in catalog/ and NOTICE.md.

This repository does not contain the UniKey source code or claim to be the
UniKey engine. The earlier uploaded UniKey binary/keymap was used only as a
reference for the Telex rule work; the current package is a Clink language
pack built from documented resources.

## Release

GitHub Actions fetches the pinned sources, builds all four vi.* resources,
validates them, computes SHA-256 hashes, and publishes an immutable release.
The release tag for this generation is vvi-official-4-1.

A successful GitHub Actions run proves package construction and validation; it
does not by itself prove activation on a particular device or Clink client.
