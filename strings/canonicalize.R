# Get canonicalized bag of words as vector given a word or vector of words.
# e.g.) canonical_words("hello world")
#       canonical_words(c("hello world", "good morning there"))
canonical_words <- function(w) {
  return(unlist(lapply(strsplit(w, split=" |/"), tolower)))
}
