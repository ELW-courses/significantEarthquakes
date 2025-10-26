########################################################################
#                                                                      #
#  Functions for mapping earthquake data                               #
#  Author :  EL Williams                                               #
#  Project:  Coursera - Building Data Visualization Tools - Capstone   #
#  Date   :  2025-10-26                                                #
#                                                                      #
########################################################################

#' @title eq_map
#' @import leaflet
#' @import magrittr
#' @importFrom dplyr mutate
#' @importFrom htmltools HTML
#' @description Create Leaflet Map of Earthquake Data
#' @details This function creates a leaflef map of cleaned significant earthquake data from  NOAA's significant
#' eathquake database (url{https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1}). Data should be cleaned
#' using eq_clean_data() and eq_location_clean() for best usage. An annotation column can be specified for including
#' in a popup for the earthquake points.
#'
#' @param df cleaned data to work with
#'
#' @param annot_col specific column to include in map popup
#'
#' @return leaflet map of earthquake locations
#' @examples
#' \dontrun{
#' eq_clean_data(filepath = "inst/extdata/earthquakes.tsv") %>%
#'   eq_location_clean() %>%
#'   dplyr::filter(Country == "Mexico" & Date >= 2000) %>%
#'   dplyr::mutate(popup = eq_create_label(.)) %>%
#'   eq_map(annot_col = "popup")
#' }
#' @export
#'

eq_map <- function(df, annot_col){
  # Validate data and column exists
  stopifnot(
    !is.null(df),
    is.data.frame(df),
    length(annot_col) == 1,
    annot_col %in% names(df)
  )
  #
  # Add popup info to data frame
  df <- df %>%
    rename_with(
      ~ case_when(
        str_detect(.x, regex("lat", ignore_case = TRUE)) ~ "latitude",
        str_detect(.x, regex("long", ignore_case = TRUE)) ~ "longitude",
        TRUE ~ .x
      )) %>%
    dplyr::mutate(popup_text = if(!any(grepl("popup", names(.data$.)))){
      sprintf(
      '<div style="padding: 8px; font-family: Arial, sans-serif;">
      <span style="font-size: 13px; font-weight: bold;">%s:</span>&nbsp;
      <span style="font-size: 12px;">%s</span>
      </div>',
      annot_col, .[[annot_col]])
    } else {
      # Find the first column containing "popup"
      popup_col <- names(.data$.)[grepl("popup", names(.data$.))][1]
      # Copy the content of the popup column to popup_text
      .[[popup_col]]
    }
    )
  # Map data
  df %>%
    leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addCircles(lng = df$longitude, lat = df$latitude,
                        popup = lapply(df$popup_text, htmltools::HTML),
                        color = "red",
                        opacity = 0.85,
                        weight = 1,
                        radius = ~Magnitude*5000)

}

#' @title eq_create_label
#' @description Create Leaflet Popup with Location, Magnitude, and Total Deaths
#' @details This function creates a base option for more interesting leaflef map popups for cleaned significant
#' earthquake data. Popups created using this function will include location name(s) where earthquake occurred,
#' the magnitude of the earthquake, and the total deaths attributed to the earthquake.
#'
#' @param df cleaned earthquake data
#'
#' @return modified data frame
#' @examples
#' \dontrun{
#' eq_clean_data(filepath = "inst/extdata/earthquakes.tsv") %>%
#'   eq_location_clean() %>%
#'   dplyr::filter(Country == "Mexico" & Date >= 2000) %>%
#'   dplyr::mutate(popup = eq_create_label(.)) %>%
#'   eq_map(annot_col = "popup")
#' }
#' @export
#'

eq_create_label <- function(df) {
  # Create formatted strings for each field with NA handling
  location_str <- ifelse(!is.na(df$Locale),
                         sprintf('<span style="font-size: 13px; font-weight: bold;">Location:</span>&nbsp;
                                 <span style="font-size: 12px;">%s</span><br>',
                                 df$Locale),
                         '')

  magnitude_str <- ifelse(!is.na(df$Magnitude),
                          sprintf('<span style="font-size: 13px; font-weight: bold;">Magnitude:</span>&nbsp;
                                  <span style="font-size: 12px;">%.1f</span><br>',
                                  df$Magnitude),
                          '')

  deaths_str <- ifelse(!is.na(df$Deaths),
                       sprintf('<span style="font-size: 13px; font-weight: bold;">Total deaths:</span>&nbsp;
                               <span style="font-size: 12px;">%s</span><br>',
                               df$Deaths),
                       '')

  # Combine all parts into final formatted div
  paste(sprintf(
    '<div style="padding: 8px; font-family: Arial, sans-serif;">
      %s%s%s
    </div>',
    location_str,
    magnitude_str,
    deaths_str
  ))
}
