
make_Claude_dir_if_nexists <- function(){
  
  if(!dir.exists("Claude")) dir.create("Claude")
  
  return(invisible(TRUE))
  
}

ship_to_Claude <- function(list_of_files){
  
  make_Claude_dir_if_nexists()
  
  walk(list_of_files, function(x){
    
    file.copy(
      x, 
      to = glue("Claude/{r_file_as_txt}",
                r_file_as_txt = gsub('\\.R$', '\\.txt', x = basename(x))),
      overwrite = TRUE
    )
    
  })
  
  return(invisible(NULL))
  
}

data_sample_for_Claude <- function(table_names, quick_ref_regex){
  
  make_Claude_dir_if_nexists()
  
  walk(table_names, function(tbl_name_i){
    
    write_csv(
      get(tbl_name_i) |> filter(str_starts(quick_ref, quick_ref_regex)),
      paste0("Claude/", tbl_name_i, ".csv"),
      na = ""
    )
    
  })
  
}


if(FALSE){
  
  ship_to_Claude(c(
    "global.R",
    "server.R",
    "ui.R",
    "R/module_cards_by_paper.R",
    "R/server_filters.R",
    "R/reactable_definitions.R"
  ))
  
  data_sample_for_Claude(
    c("d_paper", "d_risk_category", "d_additional_evidence"),
    "Solai|Critch"
  )
  
  
}
