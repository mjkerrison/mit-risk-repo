library(tidyverse)
library(googlesheets4)
library(janitor)
library(assertthat)
library(memoise)
library(glue)

library(shiny)
library(bslib)
library(reactable)
library(shinyWidgets)

walk(
  list.files("R/", pattern = "\\.R$", full.names = TRUE),
  \(x) source(x, local = FALSE)
)

# Verify OAuth is set up; once done, googlesheets4 will handle it internally 
# from here on out
# gs4_auth()

# Set the URL in .Renviron (gitignored)
risk_database_gsheet_url <- Sys.getenv("risk_database_gsheet_url")

# Read & process ===============================================================

## Main Google sheet -----------------------------------------------------------
raw_database <- fetch_risk_db_sheet(risk_database_gsheet_url,
                                    tab_name = "AI Risk Database v2",
                                    starting_row = 3,
                                    column_types = "c",
                                    endmatter_rows = 0)

# All columns in the main database are read as characters:
#   - Most columns are, except (you would think) page refs
#   - There are some page references that are actually ranges, e.g. "5-6"
#   - This ran afoul of the NULL/NA logic for {googlesheets4}:
#   - https://github.com/tidyverse/googlesheets4/issues/203#issuecomment-751794949
#   - TL;DR if it's guessing an atomic for the col, it'll do NA, but if it looks
#     mixed, it'll do list and NULLS.

# raw_database |> View()

## Included resources sheet ----------------------------------------------------
d_paper <- fetch_risk_db_sheet(risk_database_gsheet_url,
                               tab_name = "Included resources",
                               starting_row = 12,
                               column_types = c("cdccccdccccc"),
                               endmatter_rows = 8)

# d_paper |> View()

## Normalise risk information --------------------------------------------------
d_risk_category <- raw_database |> normalise_risk_category()

# d_risk_category |> View()

## Normalise additional evidence -----------------------------------------------
d_additional_evidence <- raw_database |> normalise_additional_evidence()

# d_additional_evidence |> View()

# Can we further normalise the risks? ==========================================

check_risk_labelling <- within(list(), {
  
  risk_labelling_nested <- d_risk_category |> 
    distinct(risk_category, risk_subcategory, entity, intent, timing, domain, sub_domain) |> 
    group_by(risk_category, risk_subcategory) |> 
    nest(labelling = c(entity, intent, timing, domain, sub_domain)) |> 
    ungroup() |> 
    mutate(n_distinct_labels = map_dbl(labelling, nrow))
  
  risk_labelling_summary <- risk_labelling_nested |> 
    group_by(n_distinct_labels) |> 
    count()
  
})#; print(check_risk_labelling)


check_risk_labelling$risk_labelling_nested |> 
  
  arrange(desc(n_distinct_labels)) |> 
  
  head(1) |> 
  
  unnest(labelling)

# So it looks like entity, intent, and timing may vary by paper.
# 
# Not 1:1 with domain/sub-domain either.
# 
# And it looks like domain and sub-domain (i.e. the mid-level domain taxonomy)
# can vary across the high-level causal taxonomy as well - at least by paper.


# Interesting research questions ===============================================

# - Where is there 'disagreement' in the literature about which risks stem from
#   what entities/intent/timing | domain/subdomain?
#     -> Look at something like the check_risk_labelling tables and visualise
#        which risks have the most diverse labelling
#     -> May yield either something interesting, or a sense-check / validation 
#        for the team's labelling efforts...

# - Is there anything that's mutually exclusive?

# - Probabilities - out of scope


# Static assets ================================================================

ui_no_results <- card(
  full_screen = FALSE,
  h5("No results found.")
)
