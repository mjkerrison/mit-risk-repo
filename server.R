
server <- function(input, output, session) {
  
  filtered_data <- reactive({
    
    label_all_linked_risk_data(
      d_paper,
      d_risk_category,
      d_additional_evidence,
      # Inputs - explicit so we take dependencies properly
      input$query_freetext_fields,
      input$query_freetext,
      input$filter_year,
      input$sort_order,
      input$sort_by
    )
    
  })
  
  
  filtered_cards_by_paper <- server_cards_by_paper("cards_by_paper", filtered_data)
  
  # This one needs work...
  # filtered_cards_by_risk <- server_cards_by_risk("cards_by_risk", filtered_data)
  
}


