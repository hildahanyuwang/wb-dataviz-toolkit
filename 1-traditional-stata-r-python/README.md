# Workflow 1 — Reusable DIME house-style charting toolkit (Stata / R / Python)

A **reusable charting toolkit** for producing publication-ready, DIME-styled figures from
any tidy dataset — in whichever of the analyst languages a team works in: **Stata, R, or
Python**. This is a system to use on the job, not a one-off demo: the house style is encoded
once in **theme files**, so every future chart inherits it automatically and stays on-brand.

The worked example uses verified figures from the World Bank's **LEADS** regional leadership
workshops and **DIME** scale indicators, but the point is the workflow underneath: swap the
CSV, run the script, get a styled chart suite.

> All figures here are **sample work — not official World Bank publications.**
> No World Bank logo is used.

---

## Standard operating procedure

On the job, producing a new chart is three steps:

1. **Drop a new dataset in `data/`** — a tidy CSV, one row per observation, one column per
   variable. (The shipped example: `data/leads_workshops.csv`, `data/dime_scale.csv`.)
2. **Run the driver script in your language of choice** — Python, R, or Stata. Each driver
   is thin: it loads the CSV and calls the shared house-style helper.
3. **Collect publication-ready, DIME-styled charts in `output/`** — 300-dpi PNGs, on-brand,
   with the mandatory source note already attached.

To regenerate the suite for next quarter, replace the CSV (or pass a new path) and re-run.
Nothing about the styling needs to be touched.

## The reusable asset: the THEME files

The thing that makes this a toolkit rather than a script is that **the house style is encoded
once** and imported everywhere. These are the assets that keep every future chart on-brand:

| Language | Theme file | What it provides |
|---|---|---|
| Python | [`python/dime_style.py`](./python/dime_style.py) | `PALETTE` constants · `apply_dime_style()` · `dime_barh(df, label, value, …)` · `add_source_note()` |
| R | [`R/theme_dime.R`](./R/theme_dime.R) | `wb` color vector · `theme_dime()` ggplot2 theme · `dime_barh(df, …)` helper |
| Stata | [`stata/dime_scheme.do`](./stata/dime_scheme.do) | reusable `dime_hbar` program (palette + DIME conventions encoded once) |

Each driver (`leads_charts.*`) imports/sources its theme file and is just a few lines: load,
call helper, save. Change a palette hex or a chart rule in the theme file and it propagates to
every chart that uses it — the same discipline as Workflow 2's `wb.css`.

## Project layout

```
1-traditional-stata-r-python/
├── data/
│   ├── leads_workshops.csv      # one row per LEADS workshop (the input you swap)
│   ├── dime_scale.csv           # tidy DIME scale KPIs
│   ├── ie_coefficients.csv      # illustrative treatment estimates + 95% CIs
│   └── ie_eventstudy.csv        # illustrative event-study coefficients + SEs
├── python/
│   ├── dime_style.py            # REUSABLE house-style theme (palette + helpers)
│   ├── leads_charts.py          # thin driver: load CSV -> dime_barh -> PNG
│   ├── coefficient_plot.py      # thin driver: coefficient plot + event study
│   ├── requirements.txt
│   └── output/                  # PNGs (generated)
├── R/
│   ├── theme_dime.R             # REUSABLE theme_dime() + dime_barh()
│   ├── leads_charts.R           # thin driver, sources theme_dime.R
│   ├── coefficient_plot.R       # coefficient plot + event study (sources theme_dime.R)
│   └── output/                  # PNG (generated)
├── stata/
│   ├── dime_scheme.do           # REUSABLE dime_hbar program
│   ├── leads_charts.do          # thin driver, runs dime_scheme.do then calls dime_hbar
│   └── coefficient_plot.do      # coefficient plot + event study
└── README.md
```

---

## DIME house style (encoded in every theme file)

Every chart follows the same rules across all three languages, because the rules live in the
theme file, not the driver:

