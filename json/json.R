library("rjson")

load_json <- function(fname) {
  return(fromJSON(
    paste("[", paste(readLines(fname), collapse=","), "]")))
}

# Convert the output of load_json to data frame. Because json objects can be 
# nested, each row is converted data frame first, and the rbind-ed.
to_data_frame <- function(json_data) {
  return(do.call(rbind, lapply(json_data, function(x) { as.data.frame(x) })))
}
