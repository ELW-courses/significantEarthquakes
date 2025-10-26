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
#'   eq_map(annot_col = "Date")
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
    dplyr::mutate(popup_text = sprintf(
      '<div style="padding: 8px; font-family: Arial, sans-serif;">
        <span style="font-size: 13px; font-weight: bold;">%s:</span>&nbsp;
        <span style="font-size: 12px;">%s</span>
      </div>',
      annot_col, .[[annot_col]])
    )
  # Map data
  df %>%
    leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addCircles(popup = lapply(df$popup_text, htmltools::HTML),
                        color = "red",
                        opacity = 0.85,
                        weight = 1,
                        radius = ~Magnitude*5000)

}

