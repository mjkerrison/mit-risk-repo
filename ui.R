ui <- bslib::page_sidebar(
  
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly"
  ),
  
  fillable = FALSE,
  
  # Custom CSS
  tags$head(
    tags$style(HTML("
      .card-img-top {
        height: 200px;
        object-fit: cover;
      }
      .card {
        transition: transform 0.2s;
      }
      .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
      }
    "))
  ),
  
  sidebar = sidebar(
    
    # Free-text search
    card(
      textInput("query_freetext", "Free text search", ""),
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
      step = 1
    ),
    
    card(
      selectInput(
        "sort_by", 
        "Sort by:",
        choices = c("title",
                    "year",
                    "authors_short"),
        selected = "year"
      ),
      selectInput(
        "sort_order", 
        "Sort order:",
        choices = c("Ascending", "Descending"),
        selected = "Descending"
      ),
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
      uiOutput("cards_by_risk")
    )
    
  )
  
)