- **Direct data labels on bars** — values printed at each bar end, so **no legend** is needed.
- **Value axis starts at ZERO** — bar lengths are honest and comparable.
- **No redundant gridlines** — minimal chart junk; the data label carries the precision.
- **Emphasis through color** — the largest bar is **Oxford Blue**, others sit in **Mid Blue**;
  gold / electric blue are used sparingly for highlights.
- **Mandatory source note** on every chart —
  `Source: World Bank Development Impact (DECDI), worldbank.org` plus the sample disclaimer.
- **Clean sans-serif** type (Inter / system sans), white plot surface, top/right spines removed.

**World Bank / DIME palette**

| Role | Color | Hex |
|------|-------|-----|
| Primary (largest bar, text) | Oxford / Solid Blue | `#002244` |
| Accent | Electric / Bright Blue | `#009FDA` |
| Secondary bars | Mid Blue | `#006C99` |
| Sparing highlight | Gold | `#FDB714` |
| Surface | Surface Grey | `#F7F9FA` |

---

## Charts the example produces

- **`leads_financing.png`** — horizontal bar chart of development financing discussed at each
  LEADS workshop (Python, R, and Stata each reproduce this from the same CSV via the helper).
- **`coverage_gap.png`** (Python) — a 100-square waffle showing that *fewer than 5% of World
  Bank projects include an impact evaluation*.
- **`coefficient_plot.png`** and **`event_study.png`** — the two chart types that signal a
  credible impact evaluation: a **coefficient plot** (point estimate + 95% CI per treatment, with
  a zero reference line) and an **event study** (effect over time, with a confidence band and a
  flat pre-trend before t = 0). Reproduced in Python, R, and Stata from `data/ie_coefficients.csv`
  and `data/ie_eventstudy.csv`. The bundled numbers are an illustrative example, not real results.

---

## How to run

### Python (matplotlib + pandas)

```bash
cd python
pip install -r requirements.txt
python leads_charts.py                    # uses ../data/leads_workshops.csv
python leads_charts.py path/to/other.csv  # any tidy CSV with the same columns
python coefficient_plot.py                # coefficient plot + event study
# -> output/leads_financing.png, output/coverage_gap.png, output/coefficient_plot.png, output/event_study.png
```

The toolkit uses the non-interactive `Agg` backend, so it renders straight to PNG with no
display required. `leads_charts.py` imports the reusable style from `dime_style.py`.

### R (ggplot2)

```bash
cd R
Rscript leads_charts.R                    # uses ../data/leads_workshops.csv
Rscript leads_charts.R other.csv          # any tidy CSV with the same columns
Rscript coefficient_plot.R                # coefficient plot + event study
# -> output/leads_financing.png, output/coefficient_plot.png, output/event_study.png
```
`leads_charts.R` sources `theme_dime.R`. Requires `ggplot2`, `dplyr`, `readr`.

### Stata

```stata
cd stata
do leads_charts.do
do coefficient_plot.do
* -> stata/leads_financing.png, stata/coefficient_plot.png, stata/event_study.png
```
`leads_charts.do` runs `dime_scheme.do` (which defines `dime_hbar`) then calls it. Base Stata
only — no community add-ons required.

---

## Data sources & caveats

All numbers are drawn from World Bank (worldbank.org) public materials on the LEADS programme
and DIME. Where a field was **not published** it is left blank in the CSV and excluded from
the relevant chart (e.g. Tokyo has no financing bar). No values are imputed or invented.

- **AFE — Cape Town, 2024:** US$12.8B financing, 250 leaders, 16 countries, 33 projects.
- **India — New Delhi, 2025:** US$9.7B financing, 6 flagship programs (leader/country counts
  not published).
- **AFW — Lomé, 2025:** US$5.3B financing, 200+ leaders, 11 countries, 20 investments.
- **Tokyo, 2026:** first East Asia convening (with JICA & ADB); no financing figure published.

DIME scale indicators (`dime_scale.csv`): 60+ countries, 200+ impact evaluations, US$26B
development finance shaped, 30+ agencies advised; fewer than 5% of World Bank projects include
an impact evaluation; investing <1% of project cost in research design can increase impact by
>50%.

> Sample — not an official World Bank publication.
