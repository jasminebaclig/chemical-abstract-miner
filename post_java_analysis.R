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

results_and <- filter(results, grepl(" and ", chemical)) #179
results <- filter(results, !grepl(" and ", chemical)) #33998

cid_table <- data.frame(chemical = c("name"), cid = c("code"), cid_count = c(1))
for(i in 1:50) { #length(results[[1]])
  cid_compound <- get_cid(results$chemical[i], domain = "compound")
  cid_substance <- get_cid(results$chemical[i], domain = "substance")
  
  if(length(cid_compound[[1]]) == 1 & is.na(cid_compound$cid[1])) {
    cid <- cid_substance
  } else {
    cid <- bind_rows(cid_compound, cid_substance) %>% distinct()
  }
  
  
  if(length(cid[[1]]) == 1 & is.na(cid$cid[1])) {
    new_row <- c(results$chemical[i], NA, 0)
  } else {
    new_row <- c(results$chemical[i], cid$cid %>% paste(collapse = " "), length(cid$cid))
  }
  
  cid_table <- rbind(cid_table, new_row)
  print(paste("Chemical processed:", i))
}
cid_table = cid_table[-1, ]
results = results[1:50, ]
results <- left_join(results, cid_table, by = join_by(chemical == chemical))

results_no_cid <- filter(results, cid_count == 0)
results <- filter(results, cid_count != 0)

get_names <- function(cid_string) {
  cid_vector <- strsplit(cid_string, " ")
  name_vector <- c()
  
  for(j in 1:length(cid_vector[[1]])) {
    name_vector <- append(name_vector, pc_synonyms(cid_vector[[1]][i], from = "cid"))[[1]][1]
  }
  
  name_string <- paste(name_vector, collapse = " ")
}
results <- transform(results, pc_name = sapply(cid, get_names))
