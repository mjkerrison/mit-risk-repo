# UI Module
ui_cards_by_paper <- function(id) {
  ns <- NS(id)
  
  tagList(

    uiOutput(ns("cards_by_paper"))
    
  )
  
}

# More elegant conditional display? -> https://github.com/rstudio/bslib/issues/1102

# Note - in theory we could just have one of everything, and dynamically switch 
# the content. However, because of how renderUI / Shiny / bslib handles all of 
# this, we couldn't quite get there 'off the shelf'. Claude tried hard, but we 
# still ended up needing one of everything per card. Would probably have to 
# write a custom card implementation (or find another package, I guess) to avoid
# this.
#
# To be more specific: it looks like all of the UI within a conditionalPanel 
# *exists* whether the conditionalPanel is shown or not, so even though only one
# [card_id]_full_screen input can be TRUE at one time, the *content* of every 
# one of those panels is still pre-rendered.


# Server Module
server_cards_by_paper <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    
    # Create collection of `paper` cards =======================================
    
    output$cards_by_paper <- renderUI({
      
      req(filtered_data())
      
      all_data <- filtered_data()
      
      .d_paper <- all_data$d_paper |> filter(matches)
      
      ns <- NS(id)
      
      if(nrow(.d_paper) == 0){
        
        return(ui_no_results)
      
      }
      
      cards <- map(1:nrow(.d_paper), function(i) {
        
        card_id_i <- ns(.d_paper$quick_ref[i])
        
        generate_one_card_by_paper(.d_paper,
                                   i,
                                   card_id_i,
                                   ns)
        
      })
      
      cards
      
    })
    
    
    # Create {reactable} for each card =========================================
    
    observe({
      req(filtered_data())
      all_data <- filtered_data()
      
      .d_paper <- all_data$d_paper |> filter(matches)
      
      .d_risk_category <- all_data$d_risk_category
      
      .d_additional_evidence <- all_data$d_additional_evidence
      
      for(i in 1:nrow(.d_paper)) {
        local({
          local_i <- i
          table_id <- paste0("fullscreen_risk_reactable_", .d_paper$quick_ref[local_i])
          
          output[[table_id]] <- renderReactable({
            
            risks_i <- filter(.d_risk_category, quick_ref == .d_paper$quick_ref[local_i])
            
            render_risk_reactable(risks_i,
                                  .d_additional_evidence)
            
          })
        })
      }
    })    
    
    return(invisible(TRUE))
    
  })
}


generate_one_card_by_paper <- function(.d_paper,
                                       i,
                                       card_id_i,
                                       ns){
  
  card(
    full_screen = TRUE,
    id = card_id_i,
    class = "cardItem",
    
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
        
        # Top: paper details
        
        layout_column_wrap(
          width = 1/2,
          # Left column
          card(
            h4("Publication Details"),
            tags$p(
              tags$strong("Authors: "), .d_paper$authors_full[i],
              tags$br(),
              tags$strong("Year: "), .d_paper$year[i],
              tags$br(),
              tags$strong("DOI: "), 
              tags$a(href = .d_paper$url[i], .d_paper$doi[i], target = "_blank")
            )
          ),
          # Right column
          card(
            h4("Impact Metrics"),
            tags$p(
              tags$strong("Total Citations: "), .d_paper$citations_28_may_2024[i],
              tags$br(),
              tags$strong("Citations per Year: "), .d_paper$cites_yr[i]
            )
          ),
        ),
        
        # Bottom: associated risks etc.
        
        card(
          fill = FALSE,
          
          h4("Risk details"),
          
          reactableOutput(ns(glue("fullscreen_risk_reactable_{.d_paper$quick_ref[i]}")))
          
        )
        
      )
      
    )
    
  )
  
}



colDefVisible <- partial(colDef,
                         show = TRUE)


render_risk_reactable <- function(.d_risk_category,
                                  .d_additional_evidence){
  
  reactable(
    
    data = .d_risk_category |> 
      mutate(`Additional Evidence` = NA) |> 
      select(
        # Order to display, per columns arg below...
        risk_category, 
        risk_subcategory,
        description, 
        p_def,
        `Additional Evidence`,
        entity,
        intent,
        timing,
        domain,
        sub_domain,
        # Everything else - retained for e.g. conditional formatting
        everything()
      ),
    
    # Default to hiding columns; we'll just manually specify the ones we want
    # to retain
    defaultColDef = colDef(
      show = FALSE
    ),
    
    columns = list(
      
      risk_category = colDefVisible(),
      risk_subcategory = colDefVisible(),
      
      description = colDefVisible(),
      p_def = colDefVisible(),
      
      `Additional Evidence` = colDefVisible(
        details = function(index){
          
          maybe_add_ev <- .d_additional_evidence |> 
            inner_join(
              .d_risk_category |> slice(index),
              by = c("quick_ref", "cat_id", "sub_cat_id")
            )
          
          if(nrow(maybe_add_ev) > 0){
            
            maybe_add_ev |> 
              select(additional_ev, p_add_ev) |> 
              reactable()
            
          } else {NULL}
          
        }
      ),
      
      entity = colDefVisible(),
      intent = colDefVisible(),
      timing = colDefVisible(),
      domain = colDefVisible(),
      sub_domain = colDefVisible()
      
    )
    
  )
  
}
