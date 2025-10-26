library(testthat)
library(significantEarthquakes)

setwd(system.file("extdata", package = "significantEarthquakes"))

test_data <- eq_clean_data(filepath = "earthquakes.tsv") %>% eq_location_clean()

# EQ_MAP
test_that("output is a leaflet", {
  expect_true(inherits(test_data %>%
              dplyr::filter(Country == 'Mexico' & Date >= 2000) %>%
              eq_map(annot_col = 'Date'), "leaflet"))
})
#
# eq_create_label
test_that("pop up is a character", {
  expect_true(is.character(eq_create_label(head(test_data, 2))))
})
