#Installs and loads necessary packages
library(devtools)
library(RISmed)
library(tidyverse)

install_github("BuerkiLabTeam/G2PMineR")
library(G2PMineR)



#Imports plant species list for given animal
species_list <- read_csv("caribou_species_list.csv") %>%
                select("Species name")



#Prepares output file
output <- data.frame(species = character(), pmid = character())



for(i in 1:length(species_list)) {
  #Runs literature search on plant species and retrieves abstracts
  search_string <- paste("\"", species_list[[1]][i], "\"", sep = "")
  query_result <- EUtilsSummary(search_string, type = "esearch", db = "pubmed", retmax = 10000)
  id <- attr(query_result, "PMID") %>% as.numeric()
  abstracts <- AbstractsGetteR(id)
  
  
  
  #Removes PMID with missing abstracts
  missing <- c() #Contains indexes with missing abstracts
  
  for(i in 1:length(abstracts)) {
    if(is.na(abstracts[i])) {
      missing <- append(missing, i)
    }
  }
  
  if(!is.null(missing)) {
    id <- id[-missing]
  }
  
  
  
  #Concatenates PMID
  pmid_list <- paste(id, collapse = "\t")
  
  
  
  #Adds result to output data frame
  new_row <- c(species_list[[1]][i], pmid_list)
  output <- rbind(output, new_row)
}



#