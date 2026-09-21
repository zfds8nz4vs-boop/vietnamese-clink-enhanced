# Vietnamese Clink Enhanced

Vietnamese language resources for Clink, with a UniKey-compatible Telex reference.

## Included

- `Lexicons/vi.clex` — Clink CLEX v1 dictionary generated from the first 1,000 entries of the pinned 2018 Vietnamese FrequencyWords list, including source frequencies.
- `Lexicons/vi.emoji.json` — Vietnamese emoji aliases and stopwords.
- `source/vi.txt` — reproducible word/frequency source snapshot.
- `source/unikey-telex-keymap.txt` — Telex mapping documented by the supplied UniKey package.
- `NOTICE.md` — provenance and licensing notes.

## UniKey relationship

The supplied UniKey 4.6 RC2 Windows archive contains `UniKeyNT.exe` and `keymap.txt`; it does **not** contain the UniKey source code. This project therefore does not redistribute or embed `UniKeyNT.exe`.

The Telex mapping documented here is:

- `s` tone 1
- `f` tone 2
- `r` tone 3
- `x` tone 4
- `j` tone 5
- `z` remove tone
- `w` hook-bowl
- `a/e/o` roof
- `d` D-mark

This mapping is included for compatibility/reference. A Clink `.clex` dictionary does not itself implement the keystroke transformation performed by a Vietnamese IME.

## Build status

This first commit is an MVP dictionary pack:

- 978 normalized usable entries from the first 1,000 source rows.
- CLEX v1 binary compiled and committed as `Lexicons/vi.clex`.
- Vietnamese emoji metadata included.
- UniKey Telex mapping documented separately.
- No `.cngm` next-word model yet, because a redistributable Vietnamese sentence corpus has not been pinned and reviewed.
- No `.cime` file: Clink's `.cime` format is intended for reading-to-character IMEs such as Pinyin → Hanzi, not for implementing Telex transformation.

## Data provenance

The dictionary source is Hermit Dave's FrequencyWords 2018 Vietnamese list:

https://github.com/hermitdave/FrequencyWords/blob/master/content/2018/vi/vi_50k.txt

The upstream project identifies the generated frequency data as CC BY-SA 4.0. The source snapshot and attribution are retained so the generated CLEX resource can be traced back to its input.

## Next step

The pack can be expanded to the complete Vietnamese source, then a licensed sentence corpus can be added to build `vi.cngm`. A separate Clink-side Telex input method would require support in Clink for keystroke-to-Vietnamese composition; the language-pack dictionary alone cannot provide that behavior.

## Reproducible full-data build

The repository now includes the same CLEX/CNGM build logic used by the upstream Clink language-pack project, plus a GitHub Actions workflow. The workflow fetches the pinned Vietnamese FrequencyWords 2018 source and the Tatoeba Vietnamese sentence export, builds `vi.clex` and `vi.cngm`, validates both, and uploads them as a workflow artifact.

The checked-in `Lexicons/vi.clex` remains the small bootstrap build from the initial source snapshot. The full 50k + sentence build is intentionally generated in CI rather than committing a large, automatically downloaded corpus to the repository.

Tatoeba publishes sentence exports under CC BY 2.0 FR; FrequencyWords' generated unigram data is CC BY-SA 4.0. The build keeps those provenance boundaries explicit.
