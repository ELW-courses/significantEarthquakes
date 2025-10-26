########################################################################
#                                                                      #
#  geom for adding labels to significant earthquake timeline plots     #
#  Author :  EL Williams                                               #
#  Project:  Coursera - Building Data Visualization Tools - Capstone   #
#  Date   :  2025-10-25                                                #
#                                                                      #
########################################################################

#' @title geom_timeline_labels
#' @import ggplot2
#' @description geom_timeline_labels adds a label to a timeline of significant earthquakes
#' @details The graphic is a text-style plot adding labels to points of a significant earthquakes timeline plot using
#' data orginating from the NOAA database (url{https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1}.) Labels
#' require for size = Magnitude to be specified.
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
#'   \item \strong{\code{x}}     #Date variable
#'   \item \strong{\code{label}} #Factor for adding text labels
#'   \item \code{y}              #Factor indicating some stratification
#'   \item \code{n_max}          #Number of earthquake labels to show, ranked by magnitude
#'   \item \code{y_length}       #vertical line length to each data point
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
#'  geom_timeline(aes(x = Date, color = Magnitude))+
#'  geom_timeline_labels(aes(x = Date, label = Locale, size = Magnitude), n_max = 10)
#' }
#' @export
#'

geom_timeline_labels <- function(mapping = NULL,
                                 data = NULL,
                                 stat = "identity",
                                 position = "identity",
                                 na.rm = FALSE,
                                 show.legend = FALSE,
                                 inherit.aes = TRUE,
                                 ...){
  ggplot2::layer(geom = GeomTimelineLabels,
                 mapping = mapping,
                 data = data,
                 stat = stat,
                 position = position,
                 show.legend = show.legend,
                 inherit.aes = inherit.aes,
                 params = list(
                   na.rm = na.rm, ...))

}



#' @title GeomTimelineLabels
#' @import ggplot2
#' @importFrom grid segmentsGrob pointsGrob gpar
#'
#' @param GeomTimelineLabels `Geom*` name created to add lables to earthquake data
#'
#' @return text-style graphic with labels
#' @export
#'
GeomTimelineLabels <- ggplot2::ggproto("GeomTimelineLabels", ggplot2::Geom,
                                       required_aes = c("x",
                                                        "label"),
                                       default_aes = ggplot2::aes(y = 0.5,
                                                                  size = 0,
                                                                  n_max = 0,
                                                                  y_length = 0.1), #Default values
                                       draw_key = ggplot2::draw_key_point,
                                       #
                                       draw_panel = function(data, panel_params, coord) {
                                         #

                                         #If size is not specified
                                         if(data$n_max[1] != 0){
                                           #And plot isn't factored
                                           if(data$y[1] == 0.5){
                                             data <- data %>%
                                               dplyr::arrange(desc(size)) %>%
                                               dplyr::slice(1:data$n_max[1])
                                           } else {
                                             data <- data %>%
                                               dplyr::arrange(desc(size)) %>%
                                               dplyr::group_by(~y) %>%
                                               dplyr::slice(1:data$n_max[1])
                                           }
                                         }
                                         #
                                         if (!data$y[1]==0){
                                           data$y_length<-dim(table(data$y))
                                         }

                                         ## Transform data to plot:
                                         data <- coord$transform(data, panel_params)
                                         #
                                         #
                                         grid::gList(
                                           # Create line
                                           grid::segmentsGrob(x0 = data$x,
                                                              y0 = data$y,
                                                              x1 = data$x,
                                                              y1 = data$y+(.18/data$y_length),
                                                              gp = grid::gpar(
                                                                col = "#666666",
                                                                lwd = 1)
                                           ),
                                           # Create points
                                           grid::textGrob(x = data$x,
                                                          y = data$y+(.2/data$y_length),
                                                          label = data$label,
                                                          just = "left",
                                                          rot = 30,
                                                          default.units = "native",
                                                          gp = grid::gpar(
                                                          ))
                                         )
                                       }
)
#
