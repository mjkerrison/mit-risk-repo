# library(dplyr)
# library(tidyr)

# From Claude. 

library(visNetwork)

# Function to create nodes from risk categories
create_nodes <- function(risk_df) {
  nodes <- risk_df %>%
    distinct(ev_id, risk_category, risk_subcategory, description) %>%
    mutate(
      id = paste0("risk_", ev_id),
      label = ifelse(!is.na(risk_subcategory) & risk_subcategory != "", 
                     risk_subcategory, 
                     risk_category),
      group = risk_category,
      title = description
    ) %>%
    select(id, label, group, title)
  
  return(nodes)
}

# Function to create edges from paper-risk relationships
create_edges <- function(risk_df, paper_df) {
  # First get all risks per paper
  paper_risks <- risk_df %>%
    select(quick_ref, ev_id) %>%
    group_by(quick_ref)
  
  # Create risk pairs using tidyr
  edges <- paper_risks %>%
    group_by(quick_ref) %>%
    # Create all possible combinations within each paper
    expand(from_id = ev_id, to_id = ev_id) %>%
    # Remove self-pairs and duplicates
    filter(from_id < to_id) %>%
    ungroup()
  
  # browser()
  
  # Add paper information including citation counts
  edges <- edges %>%
    left_join(
      paper_df %>% 
        select(quick_ref, title, authors_short, year, citations_28_may_2024),
      by = "quick_ref"
    ) %>%
    mutate(
      from = paste0("risk_", from_id),
      to = paste0("risk_", to_id),
      label = paste0(authors_short, " ", year),
      title = title,
      # Scale width based on citations
      # Using log scale to handle large differences in citation counts
      width = 1 + 2 * log(as.numeric(citations_28_may_2024) + 1),
      # Create a tooltip that includes citation count
      title = paste0(title, "\n(", as.numeric(citations_28_may_2024), " citations)")
    ) %>%
    select(from, to, label, title, width)
  
  return(edges)
}

# Create visualization with citation-based edge widths
visualize_risk_network <- function(nodes, edges) {
  visNetwork(nodes, edges) %>%
    visNodes(size = 30) %>%
    visEdges(arrows = "none", 
             smooth = TRUE,
             font = list(size = 14)) %>%
    visOptions(highlightNearest = list(enabled = TRUE, degree = 1)) %>%
    visLayout(randomSeed = 123) %>%
    visPhysics(stabilization = list(
      enabled = TRUE,
      iterations = 100
    ))
}

# Usage example:
nodes <- create_nodes(d_risk_category)
edges <- create_edges(d_risk_category, d_paper)
visualize_risk_network(nodes, edges)


# Oops - currently you get a Big Bang, and all the little galaxies of risks
# slowly drift away from each other (while lagging horrifically). Need to 
# rethink how this works. Too entangled at present. Clearly shows that there's
# some distinct clusters, though, which is interesting.
