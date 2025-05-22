#Gets PMIDs of articles related to species of interest
#Author: @jasminebaclig



#Installs and loads necessary packages
library(devtools)
library(RISmed)
library(tidyverse)



#Imports plant species list for given animal
species_list <- read_csv("./input_files/caribou_species_list.csv") %>%
                select("Species name")



#Prepares output file
output <- data.frame(species = character(), pmid = character())



for(i in 1:length(species_list[[1]])) {
  #Runs literature search on plant species and retrieves PMID
  search_string <- paste("\"", species_list[[1]][i], "\"", sep = "")
  query_result <- EUtilsSummary(search_string, type = "esearch", db = "pubmed", retmax = 10000)
  id <- attr(query_result, "PMID") %>% as.numeric()
  
  
  
  #Concatenates PMID
  pmid_list <- paste(id, collapse = "\t")
  
  
  
  #Adds result to output data frame
  new_row <- c(species_list[[1]][i], pmid_list)
  output <- rbind(output, new_row)
}



#Write output to .txt file
write.table(output, file = "./output_files/pmid.txt", append = FALSE, quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)