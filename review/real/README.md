# Real slides in the shortlisted designs (M0-3)

Two real lessons, ported 1:1 from the Impress decks in `references/`, in the six shortlisted designs D01, D02, D06, B1, B2 and B5,
each as `-dark.pdf` (presenting) and `-light.pdf`.

| Deck | Source | Frames | Content |
|---|---|---|---|
| `sorting-*` | `sorting_2025.odp` (111 slides) | 36 | questions, definitions, card sequences, long nested lists, formulas, a photo, merge figures, a chart |
| `euler-*` | `euler_mst.odp` (36 slides) | 24 | text-only slides, weighted graphs (12 vertices), the Königsberg map, text + graph with overlays |

| Design | Sorting | Euler / MST |
|---|---|---|
| D01 Buch | [dark](sorting-D01-dark.pdf) · [light](sorting-D01-light.pdf) | [dark](euler-D01-dark.pdf) · [light](euler-D01-light.pdf) |
| D02 Band 2.0 | [dark](sorting-D02-dark.pdf) · [light](sorting-D02-light.pdf) | [dark](euler-D02-dark.pdf) · [light](euler-D02-light.pdf) |
| D06 Klartext | [dark](sorting-D06-dark.pdf) · [light](sorting-D06-light.pdf) | [dark](euler-D06-dark.pdf) · [light](euler-D06-light.pdf) |
| B1 Band | [dark](sorting-B1-dark.pdf) · [light](sorting-B1-light.pdf) | [dark](euler-B1-dark.pdf) · [light](euler-B1-light.pdf) |
| B2 Leiste | [dark](sorting-B2-dark.pdf) · [light](sorting-B2-light.pdf) | [dark](euler-B2-dark.pdf) · [light](euler-B2-light.pdf) |
| B5 Bühne | [dark](sorting-B5-dark.pdf) · [light](sorting-B5-light.pdf) | [dark](euler-B5-dark.pdf) · [light](euler-B5-light.pdf) |

Porting notes:

- The text is the original's, with Swiss conventions («…», ss) and a few typos fixed. Step sequences (one Impress slide per step) are one frame with overlays.
- The original title-only slides «Selectionsort», «Bubblesort», «Mergesort» became section slides. The Euler deck has no section slides, as in the original.
- Card values are mapped to the cards in `images/playing_cards/` (5→2, 6→5, 7→6, 8→7), because there is no 8 of hearts there.
- Mode bands added where the original asks for work: «Let's go!», «Hands on!», «Ihr seid dran», «Teeren» (Mach mit), and «Finden einer Eulertour» (Zum Lesen).
- Assumed: the Euler deck is Algorithmik chapter 4. The inbox photo comes from `sorting_2025.odp`.
- The «Merge: Analogie» slides and the second shortest-path variant are left out.

Sources: `theme/real/` (`real-sorting.tex`, `real-euler.tex`, drivers `real-d.tex` and `real-b.tex`).
Rebuild with `theme/real/build_real.sh [D01 B5 …]`.
