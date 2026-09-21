#!/usr/bin/env python3
import json,pathlib
data=json.loads(pathlib.Path("catalog/language-wave.json").read_text(encoding="utf-8"))
packs={x["code"]:x for x in data.get("packs",[])}
if "vi" not in packs: raise SystemExit("catalog must contain vi")
if not packs["vi"].get("sources"): raise SystemExit("vi needs provenance sources")
print("catalog: valid")
