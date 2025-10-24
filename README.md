
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

## Data cleaning

A function, `eq_clean_data()`, is provided for basic cleaning of the raw
earthquake data. Either a file path can be specified, in which case the
file is loaded then cleaned, or a currently loaded data object can be
specified for cleaning.

``` r
#Loading file
quake_data <- eq_clean_data(filepath = "inst/extdata/earthquakes.tsv")

#Working with loaded data
quake_data <- eq_clean_data(df = earthquakes)

head(quake_date)
```

An additional function, `eq_location_clean()`, is provided to extract
the Country and State in which the earthquake occurred from the location
data column.

``` r
quake_data <- eq_location_clean(eq_date)
head(quake_date)
```
