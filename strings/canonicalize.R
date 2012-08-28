# Get canonicalized bag of words as vector given a word or vector of words.
# e.g.) canonical_words("hello world")
#       canonical_words(c("hello world", "good morning there"))
canonical_words <- function(w) {
  return(Filter(nchar, Filter(Negate(is.na),  # Remove empty and NA.
      unlist(lapply(strsplit(w, split=" |/"), tolower)))))  # Delimiter ' ' or /.
}
