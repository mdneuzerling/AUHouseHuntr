# UNDER CONSTRUCTION

# /v1/salesResults/{city}/listings/

get_sales_for_city <- function(city, api_key = get_api_key()) {
  path <- glue::glue("salesResults/{city}/listings/")
  raw_listing <- domain_api_call(path, api_key = api_key, parse_response = FALSE)
}
