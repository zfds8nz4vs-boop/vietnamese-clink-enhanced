#!/usr/bin/env python3
"""Build a Vietnamese Telex .cime table from a UTF-8 Vietnamese word list."""
import pathlib,sys,unicodedata
if len(sys.argv)!=3: raise SystemExit("Usage: build-telex-cime.py <code> <word-list.txt>")
code,source=sys.argv[1],pathlib.Path(sys.argv[2])
if code!="vi": raise SystemExit("This builder targets Vietnamese.")
SHAPE={"a":"aa","A":"AA","e":"ee","E":"EE","o":"oo","O":"OO","ă":"aw","Ă":"AW","ơ":"ow","Ơ":"OW","u":"uw","U":"UW"}
TONE={"\u0301":"s","\u0300":"f","\u0309":"r","\u0303":"x","\u0323":"j"}
def telex_char(ch):
    if ch in ("đ","Đ"): return "dd" if ch=="đ" else "DD"
    decomp=unicodedata.normalize("NFD",ch)
    if len(decomp)==1: return ch
    base=decomp[0]; marks=decomp[1:]
    out=SHAPE.get(base,base)
    tone=""
    for mark in marks:
        if mark in TONE: tone=TONE[mark].upper() if base.isupper() else TONE[mark]
    return out+tone
def telex_word(word):
    return "".join(telex_char(ch) for ch in unicodedata.normalize("NFC",word))
rows={}
for raw in source.read_text(encoding="utf-8").splitlines():
    raw=raw.strip()
    if not raw or raw.startswith("#"): continue
    fields=raw.rsplit(maxsplit=1); word=fields[0] if len(fields)==2 else raw
    word=unicodedata.normalize("NFC",word.strip())
    if not word or any(ch.isspace() for ch in word) or not any(ch.isalpha() for ch in word): continue
    reading=telex_word(word)
    if reading==word: continue
    rows.setdefault(reading,[])
    if word.lower() not in [x.lower() for x in rows[reading]]: rows[reading].append(word)
    rows[reading]=rows[reading][:16]
if not rows: raise SystemExit("No Telex rows generated.")
dest=pathlib.Path("Lexicons")/f"{code}.cime"; dest.parent.mkdir(exist_ok=True)
with dest.open("w",encoding="utf-8",newline="\n") as f:
    for reading in sorted(rows,key=str.casefold): f.write("\t".join([reading,*rows[reading]])+"\n")
print(f"Built {dest} with {len(rows):,} readings.")
