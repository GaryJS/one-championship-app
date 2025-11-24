library(rvest)
library(tidyverse)
library(dplyr)
url <- "https://www.onefc.com/athletes/"

page <- read_html(url)


names <- page %>%
  html_nodes("h3") %>%
  html_text()


countries <- page %>%
  html_nodes(".country") %>%
  html_text()


athletes_df <- data.frame(Name = names, Country = countries, stringsAsFactors = FALSE)


print(athletes_df)








#####multiple pages

base_url <- "https://www.onefc.com/athletes/martial-art/muay-thai/page/"

all_athletes <- list()


for (i in 1:35) {
  url <- paste0(base_url, i)
  webpage <- read_html(url)
  
  
  names <- webpage %>%
    html_nodes("h3") %>%
    html_text()
  
  
  countries <- webpage %>%
    html_nodes(".country") %>%
    html_text()
  
  
  athlete_urls <- webpage %>%
    html_nodes(".content a.title") %>%
    html_attr("href")
  
  
  athletes_df1 <- data.frame(Name = names, Country = countries, URL = athlete_urls, stringsAsFactors = FALSE)
  all_athletes[[i]] <- athletes_df1
}


list_all_athletes <- bind_rows(all_athletes)


write.csv(list_all_athletes, "all_athletes_final.csv", row.names = TRUE)





#####DETAILED FIGHTER DATA


list_all_athletes <- read.csv("DSSA/all_athletes_final.csv")

detailed_data <- list()

for (i in 1:nrow(list_all_athletes)) {
  athlete_url <- list_all_athletes$URL[i]
  full_url <- athlete_url  
  
  cat("Scraping:", full_url, "\n")
  
  tryCatch({
    
    athlete_page <- read_html(full_url)
    
    weight <- tryCatch({
      athlete_page %>%
        html_node(".my-4.attributes .attr:contains('Weight Limit') .value") %>%
        html_text(trim = TRUE)
    }, error = function(e) NA)
    
    height <- tryCatch({
      athlete_page %>%
        html_node(".my-4.attributes .attr:contains('Height') .value") %>%
        html_text(trim = TRUE)
    }, error = function(e) NA)
    
    country <- tryCatch({
      athlete_page %>%
        html_node(".my-4.attributes .attr:contains('Country') .value a") %>%
        html_text(trim = TRUE)
    }, error = function(e) NA)
    
    age <- tryCatch({
      athlete_page %>%
        html_node(".my-4.attributes .attr:contains('Age') .value") %>%
        html_text(trim = TRUE)
    }, error = function(e) NA)
    
    team <- tryCatch({
      athlete_page %>%
        html_node(".my-4.attributes .attr:contains('Team') .value") %>%
        html_text(trim = TRUE)
    }, error = function(e) NA)
    
    
    fight_results <- c()
    fight_methods <- c()
    
    
    page_num <- 1
    has_more <- TRUE
    
    while (has_more) {
      cat("Scraping page:", page_num, "for", list_all_athletes$Name[i], "\n")
      
      
      if (page_num == 1) {
        page_url <- full_url
      } else {
        page_url <- paste0(full_url, "matchups/page/", page_num, "/")
      }
      
      
      current_page <- tryCatch(read_html(page_url), error = function(e) NULL)
      
      if (is.null(current_page)) {
        cat("Failed to read page, stopping...\n")
        break
      }
      
      
      record_rows <- current_page %>%
        html_nodes(".simple-table.is-flat.is-mobile-row-popup tr.is-data-row")
      
      if (length(record_rows) == 0) {
        cat("No more fight records found. Ending loop.\n")
        break
      }
      
      
      for (row in record_rows) {
        result <- tryCatch({
          row %>%
            html_node(".result div") %>%
            html_text(trim = TRUE)
        }, error = function(e) NA)
        
        method <- tryCatch({
          row %>%
            html_node(".method") %>%
            html_text(trim = TRUE)
        }, error = function(e) NA)
        
        
        fight_results <- c(fight_results, result)
        fight_methods <- c(fight_methods, method)
      }
      
      
      next_page_link <- current_page %>%
        html_node("a.load-more[href*='matchups/page']") %>%
        html_attr("href")
      
      if (is.na(next_page_link) || next_page_link == "") {
        has_more <- FALSE
      } else {
        page_num <- page_num + 1
      }
    }
    
    
    if (length(fight_results) > 0) {
      athlete_df <- data.frame(
        Name = rep(list_all_athletes$Name[i], length(fight_results)),
        Country = rep(list_all_athletes$Country[i], length(fight_results)),
        Weight = rep(weight, length(fight_results)),
        Height = rep(height, length(fight_results)),
        Age = rep(age, length(fight_results)),
        Team = rep(team, length(fight_results)),
        Fight_Result = fight_results,
        Fight_Method = fight_methods,
        stringsAsFactors = FALSE
      )
      
      detailed_data[[i]] <- athlete_df
    } else {
      
      athlete_df <- data.frame(
        Name = list_all_athletes$Name[i],
        Country = list_all_athletes$Country[i],
        Weight = weight,
        Height = height,
        Age = age,
        Team = team,
        Fight_Result = NA,
        Fight_Method = NA,
        stringsAsFactors = FALSE
      )
      
      detailed_data[[i]] <- athlete_df
    }
    
  }, error = function(e) {
    cat("Error scraping athlete:", list_all_athletes$Name[i], "\n")
  })
  
  Sys.sleep(2)  
}


final_athlete_data <- bind_rows(detailed_data)


write.csv(final_athlete_data, "all_fighter_data_final.csv", row.names = FALSE)


print(final_athlete_data)


