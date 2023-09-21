#Installs and loads necessary packages
library(devtools)
library(RISmed)
library(tidyverse)
library(dictionaRy)

install_github("BuerkiLabTeam/G2PMineR")
library(G2PMineR)



#Runs literature search on plant species and retrieves abstracts
query_result <- EUtilsSummary("\"Abies balsamea\"", type = "esearch", db = "pubmed", retmax = 10000)
id <- attr(query_result, "PMID") %>% as.numeric()
abstracts <- AbstractsGetteR(id)



#Cleans up abstracts
missing <- c() #Contains indexes with missing abstracts

for(i in 1:length(abstracts)) {
  if(is.na(abstracts[i])) {
    missing <- append(missing, i)
  }
}

if(!is.null(missing)) {
  abstracts <- abstracts[-missing] #Removes missing abstracts and respective id's
  id <- id[-missing]
}

abstracts <- HTMLElementRemoveR(abstracts) #Removes HTML elements from abstracts
