#!/usr/bin/env python3
"""Fetch pinned Vietnamese unigram and Tatoeba sentence inputs.

The source URLs are pinned to a FrequencyWords commit and the current Tatoeba
weekly export path. The downloaded files are build inputs, not application code.
"""
from pathlib import Path
from urllib.request import urlopen

FREQUENCY_COMMIT = "525f9b560de45753a5ea010694e72e9aa541c6"
FREQUENCY_URL = (
    "https://raw.githubusercontent.com/hermitdave/FrequencyWords/"
    f"{FREQUENCY_COMMIT}/content/2018/vi/vi_50k.txt"
)
TATOEBA_URL = "https://downloads.tatoeba.org/exports/per_language/vie/vie_sentences.tsv.bz2"

root = Path(__file__).resolve().parents[1]
source = root / "source"
source.mkdir(exist_ok=True)

with urlopen(FREQUENCY_URL, timeout=60) as response:
    data = response.read()
(source / "vi_50k.txt").write_bytes(data)

with urlopen(TATOEBA_URL, timeout=60) as response:
    data = response.read()
(source / "vie_sentences.tsv.bz2").write_bytes(data)

print("Downloaded pinned FrequencyWords Vietnamese unigrams.")
print("Downloaded Tatoeba Vietnamese sentence export.")
