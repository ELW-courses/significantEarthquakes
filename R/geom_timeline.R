########################################################################
#                                                                      #
#  geom for plotting significant earthquake data                       #
#  Author :  EL Williams                                               #
#  Project:  Coursera - Building Data Visualization Tools - Capstone   #
#  Date   :  2025-10-25                                                #
#                                                                      #
########################################################################

#' @title geom_timeline
#' @import ggplot2
#' @description geom_timeline plots a timeline of significant earthquakes
#' @details The graphic is a point-style plot showing significant earthquakes data orginating from the NOAA database
#' (url{https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1}.) Earthquake data should be cleaned, and may be
#' filtered, to a specified date range or country. Earthquakes can be stratified by a factor variable, and points can
#' be formatted by color, point size, or alpha level based on user-specified data columns.
#'
#' @param mapping aesthetics mapping
#'
#' @param data data to be used
#'
#' @param stat stat objected with default "identity"
#'
#' @param position position object with default "identity"
#'
#' @param na.rm handling of NA values, removal default to FALSE
#'
#' @param show.legend option to show or hide the legend with default set to FALSE
#'
#' @param inherit.aes option to inherit aesthetics specified
#'
#' @param ... additional parameters passed to the function call such as color, alpha, or size
#'
#' @return a layer containing a `Geom*` object responsible for rendering the point-style graphic
#'
#' @section Aesthetics:
#' \code{geom_timeline} understands the following aesthetics (required aesthetics are in bold):
#' \itemize{
#'   \item \strong{\code{x}} #Date variable
#'   \item \code{y}          #Factor indicating some stratification
#'   \item \code{color}      #Color of points
#'   \item \code{size}       #Size of points
#'   \item \code{alpha}      #Transparency (1: opaque; 0: transparent)
#' }
#' @examples
#' \dontrun{
#'#Basic plot:
#' quake_clean %>%
#'   ggplot() +
#'   geom_timeline(aes(x = Date)))
#'
#'#Australian earthquakes colored by magnitude:
#' quake_clean %>%
#'  filter(Country == "Australia") %>%
#'  ggplot() +
#'  geom_timeline(aes(x = Date, color = Magnitude))
#' }
#' @export
#'

geom_timeline <- function(mapping = NULL,
                          data = NULL,
                          stat = "identity",
                          position = "identity",
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE,
                          ...){
  ggplot2::layer(geom = GeomTimeline,
                 mapping = mapping,
                 data = data,
                 stat = stat,
                 position = position,
                 show.legend = show.legend,
                 inherit.aes = inherit.aes,
                 params = list(
                   na.rm = na.rm, ...))

}



#' @title GeomTimeline
#' @import ggplot2
#' @importFrom grid segmentsGrob pointsGrob gpar
#'
#' @param GeomTimeline `Geom*` name created to plot earthquake data
#'
#' @return point-style graphic showing a timeline of earthqaukes
#' @export
#'
GeomTimeline <- ggplot2::ggproto("GeomTimeline", ggplot2::Geom,
                                 required_aes = c("x"),
                                 default_aes = ggplot2::aes(y = 0.5,
                                                            color = "#333333",
                                                            size = 4.5,
                                                            stroke = 1,
                                                            alpha = 0.7), #Default values
                                 draw_key = ggplot2::draw_key_point,
                                 #
                                 draw_panel = function(data, panel_params, coord) {
                                   ## Transform data to plot:
                                   data <- coord$transform(data, panel_params)
                                   #
                                   #
                                   grid::gList(
                                     # Create line
                                     grid::segmentsGrob(x0 = min(data$x),
                                                        y0 = data$y,
                                                        x1 = max(data$x),
                                                        y1 = data$y,
                                                        gp = grid::gpar(
                                                          col = "#CDCDC1",
                                                          lwd = 1)
                                     ),
                                     # Create points
                                     grid::pointsGrob(x = data$x,
                                                      y = data$y,
                                                      pch = 19,
                                                      default.units = "native",
                                                      gp = grid::gpar(
                                                        fontsize = data$size* (.pt+2) + data$stroke * .stroke / 2,
                                                        col = data$colour,
                                                        alpha = data$alpha
                                                      ))
                                   )
                                 }
)
