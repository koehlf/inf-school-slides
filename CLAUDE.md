# inf.school slides

LaTeX Beamer slides for the inf.school computer science lessons, one deck
per topic, in the theme `infschoolslides` (derived from the scripts' layout,
own copy). Requirements and design: `docs/requirements.md`, `docs/design.md`.

Status: **M0 (theme)**. This file is a stub; it is completed in M0-11.

## Language

- Talk to me in English. Slide content is German.
- Swiss Standard German: always `ss`, never `ß`. Swiss quote marks «…», inside ‹…›.
- Commit messages in English: a short title prefixed with the area
  (`Theme: …`, `Docs: …`, `Algorithmik: …`), then a body explaining what and why.

## Rules for every change

- Design values (colours, line widths, radii, sizes) live only in `theme/`,
  never inline in a deck.
- Don't change the look of the theme before the visual design agreement
  (M0-3 in `docs/design.md` §11) is signed off.
- `~/Teaching/books` is read-only from here.

## Build

Until `tools/build/build.py` exists (M0-8): `theme/test/build_catalogue.sh`
builds the catalogue light and dark. In VS Code, LaTeX Workshop has two
recipes, «deck (dark)» (default, on save) and «deck (light)».
