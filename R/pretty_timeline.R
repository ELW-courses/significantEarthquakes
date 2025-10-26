########################################################################
#                                                                      #
#  Function for output of pretty timeline of earthquake data           #
#  Author :  EL Williams                                               #
#  Project:  Coursera - Building Data Visualization Tools - Capstone   #
#  Date   :  2025-10-26                                                #
#                                                                      #
########################################################################

#' @title pretty_timeline
#' @import ggplot2
#' @import lubridate
#' @import dplyr
#' @import scales
#' @description Modify Existing Timeline Plot Formatting
#' @details This function modifes an existing timeline plot created using geom_timeline() of significant earthquake
#' data from NOAA's significant eathquake database (url{https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1}).
#' The base plot should already exist. This function allows for consistent plot formatting.
#'
#' @param df cleaned data frame of earthquake data
#'
#' @param plot existing ggplot object to apply formatting to
#'
#' @param timeline_y if data was split on the y-axis by a factor column (TRUE/FALSE)
#'
#' @return modified timeline plot of earthquake data
#' @examples
#' \dontrun{
#'Argentina_data <- eq_filtering(quake_clean, SelectedCountry = "Argentina", groupingBy = c("Deaths", "Magnitude"))
#'Arg_plot <- Argentina_data %>%
#' ggplot() +
#' geom_timeline(aes(x = Date, color = Magnitude, y = Deaths))
#'pretty_timeline(df = Argentina_data, plot = Arg_plot, timeline_y = TRUE)
#' }
#' @export
#'

pretty_timeline <- function(df, plot, timeline_y = FALSE){
  # Get date limits
  data_limits <- df %>%
    # Get min and max dates
    summarise(minDate = min(Date),
              maxDate = max(Date)) %>%
    # Round to nearest month
    mutate(minDate = lubridate::floor_date(.data$minDate, "month"),
           maxDate = lubridate::ceiling_date(.data$maxDate, "month"))
  #
  # Both plots
  base_plot <- plot +
    theme_classic()+
    theme(legend.position = "top",
          axis.title.x = element_text(size = 18),
          axis.text.x = element_text(size = 14),
          axis.line.x = element_line(size = 1))
  # scaling axes
  base_plot <- base_plot +
    scale_x_datetime(limits = c(as.POSIXct(data_limits$minDate), as.POSIXct(data_limits$maxDate)),
                     breaks = scales::breaks_pretty(6),
                     expand = c(0.02,0))
  #
  if(timeline_y == FALSE){
    base_plot <- base_plot +
      # Remove all evidence of y-axis
      theme(axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.line.y = element_blank(),
            axis.ticks.y = element_blank())
  } else {
    base_plot <- base_plot +
      theme(axis.title.y = element_text(size = 18),
            axis.text.y = element_text(size = 14),
            axis.line.y = element_line(size = 1))
  }
  return(base_plot)
  print(base_plot)
}

