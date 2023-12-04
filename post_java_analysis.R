install.packages(c("tidyverse", "webchem"), repos = "http://cran.us.r-project.org")
library(tidyverse)
library(webchem)

results <- read_tsv("caribou_chemicals.tsv", col_names = TRUE)

elements <- read_csv("pte.csv", col_names = TRUE) %>%
            select(Element, Symbol) %>%
            transform(Element = tolower(Element), Symbol = tolower(Symbol))
results_elem <- filter(results, chemical %in% elements$Element | chemical %in% elements$Symbol)
write.csv(results_elem, "caribou_elements.csv")
results <- filter(results, !(chemical %in% elements$Element) & !(chemical %in% elements$Symbol))

amino_acids <- read_csv("amino-acids.csv", col_names = TRUE)
amino_acids <- select(amino_acids, "full name", "three letter code", "single letter code") %>%
               transform("full name" = tolower(amino_acids$"full name"), "three letter code" = tolower(amino_acids$"three letter code"), "single letter code" = tolower(amino_acids$"single letter code"))
results_aa <- filter(results, chemical %in% amino_acids$full.name | chemical %in% amino_acids$three.letter.code | chemical %in% amino_acids$single.letter.code)
write.csv(results_aa, "caribou_amino_acids.csv")
results <- filter(results, !(chemical %in% amino_acids$full.name) & !(chemical %in% amino_acids$three.letter.code) & !(chemical %in% amino_acids$single.letter.code))

results_and <- filter(results, grepl(" and ", chemical))
write.csv(results_and, "caribou_with_and.csv")
results <- filter(results, !grepl(" and ", chemical))

results = results[1:50, ] ##CHANGE##
just_chemical <- select(results, chemical) %>%
                 unique()
cid_table <- data.frame(chemical = c("name"), cid = c("code"), cid_count = c(1))
for(i in 1:length(just_chemical[[1]])) {
  cid_compound <- get_cid(just_chemical$chemical[i], domain = "compound")
  cid_substance <- get_cid(just_chemical$chemical[i], domain = "substance")
  
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
  print(paste("Chemical processed (cid_table):", i))
}
cid_table = cid_table[-1, ]
results <- left_join(results, cid_table, by = join_by(chemical == chemical))

results_no_cid <- filter(results, cid_count == 0)
write.csv(results_no_cid, "caribou_no_cid_1_50.csv") ##CHANGE##
results <- filter(results, cid_count != 0)
write.csv(results, "caribou_pre_iupac_1_50.csv") ##CHANGE##

iupac_table <- data.frame(species = c("species"), chemical = c("chemical"), cid = c("cid"), formula = c("formula"), iupac = c("iupac"))
for(i in 1:length(results[[1]])) {
  cid_vector <- strsplit(results$cid[[i]], " ")
  
  for(j in 1:length(cid_vector[[1]])) {
    properties <- pc_prop(cid_vector[[1]][j])
    
    if(is.atomic(properties)) {
      properties <- data.frame(t(properties))
    }
    
    formula <- properties$MolecularFormula[[1]][1]
    iupac_name <- properties$IUPACName[[1]][1]
    
    if(is.null(iupac_name)) {
      iupac_name <- NA
    }
    
    new_row <- c(results$species[[i]], results$chemical[[i]], cid_vector[[1]][j], formula, iupac_name)
    iupac_table <- rbind(iupac_table, new_row)
  }
  
  print(paste("Chemical processed (iupac_table):", i))
}
iupac_table = iupac_table[-1, ]

iupac_unique <- select(iupac_table, -cid)
iupac_unique = iupac_unique[!duplicated(iupac_unique[c("species", "formula", "iupac")]), ]
write.csv(iupac_unique, "caribou_iupac_1_50.csv") ##CHANGE##