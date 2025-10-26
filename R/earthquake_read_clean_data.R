########################################################################
#                                                                      #
#  Functions for loading, cleaning, and filtering earthquake data      #
#  Author :  EL Williams                                               #
#  Project:  Coursera - Building Data Visualization Tools - Capstone   #
#  Date   :  2025-10-24                                                #
#                                                                      #
########################################################################

#' @title eq_clean_data
#' @import readr
#' @import dplyr
#' @description Load and Clean Earthquake Data
#' @details This function takes either a file path with file name or already loaded data frame object. If a file path
#' is provided, the existence of a file at the specified path is checked, then the file is loaded and cleaned. If an
#' already loaded data frame object is provided, the data is cleaned. Data cleaning includes creating a date column,
#' noting if year is  BC or AD, and making sure latitude and longitude are numeric columns.
#'
#' @param filepath file path and name of file to load
#'
#' @param df loaded data to work with
#'
#' @return tibble of earthquake data
#' @examples
#' \dontrun{
#' #Loading file
#' quake_data <- eq_clean_data(filepath = "inst/extdata/earthquakes.tsv")
#'
#' #Working with loaded data
#' quake_data <- eq_clean_data(earthquakes)
#' head(quake_data)
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
    dplyr::mutate(Yr = as.numeric(ifelse(.data$Year < 0, .data$Year *-1, .data$Year)),
                  Age = as.factor(ifelse(.data$Year < 0, "BC", "AD")),
                  Date = paste(.data$Yr, ifelse(is.na(.data$Mo), 01, .data$Mo), ifelse(is.na(.data$Dy), 01, .data$Dy), sep = "-"), .before = .data$Year) %>%
    dplyr::mutate(Date = as.Date(.data$Date, format = "%Y-%m-%d")) %>%
    # Remove Yr column, remove any odd columns due to loading
    dplyr::select(-.data$Yr) %>%
    filter(!is.na(.data$Date)) %>%
    # Rename columns for clarity
    rename("Month" = .data$Mo, "Day" = .data$Dy, "Hour" = .data$Hr,  "Minute" = .data$Mn, "Seconds" = .data$Sec,
           "Tsunami" = .data$Tsu, "volcano" = .data$Vol, "Magnitude" = .data$Mag) %>% # Set column types
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
#' @import stringr
#' @import maps
#' @description Addition of Country to Earthquake Data
#' @details This function takes an earthquake data set, checks for the existence of a Location*Name columns, then
#' extracts the country from the location column into a new 'Country' column. Additionally, a 'Locale' column is
#' created for within country location specification if applicable.
#' Special case handling currently includes: United Kingdom, United States
#'
#' @param df data frame containing earthquake data
#'
#' @return tibble of earthquake data
#' @examples
#' \dontrun{
#' quake_data <- eq_location_clean(eq_date)
#' head(quake_data)
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
    mutate(Country = case_when(
      #United Kingdom
      str_detect(!!sym(matching_column), regex("United Kingdom", ignore_case = TRUE)) ~ str_trim(str_extract(!!sym(matching_column), "(?<=:)[^:]+(?=:)")),
      str_detect(!!sym(matching_column), regex("Uk:|UK:", ignore_case = TRUE)) ~ "England", #Special case
      #United States
      str_detect(!!sym(matching_column), regex(sprintf("\\b(%s)\\b", paste(setdiff(state.name, "Georgia"), collapse = "|")), ignore_case = TRUE)) ~ "United States",
      # Everything else
      TRUE ~ str_trim(sub(":.*", replacement = "", !!sym(matching_column)))), .before = !!sym(matching_column)) %>%
    mutate(Locale = case_when(
      Country == "United States" ~ str_trim(sub(":.*", replacement = "", !!sym(matching_column))),
      TRUE ~ str_trim(str_extract(!!sym(matching_column), "(?<=:).+"))), .before = !!sym(matching_column)) %>%
    mutate(Country = stringr::str_to_title(.data$Country), Locale = str_to_title(.data$Locale))
  return(df)
}
#
#
#
#' @title eq_filtering
#' @import tidyverse
#' @import stringr
#' @description Filter Earthquake Data to Desired Country and Data Columns
#' @details This function takes a cleaned earthquake data set and filters data to optional date ranges and country
#' of occurrence. A Locale column and the Magnitude column is included in the output An optional 'groupingBy'
#' parameter allows for the additional selection of specified data columns in output.
#'
#'
#' @param df data frame containing earthquake data
#'
#' @param MinDate optional minimum date string of data to include
#'
#' @param MaxDate optional maximum date string of data to include
#'
#' @param SelectedCountry optional name of country to filter data by
#'
#' @param groupingBy optional list of other data columns to include
#'
#' @return tibble of filtered earthquake data
#'
#' @note Filtering function should only be used for producing timeline figures, not leaflet maps created using eq_map()
#'
#' @examples
#' \dontrun{
#' # Selection of earthquakes within Argentina
#' Argentina_data <- eq_filtering(quake_data,
#'  SelectedCountry = "Argentina")
#'
#' # Selection of earthquakes within Argentina since 1930
#' Argentina_data <- eq_filtering(quake_data,
#'  SelectedCountry = "Argentina", MinDate = "1930-01-01")
#'
#' # Selection of earthquakes within Argentina with magnitude
#' Argentina_data <- eq_filtering(quake_data,
#'  SelectedCountry = "Argentina", groupingBy = c("Magnitude"))
#' }
#' @export
#'

eq_filtering <- function(df, MinDate = NULL, MaxDate = NULL, SelectedCountry = NULL, groupingBy = NULL){
  # starting checks
  stopifnot(
    is.data.frame(df)
  )
  #
  # Get date bounds from data if not provided
  if (is.null(MinDate) | is.null(MaxDate)) {
    date_range <- range(df$Date, na.rm = TRUE)
    if (is.null(MinDate)) MinDate <- date_range[1]
    if (is.null(MaxDate)) MaxDate <- date_range[2]
  }
  # Convert dates with error handling
  min_date <- suppressWarnings(as.POSIXct(MinDate))
  max_date <- suppressWarnings(as.POSIXct(MaxDate))
  stopifnot(
    !is.na(min_date),
    !is.na(max_date),
    min_date <= max_date
  )
  #
  # Validate groupingBy columns
  if (!is.null(groupingBy)) {
    valid_columns <- names(df)
    invalid_cols <- setdiff(groupingBy, valid_columns)
    stopifnot(length(invalid_cols) == 0)
  }
  ## Clean data to plot
  data_to_plot <- df %>%
    # Select date and columns to plot by
    dplyr::select(Date, .data$Country, .data$Locale, .data$Magnitude, any_of(groupingBy)) %>%
    # Filter to specified date range and country
    filter(Date >= min_date & Date <= max_date) %>%
    filter(if(!is.null(SelectedCountry)){
      .data$Country == paste(stringr::str_to_title(SelectedCountry))
    } else {
      TRUE
    }) %>%
    # Modify for plot aesthetics
    mutate(across(any_of(groupingBy), factor)) %>%
    tidyr::drop_na(all_of(groupingBy))
  #
  return(data_to_plot)
  #
}
