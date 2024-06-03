# Nursery-QAQC-Seedling-Morphometric-Data-Visualization-Prototype

The premise of this tool is to act as a v1 dashboard for nursery operations -- regarding seedling morphometric measurement and analysis for Mast Reforestations QAQC program. This tool was created in RStudio, using the Shiny Application. It is best utilized via web application: http://gabrielaltieri.shinyapps.io/v6_MultiVar_SeedlingMeasurment_DashPrototype_May2024. Although, if you have access to RStudio or R Desktop, users are welcome to download the raw txt file, upload it to R, and run the script to use the application via R.

This tools primary utility is to allow nursery stakeholders at Mast Reforestation to quickly and effectively monitor and evaluate seedling morphometric (height and root collar) growth over time following endured data collections.

If you have any questions, comments or concerns regarding the Shiny application, please reach out to Gabriel Altieri - altierigabriel@gmail.com


# v1.01 Updates 

Two new deployable versions of this application have been developed. 'SF' or short-form and 'LF' or 'long-form. 

The short-form (SF) application allows a user to upload a data sheet that has inidivudal seed lots or datapoints broken up by individual sheets within the master excel file. This is cleaner for organizational purpsoes when collecting and compiling the data. Although can be more challenging for data visualization. This uses a binding function to bind all like species, regardless of seed lots. 

The long-form (LF) application allows a user to upload a data sheet that has all of the collected and compiled datapoints into one sheet. It doesn't matter how the data is oriented. This one not organized at all, but may be quicker to pull for data visualization.

