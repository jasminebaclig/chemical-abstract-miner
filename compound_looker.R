abs_param <- abstracts

compound_looker <- function(abs_param, id_param) {
  #Checks variable type of parameters
  if(class(abs_param) != "character") {
    stop("ERROR: abstracts must be a character vector.")
  }
  
  if(class(id_param) != "numeric") {
    stop("ERROR: id must be a numeric vector.")
  }
  
  
  
  #Cleans up abstracts
  abs_param <- gsub(",", "", abs_param) #Removes punctuation
  abs_param <- gsub("\\.", "", abs_param)
  abs_param <- gsub(":", "", abs_param)
  abs_param <- gsub(";", "", abs_param)
  abs_param <- gsub("\\(", "", abs_param)
  abs_param <- gsub("\\)", "", abs_param) %>% tolower()
  
  split_abs <- strsplit(abs_param, split = " ") #Splits each abstract into individual words
  
  
  
  #Checks if CSVs with prefixes and suffixes need to be read
  if(!exists("element_names") || !exists("combined_prefixes") || !exists("suffixes")) {
    source("nomenclature_csv_maker.R")
    nomenclature_csv_maker()
  }
}