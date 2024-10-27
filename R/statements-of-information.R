# Statements of information only exist for Victoria. They are mandatory, and
# provide either a price range (differing by no more than 10%) or a single
# price. Be aware that a listed price can change, and if it does the statement
# of information is usually not updated.

soi_number_regex <- "(\\d{1,3}(,\\d{3})(,\\d{3}))|(\\d{1,3}(,\\d{3}))"

soi_extract_single_price <- function(soi_text) {
  soi_text_lower <- tolower(soi_text)
  between_strings <- stringr::str_extract(
    soi_text_lower,
    "single price:.*or range"
  )
  if (is.na(between_strings)) {
    between_strings <- stringr::str_extract(soi_text_lower, "single price:.*\n")
  }
  number_text <- stringr::str_extract(between_strings, soi_number_regex)
  as.integer(gsub(",", "", number_text))
}

soi_extract_price_range <- function(soi_text) {
  soi_text_lower <- tolower(soi_text)
  between_strings <- stringr::str_extract(
    soi_text_lower,
    glue::glue("range between.*\\n")
  )
  number_text <- stringr::str_extract_all(between_strings, soi_number_regex)
  purrr::map_int(number_text[[1]], ~as.integer(gsub(",", "", .x)))
}

soi_get_text <- function(soi_url) {
  all_pages <- pdftools::pdf_text(soi_url)
  all_pages[grepl("Sections 47AF", all_pages)][1]
}

soi_extract_price <- function(soi_url) {
  if (is.null(soi_url)) return(NA_integer_)
  soi_text <- soi_get_text(soi_url)


  single_price <- soi_extract_single_price(soi_text)
  if (!is.na(single_price)) {
    return(c(single_price, single_price))
  }

  soi_extract_price_range(soi_text)
}
