# Install required packages if not already installed
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
    return(uniq_x[freq == max(freq)])  # If there are multiple modes, return all of them
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
      selectInput("seedlot", "Select Seed Lot:", "", multiple = TRUE),
      selectInput("block_num", "Select Block:", "", multiple = TRUE),
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
  
  # Reactive expression to read Excel file and combine sheets
  dataInfo <- reactive({
    req(input$file)
    
    tryCatch({
      print("Reading Excel file...")
      
      excel_file <- lapply(excel_sheets(input$file$datapath), function(sheet) {
        data <- read_excel(input$file$datapath, sheet = sheet)
        data$SeedLot <- sheet  # Add SeedLot column with the sheet name
        # Convert all columns to character to avoid type conflicts
        data <- data %>%
          mutate(across(everything(), as.character))
        return(data)
      }) %>%
        bind_rows()
      
      print("Excel file read successfully.")
      print(head(excel_file))  # Debug: print first few rows of the data
      
      # Convert the 'date' column to Date format if necessary
      if ("date" %in% names(excel_file) && !inherits(excel_file$date, "Date")) {
        print("Converting date column to Date format...")
        excel_file$date <- as.Date(excel_file$date, format = "%Y-%m-%d")  # Adjust the date format as needed
      }
      
      return(excel_file)
    }, error = function(e) {
      print(paste("Error reading Excel file:", e$message))
      return(NULL)
    })
  })
  
  # Reactive expression to filter data based on selected date range
  filteredDataByDate <- reactive({
    req(dataInfo(), input$dateRange)
    
    tryCatch({
      filtered <- subset(dataInfo(), date >= input$dateRange[1] & date <= input$dateRange[2])
      print("Filtered data by date:")
      print(head(filtered))  # Debug: print first few rows of the filtered data
      return(filtered)
    }, error = function(e) {
      print(paste("Error filtering data by date:", e$message))
      return(NULL)
    })
  })
  
  # Update species dropdown choices based on the filtered data
  observe({
    tryCatch({
      species_choices <- unique(filteredDataByDate()$spp)
      print("Available species choices:")
      print(species_choices)  # Debug: print available species choices
      updateSelectInput(session, "species", choices = species_choices)
    }, error = function(e) {
      print(paste("Error updating species input:", e$message))
    })
  })
  
  # Update seed lot dropdown choices based on the selected species
  observe({
    tryCatch({
      req(input$species)
      speciesData <- filteredDataByDate()
      print("Filtered data by species for seed lot update:")
      print(head(speciesData))  # Debug: print filtered data by species
      
      if ("SeedLot" %in% colnames(speciesData)) {
        seedlot_choices <- unique(speciesData[speciesData$spp == input$species, "SeedLot"])
        print(paste("Available seed lot choices for species", input$species, ":"))
        print(seedlot_choices)  # Debug: print available seed lot choices
        updateSelectInput(session, "seedlot", choices = seedlot_choices)
      } else {
        print("Error: 'SeedLot' column not found in the data")
      }
    }, error = function(e) {
      print(paste("Error updating seed lot input:", e$message))
    })
  })
  
  # Update block number dropdown choices based on the selected species and seed lot
  observe({
    tryCatch({
      req(input$species, input$seedlot)
      speciesSeedlotData <- filteredDataByDate()
      print("Filtered data by species and seed lot for block update:")
      print(head(speciesSeedlotData))  # Debug: print filtered data by species and seed lot
      
      if ("block_num" %in% colnames(speciesSeedlotData)) {
        block_choices <- unique(speciesSeedlotData[speciesSeedlotData$spp == input$species & speciesSeedlotData$SeedLot %in% input$seedlot, "block_num"])
        print(paste("Available block choices for species", input$species, "and seed lot", input$seedlot, ":"))
        print(block_choices)  # Debug: print available block choices
        updateSelectInput(session, "block_num", choices = block_choices)
      } else {
        print("Error: 'block_num' column not found in the data")
      }
    }, error = function(e) {
      print(paste("Error updating block input:", e$message))
    })
  })
  
  # Reactive expression to filter data based on selected species, seed lot, and block
  filteredData <- reactive({
    req(filteredDataByDate(), input$species, input$seedlot)
    
    tryCatch({
      filtered <- subset(filteredDataByDate(), spp == input$species & SeedLot %in% input$seedlot)
      
      if (!is.null(input$block_num) && length(input$block_num) > 0) {
        filtered <- subset(filtered, block_num %in% input$block_num)
      }
      
      print("Filtered data by species, seed lot, and block:")
      print(head(filtered))  # Debug: print first few rows of the filtered data
      return(filtered)
    }, error = function(e) {
      print(paste("Error filtering data by species, seed lot, and block:", e$message))
      return(NULL)
    })
  })
  
  # Reactive expression to summarize data across blocks
  summarizedData <- reactive({
    req(filteredDataByDate(), input$species, input$seedlot)
    
    tryCatch({
      data <- filteredDataByDate()
      summarized <- data %>%
        filter(spp == input$species & SeedLot %in% input$seedlot) %>%
        group_by(date, SeedLot) %>%
        summarize(
          height_cm = mean(as.numeric(height_cm), na.rm = TRUE),
          rcd_mm = mean(as.numeric(rcd_mm), na.rm = TRUE),
          block_num = "All Blocks"  # Add a placeholder for block_num
        )
      
      print("Summarized data across blocks:")
      print(head(summarized))  # Debug: print first few rows of the summarized data
      return(summarized)
    }, error = function(e) {
      print(paste("Error summarizing data across blocks:", e$message))
      return(NULL)
    })
  })
  
  # Create a plot of seedling measurement for the selected species, seed lot, block, and date range
  output$measurementPlot <- renderPlot({
    req(filteredData())
    summary_function <- switch(input$summaryType,
                               "mean" = mean,
                               "median" = median,
                               "mode" = calculate_mode)
    
    tryCatch({
      plot_data <- if (!is.null(input$block_num) && length(input$block_num) > 0) {
        filteredData()
      } else {
        summarizedData()
      }
      
      ggplot(plot_data, aes(x = date, y = as.numeric(get(input$measurement)), color = interaction(SeedLot, block_num), linetype = factor(block_num))) +
        geom_line(stat = "summary", fun = summary_function, aes(group = interaction(SeedLot, block_num)), size = 1) +
        geom_point(stat = "summary", fun = summary_function, size = 3, shape = 16, aes(group = interaction(SeedLot, block_num)), color = "black") +
        geom_point(size = 1, color = "black") +
        labs(title = paste("Seedling", input$summaryType, "Over Time -", input$species),
             x = "Date", 
             y = ifelse(input$measurement == "height_cm", "Seedling Height (centimeters)", "Seedling RCD (millimeters)"), 
             color = "Seed Lot - Block", linetype = "Block") +
        scale_color_brewer(palette = "Set1") +
        theme(legend.position = "bottom", axis.ticks.x = element_blank(), 
              axis.text.x = element_text(hjust = 1), axis.title.x = element_text(size = 12)) +
        scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
    }, error = function(e) {
      print(paste("Error in plot rendering:", e$message))
      return(NULL)
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
