domain_api_call <- function(path, api_key, parse_response = TRUE, version = 1L) {
  request_url <- glue::glue("https://api.domain.com.au/v{version}/{path}") %>%
    gsub(" ", "%20", .)
  raw_response <- request_url %>%
    httr2::request() %>%
    httr2::req_headers(accept = "text/plain", `X-Api-Key` = api_key) %>%
    httr2::req_perform()

  if (parse_response) {
    raw_response %>% httr2::resp_body_json()
  } else {
    raw_response %>% httr2::resp_body_string()
  }
}
