# ONE Championship Muay Thai Dashboard 🥊  
Interactive Shiny dashboard exploring Muay Thai athletes in the ONE Championship.

🔗 **Live App:**  
https://gary-sanangelo.shinyapps.io/Assignment_4/

---

## Table of Contents  
1. [Project Summary](#project-summary)  
2. [Project Environment](#project-environment)  
3. [Scope & Project Steps](#scope--project-steps)  
4. [Data Sources & Data Gathering](#data-sources--data-gathering)  
5. [Exploratory Data Analysis & Data Manipulation](#exploratory-data-analysis--data-manipulation)  
6. [Defining The Data Model](#defining-the-data-model)  
7. [ETL](#etl)  
8. [Detailed Project Discussion](#detailed-project-discussion)  
9. [Supporting Functions & Code](#supporting-functions--code)  
10. [Tech Stack](#tech-stack)  
11. [How to Run Locally](#how-to-run-locally)  
12. [License](#license)

---

## Project Summary  
This project presents a dashboard that allows users to explore fighters competing in the **ONE Championship Muay Thai division**.  
Users can filter by:
- Country  
- Weight Class  
- Gym / Team  
- Win Method (KO/TKO vs Decision)

The dashboard provides a visual, interactive summary of fighter profiles, performance history, and gym representation.

---

## Project Environment  
- **R / RStudio** (development environment)  
- **flexdashboard + shiny** for dashboard interactivity  
- **tidyverse, dplyr, ggplot2** for data transformation & visualization  
- **shinyapps.io** for cloud deployment  
- GitHub repository: https://github.com/GaryJS/one-championship-app

---

## Scope & Project Steps  

### **Scope**
- Build an interactive browser-based dashboard showcasing ONE Championship Muay Thai fighters  
- Provide insights on global representation, win-type patterns, and gym affiliations  
- Showcase scraping, data cleaning, and Shiny interactivity for portfolio use  

### **Steps**
1. Scrape Muay Thai fighter list + profile URLs  
2. Scrape each fighter’s individual stats and fight history  
3. Combine & clean data into `all_fighter_data_final.csv`  
4. Build a Shiny flexdashboard for exploration  
5. Deploy app publicly on shinyapps.io  
6. Document all steps for portfolio presentation  

---

## Data Sources & Data Gathering  
The dataset is generated entirely through web scraping using **rvest**.

Data gathering happens in **two phases**:

### **1. Scraping Muay Thai fighter index pages**
- Base URL:  
  `https://www.onefc.com/athletes/martial-art/muay-thai/page/`
- Looped through pages **1 to 35**
- Extracted for each fighter:
  - Name (`<h3>`)
  - Country (`.country`)
  - Profile URL (`.content a.title[href]`)
- Combined into:  
  **`all_athletes_final.csv`**

### **2. Scraping detailed fighter profile pages**
For each fighter profile:
- Extracted:
  - Weight Limit  
  - Height  
  - Country  
  - Age  
  - Team / Gym  
- Then followed **matchups pagination**, scraping full fight history:
  - `Fight_Result` (Win, Loss, No Contest, etc.)  
  - `Fight_Method` (KO, TKO, Decision, etc.)  

Each fighter’s results were appended into a single unified dataset.

Final output:  
📁 **`all_fighter_data_final.csv` — used by the Shiny app**

---

## Exploratory Data Analysis & Data Manipulation  
Before building the dashboard, the dataset was cleaned and summarized:

- Standardized gym names  
- Removed incomplete or malformed fight pages  
- Extracted weight classes into a usable format  
- Grouped fighters by:
  - Country  
  - Gym  
  - Win type  
  - Weight class  
- Summarized total:
  - KO/TKO wins  
  - Decision wins  
  - Fight counts  
- Filtered data to *only Muay Thai fighters*

This cleaned dataset is what drives the Shiny dashboard.

---

## Defining The Data Model  

### **Entities**
- **Fighter**  
  - Name  
  - Country  
  - Team / Gym  
  - Height  
  - Weight Class  
  - Age  

- **Fight Record**  
  - Result  
  - Method  

### **Relationship**
Each fighter can have **multiple** fight records (1:N).  
The final CSV is essentially a **flattened star-schema** with fighter attributes duplicated across their fights.

---

## ETL  

### **Extract**
- Scraped Muay Thai fighter list across 35 index pages  
- Scraped each fighter’s profile URL  
- Scraped matchups from additional paginated pages  
- All web scraping done with `rvest::read_html()`

### **Transform**
- Cleaned missing fields using `tryCatch()` for robustness  
- Standardized:
  - Country names  
  - Weight classes  
  - Gym names  
- Created a structured row per fight event  
- Merged fighter attributes + fight history  
- Applied rate limiting (`Sys.sleep(2)`) to avoid overloading the server

### **Load**
- Final combined dataset written to:  
  **`all_fighter_data_final.csv`**

This CSV serves as the backend data source for `assignment3.Rmd`.

---

## Detailed Project Discussion  
This section explains the design decisions behind the dashboard:

- **Filtering Logic**  
  Uses `shinyWidgets::pickerInput()` for multi-select filtering of countries, gyms, and weight classes.

- **Reactive Summaries**  
  `dplyr` pipelines inside reactive expressions keep the app responsive even with many fighters.

- **Visualizations**
  - KO/TKO vs Decision bar chart  
  - Fighters by country  
  - Fighter distribution by gym  
  - Filtering combinations update all graphs instantly  

- **UI Layout**
  - Built in flexdashboard for a cleaner layout  
  - Sidebar controls + main content area  
  - Dark theme styling for readability  

- **Deployment Notes**  
  Deployed to shinyapps.io using `rsconnect::deployApp()`  
  Free tier → app sleeps after inactivity but wakes automatically.

---
