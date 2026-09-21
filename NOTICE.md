# NOTICE

## UniKey

UniKey is by Phạm Kim Long. The official UniKey project distributes its Vietnamese input-method source under the GNU GPL. This repository does not redistribute the supplied Windows executable.

The supplied archive was:

- `unikey46RC2-230919-win64.zip`
- contents: `UniKeyNT.exe` and `keymap.txt`

The repository keeps only the small Telex mapping needed to document compatibility.

## FrequencyWords

Source: Hermit Dave, FrequencyWords, 2018 Vietnamese list:

https://github.com/hermitdave/FrequencyWords/blob/master/content/2018/vi/vi_50k.txt

FrequencyWords describes its generated content as CC BY-SA 4.0 and its code as MIT. The Clink dictionary in this repository is a transformed/compiled derivative of that content and therefore preserves the content license.

## Clink format

The binary `vi.clex` follows the CLEX v1 format used by the Clink language-pack project. It is generated from the source word/frequency list; it is not copied from the upstream Clink Vietnamese binary.

## Scope

This first version is an MVP dictionary pack. It does not claim to implement the UniKey IME engine inside Clink.
