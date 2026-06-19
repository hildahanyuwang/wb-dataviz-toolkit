"""
coefficient_plot.py — DIME-signature impact-evaluation charts (Python driver)
-----------------------------------------------------------------------------
The two chart types that signal a credible impact evaluation:

  1. Coefficient plot  — each treatment's point estimate with its 95% CI, and a
                         zero reference line so "significant vs not" reads instantly.
  2. Event study       — the effect over time relative to the program, with a
                         confidence band and a flat pre-trend before t = 0.

Like the rest of the toolkit, this is a thin DRIVER: all house style lives in
the reusable `dime_style` module, and the numbers live in CSVs, so pointing it
at different estimates regenerates the same on-brand charts.

    python coefficient_plot.py        # uses ../data/ie_coefficients.csv + ../data/ie_eventstudy.csv

The bundled data is an ILLUSTRATIVE example, not real evaluation results.
Sample work — not an official World Bank publication.
"""

import os
import pandas as pd
import matplotlib.pyplot as plt

from dime_style import apply_dime_style, add_source_note, PALETTE

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "data")
OUTPUT_DIR = os.path.join(HERE, "output")

ILLUSTRATIVE_NOTE = (
    "Illustrative example, not real evaluation results. Built to DIME Analytics conventions.\n"
    "Sample — not an official World Bank publication."
)


def coefficient_plot(df, output_dir):
    """Dot-and-whisker plot: point estimate + 95% CI per intervention, zero line."""
    d = df.sort_values("estimate").reset_index(drop=True)
    y = range(len(d))

    fig, ax = plt.subplots(figsize=(9, 4.8))
    for i, row in d.iterrows():
        # A CI that clears zero is "significant" -> emphasize in Oxford/Electric.
        sig = row["ci_low"] > 0
        line_c = PALETTE["oxford"] if sig else PALETTE["text_grey"]
        dot_c = PALETTE["electric"] if sig else PALETTE["text_grey"]
        ax.plot([row["ci_low"], row["ci_high"]], [i, i], color=line_c, lw=2.2, zorder=2)
        ax.plot(row["estimate"], i, "o", color=dot_c, ms=9, zorder=3)

    ax.axvline(0, color=PALETTE["mid"], lw=1.1, ls="--", zorder=1)  # zero reference
    ax.set_yticks(list(y))
    ax.set_yticklabels(d["intervention"], fontsize=11)
    ax.set_xlabel("Effect size (std. dev.)", fontsize=10, color=PALETTE["text_grey"])
    for side in ("top", "right", "left"):
        ax.spines[side].set_visible(False)
    ax.tick_params(axis="y", length=0)
    ax.set_title("Coefficient plot: estimated effect with 95% CI",
                 fontsize=14, fontweight="bold", loc="left", pad=14)

    fig.subplots_adjust(left=0.28, right=0.96, top=0.86, bottom=0.16)
    add_source_note(fig, ILLUSTRATIVE_NOTE)
    out = os.path.join(output_dir, "coefficient_plot.png")
    fig.savefig(out, dpi=300)
    plt.close(fig)
    return out


def event_study(df, output_dir):
    """Effect over time relative to the program, with a 95% band and pre-trend."""
    d = df.sort_values("period")
    t = d["period"].to_numpy()
    coef = d["coef"].to_numpy()
    lo = coef - 1.96 * d["se"].to_numpy()
    hi = coef + 1.96 * d["se"].to_numpy()

    fig, ax = plt.subplots(figsize=(9, 4.8))
    ax.fill_between(t, lo, hi, color=PALETTE["electric"], alpha=0.16, zorder=1)
    ax.plot(t, coef, "-", color=PALETTE["electric"], lw=2, zorder=2)
    ax.plot(t, coef, "o", color=PALETTE["oxford"], ms=5, zorder=3)
    ax.axvline(0, color=PALETTE["mid"], lw=1.1, ls="--")   # program start
    ax.axhline(0, color=PALETTE["text_grey"], lw=1)

    ax.set_xlabel("Quarters relative to program start", fontsize=10, color=PALETTE["text_grey"])
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    ax.set_title("Event study: effect over time, with a pre-trend check before t = 0",
                 fontsize=14, fontweight="bold", loc="left", pad=14)

    fig.subplots_adjust(left=0.10, right=0.96, top=0.86, bottom=0.16)
    add_source_note(fig, ILLUSTRATIVE_NOTE)
    out = os.path.join(output_dir, "event_study.png")
    fig.savefig(out, dpi=300)
    plt.close(fig)
    return out


def main():
    apply_dime_style()
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    coefs = pd.read_csv(os.path.join(DATA, "ie_coefficients.csv"))
    events = pd.read_csv(os.path.join(DATA, "ie_eventstudy.csv"))
    produced = [coefficient_plot(coefs, OUTPUT_DIR), event_study(events, OUTPUT_DIR)]
    print("Charts written:")
    for p in produced:
        print("  -", os.path.relpath(p, HERE))


if __name__ == "__main__":
    main()
