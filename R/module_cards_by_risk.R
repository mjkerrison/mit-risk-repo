
# Adapted from module_cards_by_paper by Claude.

# Needs some work
#   - need to "merge" the info for a risk category - highlight the fact that the
#     same risk category can get a different cat_id and different ratings *per 
#     paper*, so that needs to be the organising principle.


# UI Module
ui_cards_by_risk <- function(id) {
  ns <- NS(id)
  
  tagList(
    uiOutput(ns("cards_by_risk"))
  )
}

# Server Module
server_cards_by_risk <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    
    output$cards_by_risk <- renderUI({
      
      req(filtered_data())
      
      all_data <- filtered_data()
      
      # Get unique risk categories with their subcategories
      .d_risk_category <- all_data$d_risk_category |> 
        filter(matches) |>
        distinct(risk_category, risk_subcategory, cat_id, sub_cat_id)
      
      if(nrow(.d_risk_category) == 0) {
        return(ui_no_results)
      }
      
      # Create cards for each risk category/subcategory
      cards <- map(1:nrow(.d_risk_category), function(i) {
        
        card_id_i <- NS(id, paste0("risk_", .d_risk_category$cat_id[i], "_", .d_risk_category$sub_cat_id[i]))
        
        card(
          full_screen = TRUE,
          id = card_id_i,
          class = "cardItem",
          
          card_header(
            h4(paste0(
              .d_risk_category$risk_category[i],
              if (!is.na(.d_risk_category$risk_subcategory[i])) {
                paste0(": ", .d_risk_category$risk_subcategory[i])
              } else {""}
            ), class = "mb-0")
          ),
          
          card_body(
            # Summary view (!full-screen)
            conditionalPanel(
              condition = glue('!input["{card_id_i}_full_screen"]'),
              h6(class = "card-subtitle mb-3 text-muted",
                 paste0("Category ID: ", .d_risk_category$cat_id[i],
                        if (!is.na(.d_risk_category$sub_cat_id[i])) {
                          paste0(".", .d_risk_category$sub_cat_id[i])
                        } else {""}))
            ),
            
            # Fullscreen view
            conditionalPanel(
              condition = glue('input["{card_id_i}_full_screen"]'),
              
              # Papers discussing this risk
              card(
                h4("Papers Discussing This Risk"),
                reactableOutput(NS(id, glue("fullscreen_papers_reactable_{.d_risk_category$cat_id[i]}_{.d_risk_category$sub_cat_id[i]}")))
              ),
              
              # Additional evidence
              card(
                h4("Additional Evidence"),
                reactableOutput(NS(id, glue("fullscreen_evidence_reactable_{.d_risk_category$cat_id[i]}_{.d_risk_category$sub_cat_id[i]}")))
              )
            )
          )
        )
      })
      
      cards
    })
    
    # Create reactables for each card
    observe({
      req(filtered_data())
      all_data <- filtered_data()
      
      .d_risk_category <- all_data$d_risk_category |> 
        filter(matches) |>
        distinct(risk_category, risk_subcategory, cat_id, sub_cat_id)
      
      for(i in 1:nrow(.d_risk_category)) {
        local({
          local_i <- i
          
          # Papers table
          papers_table_id <- paste0("fullscreen_papers_reactable_", 
                                    .d_risk_category$cat_id[local_i], "_",
                                    .d_risk_category$sub_cat_id[local_i])
          
          output[[papers_table_id]] <- renderReactable({
            papers_for_risk <- all_data$d_risk_category |>
              filter(cat_id == .d_risk_category$cat_id[local_i],
                     sub_cat_id == .d_risk_category$sub_cat_id[local_i]) |>
              left_join(all_data$d_paper, by = "quick_ref") |>
              select(title, authors_short, year, description, p_def)
            
            reactable(papers_for_risk)
          })
          
          # Additional evidence table
          evidence_table_id <- paste0("fullscreen_evidence_reactable_",
                                      .d_risk_category$cat_id[local_i], "_",
                                      .d_risk_category$sub_cat_id[local_i])
          
          output[[evidence_table_id]] <- renderReactable({
            evidence_for_risk <- all_data$d_additional_evidence |>
              filter(cat_id == .d_risk_category$cat_id[local_i],
                     sub_cat_id == .d_risk_category$sub_cat_id[local_i])
            
            if(nrow(evidence_for_risk) > 0) {
              reactable(evidence_for_risk |>
                          select(additional_ev, p_add_ev))
            }
          })
        })
      }
    })
    
    return(invisible(TRUE))
  })
}
