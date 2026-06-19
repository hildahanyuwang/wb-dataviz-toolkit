# leads_charts.R — DIME-style chart suite (R driver)
# -------------------------------------------------------------------
# A thin DRIVER. All house style lives in the reusable theme_dime.R, so
# this file just: load a CSV, build the chart, write the PNG. Point it at
# a different CSV and the same styled chart regenerates.
#
# Run:  Rscript leads_charts.R                  (from the R/ directory)
#       Rscript leads_charts.R other.csv        (any tidy CSV, same columns)
#
# Requires: ggplot2, dplyr, readr.
# Sample work — not an official World Bank publication.

library(readr)
library(dplyr)

# Source the reusable house-style asset (palette + theme_dime + dime_barh).
source("theme_dime.R")

args <- commandArgs(trailingOnly = TRUE)
data_path <- if (length(args) >= 1) args[[1]] else file.path("..", "data", "leads_workshops.csv")
dir.create("output", showWarnings = FALSE)

# --- Read tidy CSV; keep only workshops with published financing ---
workshops <- read_csv(data_path, show_col_types = FALSE) %>%
  filter(!is.na(financing_usd_bn)) %>%
  mutate(label_full = paste0(workshop, " (", city, ", ", year, ")"))

# --- Build the chart from the reusable helper ----------------------
p <- dime_barh(
  workshops,
  label_col = "label_full",
  value_col = "financing_usd_bn",
  title     = "LEADS regional workshops mobilized billions in financing",
  subtitle  = "Development financing discussed, by workshop (US$ billions)",
  value_fmt = "$%.1fB"
)

# --- Export publication-ready PNG (300 dpi) ------------------------
ggsave(
  filename = file.path("output", "leads_financing.png"),
  plot = p, width = 9, height = 4.8, dpi = 300, bg = "white"
)

message("Wrote output/leads_financing.png")
