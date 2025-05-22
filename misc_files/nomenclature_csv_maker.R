nomenclature_csv_maker <- function() {
  #Loads CSVs of prefixes and suffixes from IUPAC red and blue book
  element_names <- read_csv("element_names.csv", col_names = "name")
  element_prefixes <- read_csv("element_prefixes.csv", col_names = "prefix")
  multiplicative_prefixes <- read_csv("multiplicative_prefixes.csv", col_names = "prefix")
  suffixes <- read_csv("suffixes.csv", col_names = "suffix")
  prefixes <- read_csv("prefixes.csv", col_names = "prefix")
  geometric_prefixes <- read_csv("geometric_prefixes.csv", col_names = "prefix")
  
  #Removes -a suffix from element prefixes
  remove_a <- function(string) {
    return(substr(string, 1, nchar(string) - 1))
  }
  
  #Fixes formatting on some CSVs
  element_names <- sapply(element_names, tolower)
  element_prefixes <- sapply(element_prefixes, remove_a)
  
  #Combines all vectors with prefixes
  combined_prefixes <- rbind(element_prefixes, multiplicative_prefixes, prefixes, geometric_prefixes)
  
  #Sorts vectors alphabetically
  element_names <<- sort(element_names)
  combined_prefixes <<- combined_prefixes[order(combined_prefixes$prefix),]
  suffixes <<- suffixes[order(suffixes$suffix),]
}