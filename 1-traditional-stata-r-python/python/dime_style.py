"""
dime_style.py — reusable World Bank / DIME matplotlib house style
-----------------------------------------------------------------
Drop-in styling so EVERY future chart inherits the DIME look in one line.

    from dime_style import apply_dime_style, dime_barh, add_source_note, PALETTE

    apply_dime_style()                 # set global rcParams once
    fig, ax = dime_barh(df, "label", "value", title="...", subtitle="...")
    add_source_note(fig)
    fig.savefig("out.png", dpi=300)

DIME Analytics chart conventions baked in here so they never have to be
re-typed per chart:
  * Direct data labels on bars   -> no legend needed
  * Value axis starts at ZERO    -> honest, comparable bar lengths
  * No redundant gridlines        -> minimal chart junk
  * Largest bar emphasized in Oxford Blue, the rest in Mid Blue
  * Mandatory source note on every figure
  * Clean sans-serif type, white surface, top/right spines removed

This file is the reusable ASSET. Swap the input data and the same style
applies automatically — that is what keeps every chart on-brand over time.

Sample work — not an official World Bank publication.
"""

import matplotlib

# Non-interactive backend: render straight to file, never open a window.
matplotlib.use("Agg")

import matplotlib.pyplot as plt
import matplotlib.font_manager as fm

# --------------------------------------------------------------------------
# World Bank / DIME house palette (exact hexes) — the single source of truth.
# --------------------------------------------------------------------------
PALETTE = {
    "oxford": "#002244",   # primary (largest bar, titles, text)
    "electric": "#009FDA",  # accent / highlight
    "mid": "#006C99",       # secondary bars
    "gold": "#FDB714",      # sparing accent only
    "surface": "#F7F9FA",   # surface / empty waffle cells
    "text_grey": "#5A5A5A",  # source notes
}

# Convenience module-level constants (so callers can `from dime_style import WB_OXFORD`).
WB_OXFORD = PALETTE["oxford"]
WB_ELECTRIC = PALETTE["electric"]
WB_MID = PALETTE["mid"]
WB_GOLD = PALETTE["gold"]
WB_SURFACE = PALETTE["surface"]
WB_TEXT_GREY = PALETTE["text_grey"]

SOURCE_NOTE = (
    "Source: World Bank Development Impact (DECDI), worldbank.org\n"
    "Sample — not an official World Bank publication."
)

SANS_CANDIDATES = ["Inter", "Segoe UI", "Arial", "Helvetica Neue", "Helvetica", "DejaVu Sans"]


def apply_dime_style():
    """Set global rcParams to the DIME house style. Call once per session."""
    available = {f.name for f in fm.fontManager.ttflist}
    plt.rcParams["font.family"] = "sans-serif"
    plt.rcParams["font.sans-serif"] = [f for f in SANS_CANDIDATES if f in available] or ["DejaVu Sans"]
    plt.rcParams["axes.edgecolor"] = PALETTE["text_grey"]
    plt.rcParams["text.color"] = PALETTE["oxford"]
    plt.rcParams["axes.titlecolor"] = PALETTE["oxford"]
    plt.rcParams["figure.facecolor"] = "white"
    plt.rcParams["axes.facecolor"] = "white"
    plt.rcParams["savefig.facecolor"] = "white"
    plt.rcParams["axes.grid"] = False


def add_source_note(fig, note=SOURCE_NOTE):
    """DIME convention: every figure carries an explicit source + disclaimer."""
    fig.text(
        0.01, 0.01, note,
        ha="left", va="bottom", fontsize=8, color=PALETTE["text_grey"],
    )


def dime_barh(df, label_col, value_col, title="", subtitle="",
              value_fmt="${:.1f}B", figsize=(9, 4.8), emphasis="max"):
    """
    Reusable DIME-style horizontal bar chart.

    Parameters
    ----------
    df         : DataFrame already filtered to the rows to plot.
    label_col  : column with the category label (string).
    value_col  : column with the numeric value.
    title      : bold Oxford-Blue headline (loc='left').
    subtitle   : grey descriptor under the title.
    value_fmt  : format string for the direct data label, e.g. "${:.1f}B".
    emphasis   : "max" highlights the largest bar in Oxford Blue; pass None for
                 all-Mid-Blue bars.

    Returns (fig, ax). Caller adds the source note and saves.
    """
    data = df.sort_values(value_col, ascending=True)
    labels = data[label_col].tolist()
    values = data[value_col].to_numpy()
    max_val = values.max()

    if emphasis == "max":
        colors = [PALETTE["oxford"] if v == max_val else PALETTE["mid"] for v in values]
    else:
        colors = [PALETTE["mid"]] * len(values)

    fig, ax = plt.subplots(figsize=figsize)
    bars = ax.barh(labels, values, color=colors, height=0.62)

    # Direct data labels on bars -> no legend required (DIME convention).
    for bar, v in zip(bars, values):
        ax.text(
            bar.get_width() + max_val * 0.015,
            bar.get_y() + bar.get_height() / 2,
            value_fmt.format(v),
            va="center", ha="left", fontsize=11, fontweight="bold",
            color=PALETTE["oxford"],
        )

    # Value axis starts at ZERO (honest bar lengths).
    ax.set_xlim(0, max_val * 1.18)

    # No redundant gridlines + strip chart junk.
    ax.grid(False)
    for side in ("top", "right", "bottom"):
        ax.spines[side].set_visible(False)
    ax.spines["left"].set_color(PALETTE["text_grey"])
    ax.set_xticks([])
    ax.tick_params(axis="y", length=0, labelsize=10.5)

    if title:
        ax.set_title(title, fontsize=14, fontweight="bold", pad=34, loc="left")
    if subtitle:
        ax.text(0, 1.035, subtitle, transform=ax.transAxes,
                fontsize=10.5, color=PALETTE["text_grey"])

    fig.subplots_adjust(left=0.30, right=0.97, top=0.80, bottom=0.14)
    return fig, ax
