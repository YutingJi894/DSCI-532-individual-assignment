library(shiny)
library(bslib)
library(dplyr)
library(readr)
library(leaflet)

clean_df <- read_csv("clean-non-market-housing.csv", show_col_types = FALSE)

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
      card_header("Project Map"),
      leafletOutput("map", height = "500px")
    )
  )
)

server <- function(input, output, session) {
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

  output$map <- renderLeaflet({
    df <- filtered_df()

    req(all(c("Latitude", "Longitude") %in% names(df)))

    leaflet(df) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~Longitude,
        lat = ~Latitude,
        radius = 5,
        popup = ~paste0(
          "<b>", ifelse(is.na(Name), "N/A", Name), "</b><br>",
          "<b>Address:</b> ", ifelse(is.na(Address), "", Address)
        )
      )
  })
}

shinyApp(ui, server)
