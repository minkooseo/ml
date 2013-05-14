library(foreach)
library(rjson)

load_json <- function(fname) {
  return(fromJSON(
    paste("[", paste(readLines(fname), collapse=","), "]")))
}

# Converts an array within the list returned by load_json() into data frame.
# If json file contains array, say, { "key": ["a1", "a2"] }, it won't be easily converted to
# data frame by json_to_data_frame(). 
#
# Therefore, one can use this function to get array data as separate data frame. When needed,
# the data frame can be merged with the output from json_to_data_frame().
#
# Example)
# json_data <- fromJSON(
#   paste('[{ "id": 1, "ary": ["a1", "a2"], "score": 20},',
#         '{ "id": 2, "ary": ["b1", "a2"], "score": 30 }]'))
# ary_frame <- json_array_to_data_frame(json_data, "id", "ary")
json_array_to_data_frame<- function(json_data, id_name, array_name) {
  key_to_value <- adply(json_data, 1, function(x) {
    # Convert to data frame containing (key, variable name, 1).
    adply(x[[array_name]], 1, function(varname) {
        data.frame(id_name=x[[id_name]], varname, value=1)
    })
  }, .parallel=FALSE)
  if (NROW(key_to_value) > 0) {
    return(dcast(key_to_value, id_name ~ varname, fill=0))
  } else {
    return(data.frame())
  }
}

# Converts the output of load_json to data frame. Because json objects can be 
# nested, each row is converted data frame first, and then rbind-ed. In each element of
# json_data, elements whose name appear in columns_to_exclude won't be included
# in the final data frame. This is useful if you want to exclude arrays when generating
# data frame using this function.
#
# See json_array_to_data_frame() for better way of getting data frame out of json data.
#
# Example)
# json_data <- fromJSON(
#   paste('[{ "id": 1, "ary": ["a1", "a2"], "score": 20},',
#         '{ "id": 2, "ary": ["b1", "a2"], "score": 30 }]'))
# df <- json_to_data_frame(json_data, c("ary"))
json_to_data_frame <- function(json_data,
                               columns_to_exclude=c()) {
  return(do.call(rbind, lapply(json_data, function(x) {
    columns_to_select <- Filter(function(x) { !(x %in% columns_to_exclude) },
                                names(x))
    as.data.frame(x[columns_to_select])
  })))
}

z <- json_to_data_frame(data.business, c("categories", "neighborhoods"))