[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot
python tools/fetch-vietnamese-sources.py
python -c "import bz2,pathlib; p=pathlib.Path('source/vie_sentences.tsv.bz2'); pathlib.Path('source/vie_sentences.tsv').write_bytes(bz2.open(p,'rb').read())"
python tools/build-pack.py vi source/vi_50k.txt
python tools/build-next-word.py vi source/vi_50k.txt source/vie_sentences.tsv
python tools/build-telex-cime.py vi source/vi_50k.txt
python tools/validate-pack.py vi
python -m unittest discover -s tools -p "test_*.py" -v
git add -A
git diff --cached --quiet
if ($LASTEXITCODE -eq 1) { git commit -m "Build Vietnamese language pack" }
$tag="vvi-"+[DateTime]::UtcNow.ToString("yyyy.MM.dd.HHmmss")
git tag $tag
git push origin "HEAD:refs/heads/main" "refs/tags/$tag"
Write-Host "Published $tag"
