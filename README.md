
<!-- README.md is generated from README.Rmd. Please edit that file -->

# significantEarthquakes

<!-- badges: start -->

<!-- badges: end -->

The **significantEarthquakes** package was developed for the capstone
course of the “Mastering Software Development in R Specialization” by
Johns Hopkins University on Coursera.

Earthquake data originates from the National Oceanic and Atmospheric
Administration’s earthquakes database: National Geophysical Data Center
/ World Data Service (NGDC/WDS): NCEI/WDS Global Significant Earthquake
Database. NOAA National Centers for Environmental Information.
<doi:10.7289/V5TD9V7K>

Downloading data from the database results in a *.tsv* file. Once the
raw file is located where the user can easily locate and load the data
file, this package can be used to clean the data.

## Installation

You can install and use the development version of
**significantEarthquakes** with:

``` r
# install.packages("pak")
pak::pak("ELW-courses/significantEarthquakes")
library(significantEarthquakes)
```

Data pulled from the website on October 23, 2025 is provided in the
package and is used for all examples.

## Data cleaning and filtering

A function, `eq_clean_data()`, is provided for basic cleaning of the raw
earthquake data. Either a file path can be specified, in which case the
file is loaded then cleaned, or a currently loaded data object can be
specified for cleaning.

``` r
library(significantEarthquakes)
#Loading file
quake_data <- eq_clean_data(filepath = "inst/extdata/earthquakes.tsv")

#Working with loaded data
quake_data <- eq_clean_data(df = earthquakes)
```

An additional function, `eq_location_clean()`, is provided to extract
the Country and Locale in which the earthquake occurred from the
location data column.

``` r
quake_data <- eq_location_clean(eq_date)
```

Before plotting earthquake data, a cleaned data frame can be filtered
using the `eq_filtering()` function. This function provides optional
filtering by country in which the earthquake occurred, minimum date for
plotting, and maximum date for plotting. The user can optionally supply
additional columns to include in the filtered data output for ease when
plotting.

``` r
# Selection of earthquakes within Argentina
Argentina_data <- eq_filtering(quake_data, SelectedCountry = "Argentina")

# Selection of earthquakes within Argentina since 1930
Argentina_data <- eq_filtering(quake_data, SelectedCountry = "Argentina", MinDate = "1930-01-01")

# Selection of earthquakes within Argentina with magnitude
Argentina_data <- eq_filtering(quake_data, SelectedCountry = "Argentina", groupingBy = c("Magnitude"))
```

## Earthquake timeline

Significant earthquakes can be plotted on a timeline showing when
earthquakes occurred by using `geom_timeline()`. This `geom_*` requires
that earthquake data be cleaned using `eq_clean_data()` and
`eq_location_clean` so that a date column and country column are
present. Data can futher be filtered using `eq_filtering()` to limit
data to a specific country, date range, and user-specified data columns.

``` r
# Plotting cleaned data:
quake_clean %>%
  ggplot() +
  geom_timeline(aes(x = Date)))

# Plotting earthquakes in Australia colored by magnitude:
quake_clean %>%
  filter(Country == "Australia") %>%
  ggplot() +
  geom_timeline(aes(x = Date, color = Magnitude))

# Plotting filtered data with points sized by magnitude
Argentina_data %>%
  ggplot() +
  geom_timeline(aes(x = Date, size = Magnitude))
```

Text lables can be added to the timeline plot by using
`geom_timeline_labels()`. This `geom_*` requires the column to use for
labels to be specfied. A maximum number of earthquakes to label based on
magnitude can be set as long as the size aesthetic is set to Magnitude.

``` r
# Adding labels to the 10 strongest earthquakes in Argentina
Argentina_data %>%
  ggplot() +
  geom_timeline(aes(x = Date, color = Magnitude)) +
  geom_timeline(aes(x = Date, size = Magnitude), n_max = 10)
```

A additional function has been supplied for assitance in consistent
formatting of timeline plots. Once an existing plot is created,
`pretty_timeline()` can be used to format axes titles and text and scale
axes based on data plotted.

``` r
quake_data <- eq_clean_data(filepath = "inst/extdata/earthquakes.tsv") %>%
  eq_location_clean() %>% 
  eq_filtering(SelectedCountry = "Argentina", MinDate = "1930-01-01")

ArgPlot <- quake_data %>%
  ggplot() +
  geom_timeline(aes(x = Date, color = Magnitude))
```

![](https://github.com/ELW-courses/significantEarthquakes/blob/main/man/figures/Argentina_timeline.png?raw=true)

``` r
pretty_timeline(df = quake_data, plot = ArgPlot, timeline_y = TRUE)
```

![](https://github.com/ELW-courses/significantEarthquakes/blob/main/man/figures/Argentina_timeline_pretty.png?raw=true)

## Earthquake mapping

Significant earthquakes can be mapped to show where earthquakes occurred
by using `eq_map()`. This function requires that earthquake data be
cleaned using `eq_clean_data()` and `eq_location_clean` so that at
minimum location columns (Latitude and Longitude) and any annotation
columns are present. The column to annotate by can be specified using
*annot_col*.

``` r
eq_clean_data(filepath = "inst/extdata/earthquakes.tsv") %>%
 eq_location_clean() %>%
 dplyr::filter(Country == "Mexico" & Date >= 2000) %>%
 eq_map(annot_col = "Date")
```

<figure>
<img
src="https://github.com/ELW-courses/significantEarthquakes/blob/main/man/figures/Mexico_leaflet_example.png?raw=true"
alt="Example static image of earthquakes in Mexico since 2000" />
<figcaption aria-hidden="true">Example static image of earthquakes in
Mexico since 2000</figcaption>
</figure>

``` r
eq_clean_data(filepath = "inst/extdata/earthquakes.tsv") %>%
 eq_location_clean() %>%
 dplyr::filter(Country == "Argentina") %>%
 eq_map(annot_col = "Date")
```

<figure>
<img
src="https://github.com/ELW-courses/significantEarthquakes/blob/main/man/figures/Argentina_leaflet_example.png?raw=true"
alt="Example static image of earthquakes in Argentina" />
<figcaption aria-hidden="true">Example static image of earthquakes in
Argentina</figcaption>
</figure>
