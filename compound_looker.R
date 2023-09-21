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
  abs_param <- gsub("\\)", "", abs_param)
  abs_param <- gsub("\"", "", abs_param)
  abs_param <- gsub("\\[", "", abs_param)
  abs_param <- gsub("\\]", "", abs_param)
  abs_param <- gsub("\\/", "", abs_param) %>% tolower()
  
  split_abs <- strsplit(abs_param, split = " ") #Splits each abstract into individual words
  
  
  
  #Checks if CSVs with prefixes and suffixes need to be read
  if(!exists("element_names") || !exists("combined_prefixes") || !exists("suffixes")) {
    source("nomenclature_csv_maker.R")
    nomenclature_csv_maker()
  }
  
  
  #FIRST ITERATION: Removes strings with no letters and combines two-word chemical names
  no_letters <- c()
  two_word_end <- c()
  two_word_start <- c()
  
  for(i in 1:length(split_abs)) {
    for(j in 1:length(split_abs[[i]])) {
      string <- split_abs[[i]][j]
      
      if(!grepl("[A-Za-z]", string)) {
        no_letters <- append(no_letters, j)
      }
      
      if(string == "acid") {
        two_word_end <- append(two_word_end, j)
      }
      
      if(string %in% element_names) {
        two_word_start <- append(two_word_start, j)
      }
      
      
    }
  }
}