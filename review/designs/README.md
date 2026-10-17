# Design options (M0-3)

The same sample deck in ten designs, Algorithmik colour, each in `-dark` (presenting) and `-light` (handout, bright projectors).
Page 2 of every PDF is the design's pitch: idea, properties, strengths, weaknesses, «pick this if …».

| PDF | Design | Idea |
|---|---|---|
| `D01-*` | Buch | the spike: books header band with hanging chapter hexagon, footer band, photo cover |
| `D02-*` | Band 2.0 | one slim header band with page number, no footer (review V1) |
| `D03-*` | Seitenleiste | dark strip on the left with chapter hexagon and honeycomb (review V2) |
| `D04-*` | Wabe | the old Impress master in the books' colours: three hexagons, network line (review V3) |
| `D05-*` | Karte | content on a rounded card on a tinted page (review V4) |
| `D06-*` | Klartext | 14 pt, a colour bar, almost no chrome (review V5) |
| `D07-*` | Kapitel | no band: large chapter hexagon, section as overline, title on a rule ending in the page number |
| `D08-*` | Spalte | title column on the left, content on the right |
| `D09-*` | Fussband | title alone at the top, all orientation in a footer band |
| `D10-*` | Wegweiser | a route of section hexagons at the top shows where the lesson stands |

Colour scheme variants (same slides):

| PDF | Variant |
|---|---|
| `D03-networks-*` | D03 in the Networks colour (burnt orange, with the script's own light/dark shades) |
| `D07-graphite-*` | D07 with neutral graphite chrome; the subject colour only for accents (`\term`, states) |

Sources: `theme/designs/` (`designs.tex`, `design-dNN.sty`); rebuild with `theme/designs/build_designs.sh`.
Designs B1–B5 in `review/designs-b/` were made independently by a second designer who did not see these.
