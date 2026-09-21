#!/usr/bin/env python3
"""Build Vietnamese Telex .cime data.

The CIME format is a reading -> candidate table, so the builder must encode
both ordinary Vietnamese words and the literal-key escape forms that a
stateful IME would normally handle itself.
"""
import pathlib,sys,unicodedata

if len(sys.argv)!=3: raise SystemExit("Usage: build-telex-cime.py <code> <word-list.txt>")
code,source=sys.argv[1],pathlib.Path(sys.argv[2])
if code!="vi": raise SystemExit("This builder targets Vietnamese.")

TONE={"\u0301":"s","\u0300":"f","\u0309":"r","\u0303":"x","\u0323":"j"}
VOWELS=set("aeiouy")
SHAPE={"a":"aa","e":"ee","o":"oo","ă":"aw","ơ":"ow","ư":"uw",
       "A":"AA","E":"EE","O":"OO","Ă":"AW","Ơ":"OW","Ư":"UW"}

def telex_char(ch):
    if ch=="đ": return "dd",None
    if ch=="Đ": return "DD",None
    d=unicodedata.normalize("NFD",ch)
    base=d[0]
    marks=set(d[1:])
    lower=base.lower()
    if "\u0302" in marks: shape=SHAPE.get(lower,base.lower()); shape=shape.upper() if base.isupper() else shape
    elif "\u0306" in marks: shape="AW" if base.isupper() else "aw"
    elif "\u031b" in marks: shape=("OW" if lower=="o" else "UW") if base.isupper() else ("ow" if lower=="o" else "uw")
    else: shape=base
    tone=next((TONE[m] for m in ("\u0301","\u0300","\u0309","\u0303","\u0323") if m in marks),None)
    return shape,tone

def _map_syllable(text, tone_before_coda=False):
    parts=[]; tone=None
    for ch in text:
        shape,ch_tone=telex_char(ch)
        base=unicodedata.normalize("NFD",ch)[0].lower()
        parts.append((shape,base in VOWELS))
        if ch_tone: tone=ch_tone
    raw="".join(shape for shape,_ in parts)
    if raw=="uwow": raw="uow"
    elif raw=="UWOW": raw="UOW"
    if not tone: return raw
    if not tone_before_coda: return raw+tone
    last=max((i for i,(_,v) in enumerate(parts) if v),default=-1)
    if last<0: return raw+tone
    return "".join(shape for shape,_ in parts[:last+1])+tone+"".join(shape for shape,_ in parts[last+1:])

def telex_word(word):
    out=[];buf=[]
    for ch in unicodedata.normalize("NFC",word):
        if ch.isalpha(): buf.append(ch)
        else:
            if buf: out.append(_map_syllable("".join(buf)));buf=[]
            out.append(ch)
    if buf: out.append(_map_syllable("".join(buf)))
    return "".join(out)

def telex_aliases(word):
    canonical=telex_word(word)
    alternate=[]
    out=[];buf=[]
    for ch in unicodedata.normalize("NFC",word):
        if ch.isalpha(): buf.append(ch)
        else:
            if buf: out.append(_map_syllable("".join(buf),True));buf=[]
            out.append(ch)
    if buf: out.append(_map_syllable("".join(buf),True))
    alt="".join(out)
    if alt!=canonical: alternate.append(alt)
    return [canonical,*alternate]

def add(rows,reading,candidate):
    if not reading or not candidate or reading==candidate: return
    rows.setdefault(reading,[])
    if candidate not in rows[reading]: rows[reading].append(candidate)
    rows[reading]=rows[reading][:16]

rows={}
for raw in source.read_text(encoding="utf-8").splitlines():
    raw=raw.strip()
    if not raw or raw.startswith("#"): continue
    fields=raw.rsplit(maxsplit=1)
    word=unicodedata.normalize("NFC",fields[0] if len(fields)==2 else raw)
    if not word or any(ch.isspace() for ch in word) or not any(ch.isalpha() for ch in word): continue
    for reading in telex_aliases(word): add(rows,reading,word)

# Telex literal-key escapes. CIME has no key-repeat timing information, so
# these explicit forms prevent the common "w disappears" and "aaaa..." cases.
# aa/ee/oo/dd remain their normal Vietnamese transformations.
for vowel,typed,special in (("a","aa","â"),("e","ee","ê"),("o","oo","ô")):
    for n in range(3,33):
        add(rows,vowel*n,vowel*n)
# Repeating w after a transformed vowel means "keep the second w literally":
# uww -> ưw, oww -> ơw, aww -> ăw.
for base,special in (("u","ư"),("o","ơ"),("a","ă")):
    for extra in range(1,17):
        add(rows,base+"w"* (extra+1),special+"w"*extra)

# Also preserve repeated tone-key letters as literal characters when they are
# not part of a known Vietnamese reading.
for key in "sfrxjz":
    for n in range(2,17):
        add(rows,key*n,key*n)

dest=pathlib.Path("Lexicons")/f"{code}.cime"
dest.parent.mkdir(exist_ok=True)
with dest.open("w",encoding="utf-8",newline="\n") as f:
    for reading in sorted(rows,key=str.casefold):
        f.write("\t".join([reading,*rows[reading]])+"\n")
print(f"Built {dest} with {len(rows):,} readings.")
