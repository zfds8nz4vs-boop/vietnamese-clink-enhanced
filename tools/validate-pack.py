#!/usr/bin/env python3
import json, pathlib, struct, sys

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 tools/validate-pack.py <code>")
code = sys.argv[1]
root = pathlib.Path("Lexicons")
lexicon, ngram = root / f"{code}.clex", root / f"{code}.cngm"
errors = []
if not lexicon.exists():
    errors.append(f"Missing required {lexicon}.")
else:
    data = lexicon.read_bytes()
    if len(data) < 16 or data[:4] != b"CLEX" or struct.unpack_from("<I", data, 4)[0] != 1:
        errors.append(f"{lexicon} is not a CLEX version 1 dictionary.")
if ngram.exists():
    data = ngram.read_bytes()
    if len(data) < 12 or data[:4] != b"CNGM" or struct.unpack_from("<I", data, 4)[0] != 1:
        errors.append(f"{ngram} is not a CNGM version 1 next-word model.")
emoji = root / f"{code}.emoji.json"
if emoji.exists():
    try:
        metadata = json.loads(emoji.read_text(encoding="utf-8"))
        if metadata.get("version") != 1:
            errors.append(f"{emoji} must use metadata version 1.")
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{emoji} is not valid UTF-8 JSON: {error}")
if errors:
    raise SystemExit("\n".join("ERROR: " + e for e in errors))
print(f"{code}: looks ready for release.")
