# v2QAQC_MultiVar_Dashboard_Prototype_March_5_2024

---
title: "README_v7_Prototype"
author: "Gabriel Aliteri"
date: "2024-05-28"
output: html_document
---

The premise of this tool is to act as a v1 dashboard for nursery operations -- regarding seedling measurement and analysis per QAQC. This tool was created in RStudio, using the Shiny Application. It is best utilized via web application: http://gabrielaltieri.shinyapps.io/v6_MultiVar_SeedlingMeasurment_DashPrototype_May2024. Although, if you have access to RStudio or R Desktop, users are welcome to download the raw txt file, upload it to R, and run the script to use the application via R.

In order for this tool to function properly, you will need either download and then upload, or solely upload the .xlsx file for the nursery in which you are tracking seedling morphology for, i.e. Cal Forest or Silvaseed. Once the file is uploaded, users will be able to toggle between species, seed lot(s), reading(s), and variable of interest (i.e. Mean, Median, Mode). Additionally, the application will also allow users to choose between height or root collar diameter (RCD). Note, when using the application, you can click on one seedlot to evaluate, or multiple. If you are looking to get cancel out of a single lot, simply click on the lot of interest and hit 'Delete' on your keyboard. 

Below, I will include a step-by-step process on how to run the application:

Instructions
0. MacOS 12 - Monterey
1. Download QAQC 2024 Seedling Measurements - Cal Forest.xlsx from: 
https://docs.google.com/spreadsheets/d/1wY06_2PeuIYWoElikYkDjyaPTd6hME9aYVJw6cqQheA/edit?usp=sharing
2. Download QAQC 2024 Seedling Measurements - Silvaseed.xlsx from:
https://docs.google.com/spreadsheets/d/1niPlApdTunDwALSfHBTN4wl_ZCfDNcAIFhjp3OVyoxI/edit?usp=sharing
3. Save (1) into C:\QAQC\2024SeedlingMeasurements
4. Ensure that you have dated the saved file, as these xlsx files will be released by the QAQC team on a bi-weekly basis. 
5. Running scripts requires R with libraries here, shiny, ggplot, readxl, and dplyr. If not already installed, get from https://www.r-project.org/ and follow standard install and use install_packages() for libraries. Alternative, use RStudio, which will assist with library installation and run scripts within RStudio.
6. All of the variables, columns, and cells within the sheet should be pre-set therefore all you will need to do is upload the xlsx file downloaded and saved on your desktop. 
7. Once you upload the '.xlsx' file, you will be prompted by the following inputs: 'Select Data Range' 'Select Species', 'Select Seed Lot', 'Select Measurement', and 'Select Summary Type'. 
8. First, you must set the date range in which you would like to be evaluating the data from. This data range will allow you to choose any timeline associated with seedling morphometric data that has previously or currently been collected. 
9. Once a date range has been decided, only the species and seed lots that have data points within the specified date range will be detected by the Shiny app. 
10. Next, choose the species that you would like to evaluate, for example DF / PSME.
11. After choosing the species, the seed lot input will autopopulate with all of the species defined under 'DF / PSME' in the xlsx file.
12. You will have the option to choose a single lot within the selected species, or multiple lots. If you decide to choose multiple lots, you can click on any lots that you desire. If you choose to cut a lot from the graph, you can click on the lot and press the 'Delete' key. 
13. After choosing the lot(s), you will be able to adjust the reading or days post-sow (DPS) slider based on your timeline preference(s).
14. Next, you will be able to determine which measurement type you would like to evaluate. There are two options: 1. Seedling Height, 2. Seedling Root Collar Diameter (RCD).
15. Last, you will be able to determine the summary type that you would like the graph to represent and display. There are three summary types: 1. Mean, 2. Median, 3. Mode. 
16. Once your variables have been defined, the graph will adjust and represent based on your choices. 
17. Thank you, and if you have any questions, comments or concerns, please reach out to Gabriel Altieri - altierigabriel@gmail.com
---
