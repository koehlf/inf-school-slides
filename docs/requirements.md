# Slide Transformation – Requirements

| | |
|---|---|
| **Status** | **v1.2 — signed off; layout derived from the books** (§5.7), slide modes added (F-09b); next step: technical design (§14) |
| **Last updated** | 2026-10-17 |
| **Sources** | `idea.txt`, analysis of `references/` (`euler_mst`, `sorting_2025`, `.odp` + `.pdf`), script layout in `~/Teaching/books/common/layout/` and the Algorithmik script (read-only), customer interview (rounds 1–4), layout spikes (§5.6) |

> **How to read this document**
> Each requirement has an ID (e.g. `F-03`), a priority and a source tag:
> - **[idea]**: stated in `idea.txt`
> - **[ref]**: implied by the reference slides
> - **[script]**: implied by the script layout
> - **[customer]**: confirmed or decided in the interview
> - **[assumed]**: my guess as project manager; **please confirm or correct it**
>
> Priority: **MUST** (first usable version), **SHOULD** (first version if cheap, else later), **COULD** (later), **WON'T** (explicitly out of scope).

---

## 1. Background & Problem

The teacher (sole author, CS teacher at a Swiss Gymnasium) makes lecture slides in LibreOffice Impress with a self-made master slide and publishes them as PDF. The teaching scripts (Skripte) are written in LaTeX, live in a git repository (`inf_school_books`) and recently got a reworked shared layout (`common/layout/`).

What works today: editing in Impress is reasonably fast, and drawings are made WYSIWYG without code [idea].

What doesn't:
- **Versioning.** Decks live on a cloud drive; reworking a deck for a new semester creates copies with suffixes (`_25`, `_26`) [idea]. The references show the symptom: `euler_mst.pdf` (2022, 36 pages) no longer matches `euler_mst.odp` (2024, 35 slides) [ref].
- **Design.** The slides and the scripts have related but diverging designs. LaTeX would offer more design options and let slides and scripts visibly belong together [idea].

**Problem statement:** Slides should be versioned like the scripts and look like part of the same series, without making everyday editing (especially of drawings) much slower than in Impress.

## 2. Goals & Success Criteria

| ID | Goal | Measured by |
|---|---|---|
| G-1 | One versioned source per deck | No `_25`/`_26` copies; every semester's state is recoverable from git history or a tag [idea] |
| G-2 | Slides and scripts look like one series | Same fonts, colour per script, hexagon motif, same figure styles for graphs/arrays; a student recognises a slide and a script page as belonging together [idea] |
| G-3 | Editing stays efficient | A typical semester revision of a deck (fix text, reorder, add a slide with a small figure) takes at most ~1.5× the time it takes in Impress [assumed] |
| G-4 | Conversion is affordable | Converting one existing deck takes ≤ 2 h of the teacher's time, with Claude doing most of the work [assumed] |
| G-5 | Drawings remain easy | A new graph/array/card figure can be made in ≤ 10 min, without hand-writing TikZ coordinates [assumed] |

## 3. Users & Roles

| Role | Description | Access | Prio |
|---|---|---|---|
| Author | The teacher. Writes, edits, builds, presents. | read/write on sources | MUST |
| Students | Receive the PDF (presentation and/or handout) | PDF only | MUST |
| Claude Code | Converts decks and writes TikZ figures on request | repo, during sessions | MUST [idea] |
| Colleagues | Might reuse decks or the theme | sources or PDF | COULD [assumed] |

## 4. Domain Model / Glossary

| Term | Meaning | Example |
|---|---|---|
| **Deck** | One presentation on one topic, one `.odp` today | `sorting_2025` (111 slides), `euler_mst` (35 slides) |
| **Master slide** | The Impress template: background, title layout, decoration | `Default` (used by all slides); `Code Slide` (defined, unused in both references) |
| **Build sequence** | Several consecutive slides that show one step each of a process; today made by duplicating the slide, not by animations | "Selectionsort in Aktion" (15 slides), "Mergesort: Conquer" (26 slides) |
| **Figure family** | A recurring kind of drawing with a fixed visual grammar | weighted graph, card row with braces/pointers, array of cells with pointers |
| **Script** (Skript) | LaTeX book per subject, shares `common/layout/` | Algorithmik, Digitale Daten, Kryptologie, Logik, Networks, Programmieren |
| **Script colour** | `baseColor` set per script in its `colors.sty` | Algorithmik: `Rhodamine!90!black`; layout default: `SeaGreen` |
| **Design tokens** | Shared corner radii, line widths, sizes in `design.sty` | `\designArc`, `\designRim`, `\designFontScale` |
| **Variant** | A build output of the same source | scripts: screen, print, review, teacher; slides: presentation, handout [assumed] |

