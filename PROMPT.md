# Vietnamese Clink language pack

Build only reproducible, licensed resources. The package is data-driven:
Python builds CLEX/CNGM/CIME; PowerShell and shell scripts automate maintenance.

Telex source rules:
aa -> â, aw -> ă, ee -> ê, oo -> ô, ow -> ơ, uw -> ư, dd -> đ.
s/f/r/x/j are the tone keys and z removes a tone. Uppercase forms are supported.

The old Lua runtime adapter is intentionally not part of the package. Do not
reintroduce it unless the runtime format itself is shown to require a script.

Before release run:
python3 tools/fetch-vietnamese-sources.py
python3 tools/build-pack.py vi source/vi_50k.txt
python3 tools/build-next-word.py vi source/vi_50k.txt source/vie_sentences.tsv
python3 tools/build-telex-cime.py vi source/vi_50k.txt
python3 tools/validate-pack.py vi
python3 tools/validate-catalog.py
python3 -m unittest discover -s tools -p 'test_*.py' -v
