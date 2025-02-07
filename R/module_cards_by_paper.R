# UI Module
ui_cards_by_paper <- function(id) {
  ns <- NS(id)
  
  uiOutput(ns("cards_by_paper"))
}

# Server Module
server_cards_by_paper <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    
    # Generate movie cards
    output$cards_by_paper <- renderUI({
      
      req(filtered_data())
      
      all_data <- filtered_data()
      
      .d_paper <- all_data$d_paper |> filter(matches)
      
      if(nrow(.d_paper) == 0){
        
        return(ui_no_results)
      
      }
      
      cards <- map(1:nrow(.d_paper), function(i) {
        
        card_id_i <- NS(id)(glue("card_paper_{.d_paper$paper_id[i]}"))
        
        card(
          full_screen = TRUE,
          id = card_id_i,
          
          card_header(
            h4(.d_paper$title[i], class = "mb-0")
          ),
          
          card_body(
            
            # Summary view (!full-screen)
            conditionalPanel(
              condition = glue('!input["{card_id_i}_full_screen"]'),

              h6(class = "card-subtitle mb-3 text-muted",
                 .d_paper$authors_full[i]),
              h6(class = "card-subtitle mb-3 text-muted",
                 .d_paper$year[i])
            ),
            
            # Fullscreen view
            conditionalPanel(
              condition = glue('input["{card_id_i}_full_screen"]'),

              h6(class = "card-subtitle mb-3 text-muted",
                 .d_paper$authors_full[i]),
              h6(class = "card-subtitle mb-3 text-muted",
                 .d_paper$year[i]),
              
              p(.d_paper$doi[i]),
              p(.d_paper$url[i]),
              p(.d_paper$citations_28_may_2024[i]),
              p(.d_paper$cites_yr[i]),
              
              div(
                class = "d-flex justify-content-between align-items-center",
                span(class = "fw-bold", paste("Item type:", .d_paper$item_type[i]))#,
                # card_link("More Info", href = "#")
              )
              
            )
            
          )
          
        )
        
      })
      
      cards
      
    })
    
    return(invisible(TRUE))
    
  })
}