### 4a. Scope [customer]

| | |
|---|---|
| Subjects | about 5 |
| Decks | about 80 in total |
| Slides per deck | varies; **50 as a pessimistic average** → up to ~4000 slides; at the reference ratio (~60 % build-sequence steps) roughly **1600 frames** after conversion |

## 5. Analysis of the Reference Slides

### 5.1 Master slide / template [ref]

| Aspect | Finding |
|---|---|
| Page format | 28 × 15.75 cm, **16:9** |
| Background | near-black `#0a0a0a` |
| Decoration | three dark-red hexagons (`#410000`, rim `#6f3434`) top left; thin network lines with dots (`#754e4e`) along the title and top right; a red hexagon corner bottom right; binary `01101001 01101110 01100110` (= "inf") bottom left in dark grey |
| Fonts | **Montserrat** for titles and body; Fira Mono for numbers/code-like text; Fira Sans in node labels; LibreOffice serif in StarMath formulas; Purisa (handwriting) once |
| Title | white, Montserrat Regular, ~32 pt, top left next to the hexagons, underlined by a network line |
| Bullets | hexagon bullets in dark red, two levels (2nd level smaller) |
| Emphasis | key terms bold in a muted rose (`#bdaeb2`/`#aa8d8d`), e.g. "Ein **Pfad** ist …" |
| Title slide | the title only, bold, centred; same for section slides ("Selectionsort", "Bubblesort") |
| Footer / page numbers / logo | none |
| Second master | `Code Slide` exists but neither reference deck uses it → other decks contain code |

### 5.2 Content types (count = number of slides containing it) [ref]

| Content type | euler_mst (35) | sorting_2025 (111) | Notes |
|---|---:|---:|---|
| Bullet lists (outline) | 27 | 39 | 1–2 levels, short; many slides are "title + 1 bullet" (tasks: "Aufgabe 4") |
| Free text boxes | 9 | 14 | mostly labels (edge weights, "S", "U", "min") |
| Impress drawings | 23 | 62 | see 5.3 |
| Tables | 0 | 34 | 231 small tables = the mergesort arrays (cells with numbers) |
| Raster images | 2 | 40 | 6 playing-card PNGs (used 36× each), card back, an inbox screenshot (2×), the n² plot, check/cross marks |
| Formulas | 0 | 3 | 5 StarMath objects (Gauss sum, (n²−n)/2); plus 45 empty leftover formula objects |
| Code | 0 | 0 | — but the `Code Slide` master suggests code in other decks |
| Animations (Impress effects) | 0 | 0 | none at all |
| Build sequences (slide repeats the previous title) | 13 | 77 | **~60 % of all slides** are steps of a sequence |
| Speaker notes | 0 | 1 | practically unused |

### 5.3 Drawings in detail [ref]

Almost all drawings belong to four **figure families**:

| Family | Where | How built in Impress | Complexity |
|---|---|---|---|
| **Weighted graph** | euler_mst: 6 distinct graphs (12, 6, 5, 4 nodes), each reused across a build sequence with highlighted edges (bold white, dotted = removed) | ellipses + connectors + text boxes for weights (194 connectors, 125 ellipses) | low–medium; maps 1:1 onto `graph.sty` in the Algorithmik script (`vertex`, `vertex_active`, `chosen`, edge-weight pills) |
| **Card row** | sorting: Selection-/Bubblesort (≈ 40 slides) | 6 card PNGs + braces (`left-brace`) labelled S/U + chevron arrows ("min") + curved swap arrows | low; the script already uses the same card PNGs (`pictures/playing_cards/`) |
| **Array of cells** | sorting: Mergesort (≈ 35 slides) | tables per sub-list + chevron pointers | low; maps onto `python_array.sty` (`\pythonArray` with items, pointers, highlight, parts) |
| **Illustration** | Königsberg bridges (3 slides, drawn as paths), cars analogy for merge (5 slides, grouped shapes), check/cross marks | free paths and groups | free-form; not worth redrawing in TikZ. Keep as image (SVG/PDF export) or redraw once |

