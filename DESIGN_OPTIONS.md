# Design options for comparison (M0-3)

Branch `design-options` only. The same sample deck (title, pitch page, section, bullets, definition box,
card row, code, «Mach mit» task, merge with arrays, a 3-step Kruskal sequence, «Zum Lesen» page)
in 15 designs, all in the Algorithmik colour, each as `-dark.pdf` (presenting) and `-light.pdf`.
Page 2 of every PDF is the design's pitch: idea, properties, strengths, weaknesses, «Nimm dieses Design, wenn …».

## Set D: `review/designs/` (sources `theme/designs/`)

| Design | Idea |
|---|---|
| [D01 Buch](review/designs/D01-dark.pdf) ([light](review/designs/D01-light.pdf)) | the spike: books header band with hanging chapter hexagon, footer band, photo cover |
| [D02 Band 2.0](review/designs/D02-dark.pdf) ([light](review/designs/D02-light.pdf)) | one slim header band with page number, no footer |
| [D03 Seitenleiste](review/designs/D03-dark.pdf) ([light](review/designs/D03-light.pdf)) | dark strip on the left with chapter hexagon and honeycomb |
| [D04 Wabe](review/designs/D04-dark.pdf) ([light](review/designs/D04-light.pdf)) | the old Impress master in the books' colours: three hexagons, network line |
| [D05 Karte](review/designs/D05-dark.pdf) ([light](review/designs/D05-light.pdf)) | content on a rounded card on a tinted page |
| [D06 Klartext](review/designs/D06-dark.pdf) ([light](review/designs/D06-light.pdf)) | 14 pt, a colour bar, almost no chrome |
| [D07 Kapitel](review/designs/D07-dark.pdf) ([light](review/designs/D07-light.pdf)) | no band: large chapter hexagon, title on a rule ending in the page number |
| [D08 Spalte](review/designs/D08-dark.pdf) ([light](review/designs/D08-light.pdf)) | title column on the left, content on the right |
| [D09 Fussband](review/designs/D09-dark.pdf) ([light](review/designs/D09-light.pdf)) | title alone at the top, orientation in a footer band |
| [D10 Wegweiser](review/designs/D10-dark.pdf) ([light](review/designs/D10-light.pdf)) | a route of section hexagons at the top |

D02–D06 are the review versions V1–V5, rebuilt on the books base.

Colour scheme variants (same slides):
[D03 in Networks orange](review/designs/D03-networks-dark.pdf) ([light](review/designs/D03-networks-light.pdf)),
[D07 with graphite chrome](review/designs/D07-graphite-dark.pdf) ([light](review/designs/D07-graphite-light.pdf)).

## Set B: `review/designs-b/` (sources `theme/designs-b/`)

Made independently by a second designer (a subagent) who saw only the content of the sample slides and the books' layout files, not set D.

| Design | Idea |
|---|---|
| [B1 Band](review/designs-b/B1-dark.pdf) ([light](review/designs-b/B1-light.pdf)) | the scripts' page: header band, hanging chapter hexagon, footer band |
| [B2 Leiste](review/designs-b/B2-dark.pdf) ([light](review/designs-b/B2-light.pdf)) | dark strip on the left with section hexagon, binary and page number |
| [B3 Wabe](review/designs-b/B3-dark.pdf) ([light](review/designs-b/B3-light.pdf)) | no bands: number hexagon before the title, page number in a piece of honeycomb |
| [B4 Register](review/designs-b/B4-dark.pdf) ([light](review/designs-b/B4-light.pdf)) | a sheet on a desk, the title as a register tab |
| [B5 Bühne](review/designs-b/B5-dark.pdf) ([light](review/designs-b/B5-light.pdf)) | most room for content: corner hexagon with the section, progress line at the bottom |

Note: set B uses fixed RGB colours (base `#DC3D9A`) and a darker `\term` in light mode (`#A0457A`, 5.8 : 1);
set D uses the scripts' xcolor definitions, so the hue can differ slightly between the sets.

## Rebuild

```sh
theme/designs/build_designs.sh     # set D + variants -> review/designs/
theme/designs-b/build.sh           # set B -> review/designs-b/
```
