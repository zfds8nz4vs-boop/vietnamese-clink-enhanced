#!/usr/bin/env python3
"""Build a Vietnamese Telex .cime table from a UTF-8 Vietnamese word list."""
import pathlib,sys,unicodedata
if len(sys.argv)!=3: raise SystemExit("Usage: build-telex-cime.py <code> <word-list.txt>")
code,source=sys.argv[1],pathlib.Path(sys.argv[2])
if code!="vi": raise SystemExit("This builder targets Vietnamese.")
TONE={"\u0301":"s","\u0300":"f","\u0309":"r","\u0303":"x","\u0323":"j"}
def telex_char(ch):
    if ch in ("đ","Đ"): return ("dd" if ch=="đ" else "DD"),None
    d=unicodedata.normalize("NFD",ch)
    base=d[0]; marks=set(d[1:])
    upper=base.isupper(); b=base.lower()
    if "\u0302" in marks:
        shape={"a":"aa","e":"ee","o":"oo"}.get(b,base)
        if upper: shape=shape.upper()
    elif "\u0306" in marks:
        shape="aw" if b=="a" else "AW" if upper else "aw"
        if upper: shape="AW"
    elif "\u031b" in marks:
        shape="ow" if b=="o" else "uw"
        if upper: shape=shape.upper()
    else:
        shape=base
    tone=next((TONE[m] for m in ("\u0301","\u0300","\u0309","\u0303","\u0323") if m in marks),None)
    return shape,tone
def telex_syllable(text):
    out=[]; tone=None
    for ch in text:
        shape,ch_tone=telex_char(ch)
        out.append(shape)
        if ch_tone: tone=ch_tone
    return "".join(out)+(tone or "")
def telex_word(word):
    out=[]; buf=[]
    for ch in unicodedata.normalize("NFC",word):
        if ch.isalpha(): buf.append(ch)
        else:
            if buf: out.append(telex_syllable("".join(buf))); buf=[]
            out.append(ch)
    if buf: out.append(telex_syllable("".join(buf)))
    return "".join(out)
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