### 5.4 What a conversion has to handle

| Part | Automatable? | How |
|---|---|---|
| Titles, bullets, text, emphasis | **yes** | parse `content.xml` → Beamer frames |
| Raster images | **yes** | copy from `Pictures/`, place with `\includegraphics`; reuse the script's card images |
| Formulas | **mostly** | StarMath annotation → LaTeX math (5 formulas; trivial by hand or by Claude) |
| Tables / arrays | **yes, with mapping** | tables → `\pythonArray`-like macro |
| Build sequences | **semi** | detect consecutive slides with the same title and merge them into one frame with overlays (`\only<n>`, `\pause`); the diff between steps needs Claude's judgement |
| Graphs, card rows | **with Claude** | read positions/labels from the XML and emit TikZ in the theme's figure styles; layout coordinates can be taken over from Impress |
| Illustrations | **manual decision** | export once as SVG/PDF, or leave out |
| Design | **not converted** | the new theme replaces the master; decorations are not taken over from the XML |

### 5.5 Gap between slide design and script layout [ref] [script]

| Aspect | Slides today | Scripts | Gap |
|---|---|---|---|
| Background | black | white page, dark header/footer bands (`bgColor` = script colour 30 % + black) | **large**: dark vs light |
| Colour | one fixed dark red for all topics | one `baseColor` per script (Algorithmik: Rhodamine/mauve) | medium: the slide red is close to the Algorithmik colour, but not to the others |
| Fonts | Montserrat | Fira Sans + Fira Mono (`\designFontScale`) | medium |
| Motif | hexagons, network lines, binary "inf" | hexagons (page number, box icons, chapter banner), binary "inf school" in the header | **small**: the same brand already |
| Emphasis | bold rose | `\term{}` = bold in `termColor` | small: same idea |
| Boxes | none | `concept`, `info`, `example`, `task`, `think`, … with hexagon icons | new on slides |
| Graphs | white-rimmed pink nodes on black | `graph.sty`: light nodes, script-coloured rims, weight pills | medium: same structure, colours tuned for white paper |
| Code | (Code master, unknown) | `pythonhighlight.sty` boxes | unknown |

**What "looking like they belong together" would mean in practice** [assumed]: Fira Sans, the script colour of the subject, the hexagon motif and header band from the scripts, `\term` and the box environments (`concept`, `task`) on slides, and the *same* TikZ styles for graphs, arrays and cards, so a figure can move between script and slide unchanged. Resolved: light «Band» layout plus a dark switch (N-08); the slide theme is separate from the script layout but copies its values (N-01a).

### 5.6 Layout spikes

