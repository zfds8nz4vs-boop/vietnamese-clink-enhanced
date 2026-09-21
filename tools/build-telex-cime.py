#!/usr/bin/env python3
"""Build a Vietnamese Telex .cime table from a UTF-8 Vietnamese word list."""
import pathlib,sys,unicodedata
if len(sys.argv)!=3: raise SystemExit("Usage: build-telex-cime.py <code> <word-list.txt>")
code,source=sys.argv[1],pathlib.Path(sys.argv[2])
if code!="vi": raise SystemExit("This builder targets Vietnamese.")
ACCENT={"á":"as","à":"af","ả":"ar","ã":"ax","ạ":"aj","é":"es","è":"ef","ẻ":"er","ẽ":"ex","ẹ":"ej","í":"is","ì":"if","ỉ":"ir","ĩ":"ix","ị":"ij","ó":"os","ò":"of","ỏ":"or","õ":"ox","ọ":"oj","ú":"us","ù":"uf","ủ":"ur","ũ":"ux","ụ":"uj","ý":"ys","ỳ":"yf","ỷ":"yr","ỹ":"yx","ỵ":"yj","Á":"AS","À":"AF","Ả":"AR","Ã":"AX","Ạ":"AJ","É":"ES","È":"EF","Ẻ":"ER","Ẽ":"EX","Ẹ":"EJ","Í":"IS","Ì":"IF","Ỉ":"IR","Ĩ":"IX","Ị":"IJ","Ó":"OS","Ò":"OF","Ỏ":"OR","Õ":"OX","Ọ":"OJ","Ú":"US","Ù":"UF","Ủ":"UR","Ũ":"UX","Ụ":"UJ","Ý":"YS","Ỳ":"YF","Ỷ":"YR","Ỹ":"YX","Ỵ":"YJ"}
BASE={"â":"aa","ă":"aw","ê":"ee","ô":"oo","ơ":"ow","ư":"uw","đ":"dd","Â":"AA","Ă":"AW","Ê":"EE","Ô":"OO","Ơ":"OW","Ư":"UW","Đ":"DD"}
PLAIN={k:v[0] for k,v in ACCENT.items()}
def telex_word(word):
    out=[]
    for ch in unicodedata.normalize("NFC",word):
        if ch in ACCENT: out.append(PLAIN[ch]+ACCENT[ch][-1])
        elif ch in BASE: out.append(BASE[ch])
        else: out.append(ch)
    return "".join(out)
rows={}
for raw in source.read_text(encoding="utf-8").splitlines():
    raw=raw.strip()
    if not raw or raw.startswith("#"): continue
    fields=raw.rsplit(maxsplit=1); word=fields[0] if len(fields)==2 else raw
    word=unicodedata.normalize("NFC",word.strip().lower())
    if not word or any(ch.isspace() for ch in word) or not any(ch.isalpha() for ch in word): continue
    reading=telex_word(word)
    if reading==word: continue
    rows.setdefault(reading,[])
    if word not in rows[reading]: rows[reading].append(word)
    rows[reading]=rows[reading][:16]
if not rows: raise SystemExit("No Telex rows generated.")
dest=pathlib.Path("Lexicons")/f"{code}.cime"; dest.parent.mkdir(exist_ok=True)
with dest.open("w",encoding="utf-8",newline="\n") as f:
    for reading in sorted(rows): f.write("\t".join([reading,*rows[reading]])+"\n")
print(f"Built {dest} with {len(rows):,} readings.")
