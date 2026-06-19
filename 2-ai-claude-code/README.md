# Workflow 2 — Reusable content-production studio (AI-assisted)

A **repeatable studio** for producing on-brand knowledge products — infographics, social
cards, newsletters — from new data, fast. It is a system to use on the job: the
[`wb.css`](./wb.css) design system + **parameterized HTML templates** + the
[`render.ps1`](./render.ps1) render step together turn verified numbers into
publication-ready PNG/PDF assets that drop straight into the site.

This is **not** "ask an AI to make a poster." It is a disciplined production line where the
design system and templates are fixed assets, the human verifies every figure, and producing
next quarter's product is a matter of updating a small data block and re-rendering.

![Pipeline](./pipeline.png)

## SOP — to produce next quarter's product

1. **Copy the closest template.** Pick the one whose layout matches the deliverable
   (infographic, social card, newsletter, chart sheet, product grid) from `templates/`.
2. **Update ONLY the data block.** Every template keeps its numbers and copy near the top of
   the file (see the map below), so a non-coder teammate can change figures without touching
   layout or CSS.
3. **Render.** Run `render.ps1` to produce a high-resolution PNG (and PDF for print/zip
   submission) at exact dimensions — no manual export, fully repeatable.
4. **Ship.** Drop the PNG/PDF into the deliverable and the rendered asset into the site;
   because templates use the same tokens as the live website, nothing looks bolted on.

```powershell
# Windows, with Edge or Chrome installed
.\render.ps1 templates\01_leads_hero 1080 1440
.\render.ps1 templates\03_linkedin_card 1200 1200
```

Change a palette or type token in `wb.css` once and it propagates across every product.

## Where each template's data block lives

A teammate updating figures only needs to find the numbers near the top of the body — layout
and CSS below can be left alone.

| Template | Dimensions | Data block to edit |
|---|---|---|
| [`01_leads_hero.html`](./templates/01_leads_hero.html) | 1080×1440 | KPI row (`.kpis`) and the three `.bar` rows (each `width:%` + `$XX.XB` label); evidence `.card` figures |
| [`02_report_charts.html`](./templates/02_report_charts.html) | 1080×1440 | waffle `<span class="on">` count (=%), the two `.cmp .row` percentages, the four `.strip .k` KPIs |
| [`03_linkedin_card.html`](./templates/03_linkedin_card.html) | 1200×1200 | the three `.line` figures (`<5%`, `<1%`, `+50%`) and their captions |
| [`04_newsletter.html`](./templates/04_newsletter.html) | 1080×1100 | masthead date, lead story copy, the dated `.item` entries under each section |
| [`05_dime_ai.html`](./templates/05_dime_ai.html) | 1080×960 | the two header `.tags` figures and each product `.p` (name, year, `.stat`) |

## Verification SOP (job-critical)

Before anything ships, every figure is checked. This is the discipline that makes the output
trustworthy, not just fast:

- **Every figure is tagged to a public source** before publishing — see
  [`../data/DATA_SOURCES.md`](../data/DATA_SOURCES.md), which records the URL and confidence
  for each number used.
- **Single-source figures are flagged**, not presented as settled fact (e.g. the aggregate
  LEADS efficiency-gains figure is marked single-source).
- **Nothing unverifiable ships.** Real example: an earlier brief assumed a newsletter called
  *"Ideas for Impact"* with an *Explore / Engage / Exchange* structure. Neither the name nor
  the structure could be confirmed in any official source, so both were **dropped** in favor
  of the real **"Development Impact Evaluation News"** and its real remit (events, conferences,
  courses, and high-quality data & research). The sample newsletter uses only what is verified.

## What's in here

```
2-ai-claude-code/
├── README.md
├── pipeline.html / pipeline.png   # the diagram above (itself built with this studio)
├── wb.css                         # the shared design system (the reusable asset)
├── render.ps1                     # HTML -> high-res PNG via headless Edge/Chrome
└── templates/                     # parameterized source HTML for each product type
    ├── 01_leads_hero.html         # LEADS flagship infographic
    ├── 02_report_charts.html      # report-style chart sheet (waffle / bars / KPIs)
    ├── 03_linkedin_card.html      # social card
    ├── 04_newsletter.html         # DIME newsletter issue
    └── 05_dime_ai.html            # DIME AI product grid
```

`wb.css` encodes the house style once: the official WB blues (`#002244`, `#009FDA`, `#006C99`),
a sparing gold accent, an Inter (Andes-substitute) type scale, and components that bake in DIME
chart rules (direct labels, zero baselines, no redundant gridlines, a mandatory source note).

## Why this fits the role

KM & communications work is a stream of audience-specific products under deadline. This studio
lets one person hold the **rigor** of a research team (every figure traced to a source, nothing
unverifiable shipped) and the **throughput + design range** of a studio — turning new data into
on-brand products in minutes, with a teammate able to refresh the figures unaided.

> All outputs are **sample work — not official World Bank publications.** No WB logo is used.
