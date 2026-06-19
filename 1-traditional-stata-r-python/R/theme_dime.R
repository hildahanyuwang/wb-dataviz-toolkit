# theme_dime.R — reusable World Bank / DIME ggplot2 house style
# -------------------------------------------------------------------
# Source this file and EVERY future chart inherits the DIME look:
#
#   source("theme_dime.R")
#   p <- dime_barh(df, label_col = "label_full", value_col = "financing_usd_bn",
#                  title = "...", subtitle = "...", value_fmt = "$%.1fB")
#   ggsave("output/chart.png", p, width = 9, height = 4.8, dpi = 300, bg = "white")
#
# DIME Analytics chart conventions baked in here so they never have to be
# re-typed per chart: direct data labels, zero baseline, no redundant
# gridlines, largest bar in Oxford Blue, mandatory source note.
#
# This file is the reusable ASSET that keeps every chart on-brand.
# Sample work — not an official World Bank publication.

library(ggplot2)
library(dplyr)

# --- World Bank / DIME house palette (exact hexes) -----------------
wb <- c(
  oxford   = "#002244",  # primary (largest bar, titles, text)
  electric = "#009FDA",  # accent / highlight
  mid      = "#006C99",  # secondary bars
  gold     = "#FDB714",  # sparing accent only
  surface  = "#F7F9FA",
  text     = "#5A5A5A"
)

dime_source_note <- paste(
  "Source: World Bank Development Impact (DECDI), worldbank.org",
  "Sample — not an official World Bank publication.",
  sep = "\n"
)

# --- theme_dime(): the reusable ggplot2 theme ----------------------
theme_dime <- function(base_size = 12, base_family = "sans") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      panel.grid        = element_blank(),          # no redundant gridlines
      axis.text.x       = element_blank(),
      axis.ticks        = element_blank(),
      plot.title        = element_text(face = "bold", color = wb["oxford"], size = 15),
      plot.subtitle     = element_text(color = wb["text"], size = 11),
      plot.caption      = element_text(color = wb["text"], hjust = 0, size = 8),
      plot.caption.position = "plot",
      plot.title.position   = "plot",
      axis.text.y       = element_text(color = wb["oxford"], size = 11),
      plot.background   = element_rect(fill = "white", color = NA),
      panel.background  = element_rect(fill = "white", color = NA),
      plot.margin       = margin(14, 18, 10, 10)
    )
}

# --- dime_barh(): reusable DIME-style horizontal bar chart ---------
# df        : data frame already filtered to the rows to plot
# label_col : column with the category label (string)
# value_col : column with the numeric value (string)
# emphasis  : "max" highlights the largest bar in Oxford Blue
dime_barh <- function(df, label_col, value_col, title = "", subtitle = "",
                      value_fmt = "$%.1fB", emphasis = "max") {
  d <- df
  d$.val <- d[[value_col]]
  d$.lab <- d[[label_col]]
  max_val <- max(d$.val)

  d$.col <- if (identical(emphasis, "max")) {
    ifelse(d$.val == max_val, wb["oxford"], wb["mid"])
  } else {
    wb["mid"]
  }
  # Order factor so the largest bar sits on top after coord_flip().
  d$.lab <- reorder(d$.lab, d$.val)

  ggplot(d, aes(x = .lab, y = .val)) +
    geom_col(aes(fill = I(.col)), width = 0.62) +              # identity bars
    geom_text(                                                 # direct labels
      aes(label = sprintf(value_fmt, .val)),
      hjust = -0.15, fontface = "bold", size = 4, color = wb["oxford"]
    ) +
    coord_flip() +
    scale_y_continuous(limits = c(0, max_val * 1.18), expand = c(0, 0)) +  # zero baseline
    labs(title = title, subtitle = subtitle, x = NULL, y = NULL,
         caption = dime_source_note) +
    theme_dime()
}
