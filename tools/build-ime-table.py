#!/usr/bin/env python3
"""Generic CIME builder retained for pack maintenance.

Input is TAB-separated: reading, candidate1, candidate2, ...
"""
import pathlib,sys,unicodedata
if len(sys.argv)!=3: raise SystemExit("Usage: build-ime-table.py <code> <readings.tsv>")
code,source=sys.argv[1],pathlib.Path(sys.argv[2])
rows={}
for number,raw in enumerate(source.read_text(encoding="utf-8").splitlines(),1):
    if not raw.strip() or raw.lstrip().startswith("#"): continue
    fields=[unicodedata.normalize("NFC",x.strip()) for x in raw.split("\t")]
    reading,candidates=fields[0].lower(),[x for x in fields[1:] if x]
    if not reading or not candidates: raise SystemExit(f"Line {number}: missing reading/candidate")
    rows[reading]=list(dict.fromkeys(candidates))[:16]
dest=pathlib.Path("Lexicons")/f"{code}.cime"; dest.parent.mkdir(exist_ok=True)
with dest.open("w",encoding="utf-8",newline="\n") as f:
    for reading in sorted(rows): f.write("\t".join([reading,*rows[reading]])+"\n")
print(f"Built {dest} with {len(rows):,} readings.")
