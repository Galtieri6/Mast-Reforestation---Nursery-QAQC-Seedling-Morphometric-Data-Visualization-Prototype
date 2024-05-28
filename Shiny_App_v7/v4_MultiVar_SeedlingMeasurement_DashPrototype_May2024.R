# Install required packages
if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny")
}

if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}

# Load required libraries
library(shiny)
library(ggplot2)
library(readxl)
library(dplyr)

# Mode function
calculate_mode <- function(x) {
  uniq_x <- unique(x)
  freq <- tabulate(match(x, uniq_x))
  
  mode_value <- uniq_x[which.max(freq)]
  
  if (length(mode_value) > 1) {
    # If there are multiple modes, return all of them
    return(uniq_x[freq == max(freq)])
  } else {
    return(mode_value)
  }
}

# Define the UI
ui <- fluidPage(
  titlePanel("Seedling Measurement Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose Excel File", accept = c(".xlsx")),
      dateRangeInput("dateRange", "Select Date Range:", start = Sys.Date() - 30, end = Sys.Date()),
      selectInput("species", "Select Species:", ""),
      selectInput("seedLot", "Select Seed Lot:", "", multiple = TRUE),
      selectInput("measurement", "Select Measurement:", choices = c("height_cm", "rcd_mm"), selected = "height_cm"),
      selectInput("summaryType", "Select Summary Type:", choices = c("mean", "median", "mode"), selected = "mean")
    ),
    
    mainPanel(
      plotOutput("measurementPlot")
    )
  )
)

# Define the server
server <- function(input, output, session) {
  
  # Reactive expression to read Excel file and extract seed lots, dates, and species
  dataInfo <- reactive({
    req(input$file)
    
    tryCatch({
      print("Reading Excel file...")
      
      # Read all sheets in the Excel file
      excel_file <- lapply(excel_sheets(input$file$datapath), function(sheet) {
        data <- read_excel(input$file$datapath, sheet = sheet)
        data$SeedLot <- sheet  # Add SeedLot column with the sheet name
        return(data)
      }) %>%
        bind_rows()
      
      print("Excel file read successfully.")
      
      print(head(excel_file))  # Debugging: print first few rows of the data
      
      # Convert the 'date' column to Date format if necessary
      if ("date" %in% names(excel_file) && !inherits(excel_file$date, "Date")) {
        print("Converting date column to Date format...")
        excel_file$date <- as.Date(excel_file$date, format = "%Y-%m-%d")  # Adjust the date format as needed
      }
      
      list(data = excel_file)
    }, error = function(e) {
      print(paste("Error reading Excel file:", e$message))
      NULL
    })
  })
  
  # Reactive expression to filter data based on selected date range
  filteredDataByDate <- reactive({
    req(dataInfo(), input$dateRange)
    
    tryCatch({
      print("Filtering data by date...")
      
      filtered <- subset(dataInfo()$data, date >= input$dateRange[1] & date <= input$dateRange[2])
      
      print(head(filtered))  # Debugging: print first few rows of the filtered data by date
      
      filtered
    }, error = function(e) {
      print(paste("Error filtering data by date:", e$message))
      NULL
    })
  })
  
  # Update species dropdown choices based on the filtered data by date range
  observe({
    filteredData <- filteredDataByDate()
    species <- unique(filteredData$spp)
    updateSelectInput(session, "species", choices = species)
  })
  
  # Update seed lot dropdown choices based on the selected species and date range
  observe({
    req(input$species)
    filteredData <- filteredDataByDate()
    speciesSeedLots <- unique(filteredData[filteredData$spp == input$species, "SeedLot"])
    updateSelectInput(session, "seedLot", choices = setNames(speciesSeedLots, speciesSeedLots))
  })
  
  # Reactive expression to filter data based on selected seed lot and date range
  filteredData <- reactive({
    req(filteredDataByDate(), input$seedLot)
    
    tryCatch({
      print("Filtering data by seed lot...")
      
      filtered <- subset(filteredDataByDate(), SeedLot %in% input$seedLot)
      
      print(head(filtered))  # Debugging: print first few rows of the filtered data
      
      filtered
    }, error = function(e) {
      print(paste("Error filtering data by seed lot:", e$message))
      NULL
    })
  })
  
  # Create a plot of seedling measurement for the selected seed lot and date range
  output$measurementPlot <- renderPlot({
    summary_function <- switch(input$summaryType,
                               "mean" = mean,
                               "median" = median,
                               "mode" = calculate_mode
    )
    
    tryCatch({
      ggplot(filteredData(), aes(x = date, y = if (input$measurement == "height_cm") get(input$measurement) * 0.393701 else get(input$measurement), color = factor(SeedLot))) +
        geom_line(size = 1, stat = "summary", fun = summary_function, aes(group = SeedLot)) +  # Each SeedLot has its own line
        geom_point(stat = "summary", fun = summary_function, size = 3, shape = 16, aes(group = SeedLot), color = "black") +  # Points for each SeedLot in black
        geom_point(size = 1, color = "black") +  # All datapoints as small black points
        labs(title = paste("Seedling", ifelse(input$summaryType == "mode", "Mode", input$summaryType), "Over Time -", 
                           if (length(input$seedLot) == 1) input$seedLot else "All Seed Lots"),
             x = "Date",  # Set x-axis label explicitly
             y = ifelse(input$measurement == "height_cm", "Seedling Height (inches)", "Seedling RCD (millimeters)"),  # Set y-axis label explicitly
             color = "Seed Lot") +
        scale_color_brewer(palette = "Set1") +
        theme(legend.position = "bottom", axis.ticks.x = element_blank(), 
              axis.text.x = element_text(hjust = 1),
              axis.title.x = element_text(size = 12)) +
        scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
    }, error = function(e) {
      print(paste("Error in plot rendering:", e$message))
      NULL
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
