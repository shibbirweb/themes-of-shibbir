# R sample: vectors, data frames, pipes, functions, formulas.

library(dplyr)
library(ggplot2)

DEFAULT_HEX <- "#EEFFFF"
MAX_DEPTH <- 8L
HEX_PATTERN <- "^#([0-9a-fA-F]{3}){1,2}$"

palette <- c(
  background = "#263238",
  foreground = "#EEFFFF",
  keyword    = "#C792EA",
  string     = "#C3E88D",
  number     = "#F78C6C"
)

luminance <- function(hex) {
  if (!grepl(HEX_PATTERN, hex)) {
    warning(sprintf("Invalid hex value: %s", hex))
    return(NA_real_)
  }

  channels <- strtoi(substring(hex, c(2, 4, 6), c(3, 5, 7)), base = 16L)
  sum(channels * c(0.2126, 0.7152, 0.0722)) / 255
}

describe <- function(label, hex = DEFAULT_HEX, ...) {
  stopifnot(is.character(label), nchar(label) > 0)
  sprintf("%-12s => %s", label, hex)
}

swatches <- data.frame(
  label = names(palette),
  hex = unname(palette),
  stringsAsFactors = FALSE
)

swatches$luminance <- vapply(swatches$hex, luminance, numeric(1))
swatches$tone <- ifelse(swatches$luminance < 0.5, "dark", "light")

summary_table <- swatches %>%
  filter(!is.na(luminance)) %>%
  mutate(label = toupper(label)) %>%
  arrange(desc(luminance)) %>%
  group_by(tone) %>%
  summarise(
    count = n(),
    mean_luminance = round(mean(luminance), 4),
    .groups = "drop"
  )

for (i in seq_len(nrow(swatches))) {
  row <- swatches[i, ]
  cat(describe(row$label, row$hex), sprintf("  %.4f  %s\n", row$luminance, row$tone))
}

print(summary_table)

model <- lm(luminance ~ nchar(label), data = swatches)
cat("R-squared:", round(summary(model)$r.squared, 4), "\n")

plot <- ggplot(swatches, aes(x = reorder(label, luminance), y = luminance, fill = hex)) +
  geom_col() +
  scale_fill_identity() +
  coord_flip() +
  labs(
    title = "Themes of Shibbir",
    subtitle = paste("Max depth:", MAX_DEPTH),
    x = NULL,
    y = "Relative luminance"
  ) +
  theme_minimal()

if (interactive()) {
  print(plot)
}

result <- tryCatch(
  {
    luminance("not-a-hex")
  },
  warning = function(w) {
    message("caught warning: ", conditionMessage(w))
    NA_real_
  },
  finally = {
    message("done")
  }
)
