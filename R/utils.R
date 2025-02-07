
label_match_in_any_column <- function(data, 
                                      fields = NULL,
                                      pattern, 
                                      ignore.case = TRUE) {
  
  maybe_tolower <- ifelse(ignore.case, tolower, identity)
  
  maybe_lower_pattern <- maybe_tolower(pattern)
  
  field_tidyselect <- if(is.null(fields)) tidyr::everything else partial(tidyr::any_of, x = fields)

  mutate(
    data,
    matches_freetext = if_any(
      field_tidyselect(),
      \(x) str_detect(maybe_tolower(as.character(x)), maybe_lower_pattern)
    )
  )
}
