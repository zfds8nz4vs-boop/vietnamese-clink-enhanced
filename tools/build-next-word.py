#!/usr/bin/env python3
"""Build a Clink CNGM v1 next-word model from a sentence corpus."""
import collections, math, pathlib, re, struct, sys, unicodedata

if len(sys.argv) != 4:
    raise SystemExit("Usage: python3 tools/build-next-word.py <code> <word-list.txt> <sentences.txt>")
code, word_path, corpus_path = sys.argv[1], pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])

def word(value):
    value = unicodedata.normalize("NFC", value.strip().lower())
    return value if value and not any(c.isspace() for c in value) and any(c.isalpha() for c in value) else None

words = set()
for raw in word_path.read_text(encoding="utf-8").splitlines():
    if raw.strip() and not raw.lstrip().startswith("#"):
        candidate = word(raw.rsplit(maxsplit=1)[0])
        if candidate:
            words.add(candidate)
ordered = sorted(words, key=lambda value: value.encode("utf-8"))
if not ordered:
    raise SystemExit("The word list contains no usable words.")
ids = {value: i for i, value in enumerate(ordered)}

pairs = collections.Counter()
for raw in corpus_path.read_text(encoding="utf-8").splitlines():
    sentence = raw.rsplit("\t", 1)[-1]
    tokens = [word(t) for t in re.findall(r'[^\s.,!?;:"“”‘’()\[\]{}]+', sentence)]
    tokens = [t for t in tokens if t in ids]
    pairs.update(zip(tokens, tokens[1:]))

if not pairs:
    raise SystemExit("No word pairs matched the word list.")
totals = collections.Counter()
for (previous, _), count in pairs.items():
    totals[previous] += count
ranked = sorted(pairs.items(), key=lambda item: (ids[item[0][0]], -item[1], ids[item[0][1]]))

blob = bytearray(b"CNGM" + struct.pack("<II", 1, len(ranked)))
for (previous, _), _ in ranked:
    blob += struct.pack("<I", ids[previous])
for (_, following), _ in ranked:
    blob += struct.pack("<I", ids[following])
for (previous, _), count in ranked:
    probability = count / totals[previous]
    blob.append(max(0, min(255, round((math.log10(probability) + 6) * 42))))

destination = pathlib.Path("Lexicons") / f"{code}.cngm"
destination.parent.mkdir(exist_ok=True)
destination.write_bytes(blob)
print(f"Built {destination} with {len(ranked):,} next-word pairs.")
