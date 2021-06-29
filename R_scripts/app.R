# UT Leg Contrib


# Global 

### Author: J N Barber
### Purpose: Visualize the data scraped and cleaned in the Jupyter notebook using Python

# Consider using highchart package instead. This is not great
# library("highcharter")

# imports
library(treemap)
# library(remotes)
# remotes::install_github("timelyportfolio/d3treeR")
library(d3treeR)
library(htmlwidgets)
library(tidyverse)
library(jsonlite)
library(shiny)
# install.packages("ECharts2Shiny")
# library(rlist)

# wd <- getwd()

# change the following as needed:
# setwd(paste0(wd, '/DataProjects/UTLeg'))

# Set the years to generate here:
# there is no data for 2007
years <- c(2006, 2008:2020)
# years <- c(2008:2020)

all_treemaps <- list()
dfs <- list()

# Open the combined reports for each year and generate a widget from a treemap
for (y in years) {

    df_name <- paste0('df_', as.character(y))

    combined_pass_filepath <- paste0(
        'C:\\Users\\indig\\Documents\\DataProjects\\UT_campaign_contributions\\py_branch_2020_09_28\\data\\Final_categorization_',
        # 'py_branch_2020_09_28\\data\\Final_categorization_',
        as.character(y),
        '.csv'
    )

    file_name <- paste0('interactiveTreemap_', as.character(y), '.html')

    df <- as_tibble(read.csv(file = combined_pass_filepath))
    
    # factor not necessary if type of treepmap isn't able to use it
    # df['Contributor_type'] <- as.factor(df['Contributor_type'])

    assign(df_name, df)

    treemap_name <- paste0('leg_treemap_', as.character(y))

    assign(
        treemap_name,
        treemap(
            df,
            index = c("PCC", "Contributor_type", "NAME"),
            vSize = "TRAN_AMT",
            vColor = "Contributor_type", # "NAME"*7, # "Contributor_type/1000" # not needed for index or depth
            type = "index", # "depth", #  "categorical", # 
            palette = "Set3",
            fontsize.labels = c(16, 10, 8),
            fontcolor.labels = c("black", "black", "grey"),
            fontface.labels = c(2, 2, 1),
            # bg.labels = c("transparent"), #80, #controls transparency # use defaults
            align.labels = list(
                c("center", "center"),
                c("left", "top"),
                c("left", "bottom")
            ),
            overlap.labels = 0.3, #0.1, # 0.2
            inflate.labels = F,
            border.col = c("black", "black", "grey"),
            border.lwds = c(4, 2, 1),
            title = paste("Utah State Campaign Contributions", as.character(y)),
            fontsize.title = 24, # Title not used in dashboard
            # # position.legend = "right" # not
        )
    ) %>%
        d3tree2(
            rootname = paste(as.character(y),"Campaign Contributions")
        ) %>%
        saveWidget(file=file_name)

}


# UI Starts here

ui <- fluidPage(
    verticalLayout(
        titlePanel('Campaign Contributions for Utah State Offices'),
        fluidRow(
            column(width = 12,
                   radioButtons(
                       inputId='data_year', label='Year',
                       choices = years,
                       selected = max(years),
                       inline = TRUE
                   # numericInput(
                   #     inputId='data_year', label='Year',
                   #     min=min(years), max=max(years),
                   #     value=max(years)
                    )
            )#,
            # column(width = 2, offset = 1,
            #        output$selectedYear
            # )
        ),
        mainPanel(
            
            # textOutput("selectedTM"),
            htmlOutput('TM'),
            width = 12 # for fluid layout 12 is max
            
        ),
        fluidRow(
            column(width = 12,
            "Click on a square to drill down the treemap. Click on the treemap title bar to navigate back up the treemap heiarchy. The data were collected from Utah.gov on December 8, 2020."
            )
        ),
        fluidRow(
            column(width = 12,
                   "The treemap is better than pie charts, but this is not a good visualization. Find a better way."
            )
        )
    )
    
)



# Server starts here 

server <- function(input, output) {
    
    # reactive input

    output$selectedTM <- renderText({
        paste0('"', 'interactiveTreemap_', as.character(input$data_year), '.html', '"')
        # paste0('interactiveTreemap_', as.character(input$data_year), '.html')
    })
    
    output$TM <- renderUI({
        TM_path <- paste0('interactiveTreemap_', as.character(input$data_year), '.html')
        includeHTML(path = TM_path)
        
    })
    

}


# Run the application 
shinyApp(ui = ui, server = server)

