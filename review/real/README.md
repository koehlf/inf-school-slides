# Real slides in the shortlisted designs (M0-3)

Three real lessons, ported 1:1 from the Impress decks in `references/`, in the six shortlisted designs D01, D02, D06, B1, B2 and B5,
each as `-dark.pdf` (presenting) and `-light.pdf`.

| Deck | Source | Frames | Content |
|---|---|---|---|
| `sorting-*` | `sorting_2025.odp` (111 slides) | 36 | questions, definitions, card sequences, long nested lists, formulas, a photo, merge figures, a chart |
| `euler-*` | `euler_mst.odp` (36 slides) | 24 | text-only slides, weighted graphs (12 vertices), the Königsberg map, text + graph with overlays |
| `krypto-*` | `krypto_intro.odp` (25 slides) | 22 | **Kryptologie colour (SeaGreen)**: definitions, two flow diagrams, a punch card grid, a table, three pictures |

| Design | Sorting | Euler / MST | Kryptologie |
|---|---|---|---|
| D01 Buch | [dark](sorting-D01-dark.pdf) · [light](sorting-D01-light.pdf) | [dark](euler-D01-dark.pdf) · [light](euler-D01-light.pdf) | [dark](krypto-D01-dark.pdf) · [light](krypto-D01-light.pdf) |
| D02 Band 2.0 | [dark](sorting-D02-dark.pdf) · [light](sorting-D02-light.pdf) | [dark](euler-D02-dark.pdf) · [light](euler-D02-light.pdf) | [dark](krypto-D02-dark.pdf) · [light](krypto-D02-light.pdf) |
| D06 Klartext | [dark](sorting-D06-dark.pdf) · [light](sorting-D06-light.pdf) | [dark](euler-D06-dark.pdf) · [light](euler-D06-light.pdf) | [dark](krypto-D06-dark.pdf) · [light](krypto-D06-light.pdf) |
| B1 Band | [dark](sorting-B1-dark.pdf) · [light](sorting-B1-light.pdf) | [dark](euler-B1-dark.pdf) · [light](euler-B1-light.pdf) | [dark](krypto-B1-dark.pdf) · [light](krypto-B1-light.pdf) |
| B2 Leiste | [dark](sorting-B2-dark.pdf) · [light](sorting-B2-light.pdf) | [dark](euler-B2-dark.pdf) · [light](euler-B2-light.pdf) | [dark](krypto-B2-dark.pdf) · [light](krypto-B2-light.pdf) |
| B5 Bühne | [dark](sorting-B5-dark.pdf) · [light](sorting-B5-light.pdf) | [dark](euler-B5-dark.pdf) · [light](euler-B5-light.pdf) | [dark](krypto-B5-dark.pdf) · [light](krypto-B5-light.pdf) |

[`overview.png`](overview.png) and [`overview-krypto.png`](overview-krypto.png): one row per design (D01, D02, D06, B1, B2, B5): title, section, card step, text slide (sorting, dark), Königsberg map, Fleury step (Euler, light); for Kryptologie: title, three text slides, punch card (dark), text and the key diagram (light).

## Type size trial (2026-10-18)

All six designs are built at **14 pt** base. Slides can step up or down per frame
(`theme/real/realtext.sty`), as fixed steps, never as automatic fitting:

| Step | Body text | Share of page width | ≈ size in a 28 cm Impress page | Used on |
|---|---|---|---|---|
| `text=large` | 17.3 pt | 38 ‰ | 30 pt | slides with little text (most text slides of the originals: 37–40 ‰) |
| default | 14.4 pt | 32 ‰ | 25 pt | text with figures, longer lists |
| `text=small` | 12 pt | 26.5 ‰ | 21 pt | the two long step lists («Selectionsort», «Finden einer Eulertour»; originals: 28.6 ‰) |

[`sizes.png`](sizes.png): the original slide, then D01, D06, B1, B5 (large, default, default, small). The two `overview` images still show the earlier 12 pt builds.

At these sizes D01, D02, D06 and B1 fit every slide. **B2 and B5 overflow on several slides** (figures, Bäume, Pfade, Merge):
B2 loses width to its strip, B5 reserves 15 mm for the title and 11 mm for the progress line, and set B spaces lists more widely.

Porting notes:

- The text is the original's, with Swiss conventions («…», ss) and a few typos fixed. Step sequences (one Impress slide per step) are one frame with overlays.
- The original title-only slides «Selectionsort», «Bubblesort», «Mergesort» became section slides. The Euler deck has no section slides, as in the original.
- Card values are mapped to the cards in `images/playing_cards/` (5→2, 6→5, 7→6, 8→7), because there is no 8 of hearts there.
- Mode bands added where the original asks for work: «Let's go!», «Hands on!», «Ihr seid dran», «Teeren» (Mach mit), and «Finden einer Eulertour» (Zum Lesen).
- Assumed: the Euler deck is Algorithmik chapter 4. The inbox photo comes from `sorting_2025.odp`.
- The «Merge: Analogie» slides and the second shortest-path variant are left out.

Sources: `theme/real/` (`real-sorting.tex`, `real-euler.tex`, drivers `real-d.tex` and `real-b.tex`).
Rebuild with `theme/real/build_real.sh [D01 B5 …]`.
