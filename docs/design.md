# Slide Transformation – Technical Design

| | |
|---|---|
| **Status** | **v1.0 — signed off; next step: implementation, starting with M0 and the visual design agreement (§11)** |
| **Last updated** | 2026-10-17 |
| **Based on** | `requirements.md` v1.2 (signed off), theme spike `spikes/books/`, analysis scripts `spikes/analysis/`, books repo `CLAUDE.md` and `common/layout/` (read-only), design spikes S-1 to S-6 (§10), customer rounds 1–3, books `scripts/*/colors.sty`, `Algorithmik/graph.sty` and `python_array.sty` (read-only, Q-8) |
| **Next step** | M0-1 to M0-3 (§11): repo skeleton, design proposal, **visual design agreement with the customer** before the theme is built out |

> **How to read this document**
> Each design decision has an ID (`D-xx`) and is listed in the decision log (§12). Requirement IDs (`F-xx`, `N-xx`, `G-x`, `AC-x`) show which requirement a choice serves. Items marked **[check]** are technical details to be verified during implementation, at the milestone named; they don't change the design. Items marked **[assumed]** are my guesses as architect; please confirm or correct them. Spike results are in §10.

---

## 1. Summary

A **separate git repository** holds a Beamer **class** `infschoolslides` (the cleaned-up theme from `spikes/books/`, split into tokens, palettes, subjects, chrome, boxes, code and figures), one folder per subject with one folder per deck, shared images, and two Python tools: **`build.py`** (one command for one, some or all decks; variants light, dark, handout) and **`convert.py`** (one-off `.odp` → Beamer conversion, interactive per deck or as an unattended batch).

The converter is a **pipeline with a JSON intermediate model**. Python does everything that can be computed: parsing, recognising the figure families (graphs are fully recoverable from Impress connectors, §10 S-1), detecting build sequences and the per-step differences, StarMath → LaTeX, text frames, the vector fallback export via `soffice` and the report. **Claude (headless, no tools)** is used for judgement only: one *plan* call per deck (layout, mode, sequence boundaries, illustration triage) and one *frame* call per figure or build-sequence frame (writing the TikZ + overlays from the model). Every Claude result is compiled and checked; if it fails twice, the slide falls back to vector images, so a batch always finishes (F-26, F-27).

| Layer | Choice |
|---|---|
| Slides | LaTeX Beamer, own class `infschoolslides` (from `spikes/books/`) |
| Engine | pdfLaTeX via `latexmk` (TeX Live) |
| Figures | TikZ with the theme's figure styles; images (PNG/JPG/PDF) |
| Code | `listings` in a `tcolorbox` (as in the spike) |
| Tools | Python 3 (standard library + `pypdf`), `soffice` headless, `claude -p` |
| Repository | git, own repo, tag per semester |

## 2. Repository Layout — D-01, D-02

**Serves N-01, F-02, F-30, F-33, G-1.**

Repository `inf_school_slides`, checked out at `~/Teaching/slides` next to the books (Q-1):

```
slides/
├── CLAUDE.md                  rules for Claude Code sessions (language, theme-only design values, figures)
├── .vscode/settings.json      LaTeX Workshop recipes: dark (default), light (§7.2)
├── .claude/rules/figures.md   figure rules, loads FIGURES.md when a deck is edited
├── docs/                      requirements.md, design.md (moved here from the idea folder)
├── theme/                     the class and its parts (§3), on TEXINPUTS
│   ├── infschoolslides.cls
│   ├── infschool-*.sty
│   ├── cover/<subject>/       cover photos per subject + SOURCES.md
│   ├── FIGURES.md             figure cookbook: one example per family (also prompt context, §6)
│   └── test/catalogue.tex     every layout, mode, box and figure; built for all subjects × palettes
├── images/                    shared images, on TEXINPUTS: playing_cards/2h.png, playing_cards/back.png, …
├── subjects/
│   └── algorithmik/
│       ├── euler_mst/
│       │   ├── euler_mst.tex  the deck (one file)
│       │   ├── img/           deck images: raster images, fallback PDFs (img/s07-bruecken-light.pdf)
│       │   └── CONVERSION.md  conversion report (§5.8), committed; open items as check boxes
│       └── sorting/
├── tools/
│   ├── build/build.py         §7
│   ├── convert/               §5: odpconv package, convert.py, batch.py, prompts/, assets.toml
│   └── check/                 lint (N-03), contrast (N-02)
└── build/                     ignored: work/, out/, convert/ (intermediate files, Claude logs, cache)
```

- **Subject folders** use the books' slugs in lower case (`algorithmik`, `digitale_daten`, `kryptologie`, `logik`, `networks`, `programmieren`) [check M0: same spelling as the books' slugs]. **Deck folders** are named after the topic, **without year suffix** (`sorting`, not `sorting_2025`), so a deck keeps its path for its whole life (G-1).
- **One folder per deck**: images and the report stay next to the deck; deleting or renaming a deck is one folder.
- **Original `.odp` files are not committed** (Q-1): they are binary, large (the two references alone are 7 MB) and only needed once (F-24). The report records the source file name and its SHA-256, and the originals stay archived on the cloud drive (Q-1).
- **Output**: `build/out/<subject>/<deck>-light.pdf`, `-dark.pdf`, `-handout.pdf`; the teacher uploads the handout from there (F-33).
- **Semester tags**: an annotated tag `hs26`, `fs27`, … on `main` at the **end** of each semester, so the tag is "what was taught" (Q-9, N-01, AC-6). An old state is rebuilt with `git worktree add ../slides-hs26 hs26` and `build.py` in there.
- **Docs**: `requirements.md` and `design.md` move into `docs/` when the repo is created; the idea folder stays as the record of the spikes (Q-1).

## 3. Theme Structure — D-03 to D-07

**Serves F-09a, F-09b, N-01a, N-03, N-08, N-09, G-2.**

### 3.1 Class and files

The theme becomes a **class** that loads `beamer` with fixed options (`aspectratio=169`, `12pt`, `xcolor=dvipsnames`), so a deck cannot set design-relevant options by accident (N-03). A deck preamble is four lines:

```latex
\documentclass{infschoolslides}
\slidesubject{algorithmik}     % colour, subject name, cover photos (N-09)
\slidechapter{4}               % number in the header hexagon
\title{Eulertouren und Spannbäume}
```

| File | Content | From the spike |
|---|---|---|
| `infschoolslides.cls` | loads beamer + the parts; palette switch (§3.3); `\graphicspath` | preamble of `infschoolslides.sty` |
| `infschool-tokens.sty` | sizes, line widths, radii, font sizes, figure sizes; **same names as the books' `design.sty`**, values scaled to 16:9 (e.g. `\designHeaderHeight` 9 mm instead of 10 mm); slide-only tokens get the same `\design…` prefix (`\designNodeSize`, `\designCellSize`, `\designPointerLength`) | "tokens" block; figure sizes now moved out of `\tikzset` |
| `infschool-subjects.sty` | table of subjects: slug → display name, `baseColor` (copied from the script's `colors.sty`, see below), optional overrides of `primaryDark`/`primaryLight`, cover photo list | new; replaces `\slidecolor`/`\slidecoverimages` in decks |
| `infschool-palette-light.sty`, `infschool-palette-dark.sty` | all colour roles, derived from `baseColor` (§3.2) | the two branches of `\slide@palette` |
| `infschool-chrome.sty` | header and footer band, mode band and tag, title slide (L1), section slide (L2), `layout=` key (§3.4) | bands, modes, cover, `\sectionslide` |
| `infschool-text.sty` | bullets, `\term`, `\highlight`, `\boxtitle`, `\slidehead`, `\slidelabel`, `stepcaptions` | text block |
| `infschool-boxes.sty` | `concept`, `info`, `example`, `think`, `task`, `checklist` (names as in the books) | boxes |
| `infschool-code.sty` | `code` box, Python style; other languages via `listings` built-ins (F-06) | code |
| `infschool-figures.sty` | figure styles and overlay helpers (§4) | figures |
| `infschool-icons.sty`, `infschool-logo.sty` | box icons incl. the open book, logo | `slideicons.sty`, `slidelogo.sty` |

Subject colours, copied from the books (N-09, Q-8):

| Slug | Name | `baseColor` | Derived shades |
|---|---|---|---|
| `algorithmik` | Algorithmik | `Rhodamine!90!black` | standard: `primaryDark` = base 30 % + black, `primaryLight` = base 80 % + black |
| `digitale_daten` | Digitale Daten | `RoyalBlue` (set in the script's `main.tex`, not in a `colors.sty`) | standard |
| `kryptologie` | Kryptologie | `SeaGreen` | standard |
| `logik` | Logik | `Emerald!95!black` | standard |
| `networks` | Networks | `#D2601A` (burnt orange) | **own**: `primaryDark` = `#9E4310` 90 % + black, `primaryLight` = base 80 % + **white** |
| `programmieren` | Programmieren | `ForestGreen` | standard |

Every subject has its own colour (Q-11).

Cleanup while moving (M0): `\RequirePackage{theme/…}` paths become plain names (the theme is found via TEXINPUTS, §7.2); `\shorthandoff{"}` and `babel` options stay; the `read` icon moves into `infschool-icons.sty`; the open review items R-5/R-6/R-7 of `layout_review.md` are checked against the new chrome.

### 3.2 Colour roles

The books' roles keep their names and meaning (`baseColor`, `primaryDark`, `primaryLight`, `borderColor`, `bgColor`, `titleColor`, `termColor`, `boxBg`). Slides add roles the scripts don't need because the page is white there:

| Role | Light | Dark | Used by |
|---|---|---|---|
| `pageBg`, `textFg`, `mutedFg` | white, black 87 %, black 50 % | `baseColor` 7 % on black, white 90 %, white 55 % | page, body text |
| `termColor` | `primaryLight` | `baseColor!50!white` (≈ 9.6 : 1, R-8) | `\term`, bullets, pointers |
| `nodeFill`, `nodeText`, `edgeCol`, `chosenCol`, `removedCol` | as spike; `removedCol` = `edgeCol` 50 % | as spike | graphs |
| `cellFill`, `cellActive`, `cellDone` | | | arrays |
| `codeBg`, `codeComment`, `codeString` | | | code |

A palette file only assigns roles; no layout or figure file contains a colour value (N-03). The palettes are computed `\AtBeginDocument`, after `\slidesubject`, so the order of preamble lines doesn't matter.

### 3.3 Palette switch at build time — D-04

**Serves N-08, F-31.** The class reads `\slidepalette` if it is defined before the class is loaded, otherwise uses `dark` (Q-6). The build tool sets it without touching the deck:

```sh
latexmk -pdf -usepretex='\def\slidepalette{dark}' -jobname=euler_mst-dark euler_mst.tex
```

In VS Code the two LaTeX Workshop recipes pass the same pre-definition (§7.2); `\documentclass[light]{infschoolslides}` or `[dark]` works for a one-off test (the pre-defined macro wins). The class default is **dark**, because that is how the decks are presented (Q-6). The **handout is not a LaTeX variant**: it is cut from the light presentation PDF (§7.3), so the decks need no `handout:` overlay specs at all.

### 3.4 Layouts and modes — D-05, D-06

**Serves F-09a, F-09b, AC-8.** Layouts stay ordinary Beamer (frames, `columns`, `itemize`, boxes), because that is what the teacher and Claude can edit fastest (N-07). Only what needs structure gets a command or environment:

| ID | Layout | In the deck |
|---|---|---|
| L1 | Titel | `\titleslide` (wraps the plain frame and the cover) |
| L2 | Abschnitt | `\sectionslide[3.2]{Selectionsort}[«Wiederholtes Suchen des Minimums»]` — also issues `\section` |
| L3 | Programm (COULD) | frame + `columns` + `\slidelabel` |
| L4 | Aufzählung | frame + `itemize` (2 levels, `\item<2->`) |
| L5 | Text + Grafik | frame + `columns` (text left, figure right) |
| L6 | Grafik | frame, centred figure, one caption line |
| L7 | Begriff | `concept` box + bullets |
| L8 | Algorithmus | `enumerate` with `\item<alert@n>` + figure column |
| L9 | Schritt für Schritt | figure with overlay styles + `stepcaptions` + `\stepdots` |
| L10 | Code | `code` box (`[fragile]` frame) |
| L11 | Formel | display maths + bullets |
| L12 | Denkanstoss | `think` box |
| L13 | Aufgabe | `task` box, usually with `doit=` |
| L14 | Zusammenfassung (COULD) | bullets + `checklist` |

Every frame may carry a **`layout=<name>` frame key** (`liste`, `textgrafik`, `grafik`, `begriff`, `algorithmus`, `schritte`, `code`, `formel`, `denkanstoss`, `aufgabe`, `programm`, `fazit`). It does two things: it applies the layout's spacing (vertical centring and larger text for `denkanstoss`/`aufgabe`, R-4; centred figure for `grafik`/`schritte`), and it makes the layout **checkable**: the converter writes it on every frame, and `check` lists frames without it (AC-8). Hand-written frames may omit it.

**`stepcaptions`** replaces the chain of `\only<1>{…}\only<2>{…}` from the spike: each `\item` shows on its own overlay, and the box reserves the height of the tallest caption so the figure doesn't jump (G-3: a step is one line to edit).

**Modes** stay frame keys as in the spike: `doit=<tag>` («Mach mit»), `read=<tag>` («Zum Lesen»), reset to normal on every frame (F-09b).

## 4. Figure Styles and Overlay Helpers — D-08, D-09

**Serves F-10, F-11, F-12, G-5, N-08.** One file, `infschool-figures.sty`, all sizes from tokens, all colours from roles, so every figure works in both palettes. `FIGURES.md` shows one complete example per family; Claude uses it both in editing sessions and in the converter prompts (one source for both).

The slide theme offers **the books' macro and style names with the same keys** (Q-8, G-2), so a figure call can be copied between script and slide unchanged; only sizes and colours differ (slide tokens, both palettes). Slide-only additions are marked "new".

| Family | Books name (kept) | Slide additions | Notes |
|---|---|---|---|
| Graph | `graph` environment; styles `vertex`, `vertex_active`, `every edge`, `edge weight` (pills via `edge["5"]`), `dedge` (directed), `chosen` | `removed` (dashed), `visited` [check M1: needed by the Fleury/Kruskal decks?] | plain `\node`/`\path edge`, so TikZiT stays possible later |
| Array of cells | `\pythonArray{items={2,5,3}, highlight={0,2}, ptrs={0/i,2/j}, parts={0/1/L,2/2/R}, drawindexes, blank, nodesize}` | key `name=<prefix>` → cells are nodes `<prefix>0…`, so pointers and states can be overlaid; key `done={…}` (cells already merged) | same keys and 0-based indexes as the books |
| Card row | `\cardArray{items={2h,6h,5h}, parts={1/1/S,2/6/U}, highlight={3}, size}`, `\cardMerge{sorted, left, right, comp}`, `\cardSplit{items={{…},{…}}}` | key `name=<prefix>`; `\swaparrow{<a>}{<b>}`; `\pointerbelow{<node>}{<label>}` ("min") | images found as `playing_cards/<card>` via TEXINPUTS (the books use `pictures/playing_cards/`) |
| Braces, pointers | `parts=` keys of the macros above | `brace`, `pointer` styles for free use | |
| Progress | | `\stepdots{<n>}` (new) | |

**Overlay helpers** (F-11), all in TikZ keys so the figure exists once:

- `onslide=<2->{chosen}`: apply a style on some overlays (spike, kept);
- `visible on=<3->`: draw but keep invisible elsewhere (no jumping), the usual `opacity=0` trick;
- for steps that change the *data* of an array or card row (a swap, a merge step), the step is one macro call per overlay inside `\only<n>` (`\only<3>{\cardArray{items={2h,5h,6h,…}}}`): one line of data per step, the drawing itself is never copied.

## 5. Converter — D-10 to D-17

**Serves F-20 to F-28, AC-8, AC-9.**

### 5.1 Pipeline

```
.odp ──unzip──▶ parse ──▶ recognise ──▶ sequences ──▶ plan (Claude) ──▶ emit ──▶ frames (Claude) ──▶ check ──▶ deck.tex + img/ + CONVERSION.md
                 │           │              │                              │            │               │
               raw XML    figure families  steps + diffs              text frames   figure/sequence   compile light+dark,
                          (graph, cards,                              (Python)      frames            lint, content check;
                           cells, tables,                                                             fail twice → fallback (5.6)
                           formulas, images)
```

Each stage writes its result into `build/convert/<deck>/` (`model.json`, `sequences.json`, `plan.json`, `frames/NN.tex`, `claude/*.json`), so a run can resume at any stage and a teacher can look at what the converter saw. Package `tools/convert/odpconv/` with one module per stage; `spikes/analysis/` seeds `parse` and the spike scripts of §10 seed `recognise` and `starmath`.

### 5.2 Intermediate model — D-10

`model.json` (`odpconv/v1`): a list of slides; each slide has `title`, `hidden`, `notes` (counted, dropped: F-09) and **elements** in z-order, each with a bounding box in slide cm and a `kind`:

| Kind | Content | Recognised from |
|---|---|---|
| `text` | paragraphs with list level and runs (`bold`, `accent` = the master's rose → `\term`, `code` = Fira Mono) | outline/subtitle frames, text boxes |
| `image` | file, SHA-256, crop, `asset` (if the hash is in `assets.toml`) | `draw:image` |
| `table` | rows × cells (text) | `table:table` |
| `formula` | StarMath source, LaTeX, unknown tokens | `Object N/content.xml` annotation; empty objects are dropped and counted |
| `graph` | nodes (label, centre, state), edges (from, to, weight, state) | ellipses + connectors (glued via `draw:start-shape`/`end-shape`; unglued ends snap to the nearest node); weight labels = text boxes nearest to an edge midpoint (rotated frames via `draw:transform`); state from the stroke: wide = `chosen`, dashed = `removed`, fill change = `active` (§10 S-1) |
| `cards` | ordered card names, plus braces/pointers/arrows near the row | images whose hash maps to `playing_cards/*` in `assets.toml`, aligned in a row |
| `cells` | one or more arrays (values, positions) plus pointers | tables of one row, chevron shapes below |
| `drawing` | shape ids and bbox, nothing else | everything left over: paths, groups, unknown custom shapes |

Coordinates are kept in the model; scaling to the target layout (e.g. 7 × 6 cm in L5, 13 × 6.5 cm in L9, y flipped) happens when a figure is written.

### 5.3 Build sequences and overlay diffs — D-11

**Serves F-04, F-21, F-11, AC-3.**

1. **Candidates (Python):** consecutive slides whose normalised title is equal (case, punctuation, "(2)" removed) **or** whose figure has the same signature (same node labels at the same positions, or same table shapes). This also catches `Kürzester Weg!` → `Kürzester Weg (2) !` in `euler_mst`.
2. **Diff (Python):** per step, compared with the previous step: text paragraphs added / removed / changed; figure element state changed (edge `chosen`, node `active`, cell value); elements added / removed; elements moved (card swap).
3. **Overlay mapping:** added text → `\item<n->`; changed text → a `stepcaptions` item; state change → `onslide=<n->{state}` (or `<n>` if it is undone later); added element → `visible on=<n->`; moved cards or changed cell values → one `\cardArray`/`\pythonArray` call per step.
4. **Boundaries:** the plan call (§6) confirms or splits candidates (e.g. a slide in the middle of "Fleury in Action" that shows something else, slide 20 in `euler_mst`).

Long sequences stay one frame (Mergesort: Conquer, 26 steps); the handout gets the last step (F-31).

### 5.4 Layout and mode mapping — D-12

Python computes a **proposal** per frame from the model with simple rules (first slide → `titel`; title only → `abschnitt`; text only → `liste`; text + figure → `textgrafik`; figure only → `grafik`; sequence → `schritte`; formula → `formel`; "Aufgabe…", "Ihr seid dran" → `aufgabe` + `doit`). The **plan call** gets the whole deck as a compact outline and returns the final layout, mode and mode tag for every frame (it can see that "Hands on!" is a «Mach mit» slide, or that a long definition list is «Zum Lesen»). The answer is validated against the closed vocabulary; on an invalid answer the Python proposal is used and the frame is flagged.

### 5.5 StarMath → LaTeX — D-13

A small rule-based translator for the common subset (`over`, `cdot`, `sum_`/`^`, `...`, `"text"`, relations, Greek, `sqrt`, `color …` dropped). The spike translated **all 5 formulas** of `sorting_2025` correctly (§10 S-4). Unknown words are kept, listed in the model, and the frame goes to a Claude frame call; the report lists them.

### 5.6 Fallback: vector export via `soffice` — D-14

**Serves F-27, AC-9.** For every `drawing` element (and for any figure whose Claude frame call failed twice), Python writes **one temporary `.odp` per deck** with one page per fallback item: only that item's shapes, master decoration removed, page background set to none. One `soffice --headless --convert-to pdf` call renders all of them (≈ 1 s), `pdfseparate` + `pdfcrop` cut each page to its content (§10 S-2).

The old drawings were made for a black background (white strokes, rose accents). Each item is therefore exported **twice**, `img/<name>-dark.pdf` with the original colours and `img/<name>-light.pdf` with a colour map (greys inverted, the master's rose/red family → the subject's `termColor`); colourful drawings (the blue river of Königsberg) pass unchanged. `\slideimage{<name>}` picks the file matching `\slidepalette` (N-08). The fallback is meant as a stop-gap: the report lists each one as an open item ("redraw or keep").

Raster images are copied to `img/` (deduplicated by hash); images listed in `assets.toml` (e.g. the playing cards, whose PNGs differ by hash from the books' copies) are replaced by the shared file in `images/`.

### 5.7 Text conversion rules

LaTeX special characters escaped; Unicode outside T1 (arrows, ≤, ·) mapped by a table, unknown characters flagged; straight quotes "…" → «…» (N-06) and listed in the report; hidden Impress slides become `\begin{frame}<0>` with a comment (Q-9) [check M1: Beamer skips `<0>` frames]; speaker notes and empty formula objects are dropped and counted.

### 5.8 Conversion report — D-15

**Serves F-23, F-28, AC-8.** `CONVERSION.md` next to the deck, committed:

- header: source file + SHA-256, date, converter version (git hash), prompt versions, model, Claude cost and wall time;
- one row per frame: original slide numbers → frame number, layout, mode, **how** (`python`, `claude`, `fallback`), flags;
- open items as check boxes: fallback images, unknown formula tokens, unclear diffs, frames where Claude's output failed the content check, overfull boxes.

Plus `build/convert/<deck>/review.pdf`: one page per frame, the original slide (all steps as thumbnails, rendered once with `soffice`) next to the new frame's last step in light and dark. This is the review tool for batch runs: flip through one PDF instead of opening two decks.

## 6. Claude's Role — D-16, D-17

**Serves F-12, F-22, F-26, F-28, G-4.**

### 6.1 Who does what

| Step | Python | Claude |
|---|---|---|
| Parse, figure recognition, StarMath (known subset), images, tables | ✓ | |
| Sequence candidates and diffs | ✓ | |
| Layout, mode, sequence boundaries, illustration triage (TikZ family vs fallback) | proposal | **plan** call, 1 per deck |
| Text-only frames (L1–L4, L7, L10–L14 without figures) | ✓ templates | |
| Frames with a figure or a build sequence (L5, L6, L8, L9) | draft model + diff | **frame** call, 1 per frame |
| Unknown formula tokens, unmappable text | flag | inside the frame call |
| Compile, lint, content check, retry, fallback | ✓ | |
| Review notes (optional, COULD) | | **review** call, 1 per deck: compares `review.pdf` pages, adds notes to the report |

**Why Claude writes the figure frames instead of Python emitting TikZ:** Python already extracts exact geometry and states, so the hard part is solved; what remains is judgement: which text is a caption per step vs. persistent, which layout fits, how to merge 26 steps without clutter. The spike (§10 S-3) shows one call turning the extracted "Kruskal in Action" model (5 slides) into a correct L5 frame with overlays, for **$0.05 in 12 s**, compiling first time. A Python TikZ emitter would only move the work, not remove the judgement.

### 6.2 Prompts

In `tools/convert/prompts/`: `plan.md`, `frame.md`, `review.md`, plus `FIGURES.md` and the layout table of §3.4 included verbatim. Each prompt states the closed vocabulary (layouts, modes, styles, macros), the output format (JSON for plan, one LaTeX frame for frame) and the rules (no inline colours or sizes, Swiss German, keep all text). Prompt files are versioned with the repo; the report records their git hash.

### 6.3 Headless invocation

```sh
claude -p --model claude-sonnet-5-5 --tools "" --output-format json \
       --no-session-persistence --max-budget-usd 0.50 < prompt.txt
```

- **Account:** the teacher's logged-in `claude` CLI (Q-4). With a subscription login, `--max-budget-usd` and the reported cost are API-equivalent figures; the real limit is the plan's usage window, so a batch that hits it stops cleanly and resumes from the cache [check M4].
- **No tools** (`--tools ""`): Claude gets text in and gives text out; it cannot read or write the repo during a batch. Python writes all files. Slide images for the frame call (the original slide as PNG) are passed in the input as image blocks via `--input-format stream-json` [check M1].
- **Model:** Sonnet 5.5 for all calls (Q-4); configurable per call type in `tools/convert/convert.toml`.
- **Cache:** responses are cached in `build/convert/cache/` by hash of (prompt file + input). Re-running a deck after a Python fix costs nothing for unchanged frames.
- **Validation of a frame answer:** compiles alone in a one-frame test document, light and dark; passes the lint (no colour names, no `\definecolor`, no `line width=`/`\fontsize` in the deck, only known macros); overlay count = number of steps; **content check**: every word of the source text appears in the frame (catches dropped bullets). On failure: one retry with the error message; then fallback (§5.6) and a report item.

### 6.4 Limits and review of a batch run

- `batch.py <folder> --subject <slug> --jobs 3 --budget 2.00 --total-budget 60` (Q-4): per-call cap via `--max-budget-usd`, per-deck cap and batch cap enforced by Python (a deck over budget finishes with fallbacks, the batch stops starting new decks over the total).
- Estimated cost: 1 plan + ~15–25 frame calls per deck ≈ **$1 per deck, ~$80 for all 80 decks** [estimate from S-3; the $60 cap applies per batch run, so the full migration takes two runs].
- The batch runs on a branch `batch-<date>`, **one commit per deck** ("Convert algorithmik/graphs"), so each deck can be reviewed, fixed or dropped separately (Q-5). The teacher reviews with `review.pdf` + `CONVERSION.md`, fixes, and merges (F-28: review after, not during the run).
- A summary `build/convert/batch-<date>.md` lists all decks with frames, fallbacks, open items, cost and time.

## 7. Build — D-18 to D-20

**Serves F-30, F-31, F-33, N-04, N-05, N-07.**

### 7.1 Command

```sh
tools/build/build.py                          # all decks, default variants
tools/build/build.py algorithmik/euler_mst    # one deck (folder, or deck name if unique)
tools/build/build.py algorithmik              # one subject
tools/build/build.py -v dark …                # variants: light, dark, handout, all
tools/build/build.py --changed                # only decks whose deck folder, theme or images changed
tools/build/build.py --check                  # plus lint, contrast and overfull-box report
```

Default variants: **dark + light + handout** (Q-6): dark for presenting, light for a projector that washes dark slides out, handout cut from light; `-v dark` etc. restricts the run. Decks are built in parallel (one `latexmk` per deck and variant, `--jobs` = cores). Logs in `build/work/<subject>/<deck>/<variant>/`, PDFs in `build/out/<subject>/` (same pattern as the books' `tools/build/`, F-32 in spirit, without a dependency on it).

### 7.2 Finding the theme, editing in VS Code — D-23

`build.py` sets `TEXINPUTS=<repo>/theme//:<repo>/images//:` for every run, so a tagged checkout builds with its own theme.

For editing, the repo commits `.vscode/settings.json` with two **LaTeX Workshop** recipes (Q-13), both `latexmk` with the same `TEXINPUTS` in the tool's `env`: **«deck (dark)»**, the default that runs on save, and **«deck (light)»**. Aux files and the PDF go to `build/work/…` next to the build tool's output, so deck folders stay clean; the PDF viewer tab shows the dark build. Nothing is installed into `~/texmf`, so two checkouts (e.g. `main` and a semester tag) never see each other's theme (Q-7).

### 7.3 Variants

| Variant | How |
|---|---|
| presentation-light | `latexmk -pdf -jobname=<deck>-light` |
| presentation-dark | same with `-usepretex='\def\slidepalette{dark}'` |
| handout | **cut from the light PDF**: Beamer's `.nav` file lists the page range of every frame (`\beamer@framepages{a}{b}`); `pypdf` keeps page *b* of each frame (the last step) and deduplicates resources (§10 S-6) |

The handout costs no LaTeX run and always matches the presentation. Beamer's own `handout` mode is not used: it would show every `\only` caption of a build sequence at once unless each overlay carried a `handout:` spec.

### 7.4 Engine and build time — D-19

**pdfLaTeX.** The spike theme works with it unchanged; LuaLaTeX was 1.6× slower on the same deck (§10 S-5) and brings nothing the theme needs (Fira via the `FiraSans` package, T1 covers German). The books use pdfLaTeX too, so figures move between script and slide without engine issues.

Measured: 17 frames / 26 pages incl. six cover photos, 2.8 s per run. A 100-frame deck ≈ 2 runs × ~10 s ≈ **20 s per variant**; dark and light run in parallel, the handout is cut afterwards in < 1 s (N-04 ✓). All ~80 decks on 4 cores ≈ 15 min; daily use is `--changed` or the VS Code recipe.

## 8. Checks — D-21

**Serves N-02, N-03, AC-7, AC-8.**

- **Lint** (`tools/check/lint.py`, also run on every Claude frame): decks contain no colour names, `\definecolor`, `\color{…}` with a literal colour, `line width=`, `\fontsize`, `\setbeamer…`; every converted frame has `layout=`.
- **Contrast** (`tools/check/contrast.py`): the class writes the resolved RGB of every role to the log (`\extractcolorspec`); the script checks WCAG AA (4.5 : 1 text, 3 : 1 large text and figure strokes) for all subjects × both palettes.
- **Visual test**: `theme/test/catalogue.tex` builds every layout, mode, box and figure for every subject in both palettes; `build.py --check` renders an overview PNG per subject for a quick look after theme changes.
- **Overfull boxes** from the log are listed per frame.

## 9. Pilot Plan and Measurements — D-22

**Serves F-25, G-3, G-4, G-5, AC-1 to AC-9.**

| Step | Content | Exit criterion |
|---|---|---|
| **M0 Theme** | class split and cleanup (§3), figure styles incl. cells/cards/braces (§4), subjects table, catalogue test, **minimal build tool** (light, dark, handout), lint, contrast check | catalogue builds for all subjects in both palettes; contrast check green (AC-7 for the theme) |
| **M1 `euler_mst`** | converter: parse, text, images, graphs, sequences, plan + frame calls, fallback (Königsberg), report, `review.pdf` | AC-1, AC-3, AC-4, AC-7, AC-8 on `euler_mst` |
| **M2 `sorting_2025`** | cards (with `assets.toml`), cells/tables, formulas, long sequences (26 steps) | same ACs on `sorting` |
| **M3 Build & publish** | all decks, `--changed`, `--check`, VS Code recipes, `CLAUDE.md` of the repo | daily use |
| **M4 Batch** | `batch.py`, budgets, branch + commits, batch summary | AC-9 on ≥ 5 unseen decks chosen by the teacher (incl. one with code) |

Compared with `requirements.md` §13, the build command moves forward into M0 (the pilot needs presentation and handout for AC-1); M3 then only covers all-deck builds and polish.

**How G-4 (conversion ≤ 2 h teacher time) is measured:** the converter's machine time and Claude cost are in the report. The teacher's time is logged in `docs/pilot.md`, one line per working session: date, deck, activity (`review`, `fix`, `redraw`, `revision-A`, `revision-B`), minutes rounded to 5 (Q-10). The sum of `review` + `fix` + `redraw` until the teacher accepts the deck is the G-4 number. Measured separately for M1 and M2; the M2 number is the one that predicts the batch.

**How G-3 (revision ≤ 1.5× Impress) and G-5 (new figure ≤ 10 min) are measured:** a fixed revision task, defined before conversion in two equivalent sets A and B: (1) fix two typos and reword one bullet, (2) move one slide and delete one, (3) add a slide with a 5-node weighted graph and a 3-step highlight. The teacher does set A in Impress on a copy of the original `.odp` and set B on the converted deck (with Claude Code for the figure), logging each as a session line. Ratio total(B)/total(A) ≤ 1.5 → G-3; part (3) in B ≤ 10 min → G-5. Done about a week after M1, so the teacher is not still in conversion mode (AC-5).

## 10. Spikes

Throwaway scripts and artefacts in `spikes/design/` (see its `README.md`); findings recorded here.

| # | Question | Result |
|---|---|---|
| S-1 | Can graphs and their build-sequence states be extracted without Claude? | **Yes.** In `euler_mst`, 197/230 connectors are glued to nodes at the start, 224/230 at the end; unglued ends snap to the nearest node. All 8 weights of "Kruskal in Action" were assigned to the right edges (rotated text frames, `draw:transform`). Edge states are encoded in the stroke: 0.212 cm = chosen, 0.081 cm = normal, dashed = removed. The per-step diff of the 5-slide sequence came out as exactly one newly chosen edge per step. |
| S-2 | Can an unknown drawing be exported as a cropped vector PDF via `soffice`? | **Yes.** Strip a copy of the deck to one page with only the drawing's shapes, empty the master pages, set `Default-background`/`Mdp1` fills to none; `soffice --convert-to pdf` (≈ 1 s) + `pdfcrop` gave a transparent, cropped vector PDF of the Königsberg bridges. A colour map for light pages works by rewriting colour attributes before export. |
| S-3 | How well does headless Claude convert a graph build sequence? | **Well.** `claude -p --model sonnet --tools ""` with the S-1 model of slides 31–35, the theme's figure block and one example frame: one L5 frame with `onslide=<n->{chosen}` per step and step texts as `\only`, cleaned an extraction artefact (duplicated list text) by itself, compiled first time in the spike theme; $0.05, 12 s. |
| S-4 | Can StarMath be mapped to LaTeX reliably? | **For the subset in use, yes:** a 60-line translator converted all 5 formulas of `sorting_2025` (sums, `over`, `cdot`, quoted text). Unknown tokens are detectable. |
| S-5 | pdfLaTeX or LuaLaTeX, and build time? | Sample deck (17 frames, 26 pages, 6 photos): pdfLaTeX 2.8 s/run, LuaLaTeX 4.5 s/run, both without errors. |
| S-6 | Handout with only the last step of each sequence? | `.nav` gives the page range per frame; keeping the last page: 17 pages. `pdfseparate`/`pdfunite` triples the size (4.1 MB, duplicated fonts and images); `pypdf` (installed, 6.9.2) with `compress_identical_objects` keeps it at 1.2 MB. |

Also found: the playing-card PNGs in the `.odp` differ by hash from the copies in `spikes/books/pictures/cards/`, so the card mapping needs a small table (`assets.toml`) instead of automatic matching.

## 11. Next Step: Implementation

### 11.1 Visual design first — D-24

The look of the slides is agreed with the customer **before** the theme is built out (customer, sign-off 2026-10-17). `spikes/books/` is the starting point, but it has not yet been reviewed as a whole: the dark palette, every subject colour, and the figure families with the books' macros. M0-2 builds a proposal, and M0-3 is a review in rounds, the way the requirements and this design were agreed. Tasks M0-4 and later only start once the customer has signed off M0-3. Any change to the look is recorded in §3/§4 with a version bump.

### 11.2 M0 – Theme

| Task | Content | Done when |
|---|---|---|
| M0-1 | **Repo skeleton:** `git init` of `~/Teaching/slides` (§2); folders, `.gitignore` (`build/`), `docs/` with `requirements.md` and `design.md` moved from the idea folder, stub `CLAUDE.md`, `.vscode/settings.json` with the two recipes (§7.2). | First commit on `main`; a test file compiles in VS Code with the dark recipe |
| M0-2 | **Design proposal:** copy the spike theme into `theme/` unchanged (one `.sty`); add the figure families with the books' macro names and keys (§4: `\pythonArray`, `\cardArray`, `\cardSplit`, `\cardMerge`, graph styles incl. `removed`); write `theme/test/catalogue.tex` with every layout L1–L14, both modes, all boxes, code, and every figure family incl. one overlay sequence; add a title page plus one content page per subject (6 colours, including the Networks exception). Render light and dark, plus an overview PNG per palette. | Proposal PDFs and PNGs ready for review |
| M0-3 | **Design agreement (gate):** review with the customer in rounds of at most 5 points, each with a proposed default; adjust the proposal; record the decisions in §3/§4. Covers chrome, type sizes (N-02, R-1 to R-9 of `layout_review.md`), dark palette, subject colours, figure sizes and states, the mode bands. | Customer signs off the look |
| M0-4 | **Class split:** `infschoolslides.cls` with fixed beamer options and `\slidepalette` (default dark); `infschool-tokens.sty` (books' names), the two palette files, `infschool-subjects.sty` (§3.1 table, `\slidesubject`). | Catalogue builds from the class, unchanged from the agreed look |
| M0-5 | **Chrome and layouts:** header/footer bands, `\titleslide`, `\sectionslide[num]{title}[line]` (issues `\section`), the `layout=` key with its spacing (§3.4), `stepcaptions`, modes `doit=`/`read=`. | Every layout in the catalogue uses the new commands |
| M0-6 | **Boxes and code:** `concept`, `info`, `example`, `think`, `task`, `checklist`, `code` (Python; one other `listings` language as a test). | Catalogue pages for boxes and code in both palettes |
| M0-7 | **Figure styles:** `infschool-figures.sty` as agreed in M0-3, all sizes from tokens and all colours from roles; overlay helpers (`onslide`, `visible on`, `name=` keys); `theme/FIGURES.md` with one example per family. | A figure call copied from the Algorithmik script compiles unchanged on a slide |
| M0-8 | **Build tool:** `tools/build/build.py`: one deck, subject or all; variants dark, light, handout (cut via `.nav` + `pypdf`, §7.3); parallel; `--changed`; `TEXINPUTS`; output to `build/out/`. | `build.py theme/test` and a sample deck give three PDFs; the handout has one page per frame |
| M0-9 | **Checks:** `tools/check/lint.py` (N-03) and `contrast.py` (WCAG AA, all subjects × both palettes); `build.py --check`. | Contrast green for all 12 combinations, or each exception agreed in M0-3 |
| M0-10 | **Smoke test:** port `spikes/books/sorting.tex` to the final class as `subjects/algorithmik/sorting_sample/`. | Builds without warnings in all three variants; matches the agreed look |
| M0-11 | **Claude Code rules:** repo `CLAUDE.md` (language, Swiss conventions, design values only in the theme, build commands), `.claude/rules/figures.md` pointing to `FIGURES.md`. | A new 5-node graph frame made with Claude Code follows the styles without corrections (first G-5 check) |

### 11.3 Later milestones (outline)

- **M1 `euler_mst`:** `odpconv` parse, model and graph recognition (from S-1), sequences and diffs, StarMath, text frames, plan/frame prompts and the headless runner with cache and validation, `soffice` fallback (S-2), `CONVERSION.md` and `review.pdf`. Then the G-4 log, and about a week later the A/B revision task (G-3, G-5).
- **M2 `sorting_2025`:** card rows with `assets.toml`, cells and tables, long sequences, formulas; G-4 again.
- **M3 Build & publish:** all-deck builds, `--changed`/`--check` in daily use, `CLAUDE.md` finalised.
- **M4 Batch:** `batch.py` with budgets, branch and commits, batch summary; AC-9 on 5 unseen decks.

## 12. Decision Log

| ID | Decision | Options considered | Reason |
|---|---|---|---|
| D-01 | Own repo `inf_school_slides` at `~/Teaching/slides`; docs in `docs/` (customer, Q-1) | subfolder of the idea folder; inside the books repo | N-01; same pattern as the planning tool |
| D-02 | `subjects/<subject>/<deck>/<deck>.tex` + `img/` + `CONVERSION.md`; no year suffix; `.odp` not committed (customer, Q-1, Q-2) | flat `decks/`; one images folder per subject | deck = folder, easy to move and review; G-1 |
| D-03 | Theme as a class with fixed beamer options, split into tokens/palettes/subjects/chrome/text/boxes/code/figures | one `.sty` as in the spike | N-03 (no design options in decks); files match the §14 structure |
| D-04 | Palette via pre-defined `\slidepalette`, set by the build tool (`-usepretex`) and the VS Code recipes; class default dark (customer, Q-6) | class option only; two decks | N-08: one setting, no change to the source |
| D-05 | Layouts as plain Beamer + few commands; `layout=` frame key | one environment per layout | conventional Beamer (N-07); key makes AC-8 checkable |
| D-06 | `stepcaptions` environment for per-step captions | chains of `\only` | one line per step to edit (G-3), no jumping |
| D-07 | Subjects as a table in the theme, `\slidesubject{<slug>}`, colours copied from the books incl. the Networks exception | colour set in each deck | N-09: one line per deck, values in one place |
| D-08 | Books' figure names and keys on slides (`\pythonArray`, `\cardArray`, `\cardMerge`, `\cardSplit`, `graph`, `vertex_active`, …) plus slide-only keys/macros (`name=`, `done=`, `removed`, `\swaparrow`, `\pointerbelow`, `\stepdots`) (customer, Q-12) | own macro names (v0.1–v0.2) | G-2: figure calls move between script and slide unchanged |
| D-09 | `FIGURES.md` as single reference for sessions and prompts | separate prompt cheat sheet | one source, no drift |
| D-10 | JSON intermediate model with recognised figure families | direct XML → LaTeX | testable stages, resumable, readable by Claude |
| D-11 | Sequences by title or figure signature, diffs in Python, boundaries confirmed by Claude | title only; Claude only | S-1: diffs are exact from the XML |
| D-12 | Layout/mode: Python proposal + one plan call per deck | rules only; Claude per frame | modes need meaning ("Hands on!"); one call sees the deck context |
| D-13 | Rule-based StarMath translator, Claude for unknown tokens | Claude for all formulas | S-4: subset is tiny and regular |
| D-14 | Fallback: one stripped `.odp` per deck → `soffice` → `pdfcrop`, light + dark copies | screenshot PNG; crop of full slide PDF | S-2; vector, transparent, palette-aware (N-08) |
| D-15 | `CONVERSION.md` committed + `review.pdf` side by side | report only | fast review of batch output (F-28) |
| D-16 | Claude writes figure/sequence frames from the model; Python writes text frames (customer, Q-3) | Python TikZ emitter for everything | S-3: cheap and correct; judgement stays with Claude |
| D-17 | Headless `claude -p` without tools, logged-in CLI, Sonnet 5.5, caps $0.50/call, $2/deck, $60/batch; cached, validated, retry once, then fallback (customer, Q-4); batch on a branch, one commit per deck (Q-5) | Claude with file tools; Agent SDK | batch can't damage the repo; deterministic re-runs; always finishes |
| D-18 | `tools/build/build.py` around `latexmk`, parallel, `--changed`; default variants dark + light + handout (customer, Q-6) | Makefile; books' build tool | same style as the books; F-30 |
| D-19 | pdfLaTeX | LuaLaTeX | S-5: 1.6× faster; same as books |
| D-20 | Handout cut from the light PDF via `.nav` + `pypdf` | Beamer `handout` mode | S-6; no `handout:` specs in decks; always matches |
| D-21 | Lint, contrast and catalogue checks in `tools/check/` | manual review | N-02, N-03 measurable |
| D-22 | Build tool in M0; G-3/G-4 measured with a per-session time log (Q-10) and an A/B revision task | as in requirements §13 | AC-1 needs the build in M1 |
| D-23 | VS Code: committed LaTeX Workshop recipes (dark default, light) with `TEXINPUTS` in the recipe env (customer, Q-7) | link into `~/texmf` | no global install; tagged checkouts stay independent |
| D-24 | Visual design agreed with the customer (M0-3) before the theme is built out (customer, sign-off) | build the spike theme out directly | the spike look was never reviewed as a whole (dark palette, all subjects, figures) |

## 13. Open Questions

### Resolved

| # | Question | Answer |
|---|---|---|
| Q-1 | Repository | `inf_school_slides` at `~/Teaching/slides`; docs move to `docs/`; `.odp` originals not committed (archived, hash in the report). (customer, 2026-10-17) |
| Q-2 | Deck layout | `subjects/<subject>/<deck>/` with `img/` and `CONVERSION.md`; no year in the deck name. (customer) |
| Q-3 | Converter split | Python recognises and diffs; Claude writes figure and sequence frames plus one plan call per deck. (customer) |
| Q-4 | Claude account and budget | Logged-in `claude` CLI, Sonnet 5.5; caps $0.50 per call, $2 per deck, $60 per batch. (customer) |
| Q-5 | Batch review | Branch per batch, one commit per deck, review via `review.pdf` + `CONVERSION.md`, the teacher merges. (customer) |
| Q-6 | Default palette and variants | Presenting in **dark**: class default dark; `build.py` builds dark + light + handout by default. (customer, 2026-10-17) |
| Q-7 | Editing by hand | VS Code: committed LaTeX Workshop recipes, dark on save (§7.2). (customer) |
| Q-8 | Reading more of the books | Yes, read-only. Done: subject colours (§3.1), `graph.sty` and `python_array.sty` → books' names and keys on slides (§4). (customer) |
| Q-9 | Text normalisation | Yes: «…», ss, hidden slides as hidden frames, notes dropped, all counted in the report (§5.7). (customer) |
| Q-10 | Pilot time log | One line per working session in `docs/pilot.md`: date, deck, activity, minutes (§9). (customer) |
| Q-11 | Digitale Daten colour | Blue: the script sets `RoyalBlue` in its `main.tex`; v0.3 had missed it. No two subjects share a colour. (customer) |
| Q-12 | Books' figure macros on slides | Yes (§4, D-08). (customer) |
| Q-13 | VS Code extension | LaTeX Workshop (§7.2). (customer) |

### Open

None. The remaining **[check]** items are verifications during implementation.

## Changelog

- **v1.0 (2026-10-17):** Signed off. Added §11 "Next step: implementation": a visual design agreement as a gate in M0 (D-24, M0-2/M0-3), M0 broken into tasks M0-1 to M0-11, outline of M1–M4.
- **v0.4 (2026-10-17):** Round 3: per-session time log (Q-10, §9); Digitale Daten is `RoyalBlue`, set in its `main.tex` (Q-11, §3.1); books' figure macros confirmed (Q-12); LaTeX Workshop (Q-13). Technical verification items marked **[check]** with their milestone. No open questions.
- **v0.3 (2026-10-17):** Round 2: dark is the presenting palette and class default; default build dark + light + handout (Q-6, D-04, D-18). VS Code recipes instead of a `~/texmf` link (Q-7, D-23). Read the books' colours and figure styles (Q-8): subject colour table incl. the Networks exception (§3.1), books' figure names and keys on slides (§4, D-08). Text normalisation confirmed (Q-9). Round 3: Q-10 (time log, clarified) to Q-13.
- **v0.2 (2026-10-17):** Round 1: all defaults accepted (Q-1 to Q-5). Repo, deck layout, converter split, Claude account and caps, batch review fixed (D-01, D-02, D-16, D-17); note on cost caps with a subscription login (§6.3). Round 2 questions Q-6 to Q-10.
- **v0.1 (2026-10-17):** First draft. Repo layout, class split with tokens/palettes/subjects, `layout=` key and `stepcaptions`, figure macros, converter pipeline with JSON model, Claude plan/frame calls (headless, no tools, cached), `soffice` vector fallback in light and dark, report + `review.pdf`, build tool with handout cut from the light PDF, pdfLaTeX, checks, pilot plan with G-3/G-4 measurement. Spikes S-1 to S-6. Round 1 questions Q-1 to Q-5.
