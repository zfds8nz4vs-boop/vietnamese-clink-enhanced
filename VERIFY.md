# Verify the Vietnamese pack

Run the complete build and validation pipeline on Windows PowerShell, Git Bash,
or another shell with Python 3:

python3 tools/fetch-vietnamese-sources.py
python3 tools/build-pack.py vi source/vi_50k.txt
python3 tools/build-next-word.py vi source/vi_50k.txt source/vie_sentences.tsv
python3 tools/build-telex-cime.py vi source/vi_50k.txt
python3 tools/validate-pack.py vi
python3 tools/validate-catalog.py
python3 -m unittest discover -s tools -p 'test_*.py' -v

The release is considered package-complete when vi.clex, vi.cngm, vi.cime and
vi.emoji.json are present and the release manifest contains checksums for all
generated vi.* assets.

Real-client activation is a separate test and is not inferred from CI success.
