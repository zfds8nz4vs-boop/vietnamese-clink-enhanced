# Vietnamese Clink language pack

This repository is the Vietnamese counterpart of a complete Clink language-pack
repository. Keep the package data-driven and reproducible.

Resources:
- Lexicons/vi.clex: Vietnamese frequency dictionary.
- Lexicons/vi.cngm: Vietnamese next-word model.
- Lexicons/vi.cime: generated Telex reading table.
- Lexicons/vi.emoji.json: Vietnamese emoji aliases.
- manifest.json: release metadata and SHA-256 checksums.

Telex rules:
aa -> â, aw -> ă, ee -> ê, oo -> ô, ow -> ơ, uw -> ư, dd -> đ.
Tone keys: s sắc, f huyền, r hỏi, x ngã, j nặng; z removes tone.
Uppercase equivalents are supported. The earlier Lua adapter is intentionally
removed; Python generates the packaged Telex CIME data.

Build:
python3 tools/fetch-vietnamese-sources.py
python3 tools/build-pack.py vi source/vi_50k.txt
python3 tools/build-next-word.py vi source/vi_50k.txt source/vie_sentences.tsv
python3 tools/build-telex-cime.py vi source/vi_50k.txt
python3 tools/validate-pack.py vi
python3 -m unittest discover -s tools -p 'test_*.py' -v

Do not claim that Python/PowerShell/shell execute inside Clink's keystroke loop.
They are build, packaging and maintenance tooling; CIME is the runtime resource.
