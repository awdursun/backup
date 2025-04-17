
library(shiny)
library(bslib)
library(dplyr)
library(tibble)

ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "minty"),
  
  titlePanel("Filter Configuration App"),
  
  navs_tab_card(
    nav("Filters",
        layout_column_wrap(
          width = 1/2,
          
          sliderInput("mpg", "Miles Per Gallon", min = 10, max = 35, value = c(15, 30)),
          sliderInput("hp", "Horsepower", min = 50, max = 350, value = c(100, 250)),
          sliderInput("wt", "Weight", min = 1.5, max = 5.5, value = c(2, 4)),
          selectInput("cyl", "Cylinders", choices = c(4, 6, 8), selected = c(4, 6, 8), multiple = TRUE),
          selectInput("gear", "Gears", choices = c(3, 4, 5), selected = c(3, 4, 5), multiple = TRUE),
          selectInput("carb", "Carburetors", choices = sort(unique(mtcars$carb)), selected = sort(unique(mtcars$carb)), multiple = TRUE),
          checkboxInput("am", "Automatic Transmission Only", value = FALSE),
          checkboxInput("vs", "V-Engine Only", value = FALSE),
          numericInput("qsec_min", "Quarter Mile Time ≥", value = 15, min = 10, max = 25),
          numericInput("qsec_max", "Quarter Mile Time ≤", value = 22, min = 10, max = 25)
        ),
        
        hr(),
        textInput("config_name", "Save current filter configuration as:"),
        actionButton("save_config", "Save Configuration", class = "btn-primary"),
        
        hr(),
        selectInput("load_config", "Load Saved Configuration", choices = NULL),
        actionButton("load_selected", "Load Configuration", class = "btn-success")
    ),
    
    nav("Data View",
        tableOutput("filtered_data")
    ),
    
    nav("Saved Configurations",
        fluidRow(
          column(6,
                 selectInput("delete_config", "Select Configuration to Delete", choices = NULL),
                 actionButton("confirm_delete", "Delete Configuration", class = "btn-danger")
          )
        ),
        hr(),
        tableOutput("saved_config_table")
    )
  )
)

server <- function(input, output, session) {
  saved_configs <- reactiveVal(list())
  
  observeEvent(input$save_config, {
    req(input$config_name)
    configs <- saved_configs()
    configs[[input$config_name]] <- list(
      mpg = input$mpg,
      hp = input$hp,
      wt = input$wt,
      cyl = input$cyl,
      gear = input$gear,
      carb = input$carb,
      am = input$am,
      vs = input$vs,
      qsec_min = input$qsec_min,
      qsec_max = input$qsec_max
    )
    saved_configs(configs)
    
    updateSelectInput(session, "load_config", choices = sort(names(configs)))
    showNotification(paste("Saved configuration:", input$config_name))
  })
  
  observe({
    updateSelectInput(session, "delete_config", choices = sort(names(saved_configs())))
  })
  
  observeEvent(input$confirm_delete, {
    req(input$delete_config)
    showModal(modalDialog(
      title = paste("Delete configuration:", input$delete_config),
      "Are you sure you want to delete this configuration?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("delete_confirmed", "Yes, Delete", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$delete_confirmed, {
    req(input$delete_config)
    configs <- saved_configs()
    configs[[input$delete_config]] <- NULL
    saved_configs(configs)
    
    # Update inputs
    updateSelectInput(session, "load_config", choices = sort(names(configs)))
    updateSelectInput(session, "delete_config", choices = sort(names(configs)))
    
    removeModal()
    showNotification(paste("Deleted configuration:", input$delete_config), type = "message")
  })
  
  observeEvent(input$load_selected, {
    req(input$load_config)
    config <- saved_configs()[[input$load_config]]
    if (!is.null(config)) {
      updateSliderInput(session, "mpg", value = config$mpg)
      updateSliderInput(session, "hp", value = config$hp)
      updateSliderInput(session, "wt", value = config$wt)
      updateSelectInput(session, "cyl", selected = config$cyl)
      updateSelectInput(session, "gear", selected = config$gear)
      updateSelectInput(session, "carb", selected = config$carb)
      updateCheckboxInput(session, "am", value = config$am)
      updateCheckboxInput(session, "vs", value = config$vs)
      updateNumericInput(session, "qsec_min", value = config$qsec_min)
      updateNumericInput(session, "qsec_max", value = config$qsec_max)
    }
  })
  
  filtered_data <- reactive({
    df <- mtcars
    df <- df %>%
      filter(
        mpg >= input$mpg[1], mpg <= input$mpg[2],
        hp >= input$hp[1], hp <= input$hp[2],
        wt >= input$wt[1], wt <= input$wt[2],
        cyl %in% input$cyl,
        gear %in% input$gear,
        carb %in% input$carb,
        qsec >= input$qsec_min,
        qsec <= input$qsec_max
      )
    if (input$am) df <- df %>% filter(am == 0)
    if (input$vs) df <- df %>% filter(vs == 0)
    df
  })
  
  output$filtered_data <- renderTable({
    filtered_data()
  })
  
  output$saved_config_table <- renderTable({
    configs <- saved_configs()
    if (length(configs) == 0) return(NULL)
    
    sorted_names <- sort(names(configs))
    
    config_df <- lapply(sorted_names, function(name) {
      config <- configs[[name]]
      # Collapse multiple values into comma-separated strings
      sapply(config, function(x) {
        if (length(x) > 1) paste(x, collapse = ", ") else as.character(x)
      }) %>% 
        as.list() %>%
        c(Config = name, .)
    })
    
    # Convert list of named lists to a clean data frame
    dplyr::bind_rows(config_df)
  })
  
}

shinyApp(ui, server)
