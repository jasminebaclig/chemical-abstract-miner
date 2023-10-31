library(tidyverse)

results <- read_tsv("caribou_chemicals.tsv", col_names = TRUE)

elements <- read_csv("pte.csv", col_names = TRUE) %>%
            select(Element, Symbol) %>%
            transform(Element = tolower(Element), Symbol = tolower(Symbol))
