# Get canonicalized bag of words as vector given a word or vector of words.
canonical_words <- function(w) {
  return(unlist(lapply(strsplit(w, split=" |/"), tolower)))
}
