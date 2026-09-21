# Clink Vietnamese · Telex

This release mirrors the complete resource-oriented structure of the community
Chinese language-pack repository, but uses Vietnamese resources and the
Vietnamese Telex rules developed in this project.

Included:
- vi.clex — Vietnamese vocabulary dictionary.
- vi.cngm — Vietnamese next-word model from Tatoeba sentence data.
- vi.cime — generated Vietnamese Telex reading-to-candidate data.
- vi.emoji.json — Vietnamese emoji metadata.
- manifest.json — release manifest with SHA-256 hashes.

The Lua adapter is removed. Python is the source/build implementation and
PowerShell/shell provide reproducible maintenance and publishing helpers.
Those scripts do not execute in the interactive Clink input path.

This is a community implementation. CNGM/CIME compatibility is based on the
documented pack formats used by the reference repository; successful CI does
not by itself prove activation in every client.


CI packaging retry: Telex Unicode decomposition and tone placement are validated by regression tests before release publication.
