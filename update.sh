#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/fetch-vietnamese-sources.py
python3 - <<'PY'
import bz2,pathlib
p=pathlib.Path("source/vie_sentences.tsv.bz2")
pathlib.Path("source/vie_sentences.tsv").write_bytes(bz2.open(p,"rb").read())
PY
python3 tools/build-pack.py vi source/vi_50k.txt
python3 tools/build-next-word.py vi source/vi_50k.txt source/vie_sentences.tsv
python3 tools/build-telex-cime.py vi source/vi_50k.txt
python3 tools/validate-pack.py vi
python3 -m unittest discover -s tools -p 'test_*.py' -v
git add -A
if ! git diff --cached --quiet; then git commit -m "Build Vietnamese language pack"; fi
tag="vvi-$(date -u +%Y.%m.%d.%H%M%S)"
git tag "$tag"
git push origin HEAD:refs/heads/main "refs/tags/$tag"
echo "Published $tag"
