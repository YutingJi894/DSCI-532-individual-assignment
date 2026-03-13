library(shiny)
library(bslib)
library(dplyr)
library(readr)
library(ggplot2)

# load data
clean_df <- read_csv("clean-non-market-housing.csv", show_col_types = FALSE)

# local area choices
local_areas <- sort(unique(na.omit(clean_df$`Local Area`)))

ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "lux"),
  
  h2("Non-Market Housing Dashboard"),
  
  layout_sidebar(
    sidebar = sidebar(
      selectInput(
        "input_local_area",
        "Local Area",
        choices = c("All", local_areas),
        selected = "All"
      )
    ),
    
    layout_column_wrap(
      width = 1/2,
      value_box(
        title = "Total Projects",
        value = textOutput("total_projects")
      ),
      value_box(
        title = "Total Units",
        value = textOutput("total_units")
      )
    ),
    
    card(
      full_screen = TRUE,
      card_header("Clientele Unit Totals"),
      plotOutput("clientele_bar", height = "400px")
    )
  )
)

server <- function(input, output, session) {
  
  # reactive calc
  filtered_df <- reactive({
    if (input$input_local_area == "All") {
      clean_df
    } else {
      clean_df %>%
        filter(`Local Area` == input$input_local_area)
    }
  })
  
  output$total_projects <- renderText({
    nrow(filtered_df())
  })
  
  output$total_units <- renderText({
    df <- filtered_df()
    unit_cols <- c("Adaptable", "Accessible", "Standard")
    
    if (all(unit_cols %in% names(df))) {
      total <- df %>%
        select(all_of(unit_cols)) %>%
        mutate(across(everything(), ~ as.numeric(.))) %>%
        summarise(across(everything(), ~ sum(.x, na.rm = TRUE))) %>%
        unlist() %>%
        sum()
      
      format(total, big.mark = ",", scientific = FALSE)
    } else {
      "0"
    }
  })
  
  output$clientele_bar <- renderPlot({
    df <- filtered_df()
    
    cols <- c("Clientele - Families", "Clientele - Seniors", "Clientele - Other")
    
    if (!all(cols %in% names(df))) {
      ggplot() +
        annotate("text", x = 1, y = 1, label = "Required clientele columns not found") +
        theme_void()
    } else {
      for (col in cols) {
        df[[col]] <- as.numeric(df[[col]])
      }
      
      totals <- data.frame(
        Clientele = c("Families", "Seniors", "Other"),
        Units = c(
          sum(df[["Clientele - Families"]], na.rm = TRUE),
          sum(df[["Clientele - Seniors"]], na.rm = TRUE),
          sum(df[["Clientele - Other"]], na.rm = TRUE)
        )
      )
      
      ggplot(totals, aes(x = Clientele, y = Units, fill = Clientele)) +
        geom_col() +
        labs(
          x = NULL,
          y = "Total units",
          title = "Clientele unit totals"
        ) +
        theme_minimal() +
        theme(legend.position = "none")
    }
  })
}

shinyApp(ui, server)