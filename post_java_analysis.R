library(tidyverse)
library(webchem)

results <- read_tsv("caribou_chemicals.tsv", col_names = TRUE) #36207

elements <- read_csv("pte.csv", col_names = TRUE) %>%
            select(Element, Symbol) %>%
            transform(Element = tolower(Element), Symbol = tolower(Symbol))
results_elem <- filter(results, chemical %in% elements$Element | chemical %in% elements$Symbol) #1670
results <- filter(results, !(chemical %in% elements$Element) & !(chemical %in% elements$Symbol)) #34537

amino_acids <- read_csv("amino-acids.csv", col_names = TRUE)
amino_acids <- select(amino_acids, "full name", "three letter code", "single letter code") %>%
               transform("full name" = tolower(amino_acids$"full name"), "three letter code" = tolower(amino_acids$"three letter code"), "single letter code" = tolower(amino_acids$"single letter code"))
results_aa <- filter(results, chemical %in% amino_acids$full.name | chemical %in% amino_acids$three.letter.code | chemical %in% amino_acids$single.letter.code) #360
results <- filter(results, !(chemical %in% amino_acids$full.name) & !(chemical %in% amino_acids$three.letter.code) & !(chemical %in% amino_acids$single.letter.code)) #34177

results_and <- filter(results, grepl(" and ", results$chemical) == TRUE)

cid_table <- data.frame(chemical = c("name"), cid = c("code"), count = c(1))
for(i in 1:length(results[[1]])) {
  cid_compound <- get_cid(results$chemical[i], domain = "compound")
  cid_substance <- get_cid(results$chemical[i], domain = "substance")
  cid <- bind_rows(cid_compound, cid_substance) %>% distinct()
  
  if(length(cid[[1]]) == 1 & is.na(cid$cid[1])) {
    new_row <- c(results$chemical[i], NA, 0)
  } else {
    new_row <- c(results$chemical[i], cid$cid %>% paste(collapse = " "), length(cid$cid))
  }
  
  cid_table <- rbind(cid_table, new_row)
}
cid_table = cid_table[-1, ]