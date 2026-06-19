# coefficient_plot.R — DIME-signature impact-evaluation charts (R driver)
# -------------------------------------------------------------------
# The two chart types that signal a credible impact evaluation:
#   1. Coefficient plot — point estimate + 95% CI per treatment, zero line.
#   2. Event study      — effect over time vs the program, with a CI band
#                         and a flat pre-trend before t = 0.
#
# A thin DRIVER: the house palette and theme live in theme_dime.R, the
# numbers live in CSVs. Point it at different estimates and the same
# on-brand charts regenerate.
#
# Run:  Rscript coefficient_plot.R        (from the R/ directory)
# Requires: ggplot2, dplyr, readr.
#
# The bundled data is an ILLUSTRATIVE example, not real evaluation results.
# Sample work — not an official World Bank publication.

library(readr)
library(dplyr)
library(ggplot2)

# Reusable house-style asset: wb palette + theme_dime().
source("theme_dime.R")

dir.create("output", showWarnings = FALSE)

illustrative <- paste(
  "Illustrative example, not real evaluation results. Built to DIME Analytics conventions.",
  "Sample — not an official World Bank publication.",
  sep = "\n"
)

# --- 1. Coefficient plot -------------------------------------------
coefs <- read_csv(file.path("..", "data", "ie_coefficients.csv"), show_col_types = FALSE) %>%
  mutate(
    sig = ci_low > 0,                              # CI clears zero -> emphasize
    intervention = reorder(intervention, estimate)  # largest on top
  )

p1 <- ggplot(coefs, aes(x = estimate, y = intervention, color = sig)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = wb[["mid"]]) +
  geom_errorbarh(aes(xmin = ci_low, xmax = ci_high), height = 0, linewidth = 0.9) +
  geom_point(size = 3.4) +
  scale_color_manual(
    values = c(`TRUE` = wb[["electric"]], `FALSE` = wb[["text"]]), guide = "none"
  ) +
  labs(
    title = "Coefficient plot: estimated effect with 95% CI",
    x = "Effect size (std. dev.)", y = NULL, caption = illustrative
  ) +
  theme_dime() +
  theme(
    axis.text.x  = element_text(color = wb[["oxford"]], size = 10),
    axis.ticks.x = element_line(color = wb[["text"]]),
    axis.title.x = element_text(color = wb[["text"]], size = 10)
  )

ggsave(file.path("output", "coefficient_plot.png"), p1,
       width = 9, height = 4.8, dpi = 300, bg = "white")

# --- 2. Event study ------------------------------------------------
ev <- read_csv(file.path("..", "data", "ie_eventstudy.csv"), show_col_types = FALSE) %>%
  mutate(lo = coef - 1.96 * se, hi = coef + 1.96 * se)

p2 <- ggplot(ev, aes(x = period, y = coef)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = wb[["electric"]], alpha = 0.16) +
  geom_hline(yintercept = 0, color = wb[["text"]], linewidth = 0.4) +
  geom_vline(xintercept = 0, linetype = "dashed", color = wb[["mid"]]) +
  geom_line(color = wb[["electric"]], linewidth = 0.9) +
  geom_point(color = wb[["oxford"]], size = 2) +
  labs(
    title = "Event study: effect over time, with a pre-trend check before t = 0",
    x = "Quarters relative to program start", y = "Effect", caption = illustrative
  ) +
  theme_dime() +
  theme(
    axis.text.x  = element_text(color = wb[["oxford"]], size = 10),
    axis.ticks.x = element_line(color = wb[["text"]]),
    axis.title   = element_text(color = wb[["text"]], size = 10)
  )

ggsave(file.path("output", "event_study.png"), p2,
       width = 9, height = 4.8, dpi = 300, bg = "white")

message("Wrote output/coefficient_plot.png and output/event_study.png")
