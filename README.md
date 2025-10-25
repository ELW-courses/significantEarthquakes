
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
