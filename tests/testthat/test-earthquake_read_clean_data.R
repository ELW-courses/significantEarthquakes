library(testthat)
library(significantEarthquakes)

setwd(system.file("extdata", package = "significantEarthquakes"))

test_data <- eq_clean_data(filepath = "earthquakes.tsv")

# eq_clean_data
test_that("Date column is a date", {
  expect_type(test_data$Date, "double")
})
test_that("latitude column is a numeric", {
  expect_true(is.numeric(test_data$Latitude))
})
test_that("longitude column is a numeric", {
  expect_true(is.numeric(test_data$Longitude))
})
test_that("cleaned df columns are properly renamed", {
  required_columns <- c("Month", "Day", "Hour", "Minute", "Seconds",
                        "Tsunami", "Volcano", "Magnitude",
                        "Latitude", "Longitude")
  expect_true(all(required_columns %in% names(test_data)))
})
test_that("Location.Name column exists", {
  expect_true('Location.Name' %in% colnames(test_data))
})
#
#
# eq_location_clean
# Test that Country column is not empty
test_that("country column is created", {
  expect_true(all(!is.na(
    (eq_location_clean(test_data) %>%
      dplyr::filter(!str_detect(Location.Name, regex("United Kingdom", ignore_case = TRUE))))$Country)))
})
#
#
# eq_filtering
# Test that Country column is not empty and that all values are the same
test_that("country column is not null", {
  expect_true(all(!is.na(
    (eq_location_clean(test_data) %>% eq_filtering(SelectedCountry = "Argentina"))$Country)))
})

test_that("countries are all the same", {
  expect_equal(length(unique((eq_location_clean(test_data) %>% eq_filtering(SelectedCountry = "Argentina"))$Country)), 1)
})
