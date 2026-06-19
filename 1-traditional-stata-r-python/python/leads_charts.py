"""
leads_charts.py — DIME-style chart suite (Python driver)
--------------------------------------------------------
A thin, function-based DRIVER. All house style lives in the reusable
`dime_style` module, so this file just: loads a CSV, builds the chart suite,
and writes PNGs. Point it at a different CSV and the same styled suite
regenerates — that is the on-the-job workflow.

    python leads_charts.py                      # uses ../data/leads_workshops.csv
    python leads_charts.py path/to/other.csv    # any tidy CSV with the same columns

Sample work — not an official World Bank publication.
"""

import os
import sys
import pandas as pd

from dime_style import (
    apply_dime_style, add_source_note, dime_barh, PALETTE,
)
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_DATA = os.path.join(HERE, "..", "data", "leads_workshops.csv")
OUTPUT_DIR = os.path.join(HERE, "output")


def load_workshops(path):
    """Read the tidy LEADS workshop CSV; blanks parse as NaN."""
    return pd.read_csv(path)


def chart_financing(df, output_dir):
    """
    (a) Horizontal bar chart: financing by workshop — built entirely from the
    reusable dime_barh() helper, so it inherits the house style automatically.
    """
    fin = df.dropna(subset=["financing_usd_bn"]).copy()
    fin["label_full"] = (
        fin["workshop"] + " (" + fin["city"] + ", "
        + fin["year"].astype(int).astype(str) + ")"
    )

    fig, _ = dime_barh(
        fin, "label_full", "financing_usd_bn",
        title="LEADS regional workshops mobilized billions in financing",
        subtitle="Development financing discussed, by workshop (US$ billions)",
        value_fmt="${:.1f}B",
    )
    add_source_note(fig)

    out = os.path.join(output_dir, "leads_financing.png")
    fig.savefig(out, dpi=300)
    plt.close(fig)
    return out


def chart_coverage_gap(output_dir, highlighted=5):
    """
    (b) "Coverage gap" waffle for the <5% stat: fewer than 5% of World Bank
    projects include an impact evaluation. A 100-square waffle reads the gap
    instantly; the highlighted squares use Electric Blue, the rest surface grey.
    """
    n_cols, n_rows = 20, 5  # 100 squares = 100% of projects

    fig, ax = plt.subplots(figsize=(9, 4.2))
    cell, gap = 1.0, 0.18
    idx = 0
    for r in range(n_rows):
        for c in range(n_cols):
            on = idx < highlighted
            color = PALETTE["electric"] if on else PALETTE["surface"]
            edge = PALETTE["electric"] if on else "#E3E8EB"
            ax.add_patch(plt.Rectangle(
                (c * (cell + gap), (n_rows - 1 - r) * (cell + gap)),
                cell, cell, facecolor=color, edgecolor=edge, linewidth=0.6,
            ))
            idx += 1

    ax.set_xlim(-0.5, n_cols * (cell + gap))
    ax.set_ylim(-0.5, n_rows * (cell + gap))
    ax.set_aspect("equal")
    ax.axis("off")  # no axes/gridlines for an icon-style visual

    ax.set_title(
        "Fewer than 5% of World Bank projects include an impact evaluation",
        fontsize=14, fontweight="bold", pad=16, loc="left",
    )
    # Direct annotation instead of a legend (DIME convention).
    ax.text(
        0, -0.04,
        "Each square = 1% of projects.  ■ With impact evaluation (<5%)",
        transform=ax.transAxes, fontsize=10, color=PALETTE["electric"],
        fontweight="bold",
    )

    fig.subplots_adjust(left=0.04, right=0.96, top=0.82, bottom=0.16)
    add_source_note(fig)

    out = os.path.join(output_dir, "coverage_gap.png")
    fig.savefig(out, dpi=300)
    plt.close(fig)
    return out


def build_suite(data_path=DEFAULT_DATA, output_dir=OUTPUT_DIR):
    """Regenerate the full chart suite from a given CSV. Returns output paths."""
    apply_dime_style()                       # house style, once
    os.makedirs(output_dir, exist_ok=True)
    df = load_workshops(data_path)
    return [
        chart_financing(df, output_dir),
        chart_coverage_gap(output_dir),
    ]


def main():
    data_path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_DATA
    produced = build_suite(data_path=data_path)
    print("Charts written:")
    for p in produced:
        print("  -", os.path.relpath(p, HERE))


if __name__ == "__main__":
    main()
