# UI Module
ui_cards_by_risk <- function(id) {
  ns <- NS(id)
  
  uiOutput(ns("cards_by_risk"))
}

# Server Module
server_cards_by_risk <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    
    # Generate movie cards
    output$cards_by_risk <- renderUI({
      
      req(filtered_data())
      
      data <- filtered_data()
      
      if(nrow(data) == 0){
        
        return(ui_no_results)
      
      }
      
      cards <- map(1:nrow(data), function(i) {
        
        card_id_i <- NS(id)(glue("card_risk_{data$paper_id[i]}"))
        
        card(
          full_screen = TRUE,
          id = card_id_i,
          
          card_header(
            h4(data$title[i], class = "mb-0")
          ),
          
          card_body(
            
            # Summary view (!full-screen)
            conditionalPanel(
              condition = glue('!input["{card_id_i}_full_screen"]'),

              h6(class = "card-subtitle mb-3 text-muted",
                 data$authors_full[i]),
              h6(class = "card-subtitle mb-3 text-muted",
                 data$year[i])
            ),
            
            # Fullscreen view
            conditionalPanel(
              condition = glue('input["{card_id_i}_full_screen"]'),

              h6(class = "card-subtitle mb-3 text-muted",
                 data$authors_full[i]),
              h6(class = "card-subtitle mb-3 text-muted",
                 data$year[i]),
              
              p(data$doi[i]),
              p(data$url[i]),
              p(data$citations_28_may_2024[i]),
              p(data$cites_yr[i]),
              
              div(
                class = "d-flex justify-content-between align-items-center",
                span(class = "fw-bold", paste("Item type:", data$item_type[i]))#,
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
