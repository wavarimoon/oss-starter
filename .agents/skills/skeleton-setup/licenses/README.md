# License Index

This folder holds the canonical text of the 8 most-used OSS licenses, sourced from the [SPDX License List](https://spdx.org/licenses/) (the standard machine-readable catalog used by `npm`, `cargo`, GitHub, and most package managers).

> **These files exist for the `skeleton-setup` skill to choose a license at project-creation time.** They are consumed (deleted) by the skill when it runs. If you are reading this in a *generated project*, it means `skeleton-setup` did not finish — re-run it from the original skeleton repo.


## When to pick which

| SPDX id | File | When to use it |
|---|---|---|
| `mit` | `MIT.txt` | Permissive. Maximum compatibility. Most-used OSS license. Safe default for libraries. |
| `apache-2.0` | `Apache-2.0.txt` | Permissive with explicit patent grant. Preferred for enterprise / corporate contexts. The skeleton's documented default. |
| `bsd-3-clause` | `BSD-3-Clause.txt` | Permissive, similar to MIT but with a "no endorsement" clause. Common in C/C++ ecosystems. |
| `mpl-2.0` | `MPL-2.0.txt` | File-level copyleft. Modifications to MPL-licensed files must be shared; new files can be proprietary. Middle ground. |
| `gpl-3.0` | `GPL-3.0-only.txt` | Strong copyleft. Any derivative work must also be GPL. Use for compilers, system tools, or when you want to ensure the codebase stays free. |
| `agpl-3.0` | `AGPL-3.0-only.txt` | Network copyleft. Closes the "use it as a service without distributing" loophole. Use for network services where GPL isn't strong enough. |
| `lgpl-3.0` | `LGPL-3.0-only.txt` | Weak copyleft. Designed for libraries that may be linked from proprietary code. |
| `unlicense` | `Unlicense.txt` | Public domain dedication. Use if you genuinely want to disclaim copyright to the extent possible. |

## How a consumer chooses

Drop a file named `LICENSE` into the `content/` folder (see `../INPUT_GUIDE.md`) containing exactly one of the SPDX ids above (lowercase, e.g. `mit` or `apache-2.0`). When `skeleton-setup.sh` runs, it maps the id to the canonical file in this folder and writes it to the project's root `LICENSE`.

The skeleton itself is licensed under Apache-2.0 — see `../LICENSE`.

## Verbatim source

All 8 license texts are verbatim copies from the SPDX canonical source:
`https://github.com/spdx/license-list-data/tree/main/text/<SPDX-ID>.txt`

For a human-readable summary of any SPDX license, see https://choosealicense.com/ or https://opensource.org/licenses/.
