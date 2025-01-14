# load-data.R

library(fredr)

# Retrieve the FRED API key from the environment
fred_api_key <- Sys.getenv("FRED_API_KEY")

# Check if the API key is available
if (fred_api_key == "") {
  stop("FRED API key is missing")
}

# Set the FRED API key
fredr_set_key(fred_api_key)

# Fetch data for the SP500 series (or change the series_id as needed)
sp500_data <- fredr(series_id = "SP500", observation_start = as.Date("2020-01-01"))

# Check the data
print(sp500_data)

# Optionally, save the data to a file (e.g., CSV)
write.csv(sp500_data, "sp500_data.csv")
