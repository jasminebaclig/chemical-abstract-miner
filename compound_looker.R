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
  
  for(i in 1) {#:length(split_abs)) {
    for(j in 1:length(split_abs[[i]])) {
      if(!grepl("[A-Za-z]", split_abs[[i]][j])) {
        no_letters <- append(no_letters, j)
      }
    }
    
    if(!is.null(no_letters)) {
      split_abs[[i]] <- split_abs[[i]][-no_letters]
    }
    
    for(j in 1:length(split_abs[[i]])) {
      if(split_abs[[i]][j] == "acid") {
        two_word_end <- append(two_word_end, j)
      }
    }
    
    if(!is.null(two_word_end)) {
      two_word_end <- sort(two_word_end, decreasing = TRUE)
      
      for(k in 1:length(two_word_end)) {
        split_abs[[i]][two_word_end[[k]] - 1] <- paste(split_abs[[i]][two_word_end[[k]] - 1], split_abs[[i]][two_word_end[[k]]])
        split_abs[[i]][-two_word_end[[k]]]
      }
    }
    
    for(j in 1:length(split_abs[[i]])) {
      if(split_abs[[i]][j] %in% element_names) {
        two_word_start <- append(two_word_start, j)
      }
    }
    
    if(!is.null(two_word_start)) {
      two_word_start <- sort(two_word_start, decreasing = TRUE)
      
      for(k in 1:length(two_word_start)) {
        split_abs[[i]][two_word_start[[k]]] <- paste(split_abs[[i]][two_word_start[[k]]], split_abs[[i]][two_word_start[[k]] + 1])
        split_abs[[i]][-(two_word_start[[k]] + 1)]
      }
    }
  }
}