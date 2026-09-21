#!/usr/bin/env python3
import hashlib,json,pathlib,shutil,sys
if len(sys.argv)!=4: raise SystemExit("usage: build-release-manifest.py VERSION OWNER/REPO OUT")
version,repository,out=sys.argv[1:]
root=pathlib.Path(__file__).resolve().parents[1]; lexicons=root/"Lexicons"; output=pathlib.Path(out); assets=output/"assets"; assets.mkdir(parents=True,exist_ok=True)
entries=[]
for path in sorted(lexicons.glob("vi.*")):
    if not path.is_file(): continue
    name="vi--"+path.name; target=assets/name; shutil.copy2(path,target); data=target.read_bytes()
    entries.append({"path":path.name,"url":f"https://github.com/{repository}/releases/download/{version}/{name}","sha256":hashlib.sha256(data).hexdigest(),"byteCount":len(data)})
if not any(x["path"]=="vi.clex" for x in entries): raise SystemExit("vi.clex is required")
manifest={"version":version,"packs":[{"code":"vi","version":version,"assets":entries,"inputMethod":{"name":"Vietnamese Telex","rules":"aa/aw/ee/oo/ow/uw/dd; tones s/f/r/x/j; z removes tone."}}]}
(output/"manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,separators=(",",":")),encoding="utf-8")
print(f"Wrote {output/'manifest.json'} with {len(entries)} assets.")
