ui <- bslib::page_sidebar(
  
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly"
  ),
  
  fillable = FALSE,
  
  # Custom CSS
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "customcss.css"),
    tags$script(slidingSwitchBinding)
  ),
  
  sidebar = sidebar(
    
    # Free-text search
    card(
      searchInput("query_freetext", 
                  "Free text search", 
                  "",
                  btnSearch = icon("magnifying-glass"),
                  btnReset = icon("xmark")),
      checkboxGroupInput("query_freetext_fields", "In fields:",
                         choices = c("title",
                                     "authors_full"),
                         selected = c("title",
                                      "authors_full"))
    ),
    
    # Other filters
    
    sliderInput(
      "filter_year", 
      "Filter by year:",
      min = min(d_paper$year),
      max = max(d_paper$year),
      value = c(min(d_paper$year), max(d_paper$year)),
      step = 1,
      sep = ""
    ),
    
    card(
      height = "250px",
      selectInput(
        "sort_by", 
        "Sort by:",
        choices = c("title",
                    "year",
                    "authors_short"),
        selected = "year"
      ),
      slidingSwitchInput( # Custom input
        inputId = "sort_order",
        label = "Sort order",
        leftLabel = "Asc", rightLabel = "Desc", 
        leftValue = "Ascending", rightValue = "Descending",
        selected = "Descending"
      )
    )
    

  ),
  
  # Main panel ====================================================
  
  ## Global header ------------------------------------------------
  h1("MIT AI Risk Repository", class = "text-center my-4"),
  
  ## Tabs ---------------------------------------------------------
  navset_bar(
    
    nav_panel(
      title = "Explore by paper",
      ui_cards_by_paper("cards_by_paper")
    ),
    
    nav_panel(
      title = "Explore by risk",
      ui_cards_by_risk("cards_by_risk")
    )
    
  )
  
)