**Spike 1 (round 1): page chrome.** Three looks were built (`spikes/chrome/`): **«Band»** (light page, dark title band and footer band like the script header/footer), **«Nacht»** (today's dark master in script colour and Fira), **«Kapitel»** (light, chapter-number hexagon before the title). Finding: the looks differ only in the theme, so **light and dark can be built from one source** (palette switch). A 6-slide build sequence becomes one frame of ~25 lines.

**Spike 2 (round 2): layout catalogue — DRAFT.** The customer asked to step back and draft *layout options*, leaning on the scripts. Below is a catalogue of slide layouts: the kinds of slides the reference decks actually contain, each modelled on the matching script element. Built as a working Beamer draft (`spikes/catalog/catalog.tex` + `slidetheme.sty`, 14 layouts, 23 pages incl. overlay steps) on the «Band» chrome. Per the customer (Q-10), the theme is **its own package**: values, icons and figure styles were *copied* from the scripts as a starting point, with no dependency on the scripts repo.

| ID | Layout | Use (found in references) | Modelled on (script) | Key elements |
|---|---|---|---|---|
| L1 | **Titel** | first slide of a deck | cover (hexagon mosaic) | dark full page, hexagon mosaic right, subject · chapter line, binary "inf" |
| L2 | **Abschnitt** | "Selectionsort", "Bubblesort", "Kruskal" dividers | chapter banner | full-width band with large number hexagon (e.g. 3.2) |
| L3 | **Programm** | "Programm: Heute / Nächste Woche" | — | labelled columns (HEUTE / NÄCHSTE WOCHE / SKRIPT), numbered hexagons |
| L4 | **Aufzählung** | most text slides | body text, `\term` | hexagon bullets, 2 levels, step-wise reveal |
| L5 | **Text + Grafik** | "Pfade", "Fleury in Aktion" | figure next to text | two columns, figure in the theme's graph style |
| L6 | **Grafik** | card rows, "Let's go!" | figures with `\cardSplit` | full-width figure + one caption line |
| L7 | **Begriff** | "Ein Pfad ist …", "Eulersche Regel", "Ein Baum ist …" | `concept` box (bulb icon) | definition box with title bar, follow-up bullets |
| L8 | **Algorithmus** | "Finden einer Eulertour", "Algorithmus von Kruskal" | numbered steps | numbered hexagons; the current step is highlighted while the figure next to it advances |
| L9 | **Schritt für Schritt** | "… in Aktion", "Mergesort: Conquer" (~60 % of slides) | `python_array`, `graph.sty` | one figure, overlays per step, one caption line per step, progress hexagons |
| L10 | **Code** | (Code master; Programmieren) | `code` box (Python icon) | highlighted listing with file name bar, line numbers |
| L11 | **Formel** | "Kleiner Gauss", "(n²−n)/2" | display maths | centred formula + interpretation bullets |
| L12 | **Denkanstoss** | "Wie ineffizient ist das?", "Fragen zu …?" | `think` box (question icon) | one big question in a left-rule box |
| L13 | **Aufgabe** | "Ihr seid dran!", "Aufgaben 38 – 41" | `task` box (pencil icon) | task numbers + script page, work form and time |
| L14 | **Zusammenfassung** | "Zwischenfazit" | `chaptersummary`, `checklist` | key points + «Kannst du das?» checklist |

Observations from the draft: 12 pt body text on 16:9 Beamer is ~21 pt relative to today's 28 cm slides, readable but the floor (N-02); the script's icons and box shapes work on slides unchanged; figures from the reference decks fit L5/L6/L9 with no new styles.

### 5.7 Decision after sign-off: slides derived from the books layout [customer]

The customer asked to **disregard the old Impress design in `references/` entirely** and build the slides to suit the layout of the books repository. This replaces the «Band» chrome and the versions in `layout_review.md` (V1–V5), which stay as background only. The reference decks remain the source for *content* (§5.2–5.4), not for design.

Built as a working theme in `spikes/books/` (`theme/infschoolslides.sty`, sample deck `sorting.tex` with all layouts, light and dark PDFs). Mapping from script elements to slide elements:

| Script element (`common/layout/`) | Slide element |
|---|---|
| Header band (`\pageheader`): `bgColor` band with `borderColor` rules, faint binary "inf", chapter-number hexagon hanging from the top-left corner, section name on the right | Frame title band: the same, with the deck's chapter number and the current `\section` |
| Footer band (`\pagefooter`) with hexagon page number on its edge | Footer band with hexagon frame number |
| Cover (`titlepage.sty`): honeycomb of duotone photo hexagons, title block with short rule, logo, footer band with subject and author | Title slide (L1): same composition in 16:9; same duotone technique, photos per subject |
| Chapter banner with large number hexagon | Section slide (L2) |
| `concept`/`info` (title bar, icon hexagon top right) and `example`/`think`/`task`/`checklist` (left rule, icon hexagon top left), `\term`, `\boxtitle` | Same environments and names on slides (L7, L12, L13, L14) |
| `pythonhighlight.sty` code box | Code box (L10) |
| `graph.sty`, `python_array.sty`, playing cards | Figure styles (L5, L6, L8, L9), enlarged for projection |
| `design.sty` token names, `colors.sty` colour roles | Same names and roles, own copy with values scaled to the slide format |

Kept from earlier decisions: the theme is **its own package** (no file of the books repo is loaded; icons, logo, card images and cover photos are copied, with the photos' `SOURCES.md`); one colour per subject; light and dark from one source (the dark palette is new, the scripts have none); layouts L1–L14.

## 6. Functional Requirements

### 6.1 Authoring

| ID | Requirement | Prio | Source |
|---|---|---|---|
| F-01 | Decks are written as LaTeX/Beamer source and built to PDF | MUST | [idea] [customer] |
| F-02 | One source per deck; no copies per semester | MUST | [idea] |
| F-03 | Title, section and content frames with 1–2 bullet levels, emphasis (`\term`), formulas | MUST | [ref] |
| F-04 | Step-by-step reveals in one frame (overlays) instead of duplicated slides | MUST | [ref] |
| F-05 | Images (PNG/JPG/SVG/PDF) with simple placement (left/right of text, full width) | MUST | [ref] |
| F-06 | Code listings with syntax highlighting in the style of the scripts' code boxes (L10): **Python MUST**; other languages (occasional) SHOULD, via the highlighter's built-in language definitions | MUST | [ref] (Code master) [script] [customer] |
| F-07 | Script boxes on slides (`concept`, `task`, …) | SHOULD | [script] |
| F-08 | Reference tasks of the script ("Aufgabe 38–41") as links or auto-numbered references | COULD | [ref] [assumed] |
| F-09 | Speaker notes | WON'T | [ref] (unused today) |
| F-09a | A fixed set of slide layouts (catalogue L1–L14, §5.6) in the books-derived theme (§5.7), as Beamer commands/environments; converted slides are mapped onto them. L1, L2, L4–L13 MUST; L3 (Programm) and L14 (Zusammenfassung) COULD | MUST | [customer] |
| F-09b | **Slide modes** shown in the header, so the class sees at a glance what to do: *normal* (follow along); **«Mach mit»** (`doit=<tag>`: bright band, task pencil, tag with work form and time, e.g. «zu zweit · 15 Min»); **«Zum Lesen»** (`read=<tag>`: tinted page, open-book icon, tag with the reference, e.g. «Skript S. 46», meaning: read, don't copy). Set per frame as a frame option; every frame starts in normal mode. Works in light and dark. | SHOULD | [customer] |

### 6.2 Drawings

| ID | Requirement | Prio | Source |
|---|---|---|---|
| F-10 | TikZ styles for graphs, arrays and card rows in the slide theme, visually matching the scripts' figure styles (copied, not shared, see N-01a), with colours for both light and dark palettes | MUST | [ref] [script] [customer] |
| F-11 | Highlighting a graph's edges/nodes or an array's cells step by step within a build sequence, without copying the figure | MUST | [ref] |
| F-12 | New figures can be made without writing TikZ coordinates by hand: Claude writes TikZ from a description or a photo of a sketch, using the theme's figure styles | MUST | [idea] [customer] |
| F-13 | Free-form illustrations can be included as SVG/PDF made in a drawing tool (Inkscape, draw.io, Impress Draw) | SHOULD | [ref] |
| F-14 | A WYSIWYG editor for TikZ figures | COULD | [idea] — see §10 for what is realistic |

### 6.3 Conversion

| ID | Requirement | Prio | Source |
|---|---|---|---|
| F-20 | Convert an `.odp` deck into a Beamer source: text, bullets, emphasis, images, formulas, tables | MUST | [idea] [ref] |
| F-21 | Merge build sequences into overlay frames | SHOULD | [ref] |
| F-22 | Convert graphs and card rows into the theme's TikZ styles (Claude-assisted) | SHOULD | [ref] |
| F-23 | Conversion report per deck: what was converted, what needs manual work (illustrations, unclear diffs) | SHOULD | [assumed] |
| F-24 | Conversion runs as a one-off per deck; no need to re-convert a deck after it has been edited in LaTeX | MUST | [customer] |
| F-25 | Deck by deck first: each conversion is reviewed with the teacher (pilot phase) | MUST | [customer] |
| F-26 | **Batch conversion** of many decks without user input, once the pipeline works reliably on the pilot decks. With ~80 decks (§4a), converting all of them at 2 h each would cost ~160 h, so the batch is what makes a full migration affordable. | SHOULD | [customer] |
| F-27 | Fallback for anything that can't be converted automatically (free-form illustrations, unknown shapes): export that drawing from the slide as a cropped vector PDF via `soffice` and include it as an image, listed in the report. This lets the batch finish without questions. | MUST (for F-26) | [assumed] |
| F-28 | Batch runs can use Claude non-interactively (headless) for figures and build sequences; results are reviewed afterwards via the report, not during the run | SHOULD | [assumed] |

### 6.4 Build & Publishing

| ID | Requirement | Prio | Source |
|---|---|---|---|
| F-30 | Build one deck or all decks with one command | MUST | [assumed] |
| F-31 | Variants: presentation (with overlays, light or dark) and handout (light, one page per frame, last step of each build sequence) | MUST | [customer] |
| F-32 | Integrate with the existing build tool of the scripts (`tools/build/`) | COULD | [script] [assumed] |
| F-33 | Built PDFs land in a defined output folder; the teacher uploads the handout to students by hand (no publishing automation) | MUST | [customer] |

## 7. Non-Functional Requirements

| ID | Requirement | Prio | Source |
|---|---|---|---|
| N-01 | Versioned in git, in **its own repository, separate from the scripts repo (for now)**; semester states marked by tags or branches, no file copies | MUST | [idea] [customer] |
| N-01a | The slide layout is **its own theme, separate from the scripts' layout**; it may start from copied script values (tokens, icons, figure styles) but has no dependency on the scripts repo | MUST | [customer] |
| N-08 | **Light and dark from the same source**: a dark presentation variant in the first version, and the palette can be switched at any time per build (one setting, no change to the deck source). Every layout and figure style must work in both palettes. | MUST | [customer] |
| N-09 | One base colour per subject, same hues as the scripts (copied into the slide theme); changing it is a one-line setting per deck/subject | MUST | [customer] |
| N-02 | Readable in the classroom: min. body size ~20 pt equivalent, WCAG AA contrast | MUST | [assumed] |
| N-03 | Design values (colours, line widths, radii, sizes) are defined only in the slide theme (tokens and palettes), never inline in a deck; the same rule as in the scripts | MUST | [script] [customer] |
| N-04 | A deck of ~100 frames builds in < 1 min locally | SHOULD | [assumed] |
| N-05 | Only free, locally installed tools (TeX Live, LibreOffice, Python) | MUST | [assumed] |
| N-06 | German content, Swiss conventions (`ss`, «…») as in the scripts | MUST | [script] |
| N-07 | Maintainable by the teacher with Claude Code; conventional Beamer, no exotic build chain | MUST | [assumed] |

## 8. Constraints

- C-1: Single author, limited time; conversion and figures mostly done with Claude Code. [idea]
- C-2: The scripts are the visual model, but not a dependency: the slide theme copies their values and keeps its own files in the separate slides repo (N-01, N-01a). [customer]
- C-3: Tools available: `pdflatex`/`lualatex`/`xelatex`, `soffice`, `pdftotext`, `pdftoppm`. [customer]
- C-4: Slides are projected in a classroom (16:9 today). [ref]

## 9. Out of Scope (WON'T)

- A general-purpose `.odp` → LaTeX converter for arbitrary presentations; the batch converter (F-26) only needs to handle the teacher's own decks with their master [assumed]
- Round-trip editing (back from LaTeX to Impress) [assumed]
- Reproducing the current dark-red master 1:1 [assumed]
- Speaker notes [ref]

## 10. Existing Solutions

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| **Stay with Impress + git** (save as flat `.fodp`) | No learning; WYSIWYG drawings stay | Diffs of XML are noisy; design stays separate from the scripts; no shared figures | ✗ — solves G-1 only |
| **Beamer with an own theme modelled on the scripts** | Can copy fonts, colours, design tokens, icons and TikZ figure styles from the scripts; overlays replace duplicated slides; git-friendly | LaTeX editing is slower for layout tweaks; drawings need TikZ (or Claude) | **✓ Recommended** |
| **Typst + Touying/Polylux** | Fast compile, cleaner syntax, good overlays | Cannot reuse the `.sty` files or TikZ styles; design and figures would be built twice (CeTZ instead of TikZ) | ✗ for now — revisit if the scripts ever move to Typst |
| **Markdown slides** (Pandoc→Beamer, Marp, reveal.js, Quarto) | Very fast for text-only slides | Figures and step-by-step drawings are the hard part here, and these tools hand them to HTML/TikZ anyway; Pandoc→Beamer could still be used *inside* the Beamer option for text | ✗ (Pandoc as a possible input format: COULD) |
| **`odp` → LaTeX converters** (e.g. `odp2beamer`-style scripts, `writer2latex`) | Exist | Unmaintained or text-only; know nothing about the figure families or build sequences | ✗ — a small, deck-specific Python + Claude conversion does better |
| **WYSIWYG TikZ editors**: TikZiT, TikzEdit, Inkscape (`svg2tikz`), GeoGebra export, draw.io | TikZiT edits node/edge graphs visually and keeps custom styles, which fits the graph family well | TikZiT handles graphs only (no arrays, cards, overlays); svg2tikz/GeoGebra output is coordinate soup that ignores the theme's styles | TikZiT: **COULD** for graphs; others ✗ |
| **Claude writes TikZ from a description/sketch** | Uses the theme's styles; fast for the four figure families | Needs a session; free-form illustrations remain hard | **✓ main way to make figures** |

## 11. Open Questions

### Resolved

| # | Question | Answer |
|---|---|---|
| Q-1 | Core approach | **Hybrid**, Beamer on top of the scripts' design: convert once per deck (script + Claude), then edit only in LaTeX. [customer] |
| Q-2 | Convert all at once or deck by deck? | Deck by deck first; a batch conversion without user input later, once it works reliably (F-26). [customer] |
| Q-3 | Where do the slides live? | In a separate repository for now (N-01). [customer] |
| Q-4 | Which layout? | Stepped back: draft a layout catalogue leaning on the scripts first (§5.6 spike 2); chrome choice folded into Q-11. [customer] |
| Q-5 | Drawing workflow after the switch | Describe or sketch; Claude writes the TikZ in the theme's styles; photos/illustrations stay images (F-12). [customer] |
| Q-6 | Handout for students? | Yes: light, one page per frame, last step of each build sequence (F-31). [customer] |
| Q-7 | Effort budget | ≤ 2 h per deck in the pilot phase; editing ≤ 1.5× Impress (G-3, G-4). [customer] |
| Q-8 | Scope | ~5 subjects, ~80 decks, ≤ 50 slides each (§4a). [customer] |
| Q-9 | Semester-specific changes | One `main` branch, a tag per semester. [customer] |
| Q-10 | Share the scripts' design files? | No. Slide layout and script layout stay separate (N-01a). [customer] |

| Q-11 | Layout catalogue | All 14 layouts on the «Band» chrome; L3 and L14 COULD (F-09a). [customer] |
| Q-12 | Colour per subject | One base colour per subject, same hues as the scripts, copied (N-09). [customer] |
| Q-14 | Code | Mostly Python; other languages occasionally (F-06). [customer] |
| Q-15 | Publishing | Manual upload of the handout PDF from an output folder (F-33). [customer] |

| Q-13 | Dark switch | Yes, in the first version; the palette must be switchable at any time (N-08). [customer] |

### Open

None. Technical questions (theme structure, converter design, build tool, Claude batch setup) belong to the design phase (§14).

## 12. Acceptance Criteria

- [ ] AC-1: The pilot deck builds from source into a presentation PDF and a handout PDF.
- [ ] AC-2: A slide and a script page of the same topic, side by side, use the same font, script colour, hexagon motif and graph style.
- [ ] AC-3: A build sequence (e.g. "Kruskal in Aktion") is one frame with overlays; the figure exists once in the source.
- [ ] AC-4: Converting the pilot deck took ≤ 2 h of the teacher's time.
- [ ] AC-5: The teacher can make a typical semester revision of the pilot deck without help.
- [ ] AC-6: The deck's history is in git; no `_25`/`_26` copies exist.
- [ ] AC-7: The pilot deck builds in light and dark from the same source by changing one setting; every layout and figure is readable in both (WCAG AA contrast).
- [ ] AC-8: Every slide of the pilot deck uses one of the catalogue layouts (L1–L14) or is listed in the conversion report.
- [ ] AC-9: A batch run over at least 5 unseen decks finishes without user input and produces a report; anything not converted is included as a vector image (F-27).

## 13. Proposed Release Plan

| Milestone | Content | Usable for |
|---|---|---|
| **M0 – Theme** | Slide theme from `spikes/books/` (§5.7): books-derived chrome, layouts L1–L14, light and dark palettes, subject colours, figure styles in both palettes | Writing new slides |
| **M1 – Pilot deck** | Convert `euler_mst` (35 slides, graphs, no tables): converter for text/images + Claude for graphs and overlays | Validating G-3, G-4 |
| **M2 – Figure families** | Card-row and array styles in both palettes, build-sequence merging; convert `sorting_2025` | Algorithmik decks |
| **M3 – Build & publish** | Build command, handout variant, output folder | Daily use |
| **M4 – Batch** | Unattended batch conversion with fallback export and report (F-26–F-28) | Remaining decks |
| Later | L3/L14, other code languages, TikZiT setup | — |

## 14. Next Step: Technical Design

Write `design.md` in this folder, deciding:

1. **Repository layout** of the separate slides repo: theme package, per-subject folders, decks, shared images (e.g. playing cards), output folder; semester tags.
2. **Theme structure**: tokens, light/dark palettes and subject colours as separate files; the layouts L1–L14 as commands/environments (start from the books-derived theme in `spikes/books/`); how the palette switch is passed at build time (N-08).
3. **Figure styles**: graph, card row, array of cells, pointers, braces; overlay helpers for step-by-step highlighting (F-11); both palettes.
4. **Converter**: Python `.odp` parser → intermediate model (slides, shapes, tables, formulas, images) → Beamer; detection of build sequences and layout mapping; StarMath → LaTeX; fallback export of unknown drawings as cropped vector PDF via `soffice` (F-27); the conversion report (F-23).
5. **Claude's role**: which steps run as deterministic Python and which as Claude prompts (figures, overlay diffs, layout choice); prompt files and how a headless batch run is invoked and reviewed (F-28).
6. **Build**: one command per deck/all decks, variants presentation-light, presentation-dark, handout; engine (pdfLaTeX vs LuaLaTeX); build time (N-04).
7. **Pilot plan**: `euler_mst` (M1), then `sorting_2025` (M2), with the measurements for G-3/G-4.

## Changelog

- **v1.2 (2026-10-17):** Slide modes «Mach mit» and «Zum Lesen» (F-09b), built in `spikes/books/` (frame options `doit=…`, `read=…`; new open-book icon in the style of the script icons).

- **v1.1 (2026-10-17):** Layout direction changed after sign-off: old Impress design disregarded; slides derived from the books layout (§5.7, F-09a, M0, §14). Theme built in `spikes/books/` with all layouts in light and dark. «Band» chrome and the review versions V1–V5 superseded.

- **v1.0 (2026-10-17):** Interview round 4, signed off. Dark presentation variant in the first version, switchable at any time per build (N-08 → MUST, F-10, F-31 → MUST, AC-7). Removed the remaining references to sharing the script layout (C-2, N-03, §10). Acceptance criteria for layouts and batch (AC-8, AC-9). Release plan updated; added §14 (design next steps).

- **v0.4 (2026-10-17):** Interview round 3. Catalogue L1–L14 on «Band» accepted, L3/L14 COULD (F-09a); colour per subject (N-09); mostly Python code (F-06 → MUST for Python); manual upload from output folder (F-33 → MUST). Dark switch (Q-13) needs clarification.
- **v0.3 (2026-10-17):** Interview round 2. Stepped back from choosing a chrome: draft layout catalogue L1–L14 modelled on the scripts (§5.6 spike 2, F-09a). Slide layout separate from the script layout, values copied (N-01a, F-10). Drawing workflow confirmed (F-12). Scope ~5 subjects / ~80 decks / ≤ 50 slides (§4a); batch rationale (F-26). Handout, effort budget, tag per semester confirmed. Round 3 questions Q-11–Q-15.
- **v0.2 (2026-10-17):** Interview round 1. Hybrid approach with Beamer confirmed (Q-1); deck by deck first, unattended batch conversion later (F-25–F-28); separate repository (N-01, N-01a). Layout spike with three options added (§5.6), light/dark from one source (N-08). Round 2 questions Q-4–Q-10.
- **v0.1 (2026-10-17):** Initial draft from `idea.txt`, analysis of the two reference decks and of the script layout, before the interview.
