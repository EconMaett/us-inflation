# Import Data ----
library(fredr)
library(dplyr)
library(tidyr)
library(purrr)
library(readr)

# fred_api_key <- Sys.getenv("FRED_API_KEY")
# fredr_set_key(key = fred_api_key)

start_date <- as.Date("1950-01-01")

## NBER Recession Dates ----
nber_rec_dummy <- fredr(
  series_id = "USREC", 
  observation_start = start_date, 
  observation_end = Sys.Date()
)

nber_rec_dummy$diff <- c(diff(nber_rec_dummy$value, lag = 1, differences = 1), 0)
nber_rec_start <- nber_rec_dummy[nber_rec_dummy$diff ==  1, ]$date
nber_rec_end   <- nber_rec_dummy[nber_rec_dummy$diff == -1, ]$date

if (length(nber_rec_start) > length(nber_rec_end)) {
  nber_rec_end <- c(nber_rec_end, Sys.Date())
}

if (length(nber_rec_start) < length(nber_rec_end)) {
  nber_rec_start <- c(min(nber_rec_dummy$date), nber_rec_start)
}

nber_rec_dates <- data.frame(
  start = nber_rec_start,
  end = nber_rec_end
)

write_rds(nber_rec_dates, file = "data/nber_rec_dates.rds")

## Consumer Price Indices ----

### BLS ----

# Consumer Price Index for All Urban Consumers: All Items in U.S. City Average (CPIAUCSL)
#  Consumer Price Index for All Urban Consumers: All Items Less Food and Energy in U.S. City Average (CPILFESL)

series_ids <- c("CPIAUCSL", "CPILFESL")

bls_data <- map_dfr(.x = series_ids, .f = fredr, units = "pc1")

### Atlanta Fed ----
# URL: https://www.atlantafed.org/research/inflationproject/stickyprice
# Percent Change from Year Ago, Monthly, Seasonally Adjusted
# Sticky Price Consumer Price Index (STICKCPIM159SFRBATL)
# Sticky Price Consumer Price Index less Food and Energy (CORESTICKM159SFRBATL)

series_ids <- c("STICKCPIM159SFRBATL", "CORESTICKM159SFRBATL")

atlantafed_data <- map_dfr(.x = series_ids, .f = fredr, units = "lin")

cpi_data <- bind_rows(bls_data, atlantafed_data) |>
  select(date, series_id, value) |>
  pivot_wider(names_from = series_id, values_from = value) |>
  rename_with(.fn = ~ tolower(.x), .cols = everything()) |>
  setNames(nm = c("date", "cpi_headline", "cpi_core", "sticky_cpi_headline", "sticky_cpi_core")) |> 
  filter(date >= start_date)

write_rds(cpi_data, file = "data/cpi_data.rds")