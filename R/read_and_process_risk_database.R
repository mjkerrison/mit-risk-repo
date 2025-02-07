
fetch_risk_db_sheet <- function(url_to_gsheet,
                                tab_name,
                                starting_row,
                                column_types = NULL, # i.e. guess
                                endmatter_rows){
  
  initial_table <- read_sheet(
    
    url_to_gsheet,
    sheet = tab_name,
    skip = starting_row - 1,
    col_types = column_types
    
  ) |> janitor::clean_names()
  
  
  initial_table |> 
    
    # Possibly remove the pesky attribution info @ the bottom of some sheets
    slice_head(n = nrow(initial_table) - endmatter_rows)
  
}

# Memoise the above function
fetch_risk_db_sheet <- memoise::memoise(fetch_risk_db_sheet,
                                        cache = cachem::cache_disk(dir = "cache"))


normalise_risk_category <- function(raw_database){
  
  raw_database |> 
    
    filter(category_level %in% c("Risk Category", "Risk Sub-Category")) |> 
    
    distinct(
      
      # Foreign key: paper
      quick_ref, 
      
      # Key: 'row' / paper*evidence ID
      ev_id,
      
      # Paper*risk information (so 'namespaced' because - per checks below - that 
      # certain info about a risk can vary by paper)
      cat_id, risk_category, 
      sub_cat_id, risk_subcategory, 
      description,
      p_def,
      entity,
      intent,
      timing, 
      domain,
      sub_domain
      
    )
  
}

normalise_additional_evidence <- function(raw_database){
  
  raw_database |> 
    
    filter(!is.na(additional_ev)) |> 
    
    distinct(
      
      # Foreign key: paper
      quick_ref,
      
      # Foreign key: risk / risk*subcategory
      ev_id,
      
      # Foreign keys: 
      cat_id, risk_category, # FK: risk
      sub_cat_id, risk_subcategory, 
      additional_ev, add_ev_id,
      p_add_ev
    )
  
}
