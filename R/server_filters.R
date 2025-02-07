

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


label_match_for_year <- function(data, min_yr, max_yr){
  
  mutate(
    data,
    matches_year = year >= min_yr & year <= max_yr
  )
  
}


label_all_linked_risk_data <- function(d_paper,
                                       d_risk_category,
                                       d_additional_evidence,
                                       # Inputs
                                       input_query_freetext_fields,
                                       input_query_freetext,
                                       input_filter_year,
                                       input_sort_order,
                                       input_sort_by){
  
  label_match_in_any_column_P <- partial(filter_any_match,
                                         fields = input_query_freetext_fields,
                                         pattern = input_query_freetext,
                                         ignore.case = TRUE)
  
  # Apply search filter
  if (input_query_freetext != "") {
    
    d_paper               <- d_paper |> label_match_in_any_column_P()
    d_risk_category       <- d_risk_category |> label_match_in_any_column_P()
    d_additional_evidence <- d_additional_evidence |> label_match_in_any_column_P()
    
  }
  
  # Apply year filter
  d_paper <- d_paper |> label_match_for_year(min(input_filter_year),
                                             max(input_filter_year))
  
  # Apply sorting
  
  # Neither of these approaches worked (i.e. with arrange(sort_dir(...))) - 
  # not sure why... doing the uglier version instead.
  #
  # sort_dir <- ifelse(input$sort_order == "Descending", 1, -1)
  # sort_dir <- ifelse(input$sort_order == "Descending", \(x) desc(x), \(x) -desc(x))
  
  # We're going to leave this here for now, but ultimately we'll want to 
  # delegate *this* to the individual tabs - it's a display thing, so it should
  # live next to the display *for that thing*
  if(input_sort_order == "Descending"){
    
    d_paper <- d_paper |> arrange(desc(across(any_of(input_sort_by))))
    
  } else {
    
    d_paper <- d_paper |> arrange(across(any_of(input_sort_by)))
    
  }
  
  # Consolidate
  
  # TODO: logic that consolidates *across* results?
  #   Is that graph acyclic or circular...?
  
  all_results <- list(
    "d_paper" = d_paper,
    "d_risk_category" = d_risk_category,
    "d_additional_evidence" = d_additional_evidence
  ) |> 
    
    map(\(tbl_i){
      # Bit of magic - thanks Claude.
      # Could also have used NAs for FALSE and then done a coalesce(c_across())
      mutate(tbl_i, matches = if_any(starts_with("matches_"), identity))
    })
  
  
  
  return(all_results)

}

