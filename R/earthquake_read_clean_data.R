########################################################################
#                                                                      #
#  Functions for loading and cleaning earthquake data                  #
#  Author :  EL Williams                                               #
#  Project:  Coursera - Building Data Visualization Tools - Capstone   #
#  Date   :  2025-10-24                                                #
#                                                                      #
########################################################################

#' @title eq_clean_data
#' @import readr
#' @import dplyr
#' @description load and clean earthquake data
#' @details This function takes either a file path with file name or already loaded data frame object. If a file path
#' is provided, the existence of a file at the specified path is checked, then the file is loaded and cleaned. If an
#' already loaded data frame object is provided, the data is cleaned. Data cleaning includes creating a date column,
#' noting if year is  BC or AD, and making sure latitude and longitude are numeric columns.
#'
#' @param filepath file path and name of file to load
#' @param df loaded data to work with
#'
#' @return tibble of earthquake data
#' @examples
#' \dontrun{
#' #Loading file
#' quake_data <- eq_clean_data(filepath = "inst/extdata/earthquakes.tsv")
#'
#' #Working with loaded data
#' quake_data <- eq_clean_data(df = earthquakes)
#' head(quake_date)
#' }
#' @export
#'

eq_clean_data <- function(filepath = NA, df = NA){
  #Check and load file, or work with already loaded data
  if(!is.na(filepath) && !is.na(df)) {
    stop("Either filepath or df must be provided")
  }
  #
  if(!is.na(filepath)){
    # Check for file existence
    if(!file.exists(filepath)){
      stop("file '", filepath, "' does not exist")
    }
    #
    eq_data <- readr::read_delim(filepath, name_repair = "universal_quiet")
    #
  } else if(is.na(filepath) && is.data.frame(df)){
    eq_data <- df
  }
  #
  eq_data <- eq_data %>%
    # Create Date from modified year (Yr), making note of age
    dplyr::mutate(Yr = as.numeric(ifelse(Year < 0, Year *-1, Year)),
                  Age = as.factor(ifelse(Year < 0, "BC", "AD")),
                  Date = paste(Yr, ifelse(is.na(Mo), 01, Mo), ifelse(is.na(Dy), 01, Dy), sep = "-"), .before = Year) %>%
    dplyr::mutate(Date = as.Date(Date, format = "%Y-%m-%d")) %>%
    # Remove `Search Parameters`, Yr column
    dplyr::select(-Yr) %>%
    filter(!is.na(Date)) %>%
    # Set column types
    dplyr::mutate(across(any_of(c("Latitude", "Longitude")), ~as.numeric(as.character(.))))
  #
  return(eq_data)
  #
}
#
#
#
#' @title eq_location_clean
#' @import tidyverse
#' @description set Location as country
#' @details This function takes an earthquake data set, checks for the existence of a Location*Name columns, then
#' extracts the country from the location column. The country is saved as the Location*Name data.
#'
#' @param df data frame containing earthquake data
#'
#' @return tibble of earthquake data
#' @examples
#' \dontrun{
#' quake_data <- eq_location_clean(eq_date)
#' head(quake_date)
#' }
#' @export
#'

eq_location_clean <- function(df){
  # Check for location column
  matching_column <- names(df) %>% str_subset("Location.*Name|Name.*Location")
  if (length(matching_column) == 0) {
    stop("No column containing both 'Location' and 'Name' found in the dataset")
  }
  # Extract country from location name
  df <- df %>%
    mutate(Country = stringr::str_to_title(sub(":.*", replacement = "", !!sym(matching_column))),
           State = stringr::str_to_title(sub(".:*", replacement = "", !!sym(matching_column))))
  return(df)
}
